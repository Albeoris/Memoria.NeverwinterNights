@echo off
setlocal
pushd "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File ".github\scripts\Publish-AllTags.ps1" %*
set "memoriaExitCode=%ERRORLEVEL%"
popd
exit /b %memoriaExitCode%
