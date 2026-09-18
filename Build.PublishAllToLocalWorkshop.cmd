@echo off
setlocal
pushd "%~dp0"

call Build.PublishAll.cmd %*
if errorlevel 1 goto :failed

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
  "$ErrorActionPreference = 'Stop';" ^
  "$repositoryRoot = (Get-Location).Path;" ^
  "$workshopRoot = if ($env:MEMORIA_LOCAL_WORKSHOP_ROOT) { [System.IO.Path]::GetFullPath($env:MEMORIA_LOCAL_WORKSHOP_ROOT) } else { 'C:\Steam\steamapps\workshop\content\704450' };" ^
  "$projects = Get-ChildItem -LiteralPath (Join-Path $repositoryRoot 'Mods') -Filter '*.proj' -Recurse;" ^
  "foreach ($project in $projects) {" ^
  "  [xml] $xml = Get-Content -Raw -LiteralPath $project.FullName;" ^
  "  $modId = $xml.SelectSingleNode('/Project/PropertyGroup/ModId').InnerText;" ^
  "  $inputsPath = Join-Path $repositoryRoot ('artifacts\inputs\{0}.inputs' -f $modId);" ^
  "  $versionPrefix = 'mod-version' + [char]124;" ^
  "  $version = '';" ^
  "  foreach ($inputLine in Get-Content -LiteralPath $inputsPath) { if ($inputLine.StartsWith($versionPrefix)) { $version = $inputLine.Substring($versionPrefix.Length) } };" ^
  "  if ([string]::IsNullOrWhiteSpace($version)) { throw ('Published version is missing from {0}.' -f $inputsPath) };" ^
  "  $workshopIdNode = $xml.SelectSingleNode('/Project/PropertyGroup[@Label=''Steam Workshop'']/WorkshopPublishedFileId');" ^
  "  if ($null -eq $workshopIdNode -or [string]::IsNullOrWhiteSpace($workshopIdNode.InnerText)) { continue };" ^
  "  $workshopId = $workshopIdNode.InnerText.Trim();" ^
  "  $destination = [System.IO.Path]::GetFullPath((Join-Path $workshopRoot $workshopId));" ^
  "  if (-not (Test-Path -LiteralPath $destination -PathType Container)) { Write-Host ('Skipped {0}: Workshop item {1} is not installed.' -f $modId, $workshopId); continue };" ^
  "  $publishedRoot = Join-Path $repositoryRoot ('artifacts\publish\{0}\{1}\workshop' -f $modId.ToLowerInvariant(), $version);" ^
  "  $packages = @(Get-ChildItem -LiteralPath $publishedRoot -Directory);" ^
  "  if ($packages.Count -ne 1) { throw ('Expected one published Workshop directory for {0}, found {1}.' -f $modId, $packages.Count) };" ^
  "  & robocopy.exe $packages[0].FullName $destination /MIR /NFL /NDL /NJH /NJS /NP;" ^
  "  $copyExitCode = $LASTEXITCODE;" ^
  "  if ($copyExitCode -gt 7) { throw ('Failed to update {0}; robocopy exit code {1}.' -f $modId, $copyExitCode) };" ^
  "  Write-Host ('Updated {0}: {1}' -f $modId, $destination);" ^
  "}"
if errorlevel 1 goto :failed

popd
exit /b 0

:failed
set "memoriaExitCode=%ERRORLEVEL%"
popd
exit /b %memoriaExitCode%
