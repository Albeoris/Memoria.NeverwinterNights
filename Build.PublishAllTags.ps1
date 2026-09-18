param(
    [string] $Remote = 'origin',
    [string] $Workflow = 'release.yml',
    [int] $EnqueueTimeoutSeconds = 300,
    [int] $WorkflowPollSeconds = 30
)

$ErrorActionPreference = 'Stop'
$repositoryRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $repositoryRoot

if ($EnqueueTimeoutSeconds -le 0) {
    throw 'EnqueueTimeoutSeconds must be positive.'
}
if ($WorkflowPollSeconds -le 0) {
    throw 'WorkflowPollSeconds must be positive.'
}
if ($null -eq (Get-Command git -ErrorAction SilentlyContinue)) {
    throw "Required command 'git' was not found."
}

$workingChanges = @(& git status --porcelain=v1 --untracked-files=normal)
if ($LASTEXITCODE -ne 0) {
    throw 'Failed to inspect the Git working tree.'
}
if ($workingChanges.Count -ne 0) {
    throw 'The working tree must be clean before release tags are created.'
}

$branch = (& git symbolic-ref --quiet --short HEAD).Trim()
if ($LASTEXITCODE -ne 0 -or $branch -ne 'main') {
    throw "Release tags must be created from the main branch; current branch is '$branch'."
}

& git fetch $Remote main --tags --prune
if ($LASTEXITCODE -ne 0) {
    throw "Failed to fetch main and tags from '$Remote'."
}

$headCommit = (& git rev-parse HEAD).Trim()
$remoteMainCommit = (& git rev-parse "$Remote/main").Trim()
if ($LASTEXITCODE -ne 0 -or $headCommit -ne $remoteMainCommit) {
    throw "HEAD must match $Remote/main before release tags are created."
}

$remoteUrl = (& git remote get-url $Remote).Trim()
if ($LASTEXITCODE -ne 0) {
    throw "Failed to read the URL for remote '$Remote'."
}
$repositoryMatch = [regex]::Match($remoteUrl, '(?:[:/])(?<owner>[^/:]+)/(?<name>[^/]+?)(?:\.git)?$')
if (-not $repositoryMatch.Success) {
    throw "Cannot determine the GitHub repository from remote URL '$remoteUrl'."
}
$repository = "$($repositoryMatch.Groups['owner'].Value)/$($repositoryMatch.Groups['name'].Value)"

$apiHeaders = @{
    Accept = 'application/vnd.github+json'
    'Cache-Control' = 'no-cache'
    'User-Agent' = 'Memoria-PublishAllTags'
    'X-GitHub-Api-Version' = '2022-11-28'
}
$apiToken = if (-not [string]::IsNullOrWhiteSpace($env:GITHUB_TOKEN)) { $env:GITHUB_TOKEN } else { $env:GH_TOKEN }
if (-not [string]::IsNullOrWhiteSpace($apiToken)) {
    $apiHeaders.Authorization = "Bearer $apiToken"
}
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

function Invoke-GitHubApi([string] $Path) {
    try {
        $separator = if ($Path.Contains('?')) { '&' } else { '?' }
        $cacheBuster = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
        return Invoke-RestMethod -Method Get -Uri "https://api.github.com/repos/$repository/$Path${separator}cache_bust=$cacheBuster" -Headers $apiHeaders
    }
    catch {
        if ([string]::IsNullOrWhiteSpace($apiToken)) {
            throw "GitHub API request failed. The public API requires no login, but GITHUB_TOKEN or GH_TOKEN can be set if the anonymous rate limit was exhausted. $($_.Exception.Message)"
        }
        throw
    }
}

[xml] $solution = Get-Content -LiteralPath 'Memoria.NeverwinterNights.slnx' -Raw
$solutionProjects = @($solution.SelectNodes('/Solution/Folder/Project[starts-with(@Path, "Mods/")]'))
$missingTags = [Collections.Generic.List[object]]::new()
foreach ($solutionProject in $solutionProjects) {
    $projectPath = $solutionProject.GetAttribute('Path')
    [xml] $project = Get-Content -LiteralPath $projectPath -Raw
    $modIdNodes = @($project.SelectNodes('/Project/PropertyGroup[not(@Condition)]/ModId[not(@Condition)]'))
    $versionNodes = @($project.SelectNodes('/Project/PropertyGroup[not(@Condition)]/Version[not(@Condition)]'))
    if ($modIdNodes.Count -ne 1 -or $versionNodes.Count -ne 1) {
        throw "$projectPath must declare exactly one unconditional ModId and Version."
    }

    $modId = $modIdNodes[0].InnerText.Trim().ToLowerInvariant()
    $version = $versionNodes[0].InnerText.Trim()
    if ($modId -notmatch '^(esi|meconfig|medt|melse|mecm|metact|memoria)$') {
        throw "Unsupported release ModId in ${projectPath}: $modId"
    }
    if ($version -notmatch '^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$') {
        throw "Version in $projectPath must use release X.Y.Z notation: $version"
    }

    $tag = "$modId-v$version"
    $null = & git ls-remote --exit-code --tags $Remote "refs/tags/$tag"
    $lookupExitCode = $LASTEXITCODE
    if ($lookupExitCode -eq 0) {
        Write-Host "$tag already exists on $Remote."
        continue
    }
    if ($lookupExitCode -ne 2) {
        throw "Failed to check whether $tag exists on $Remote."
    }
    $global:LASTEXITCODE = 0
    $missingTags.Add([pscustomobject] @{
        ProjectPath = $projectPath
        Tag = $tag
    })
}

if ($missingTags.Count -eq 0) {
    Write-Host 'Every project version already has a release tag.'
    exit 0
}

$workflowPath = "actions/workflows/$([Uri]::EscapeDataString($Workflow))/runs?event=push&per_page=100"
Write-Host "Creating $($missingTags.Count) release tag(s) at $headCommit."
foreach ($release in $missingTags) {
    $tag = $release.Tag
    $knownRunIds = [Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
    $knownRuns = Invoke-GitHubApi $workflowPath
    foreach ($knownRun in @($knownRuns.workflow_runs | Where-Object { $_.head_branch -eq $tag -and $_.head_sha -eq $headCommit })) {
        $knownRunIds.Add([string] $knownRun.id) | Out-Null
    }

    Write-Host "Creating and pushing $tag for $($release.ProjectPath)."
    $localTag = @(& git tag --list $tag)
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to check whether local tag $tag exists."
    }
    if ($localTag.Count -gt 0) {
        & git tag --delete $tag
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to delete local tag $tag."
        }
    }
    & git tag $tag $headCommit
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to create $tag."
    }
    & git push $Remote "refs/tags/${tag}:refs/tags/${tag}"
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to push $tag."
    }

    Write-Host "Waiting 30 seconds for the new $tag release workflow to start."
    Start-Sleep -Seconds 30
    $deadline = [DateTime]::UtcNow.AddSeconds($EnqueueTimeoutSeconds)
    $run = $null
    do {
        $runs = Invoke-GitHubApi $workflowPath
        $run = @($runs.workflow_runs | Where-Object { $_.head_branch -eq $tag -and $_.head_sha -eq $headCommit -and -not $knownRunIds.Contains([string] $_.id) } | Sort-Object created_at -Descending | Select-Object -First 1)
        if ($run.Count -eq 0) {
            Start-Sleep -Seconds 5
        }
    } while ($run.Count -eq 0 -and [DateTime]::UtcNow -lt $deadline)

    if ($run.Count -eq 0) {
        throw "The release workflow for $tag did not appear within $EnqueueTimeoutSeconds seconds."
    }

    $runId = $run[0].id
    Write-Host "Release workflow: $($run[0].html_url)"
    do {
        $runState = Invoke-GitHubApi "actions/runs/$runId"
        if ($runState.status -ne 'completed') {
            Write-Host "Workflow status for ${tag}: $($runState.status)."
            Start-Sleep -Seconds $WorkflowPollSeconds
        }
    } while ($runState.status -ne 'completed')

    if ($runState.conclusion -ne 'success') {
        throw "The release workflow for $tag completed with conclusion '$($runState.conclusion)'. Remaining tags were not pushed."
    }
    Write-Host "$tag was published successfully."
}
