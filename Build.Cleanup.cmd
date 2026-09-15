@echo off
setlocal
pushd "%~dp0"
dotnet clean Memoria.NeverwinterNights.slnx --configuration Release %*
set "memoriaExitCode=%ERRORLEVEL%"
popd
exit /b %memoriaExitCode%
