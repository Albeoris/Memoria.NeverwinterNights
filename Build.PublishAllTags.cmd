@echo off
setlocal
pushd "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "Build.PublishAllTags.ps1" %*
set "memoriaExitCode=%ERRORLEVEL%"
popd
exit /b %memoriaExitCode%
