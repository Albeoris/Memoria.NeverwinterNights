@echo off
setlocal
pushd "%~dp0"
dotnet msbuild Memoria.NeverwinterNights.slnx -restore -t:Publish -p:Configuration=Release -p:CommonOutput=true -m:1 %*
set "memoriaExitCode=%ERRORLEVEL%"
popd
exit /b %memoriaExitCode%
