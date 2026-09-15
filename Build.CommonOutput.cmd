@echo off
setlocal
pushd "%~dp0"
dotnet build Memoria.NeverwinterNights.slnx --configuration Release -p:CommonOutput=true %*
set "memoriaExitCode=%ERRORLEVEL%"
popd
exit /b %memoriaExitCode%
