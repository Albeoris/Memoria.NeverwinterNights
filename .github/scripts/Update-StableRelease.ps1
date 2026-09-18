param(
    [Parameter(Mandatory = $true)]
    [string] $PublishRoot,

    [Parameter(Mandatory = $true)]
    [string] $UpdateTime,

    [Parameter(Mandatory = $true)]
    [string] $Repository
)

$ErrorActionPreference = 'Stop'
$releaseTag = 'latest'
$workRoot = [IO.Path]::GetFullPath('artifacts/latest-release')
$assetRoot = Join-Path $workRoot 'assets'
$extractRoot = Join-Path $workRoot 'extract'
$allInOneStage = Join-Path $workRoot 'all-in-one-stage'
$allInOneRoot = Join-Path $allInOneStage 'Memoria All-in-One'
$allInOneArchive = Join-Path $assetRoot 'all-in-one.zip'
New-Item -ItemType Directory -Force $assetRoot, $extractRoot, $allInOneRoot | Out-Null

[xml] $solution = Get-Content -LiteralPath 'Memoria.NeverwinterNights.slnx' -Raw
$solutionProjects = @($solution.SelectNodes('/Solution/Folder/Project[starts-with(@Path, "Mods/")]'))
$packages = [Collections.Generic.List[object]]::new()
for ($solutionIndex = 0; $solutionIndex -lt $solutionProjects.Count; $solutionIndex++) {
    $projectPath = $solutionProjects[$solutionIndex].GetAttribute('Path')
    [xml] $project = Get-Content -LiteralPath $projectPath -Raw
    $modId = $project.SelectSingleNode('/Project/PropertyGroup[not(@Condition)]/ModId[not(@Condition)]').InnerText.Trim().ToLowerInvariant()
    $displayName = $project.SelectSingleNode('/Project/PropertyGroup[not(@Condition)]/ModDisplayName[not(@Condition)]').InnerText.Trim()
    $version = $project.SelectSingleNode('/Project/PropertyGroup[not(@Condition)]/Version[not(@Condition)]').InnerText.Trim()
    $packageRoot = Join-Path $PublishRoot "$modId/$version"
    $sourceArchives = @(Get-ChildItem -LiteralPath (Join-Path $packageRoot 'nexus') -Filter '*.zip' -File)
    if ($sourceArchives.Count -ne 1) {
        throw "Expected exactly one Nexus archive for $modId $version; found $($sourceArchives.Count)."
    }

    $assetName = "$modId.zip"
    $archivePath = Join-Path $assetRoot $assetName
    Copy-Item -LiteralPath $sourceArchives[0].FullName -Destination $archivePath -Force
    $packages.Add([pscustomobject] @{
        ModId = $modId
        DisplayName = $displayName
        Version = $version
        AssetName = $assetName
        ArchivePath = $archivePath
    })
}

for ($packageIndex = 0; $packageIndex -lt $packages.Count; $packageIndex++) {
    $package = $packages[$packageIndex]
    $packageExtractRoot = Join-Path $extractRoot $packageIndex
    Expand-Archive -LiteralPath $package.ArchivePath -DestinationPath $packageExtractRoot -Force
    $archiveEntries = @(Get-ChildItem -LiteralPath $packageExtractRoot)
    if ($archiveEntries.Count -ne 1 -or -not $archiveEntries[0].PSIsContainer) {
        throw "$($package.AssetName) must contain exactly one top-level package directory."
    }
    Copy-Item -Path (Join-Path $archiveEntries[0].FullName '*') -Destination $allInOneRoot -Recurse -Force
}
Compress-Archive -LiteralPath $allInOneRoot -DestinationPath $allInOneArchive -CompressionLevel Optimal -Force

$null = gh release view $releaseTag --repo $Repository 2>$null
if ($LASTEXITCODE -ne 0) {
    gh release create $releaseTag --repo $Repository --title "Latest ($UpdateTime)" --notes 'Latest mod packages.' --latest
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to create the $releaseTag release."
    }
}

foreach ($package in $packages) {
    $label = "$($package.DisplayName) - v$($package.Version) ($UpdateTime)"
    gh release upload $releaseTag --repo $Repository "$($package.ArchivePath)#$label" --clobber
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to upload $($package.AssetName) to the $releaseTag release."
    }
}

$allInOneLabel = "Memoria All-in-One ($UpdateTime)"
gh release upload $releaseTag --repo $Repository "$allInOneArchive#$allInOneLabel" --clobber
if ($LASTEXITCODE -ne 0) {
    throw "Failed to upload the all-in-one archive to the $releaseTag release."
}

$notes = [Collections.Generic.List[string]]::new()
$notes.Add('## All-in-One')
$notes.Add('')
$notes.Add("- [$allInOneLabel](https://github.com/$Repository/releases/download/$releaseTag/all-in-one.zip)")
$notes.Add('')
$notes.Add('## Individual packages')
$notes.Add('')
foreach ($package in $packages) {
    $label = "$($package.DisplayName) - v$($package.Version) ($UpdateTime)"
    $notes.Add("- [$label](https://github.com/$Repository/releases/download/$releaseTag/$($package.AssetName))")
}
$notes.Add('')
$notes.Add('[Report feedback and issues](https://github.com/Albeoris/Memoria.NeverwinterNights/issues)')
$notesPath = Join-Path $workRoot 'release-notes.md'
[IO.File]::WriteAllLines($notesPath, $notes, [Text.UTF8Encoding]::new($false))
gh release edit $releaseTag --repo $Repository --title "Latest ($UpdateTime)" --notes-file $notesPath --latest
if ($LASTEXITCODE -ne 0) {
    throw "Failed to update the $releaseTag release metadata."
}
