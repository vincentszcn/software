echo off
if "%1" == "" goto usage
goto Invoke

:Invoke
start "LooksAlive Batch processing....Do not close this window" LooksAlivePoll.bat %1 
goto Done

:usage
echo Need to supply the ServerName
echo Usage: StartPSS SERVERNAME

:Done

