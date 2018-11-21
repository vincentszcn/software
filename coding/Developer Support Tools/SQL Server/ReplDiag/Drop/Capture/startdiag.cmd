if not defined TRACE @echo off
set SCRNAME=%0

cls

REM *****************************************************
REM Starting %SCRNAME% Batch File : Customize this file!
REM *****************************************************

set RET=
set JumpTo=

REM
REM The mode that we run in is either TRAN or MERGE
REM 
set GatherMode=MERGE

set Publisher=AIRBAG
set PublisherDB=northwind
set Publication=Northwind_ReplDiag_FullMergeTesting

set Distributor=AIRBAG
set DistributionDB=distribution

set Subscriber=AIRBAG
set SubscriberDB=TestMergePushSub
set SkipSubscriber=0

set PublisherSecurityMode=1
set DistributorSecurityMode=1
set SubscriberSecurityMode=1

set PublisherLogin=sa
set PublisherPassWord=

set DistributorLogin=sa
set DistributorPassWord=

set SubscriberLogin=sa
set SubscriberPassword=

set GetLogInfo=1
set GetPublisherDB=0
set GetDistributionDB=0
set GetSubscriberDB=0
set GetReplScripts=1
set GetPubSchema=1
set GetSubSchema=1

set SCRIPT_DIR=.\scripts
set EXE_DIR=.\Executables

set PublisherUNC=\\AIRBAG\DIAGNOSTICS
set DistributorUNC=\\AIRBAG\DIAGNOSTICS
set SubscriberUNC=\\AIRBAG\DIAGNOSTICS
set PublisherMappingLoc=X:
set DistributorMappingLoc=X:
set SubscriberMappingLoc=X:

if "%GatherMode%"=="TRAN" goto :TRAN
if "%GatherMode%"=="MERGE" goto :MERGE
if "%GatherMode%"=="BOTH" goto :BOTH

:TRAN
call trangather.cmd
if "%RET%"=="failed" goto error
goto :Success

:MERGE
call mergegather.cmd
if "%RET%"=="failed" goto error
goto :Success

:BOTH
call trangather.cmd
if "%RET%"=="failed" goto error
call mergegather.cmd
if "%RET%"=="failed" goto error

:Success
@echo SUCCESS!
@echo.
@echo Exiting %SCRNAME%
goto :EOF

:Error
@echo %SCRNAME% Failed
endlocal & set RET=failed

:endnow
@echo Exiting %SCRNAME%
echo.

