param(
    [Parameter(Mandatory = $true)]
    [string] $PackageRoot,

    [Parameter(Mandatory = $true)]
    [string] $ModId,

    [Parameter(Mandatory = $true)]
    [string] $DisplayName,

    [Parameter(Mandatory = $true)]
    [string] $Version,

    [Parameter(Mandatory = $true)]
    [string] $UpdateDate,

    [Parameter(Mandatory = $true)]
    [string] $Repository
)

$ErrorActionPreference = 'Stop'
$stableTag = 'stable'
$workRoot = [IO.Path]::GetFullPath('artifacts/stable-release')
$assetRoot = Join-Path $workRoot 'assets'
$extractRoot = Join-Path $workRoot 'extract'
$allInOneStage = Join-Path $workRoot 'all-in-one-stage'
$allInOneRoot = Join-Path $allInOneStage 'Memoria All-in-One'
$allInOneArchive = Join-Path $assetRoot 'all-in-one.zip'
New-Item -ItemType Directory -Force $assetRoot, $extractRoot, $allInOneRoot | Out-Null

$null = gh release view $stableTag --repo $Repository 2>$null
if ($LASTEXITCODE -ne 0) {
    gh release create $stableTag --repo $Repository --target main --title "Stable ($UpdateDate)" --notes 'Stable mod packages.' --latest
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to create the $stableTag release."
    }
}

$releaseJson = gh api "repos/$Repository/releases/tags/$stableTag"
if ($LASTEXITCODE -ne 0) {
    throw "Failed to read the $stableTag release."
}
$release = $releaseJson | ConvertFrom-Json

[xml] $solution = Get-Content -LiteralPath 'Memoria.NeverwinterNights.slnx' -Raw
$solutionProjects = @($solution.SelectNodes('/Solution/Folder/Project[starts-with(@Path, "Mods/")]'))
$packages = [Collections.Generic.List[object]]::new()
for ($solutionIndex = 0; $solutionIndex -lt $solutionProjects.Count; $solutionIndex++) {
    $projectPath = $solutionProjects[$solutionIndex].GetAttribute('Path')
    [xml] $project = Get-Content -LiteralPath $projectPath -Raw
    $projectModId = $project.SelectSingleNode('/Project/PropertyGroup[not(@Condition)]/ModId[not(@Condition)]').InnerText.Trim().ToLowerInvariant()
    $projectDisplayName = $project.SelectSingleNode('/Project/PropertyGroup[not(@Condition)]/ModDisplayName[not(@Condition)]').InnerText.Trim()
    $projectVersion = $project.SelectSingleNode('/Project/PropertyGroup[not(@Condition)]/Version[not(@Condition)]').InnerText.Trim()
    $assetName = "$projectModId.zip"
    $asset = @($release.assets | Where-Object { $_.name -eq $assetName })
    $isCurrent = $projectModId -eq $ModId.ToLowerInvariant()
    if (-not $isCurrent -and $asset.Count -eq 0) {
        continue
    }
    if ($asset.Count -gt 1) {
        throw "The $stableTag release contains duplicate assets named $assetName."
    }

    $archivePath = Join-Path $assetRoot $assetName
    if ($isCurrent) {
        $sourceArchives = @(Get-ChildItem -LiteralPath (Join-Path $PackageRoot 'nexus') -Filter '*.zip' -File)
        if ($sourceArchives.Count -ne 1) {
            throw "Expected exactly one Nexus archive for $projectModId; found $($sourceArchives.Count)."
        }
        Copy-Item -LiteralPath $sourceArchives[0].FullName -Destination $archivePath -Force
        $packageDisplayName = $DisplayName
        $packageVersion = $Version
        $packageDate = $UpdateDate
        $updatedAt = [DateTimeOffset]::UtcNow
    }
    else {
        gh release download $stableTag --repo $Repository --pattern $assetName --dir $assetRoot --clobber
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to download $assetName from the $stableTag release."
        }
        $packageDisplayName = $projectDisplayName
        $packageVersion = $projectVersion
        $packageDate = ([DateTimeOffset] $asset[0].updated_at).UtcDateTime.ToString('yyyy-MM-dd', [Globalization.CultureInfo]::InvariantCulture)
        $updatedAt = [DateTimeOffset] $asset[0].updated_at
        if ($asset[0].label -match '^(?<displayName>.+) — v(?<version>(?:0|[1-9][0-9]*)\.(?:0|[1-9][0-9]*)\.(?:0|[1-9][0-9]*)) \((?<date>\d{4}-\d{2}-\d{2})\)$') {
            $packageDisplayName = $Matches['displayName']
            $packageVersion = $Matches['version']
            $packageDate = $Matches['date']
        }
    }

    $packages.Add([pscustomobject] @{
        ModId = $projectModId
        DisplayName = $packageDisplayName
        Version = $packageVersion
        UpdateDate = $packageDate
        UpdatedAt = $updatedAt
        SolutionIndex = $solutionIndex
        AssetName = $assetName
        ArchivePath = $archivePath
    })
}

$currentPackages = @($packages | Where-Object { $_.ModId -eq $ModId.ToLowerInvariant() })
if ($currentPackages.Count -ne 1) {
    throw "The updated package $ModId was not found in Memoria.NeverwinterNights.slnx."
}

$mergeIndex = 0
foreach ($package in $packages | Sort-Object UpdatedAt, SolutionIndex) {
    $packageExtractRoot = Join-Path $extractRoot $mergeIndex
    Expand-Archive -LiteralPath $package.ArchivePath -DestinationPath $packageExtractRoot -Force
    $archiveEntries = @(Get-ChildItem -LiteralPath $packageExtractRoot)
    if ($archiveEntries.Count -ne 1 -or -not $archiveEntries[0].PSIsContainer) {
        throw "$($package.AssetName) must contain exactly one top-level package directory."
    }
    Copy-Item -Path (Join-Path $archiveEntries[0].FullName '*') -Destination $allInOneRoot -Recurse -Force
    $mergeIndex++
}
Compress-Archive -LiteralPath $allInOneRoot -DestinationPath $allInOneArchive -CompressionLevel Optimal -Force

$currentPackage = $currentPackages[0]
$currentLabel = "$($currentPackage.DisplayName) — v$($currentPackage.Version) ($($currentPackage.UpdateDate))"
gh release upload $stableTag --repo $Repository "$($currentPackage.ArchivePath)#$currentLabel" --clobber
if ($LASTEXITCODE -ne 0) {
    throw "Failed to upload $($currentPackage.AssetName) to the $stableTag release."
}

$allInOneLabel = "Memoria All-in-One ($UpdateDate)"
gh release upload $stableTag --repo $Repository "$allInOneArchive#$allInOneLabel" --clobber
if ($LASTEXITCODE -ne 0) {
    throw "Failed to upload the all-in-one archive to the $stableTag release."
}

$notes = [Collections.Generic.List[string]]::new()
$notes.Add('## All-in-One')
$notes.Add('')
$notes.Add("- [$allInOneLabel](https://github.com/$Repository/releases/download/$stableTag/all-in-one.zip)")
$notes.Add('')
$notes.Add('## Individual packages')
$notes.Add('')
foreach ($package in $packages | Sort-Object SolutionIndex) {
    $label = "$($package.DisplayName) — v$($package.Version) ($($package.UpdateDate))"
    $notes.Add("- [$label](https://github.com/$Repository/releases/download/$stableTag/$($package.AssetName))")
}
$notesPath = Join-Path $workRoot 'release-notes.md'
$notes | Set-Content -LiteralPath $notesPath -Encoding utf8NoBOM
gh release edit $stableTag --repo $Repository --title "Stable ($UpdateDate)" --notes-file $notesPath --latest
if ($LASTEXITCODE -ne 0) {
    throw "Failed to update the $stableTag release metadata."
}
