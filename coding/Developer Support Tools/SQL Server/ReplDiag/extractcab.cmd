
@echo off

REM Usage: %0 {ExtractFileName}
if "%1"=="" goto usage

set ExtractFile=%1

@echo.
@echo -----------------------------------
@echo Extracting CAB File %ExtractFile%
@echo -----------------------------------
extract %ExtractFile% /E /Y

:usage
@echo Usage:
@echo.
@echo %0 {ExtractFileName}
set RET=failed