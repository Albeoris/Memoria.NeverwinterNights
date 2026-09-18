param(
    [string] $Remote = 'origin',
    [string] $Workflow = 'release.yml',
    [int] $EnqueueTimeoutSeconds = 300
)

$ErrorActionPreference = 'Stop'
$repositoryRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))
Set-Location $repositoryRoot

if ($EnqueueTimeoutSeconds -le 0) {
    throw 'EnqueueTimeoutSeconds must be positive.'
}

foreach ($command in 'git', 'gh') {
    if ($null -eq (Get-Command $command -ErrorAction SilentlyContinue)) {
        throw "Required command '$command' was not found."
    }
}

$null = & gh auth status
if ($LASTEXITCODE -ne 0) {
    throw 'GitHub CLI authentication is required. Run gh auth login first.'
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

$repository = (& gh repo view --json nameWithOwner --jq '.nameWithOwner').Trim()
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($repository)) {
    throw 'Failed to resolve the GitHub repository through gh.'
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

Write-Host "Creating $($missingTags.Count) release tag(s) at $headCommit."
foreach ($release in $missingTags) {
    $tag = $release.Tag
    Write-Host "Creating and pushing $tag for $($release.ProjectPath)."
    $null = & git tag --delete $tag 2>$null
    $global:LASTEXITCODE = 0
    & git tag $tag $headCommit
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to create $tag."
    }
    & git push $Remote "refs/tags/${tag}:refs/tags/${tag}"
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to push $tag."
    }

    Write-Host "Waiting for the $tag release workflow to start."
    $deadline = [DateTime]::UtcNow.AddSeconds($EnqueueTimeoutSeconds)
    $run = $null
    do {
        $runJson = & gh run list --repo $repository --workflow $Workflow --event push --limit 100 --json databaseId,headBranch,headSha,status,conclusion
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to query release workflows after pushing $tag."
        }
        $run = @($runJson | ConvertFrom-Json | Where-Object { $_.headBranch -eq $tag -and $_.headSha -eq $headCommit } | Select-Object -First 1)
        if ($run.Count -eq 0) {
            Start-Sleep -Seconds 5
        }
    } while ($run.Count -eq 0 -and [DateTime]::UtcNow -lt $deadline)

    if ($run.Count -eq 0) {
        throw "The release workflow for $tag did not appear within $EnqueueTimeoutSeconds seconds."
    }

    & gh run watch $run[0].databaseId --repo $repository --exit-status
    if ($LASTEXITCODE -ne 0) {
        throw "The release workflow for $tag failed. Remaining tags were not pushed."
    }
    Write-Host "$tag was published successfully."
}
