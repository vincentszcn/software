echo off
echo Output being written to MainLooksAlive.log 
echo Individual files are:
echo    LooksAliveBatch.log; 
echo    LooksAliveFirstRetry.log; 
echo    LooksAliveSecondRetry.log; 
echo    LooksAliveThirdRetry.log


echo ServerName Passed in: %1 >> MainLooksAlive.log
echo Initiating LooksAlive Batch.... >> MainLooksAlive.log
Date /t >> MainLooksAlive.log
time < nul >> MainLooksAlive.log

:top
echo Executing LooksAlive MainLoop.... >> MainLooksAlive.log
Date /t >> MainLooksAlive.log
time < nul >> MainLooksAlive.log
osql -E -S%1% -iLooksAliveBatch.sql  -b -n -l15 -t15 -w2000 >>LooksAliveBatch.log
echo Errorlevel: %errorlevel% >> MainLooksAlive.log
if NOT ERRORLEVEL 70000 goto :FirstRetry
WAITFOR 30 
goto :top


:FirstRetry
rem Retrying First time, if success, then go back to top, else go to SecondRetry
echo Executing First Retry, see MainLooksAlive.log and LooksAliveFirstRetry.log for details
echo First Retry LooksAlive at: >> MainLooksAlive.log
Date /t >> MainLooksAlive.log
time < nul >> MainLooksAlive.log
osql -E -S%1% -iLooksAliveBatch.sql  -b -n -l15 -t15 -w2000 >>LooksAliveFirstRetry.log
echo Errorlevel: %errorlevel% >> MainLooksAlive.log
if NOT ERRORLEVEL 70000 goto :SecondRetry
goto :top


:SecondRetry
rem Retrying Second time, if success, then go back to top, else go to ThirdRetry
echo Executing Second Retry, see MainLooksAlive.log and LooksAliveSecondRetry.log for details
echo Second Retry LooksAlive at: >> MainLooksAlive.log
Date /t >> MainLooksAlive.log
time < nul >> MainLooksAlive.log
osql -E -S%1% -iLooksAliveBatch.sql  -b -n -l15 -t15 -w2000 >>LooksAliveSecondRetry.log
echo Errorlevel: %errorlevel% >> MainLooksAlive.log
if NOT ERRORLEVEL 70000 goto :ThirdRetry
goto :top


:ThirdRetry
rem Retrying Third(last) time, if success, then go back to top, else go to GetDump
echo Executing Third Retry, see MainLooksAlive.log and LooksAliveThirdRetry.log for details
echo Third Retry LooksAlive at: >> MainLooksAlive.log
Date /t >> MainLooksAlive.log
time < nul >> MainLooksAlive.log
osql -E -S%1% -iLooksAliveBatch.sql  -b -n -l15 -t15 -w2000 >>LooksAliveThirdRetry.log
echo Errorlevel: %errorlevel% >> MainLooksAlive.log
if NOT ERRORLEVEL 70000 goto :GetDump
goto :top


:GetDump
rem Attach to SQL and generate a UserDump (By now we have already waited for 1 min from the first failure and have retried 3 times, hence get the dump)
echo Initaiting CDB Attach>> MainLooksAlive.log
Date /t >> MainLooksAlive.log
time < nul >> MainLooksAlive.log
echo Attaching SQL to CDB and then getting Userdump
start "Attaching SQLServer to CDB...." AttachCDB.bat
goto Done


:Done


