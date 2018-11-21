if not defined TRACE @echo off
set SCRNAME=%0

REM Created by Alejanmi on 03/13/2002
REM
REM Modified for MERGE gatherer by Ryanston on 07/15/2002
REM

@echo.
@echo ******************************************************
@echo  MERGE REPLICATION DATA GATHERING TOOL                                
@echo ******************************************************
@echo.
@echo  Gathers important information from merge replication  
@echo  system tables and database backups.
@echo.
@echo  Running %SCRNAME% batch file: Data Capture Module  
@echo  Please send feedback or suggestions to your support
@echo  engineer.
@echo.
@echo ******************************************************

REM **** INITIALIZATION 
set RET=
set QueryTimeout=-t 1200 
set MAKECAB=yes

@echo.
@echo     ----------------------------------
@echo      VERIFYING ENVIRONMENT VARIABLES
@echo     ----------------------------------

REM **** REQUIRED ENVIRONMENT VARIABLES
if not defined Publisher				@echo   **** ERROR:  VARIABLE Publisher IS NOT DEFINED & goto error
if not defined PublisherSecurityMode			@echo   **** ERROR:  VARIABLE PublisherSecurityMode IS NOT DEFINED & goto error
if not defined PublisherDB				@echo   **** ERROR:  VARIABLE PublisherDB IS NOT DEFINED & goto error
if not defined Publication				@echo   **** ERROR:  VARIABLE Publication IS NOT DEFINED & goto error
if not defined Distributor				@echo   **** ERROR:  VARIABLE Distributor IS NOT DEFINED & goto error
if not defined DistributorSecurityMode			@echo   **** ERROR:  VARIABLE DistributorSecurityMode IS NOT DEFINED & goto error
if not defined DistributionDB				@echo   **** ERROR:  VARIABLE DistributionDB IS NOT DEFINED & goto error
if not defined Subscriber				@echo   **** ERROR:  VARIABLE Subscriber IS NOT DEFINED & goto error
if not defined SubscriberSecurityMode			@echo   **** ERROR:  VARIABLE SubscriberSecurityMode IS NOT DEFINED & goto error
if not defined SubscriberDB				@echo   **** ERROR:  VARIABLE SubscriberDB IS NOT DEFINED & goto error


REM Set up security for connection to publisher and distributor
set SECLOG_P=-E
set SECLOG_P_BCP=-T
if %PublisherSecurityMode% EQU 0 (

	@echo.
	@echo         Using Standard SQL Server Security to connect to Publisher %Publisher%
	
	if not defined PublisherLogin @echo   **** ERROR:  VARIABLE PublisherLogin IS NOT DEFINED & goto error
	if not defined PublisherPassword set PublisherPassword=[]
	set SECLOG_P=-U%PublisherLogin% -P%PublisherPassword%
	set SECLOG_P_BCP=-U%PublisherLogin% -P%PublisherPassword%
	
	)

set SECLOG_D=-E
set SECLOG_D_BCP=-T
set SECLOG_SCRIPT=-E
if %DistributorSecurityMode% EQU 0 (

	@echo.
	@echo         Using Standard SQL Server Security to connect to Distributor %Distributor%
	
	if not defined DistributorLogin @echo   **** ERROR:  VARIABLE DistributorLogin IS NOT DEFINED & goto error
	if not defined DistributorPassword set DistributorPassword=[]
	set SECLOG_D=-U%DistributorLogin% -P%DistributorPassword%
	set SECLOG_D_BCP=-U%DistributorLogin% -P%DistributorPassword%
	set SECLOG_SCRIPT=-U%DistributorLogin% -P%DistributorPassword%
	
	)
	
set SECLOG_S=-E
set SECLOG_S_BCP=-T
if %SubscriberSecurityMode% EQU 0 (

	@echo.
	@echo         Using Standard SQL Server Security to connect to Susbcriber %Subscriber%
	
	if not defined SubscriberLogin @echo   **** ERROR:  VARIABLE SubscriberLogin IS NOT DEFINED & goto error
	if not defined SubscriberPassword set SubscriberPassword=[]
	set SECLOG_S=-U%SubscriberLogin% -P%SubscriberPassword%
	set SECLOG_S_BCP=-U%SubscriberLogin% -P%SubscriberPassword%
	
	)
	
@echo.
@echo     ----------------------------------------
@echo      VERIFYING CONNECTIONS TO THE SERVERS 
@echo     ----------------------------------------

osql %SECLOG_P% -S%Publisher% -n -b -d%PublisherDB% -Q"print 'Connection Succeeded to Publisher %Publisher% - %PublisherDB% DB' "
if not %Errorlevel%==0 (@echo   **** ERROR:  Connection to %Publisher% - %PublisherDB% did not succeed  & goto error)

osql %SECLOG_D% -S%Distributor% -n -b -d%DistributionDB% -Q"print 'Connection Succeeded to Distributor %Distributor% - %DistributionDB% DB' "
if not %Errorlevel%==0 (@echo   **** ERROR:  Connection to %Distributor% - %DistributionDB% did not succeed  & goto error)

osql %SECLOG_P% -S%Publisher% -n -b -Q"if CHARINDEX ('Microsoft SQL Server  2000 - 8.0', @@version) <> 1 RAISERROR ('    Error Verifying Publisher MS SQL Server Version Installed',16,1)"
if not %Errorlevel%==0 (@echo   **** ERROR:  Verify %Publisher% Server has MS SQL Server 2000 or MS SQL Server 2000 Service Pack & goto error)

osql %SECLOG_D% -S%Distributor% -n -b -Q"if CHARINDEX ('Microsoft SQL Server  2000 - 8.0', @@version) <> 1 RAISERROR ('    Error Verifying Distributor MS SQL Server Version Installed',16,1)"
if not %Errorlevel%==0 (@echo   **** ERROR:  Verify %Distributor% Server has MS SQL Server 2000 or MS SQL Server 2000 Service Pack & goto error)


if %SkipSubscriber% EQU 0 (

	osql %SECLOG_S% -S%Subscriber% -n -b -d%SubscriberDB% -Q"print 'Connection Succeeded to Subscriber %Subscriber% - %SubscriberDB% DB' "
	if not %Errorlevel%==0 (@echo   **** ERROR:  Connection to %Subscriber% - %SubscriberDB% did not succeed  & goto error)

	osql %SECLOG_S% -S%Subscriber% -n -b -Q"if CHARINDEX ('Microsoft SQL Server  2000 - 8.0', @@version) <> 1 RAISERROR ('    Error Verifying Subscriber MS SQL Server Version Installed',16,1)"
	if not %Errorlevel%==0 (@echo   **** ERROR:  Verify %Subscriber% Server has MS SQL Server 2000 or MS SQL Server 2000 Service Pack & goto error)
)

@echo.
@echo.

osql %SECLOG_D% -S%Distributor% -n -b -Q"set nocount on select getdate() as 'Data Gather Start Time'"
if not %Errorlevel%==0 (goto Error)

@echo.
@echo     ---------------------------
@echo      MAPPING UNC DRIVE PATHS
@echo     ---------------------------

osql %SECLOG_P% -S%Publisher% -n -b -Q"exec master..xp_cmdshell 'net use %PublisherMappingLoc% /delete'" -onetusepubdel.out
osql %SECLOG_P% -S%Publisher% -n -b -Q"exec master..xp_cmdshell 'net use %PublisherMappingLoc% %PublisherUNC%'" -onetusepubset.out

if not exist %PublisherMappingLoc%\ReplDiagnostics\Publisher md %PublisherMappingLoc%\ReplDiagnostics\Publisher
if not %ErrorLevel%==0 (@echo **** ERROR:  Could not create Publisher directory & goto error)

set FilePath_Pub=%PublisherMappingLoc%\ReplDiagnostics\Publisher
@echo Publisher File Location:   %FilePath_pub%

osql %SECLOG_D% -S%Distributor% -n -b -Q"exec master..xp_cmdshell 'net use %DistributorMappingLoc% /delete'" -onetusedistdel.out
osql %SECLOG_D% -S%Distributor% -n -b -Q"exec master..xp_cmdshell 'net use %DistributorMappingLoc% %DistributorUNC%'" -onetusedistset.out

if not exist %DistributorMappingLoc%\ReplDiagnostics\Distributor md %DistributorMappingLoc%\ReplDiagnostics\Distributor
if not %ErrorLevel%==0 (@echo **** ERROR:  Could not create Distributor directory & goto error)

set FilePath_Dist=%DistributorMappingLoc%\ReplDiagnostics\Distributor
@echo Distributor File Location: %FilePath_dist%

if %SkipSubscriber% EQU 0 (

	osql %SECLOG_S% -S%Susbcriber% -n -b -Q"exec master..xp_cmdshell 'net use %SubscriberMappingLoc% /delete'" -onetusesubdel.out
	osql %SECLOG_S% -S%Susbcriber% -n -b -Q"exec master..xp_cmdshell 'net use %SubscriberMappingLoc% %SubscriberUNC%'" -onetusesubset.out

	if not exist %SubscriberMappingLoc%\ReplDiagnostics\Subscriber md %SubscriberMappingLoc%\ReplDiagnostics\Subscriber
	if not %ErrorLevel%==0 (@echo **** ERROR:  Could not create Subscriber directory & goto error)

	set FilePath_Sub=%SubscriberMappingLoc%\ReplDiagnostics\Subscriber
	@echo Subscriber File Location:  %FilePath_Sub%
)


@echo.
@echo     ---------------------------
@echo      DELETING OLD DATA FILES
@echo     ---------------------------

call :DeleteOldTraceFiles

@echo.
@echo     ---------------------------
@echo      CREATING HELPER OBJECTS
@echo     ---------------------------

osql %SECLOG_D% -S%Distributor% -d%DistributionDB% -n -b -i%SCRIPT_DIR%\sharedinstall.sql -o%FilePath_dist%\sharedinstall.out
if not %Errorlevel%==0 (@echo   **** ERROR:  Could not create shared install procedures at distributor & goto error)

osql %SECLOG_P% -S%Publisher% -d%PublisherDB% -n -b -i%SCRIPT_DIR%\sharedinstall.sql -o%FilePath_pub%\sharedinstall.out
if not %Errorlevel%==0 (@echo   **** ERROR:  Could not create shared install procedures at publisher & goto error)

osql %SECLOG_P% -S%Publisher% -b -n -d%PublisherDB% -i%SCRIPT_DIR%\sp_sqldiag.sql -o%FilePath_pub%\sqldiag_setup.out
if not %Errorlevel%==0 (@echo **** ERROR: Failed to set up SQLDIAG report procedure at publisher & goto error)

osql %SECLOG_D% -S%Distributor% -b -n -d%DistributionDB% -i%SCRIPT_DIR%\sp_sqldiag.sql -o%FilePath_dist%\sqldiag_setup.out
if not %Errorlevel%==0 (@echo **** ERROR: Failed to set up SQLDIAG report procedure at distributor & goto error)

osql %SECLOG_P% -S%Publisher% -n -b -d%PublisherDB% -i%SCRIPT_DIR%\mergebcp.sql -omergebcp.out
if not %Errorlevel%==0 (@echo **** ERROR: Could not create merge BCP helper procs at publisher & goto error)

REM 
REM If we're not skipping the subscriber data retrieval (%SkipSubscriber% == 0), set up the procs at the subscriber
REM
if %SkipSubscriber% EQU 0 (

	osql %SECLOG_S% -S%Subscriber% -d%SubscriberDB% -n -b -i%SCRIPT_DIR%\sharedinstall.sql -o%FilePath_sub%\sharedinstall.out
	if not %Errorlevel%==0 (@echo   **** ERROR:  Could not create shared install procedures at subscriber & goto error)

	osql %SECLOG_S% -S%Subscriber% -b -n -d%SubsriberDB% -i%SCRIPT_DIR%\sp_sqldiag.sql -o%FilePath_sub%\sqldiag_setup.out
	if not %Errorlevel%==0 (@echo **** ERROR: Failed to set up SQLDIAG report procedure at distributor & goto error)

	osql %SECLOG_S% -S%Subscriber% -n -b -d%SubscriberDB% -i%SCRIPT_DIR%\mergebcp.sql -omergebcp.out
	if not %Errorlevel%==0 (@echo **** ERROR: Could not create merge BCP helper procs at subscriber & goto error)

)

@echo.
@echo     -------------------------------------
@echo      CREATING DISTRIBUTOR LINKED SERVER
@echo     -------------------------------------

osql %SECLOG_P% -S%Publisher% -b -n -dmaster -Q"set nocount on if exists( select srvname from sysservers where srvname = N'mergediagdistrib' ) exec sp_dropserver N'mergediagdistrib'"

osql %SECLOG_P% -S%Publisher% -b -n -dmaster -Q"set nocount on exec sp_addlinkedserver @server=N'MergeDiagDistrib', @srvproduct=N'', @provider=N'SQLOLEDB', @datasrc=N'%Distributor%'"
if not %Errorlevel%==0 (@echo **** ERROR: Failed to create distributor linked server at publisher & goto error)

osql %SECLOG_P% -S%Publisher% -b -n -dmaster -Q"set nocount on exec sp_serveroption @server=N'MergeDiagDistrib', @optname=N'RPC OUT', @optvalue=N'TRUE'"
if not %Errorlevel%==0 (@echo **** ERROR: Failed to set RPC OUT for publisher->distributor linked server & goto error)

if %SkipSubscriber% EQU 0 (
	
	osql %SECLOG_S% -S%Subscriber% -b -n -dmaster -Q"set nocount on if exists( select srvname from sysservers where srvname = N'mergediagdistrib' ) exec sp_dropserver N'mergediagdistrib'"

	osql %SECLOG_S% -S%Subscriber% -b -n -dmaster -Q"set nocount on exec sp_addlinkedserver @server=N'MergeDiagDistrib', @srvproduct=N'', @provider=N'SQLOLEDB', @datasrc=N'%Distributor%'"
	if not %Errorlevel%==0 (@echo **** ERROR: Failed to create distributor linked server at subscriber & goto error)

	osql %SECLOG_S% -S%Subscriber% -b -n -dmaster -Q"set nocount on exec sp_serveroption @server=N'MergeDiagDistrib', @optname=N'RPC OUT', @optvalue=N'TRUE'"
	if not %Errorlevel%==0 (@echo **** ERROR: Failed to set RPC OUT for subscriber->distributor linked server & goto error)
)


@echo.
@echo     ------------------------------
@echo      GETTING VERSION INFORMATION
@echo     ------------------------------

osql %SECLOG_P% -S%Publisher% -d%PublisherDB% -n -b -Q"exec dbo.sp_getversioninfo 'PUBLISHER'" -ogetverpub.out
if not %Errorlevel%==0 (@echo   **** ERROR:  Could not retreive version information from publisher & goto error)

bcp %PublisherDB%..tblVersionInfo out %FilePath_pub%\tblVersionInfo_pub.bcp -S%Publisher% %SECLOG_P_BCP% -n
if not %Errorlevel%==0 goto error

osql %SECLOG_D% -S%Distributor% -n -b -d%DistributionDB% -Q"exec sp_addtocabfile @filepath = N'%FilePath_pub%\tblVersionInfo_pub.bcp', @filename = N'tblVersionInfo_pub.bcp'"
if not %Errorlevel%==0 (@echo **** Could not add publisher's version information table to CAB table & goto error)


osql %SECLOG_D% -S%Distributor% -d%DistributionDB% -n -b -Q"exec dbo.sp_getversioninfo 'DISTRIBUTOR'" -ogetverdist.out
if not %Errorlevel%==0 (@echo   **** ERROR:  Could not retreive version information from distributor & goto error)

bcp %DistributionDB%..tblVersionInfo out %FilePath_dist%\tblVersionInfo_dist.bcp -S%Distributor% %SECLOG_D_BCP% -n
if not %Errorlevel%==0 goto error

osql %SECLOG_D% -S%Distributor% -n -b -d%DistributionDB% -Q"exec sp_addtocabfile @filepath = N'%FilePath_dist%\tblVersionInfo_dist.bcp', @filename = N'tblVersionInfo_dist.bcp'"
if not %Errorlevel%==0 (@echo **** Could not add distributor's version information table to CAB table & goto error)

if %SkipSubscriber% EQU 0 (
	
	osql %SECLOG_S% -S%Subscriber% -d%SubscriberDB% -n -b -Q"exec dbo.sp_getversioninfo 'SUBSCRIBER'" -ogetverdist.out
	if not %Errorlevel%==0 (@echo   **** ERROR:  Could not retreive version information from the subscriber& goto error)

	bcp %SubscriberDB%..tblVersionInfo out %FilePath_sub%\tblVersionInfo_sub.bcp -S%Subscriber% %SECLOG_S_BCP% -n
	if not %Errorlevel%==0 goto error

	osql %SECLOG_D% -S%Distributor% -n -b -d%DistributionDB% -Q"exec sp_addtocabfile @filepath = N'%FilePath_sub%\tblVersionInfo_sub.bcp', @filename = N'tblVersionInfo_sub.bcp'"
	if not %Errorlevel%==0 (@echo **** Could not add subscriber's version information table to CAB table & goto error)
)


:BackupDistributor

if %GetDistributionDB% EQU 1 (

	@echo.
	@echo     ------------------------------
	@echo      BACKING UP DISTRIBUTION DB
	@echo     ------------------------------

	osql %SECLOG_D% -S%Distributor% -n -b -d%DistributionDB% -Q"BACKUP DATABASE %DistributionDB% TO DISK = N'%FilePath_dist%\distrib.bak'"
	if not %Errorlevel%==0 (@echo **** ERROR: Failed to back up distribution database & goto error)

	osql %SECLOG_D% -S%Distributor% -n -b -d%DistributionDB% -Q"exec sp_addtocabfile @filepath = N'%FilePath_dist%\distrib.bak', @filename = N'distrib.bak'"
	if not %Errorlevel%==0 (@echo **** Could not add distribution database to CAB table & goto error)
	
	goto :BackupPublisher
	
	)
	
REM
REM We won't get here if we back up the distribution database
REM
if %GetDistributionDB% EQU 0 (

	REM
	REM	We need to BCP out the necessary distribution database tables
	REM This is the merge-specific information in that database.  No need to get tran information.
	REM
	
	@echo.
	@echo    -------------------------------------
	@echo     BULK COPYING MSMERGE_HISTORY
	@echo    -------------------------------------
	@echo.
	bcp %DistributionDB%..MSmerge_history out MSmerge_history.bcp -S%Distributor% %SECLOG_D_BCP% -n
	if not %Errorlevel%==0 goto error

	osql %SECLOG_D% -S%Distributor% -n -b -d%DistributionDB% -Q"exec sp_addtocabfile @filepath = N'%cd%\MSmerge_history.bcp', @filename=N'MSmerge_history.bcp'"
	if not %Errorlevel%==0 (@echo **** ERROR: Could not add [MSmerge_history] table to CAB table & goto error)

	@echo.
	@echo    -------------------------------------
	@echo     BULK COPYING MSMERGE_AGENTS
	@echo    -------------------------------------
	@echo.
	bcp %DistributionDB%..MSmerge_agents out MSmerge_agents.bcp -S%Distributor% %SECLOG_D_BCP% -n
	if not %Errorlevel%==0 goto error

	osql %SECLOG_D% -S%Distributor% -n -b -d%DistributionDB% -Q"exec sp_addtocabfile @filepath = N'%cd%\MSmerge_agents.bcp', @filename=N'MSmerge_agents.bcp'"
	if not %Errorlevel%==0 (@echo **** ERROR: Could not add [MSmerge_agents] table to CAB table & goto error)

	@echo.
	@echo    -------------------------------------
	@echo     BULK COPYING MSREPL_ERRORS
	@echo    -------------------------------------
	@echo.
	bcp %DistributionDB%..MSrepl_errors out MSrepl_errors.bcp -S%Distributor% %SECLOG_D_BCP% -n
	if not %Errorlevel%==0 goto error

	osql %SECLOG_D% -S%Distributor% -n -b -d%DistributionDB% -Q"exec sp_addtocabfile @filepath = N'%cd%\MSrepl_errors.bcp', @filename=N'MSrepl_errors.bcp'"
	if not %Errorlevel%==0 (@echo **** ERROR: Could not add [MSrepl_errors] table to CAB table & goto error)

	@echo.
	@echo    -------------------------------------
	@echo     BULK COPYING MSPUBLICATIONS
	@echo    -------------------------------------
	@echo.
	bcp %DistributionDB%..MSpublications out MSpublications.bcp -S%Distributor% %SECLOG_D_BCP% -n
	if not %Errorlevel%==0 goto error

	osql %SECLOG_D% -S%Distributor% -n -b -d%DistributionDB% -Q"exec sp_addtocabfile @filepath = N'%cd%\MSpublications.bcp', @filename=N'MSpublications.bcp'"
	if not %Errorlevel%==0 (@echo **** ERROR: Could not add [MSpublications] table to CAB table & goto error)


	@echo.
	@echo    -------------------------------------
	@echo     BULK COPYING MSPUBLICATIONS
	@echo    -------------------------------------
	@echo.
	bcp %DistributionDB%..MSmerge_subscriptions out MSmerge_subscriptions.bcp -S%Distributor% %SECLOG_D_BCP% -n
	if not %Errorlevel%==0 goto error

	osql %SECLOG_D% -S%Distributor% -n -b -d%DistributionDB% -Q"exec sp_addtocabfile @filepath = N'%cd%\MSmerge_subscriptions.bcp', @filename=N'MSmerge_subscriptions.bcp'"
	if not %Errorlevel%==0 (@echo **** ERROR: Could not add [MSpublications] table to CAB table & goto error)
	
	)
	
:BackupPublisher

if %GetPublisherDB% EQU 1 (

	@echo.
	@echo     ------------------------------
	@echo      BACKING UP PUBLISHER DB
	@echo     ------------------------------

	osql %SECLOG_P% -S%Publisher% -n -b -d%PublisherDB% -Q"BACKUP DATABASE %PublisherDB% TO DISK = N'%FilePath_pub%\PublisherDB.bak'"
	if not %Errorlevel%==0 (@echo **** ERROR: Failed to back up publisher database & goto error)
	
	osql %SECLOG_D% -S%Distributor% -n -b -d%DistributionDB% -Q"exec sp_addtocabfile @filepath = N'%FilePath_pub%\PublisherDB.bak', @filename=N'PublisherDB.bak'"
	if not %Errorlevel%==0 (@echo **** ERROR: Could not add publisher database to CAB table & goto error)	
	
	)
	
if %SkipSubscriber% EQU 0 (

	if %GetSubscriberDB% EQU 1 (

	@echo.
	@echo     ------------------------------
	@echo      BACKING UP SUBSCRIBER DB
	@echo     ------------------------------

	osql %SECLOG_S% -S%Subscriber% -n -b -d%SubscriberDB% -Q"BACKUP DATABASE %SubscriberDB% TO DISK = N'%FilePath_sub%\SubscriberDB.bak'"
	if not %Errorlevel%==0 (@echo **** ERROR: Failed to back up subscriber database & goto error)

	osql %SECLOG_D% -S%Distributor% -n -b -d%DistributionDB% -Q"exec sp_addtocabfile @filepath = N'%FilePath_sub%\SubscriberDB.bak', @filename=N'SubscriberDB.bak'"
	if not %Errorlevel%==0 (@echo **** ERROR: Could not add subscriber database to CAB table & goto error)	

	)
)

	
if %GetPubSchema% EQU 1 (

	set SCPT_SEC=/I
	if %PublisherSecurityMode% EQU 0 (

		@echo.
		@echo         Using Standard SQL Server Security to script objects at Publisher %Publisher%
		
		if not defined PublisherLogin @echo   **** ERROR:  VARIABLE PublisherLogin IS NOT DEFINED & goto error
		if not defined PublisherPassword set PublisherPassword=[]
		
		set SCPT_SEC=/P %PublisherPassword%

	)

	@echo.
	@echo     --------------------------------------
	@echo      SCRIPTING PUBLISHER DATABASE OBJECTS
	@echo      (This may take a while...)
	@echo     --------------------------------------

	@echo %EXE_DIR%\scptxfr /s %Publisher% /d %PublisherDB% %SCPT_SEC% /f .\pubscripts.sql /G
	%EXE_DIR%\scptxfr /s %Publisher% /d %PublisherDB% %SCPT_SEC% /f .\pubscripts.sql /G
	if not %Errorlevel%==0 (@echo **** ERROR:  Could not script publisher database objects & goto error)
	
	osql %SECLOG_D% -S%Distributor% -n -b -d%DistributionDB% -Q"exec sp_addtocabfile @filepath = N'%cd%\pubscripts.sql', @filename=N'pubscripts.sql'"	
	if not %Errorlevel%==0 (@echo **** ERROR: Could not add publication database scripts to CAB table & goto error)		
)	
	
if %SkipSubscriber% EQU 0 (

	if %GetSubSchema% EQU 1 (

		set SCPT_SEC=/I
		if %SubscriberSecurityMode% EQU 0 (

			@echo.
			@echo         Using Standard SQL Server Security to script objects at Subscriber %Subscriber%
		
			if not defined SubscriberLogin @echo   **** ERROR:  VARIABLE PublisherLogin IS NOT DEFINED & goto error
			if not defined SubscriberPassword set SubscriberPassword=[]
		
			set SCPT_SEC=/P %SubscriberPassword%
		)

		@echo.
		@echo     --------------------------------------
		@echo      SCRIPTING SUBSCRIBER DATABASE OBJECTS
		@echo      (This may take a while...)
		@echo     --------------------------------------

		@echo %EXE_DIR%\scptxfr /s %Subscriber% /d %SubscriberDB% %SCPT_SEC% /f .\subscripts.sql /G
		%EXE_DIR%\scptxfr /s %Subscriber% /d %SubscriberDB% %SCPT_SEC% /f .\subscripts.sql /G
		if not %Errorlevel%==0 (@echo **** ERROR:  Could not script subscriber database objects & goto error)
	
		osql %SECLOG_D% -S%Distributor% -n -b -d%DistributionDB% -Q"exec sp_addtocabfile @filepath = N'%cd%\subscripts.sql', @filename=N'subscripts.sql'"	
		if not %Errorlevel%==0 (@echo **** ERROR: Could not add subscriber database scripts to CAB table & goto error)		
	)	
)

@echo.
@echo     --------------------------------------
@echo      GENERATING REPLICATION SCRIPTS
@echo     --------------------------------------

@echo %EXE_DIR%\scriptrepl -S%Distributor% -d%PublisherDB% -N%publication% %SECLOG_SCRIPT% -o%cd% -c
%EXE_DIR%\scriptrepl -S%Distributor% -d%PublisherDB% -N%publication% %SECLOG_SCRIPT% -o%cd% -c
if not %Errorlevel%==0 (@echo **** ERROR:  Could not generate replication scripts & goto error)

osql %SECLOG_D% -S%Distributor% -n -b -d%DistributionDB% -Q"exec sp_addtocabfile @filepath = N'%cd%\replscript.sql', @filename=N'replscript.sql'"	
if not %Errorlevel%==0 (@echo **** ERROR: Could not add replication scripts to CAB table & goto error)	

osql %SECLOG_D% -S%Distributor% -n -b -d%DistributionDB% -Q"exec sp_addtocabfile @filepath = N'%cd%\conflicttbls.sql', @filename=N'conflicttbls.sql'"	
if not %Errorlevel%==0 (@echo **** ERROR: Could not add replication scripts to CAB table & goto error)	

@echo.
@echo     ------------------------------------
@echo      RUNNING SQLDIAG.SQL AT PUBLISHER
@echo     ------------------------------------

osql %SECLOG_P% -S%Publisher% -b -n -w4096 -d%PublisherDB% -Q"exec sp_sqldiag NULL, NULL, 0, 0, 0" -o%FilePath_pub%\sqldiag_pub.txt
if not %Errorlevel%==0 (@echo **** ERROR: Failed to get SQLDIAG report from publisher & goto error)

osql %SECLOG_D% -S%Distributor% -n -b -d%DistributionDB% -Q"exec sp_addtocabfile @filepath = N'%FilePath_pub%\sqldiag_pub.txt', @filename=N'sqldiag_pub.txt'"
if not %Errorlevel%==0 (@echo **** ERROR: Could not add SQLDIAG to CAB table & goto error)

@echo.
@echo     ------------------------------------
@echo      GETTING EVENT LOGS FROM PUBLISHER
@echo     ------------------------------------
@echo.
@echo RETRIEVING SYSTEM EVENT LOG...
@echo %EXE_DIR%\dumpel.exe -f "%cd%\%Publisher%_evt_sys.txt" -l system -t -s \\%Publisher%
%EXE_DIR%\dumpel.exe -f "%cd%\%Publisher%_evt_sys.txt" -l system -t -s \\%Publisher%

osql %SECLOG_D% -S%Distributor% -n -b -d%DistributionDB% -Q"exec sp_addtocabfile @filepath = N'%cd%\%Publisher%_evt_sys.txt', @filename=N'%Publisher%_evt_sys.txt'"
if not %Errorlevel%==0 (@echo **** ERROR: Could not add Publisher system event log to CAB table & goto error)

@echo.
@echo RETRIEVING APPLICATION EVENT LOG...
@echo %EXE_DIR%\dumpel.exe -f "%cd%\%Publisher%_evt_app.txt" -l application -t -s \\%Publisher%
%EXE_DIR%\dumpel.exe -f "%cd%\%Publisher%_evt_app.txt" -l application -t -s \\%Publisher%

osql %SECLOG_D% -S%Distributor% -n -b -d%DistributionDB% -Q"exec sp_addtocabfile @filepath = N'%cd%\%Publisher%_evt_app.txt', @filename=N'%Publisher%_evt_app.txt'"
if not %Errorlevel%==0 (@echo **** ERROR: Could not add Publisher application event log to CAB table & goto error)


if "%Publisher%"=="%Distributor%" (

	@echo.
	@echo **** Skipping Distributor SQLDIAG and Event Logs - it is the same server as the Publisher. 
	@echo.

	goto SubSQLDiag

)

@echo.
@echo     --------------------------------------
@echo      RUNNING SQLDIAG.SQL AT DISTRIBUTOR
@echo     --------------------------------------

osql %SECLOG_D% -S%Distributor% -b -n -w4096 -d%DistributionDB% -Q"exec sp_sqldiag NULL, NULL, 0, 0, 0" -o%FilePath_dist%\sqldiag_dist.txt
if not %Errorlevel%==0 (@echo **** ERROR: Failed to get SQLDIAG report from distributor & goto error)

osql %SECLOG_D% -S%Distributor% -n -b -d%DistributionDB% -Q"exec sp_addtocabfile @filepath = N'%FilePath_dist%\sqldiag_dist.txt', @filename=N'sqldiag_dist.txt'"
if not %Errorlevel%==0 (@echo **** ERROR: Could not add SQLDIAG to CAB table & goto error)

@echo.
@echo     --------------------------------------
@echo      GETTING EVENT LOGS FROM DISTRIBUTOR
@echo     --------------------------------------
@echo.
@echo RETRIEVING SYSTEM EVENT LOG...
@echo %EXE_DIR%\dumpel.exe -f "%cd%\%Distributor%_evt_sys.txt" -l system -t -s \\%Distributor%
%EXE_DIR%\dumpel.exe -f "%cd%\%Publisher%_evt_sys.txt" -l system -t -s \\%Distributor%

osql %SECLOG_D% -S%Distributor% -n -b -d%DistributionDB% -Q"exec sp_addtocabfile @filepath = N'%cd%\%Distributor%_evt_sys.txt', @filename=N'%Distributor%_evt_sys.txt'"
if not %Errorlevel%==0 (@echo **** ERROR: Could not add Distributor system event log to CAB table & goto error)

@echo.
@echo RETRIEVING APPLICATION EVENT LOG...
@echo %EXE_DIR%\dumpel.exe -f "%cd%\%Distributor%_evt_app.txt" -l application -t -s \\%Distributor%
%EXE_DIR%\dumpel.exe -f "%cd%\%Distributor%_evt_app.txt" -l application -t -s \\%Distributor%

osql %SECLOG_D% -S%Distributor% -n -b -d%DistributionDB% -Q"exec sp_addtocabfile @filepath = N'%cd%\%Distributor%_evt_app.txt', @filename=N'%Distributor%_evt_app.txt'"
if not %Errorlevel%==0 (@echo **** ERROR: Could not add Distributor application event log to CAB table & goto error)

:SubSQLDiag

if %SkipSubscriber% EQU 0 (

	@echo.
	@echo     --------------------------------------
	@echo      RUNNING SQLDIAG.SQL AT SUBSCRIBER
	@echo     --------------------------------------

	osql %SECLOG_S% -S%Subscriber% -b -n -w4096 -d%SubscriberDB% -Q"exec sp_sqldiag NULL, NULL, 0, 0, 0" -o%FilePath_sub%\sqldiag_sub.txt
	if not %Errorlevel%==0 (@echo **** ERROR: Failed to get SQLDIAG report from subscriber & goto error)

	osql %SECLOG_D% -S%Distributor% -n -b -d%DistributionDB% -Q"exec sp_addtocabfile @filepath = N'%FilePath_sub%\sqldiag_sub.txt', @filename=N'sqldiag_sub.txt'"
	if not %Errorlevel%==0 (@echo **** ERROR: Could not add SQLDIAG to CAB table & goto error)

	@echo.
	@echo     --------------------------------------
	@echo      GETTING EVENT LOGS FROM SUBSCRIBER
	@echo     --------------------------------------
	@echo.
	@echo RETRIEVING SYSTEM EVENT LOG...

	@echo %EXE_DIR%\dumpel.exe -f "%cd%\%Subscriber%_evt_sys.txt" -l system -t -s \\%Subscriber%
	%EXE_DIR%\dumpel.exe -f "%cd%\%Subscriber%_evt_sys.txt" -l system -t -s \\%Subscriber%

	osql %SECLOG_D% -S%Distributor% -n -b -d%DistributionDB% -Q"exec sp_addtocabfile @filepath = N'%cd%\%Subscriber%_evt_sys.txt', @filename=N'%Subscriber%_evt_sys.txt'"
	if not %Errorlevel%==0 (@echo **** ERROR: Could not add Subscriber system event log to CAB table & goto error)

	@echo.
	@echo RETRIEVING APPLICATION EVENT LOG...

	@echo %EXE_DIR%\dumpel.exe -f "%cd%\%Subscriber%_evt_app.txt" -l application -c -s \\%Subscriber%
	%EXE_DIR%\dumpel.exe -f "%cd%\%Subscriber%_evt_app.txt" -l application -c -s \\%Subscriber%

	osql %SECLOG_D% -S%Distributor% -n -b -d%DistributionDB% -Q"exec sp_addtocabfile @filepath = N'%cd%\%Subscriber%_evt_app.txt', @filename=N'%Subscriber%_evt_app.txt'"
	if not %Errorlevel%==0 (@echo **** ERROR: Could not add Subscriber application event log to CAB table & goto error)
)

@echo.
@echo    ------------------------------------------------
@echo     BULK COPYING MERGE SYSTEM OBJECTS (Publisher)
@echo    ------------------------------------------------
@echo.
osql %SECLOG_P% -S%Publisher% -n -b -d%PublisherDB% -Q"exec sp_addmergeobjects N'pub'" -oaddobjs_pub.out
if not %Errorlevel%==0 (@echo **** ERROR: Could not add merge system objects to export table at publisher & goto error)

@echo osql %SECLOG_P% -S%Publisher% -n -b -d%PublisherDB% -Q"exec sp_exportmergeobjects @ServerName = N'%Publisher%', @SecurityStr = N'%SECLOG_P_BCP%', @OutFilePath=N'%FilePath_Pub%', @FileSuffix=N'_pub', @DistribDB=N'%DistributionDB'" -opubexport.out
osql %SECLOG_P% -S%Publisher% -n -b -w5000 -d%PublisherDB% -Q"exec sp_exportmergeobjects @ServerName = N'%Publisher%', @SecurityStr=N'%SECLOG_P_BCP%', @OutFilePath=N'%FilePath_Pub%', @FileSuffix=N'_pub', @DistribDB=N'%DistributionDB%'" -opubexport.out
if not %Errorlevel%==0 (@echo **** ERROR: Could not export merge system objects from publisher & goto error)

@echo.
@echo    -------------------------------------
@echo     BULK COPYING SYSSERVERS (Publisher)
@echo    -------------------------------------
@echo.
bcp master..sysservers out sysservers_pub.bcp -S%Publisher% %SECLOG_P_BCP% -n
if not %Errorlevel%==0 goto error

osql %SECLOG_D% -S%Distributor% -n -b -d%DistributionDB% -Q"exec sp_addtocabfile @filepath = N'%cd%\sysservers_pub.bcp', @filename=N'sysservers_pub.bcp'"
if not %Errorlevel%==0 (@echo **** ERROR: Could not add publisher [sysservers] table to CAB table & goto error)


if %SkipSubscriber% EQU 0 (

	@echo.
	@echo    ------------------------------------------------
	@echo     BULK COPYING MERGE SYSTEM OBJECTS (Subscriber)
	@echo    ------------------------------------------------
	@echo.
	osql %SECLOG_S% -S%Subscriber% -n -b -d%SubscriberDB% -Q"exec sp_addmergeobjects N'sub'" -oaddobjs_sub.out
	if not %Errorlevel%==0 (@echo **** ERROR: Could not add merge system objects to export table at subscriber & goto error)

	osql %SECLOG_P% -S%Publisher% -n -b -w5000 -d%PublisherDB% -Q"exec sp_exportmergeobjects @ServerName=N'%Subscriber%', @SecurityStr=N'%SECLOG_S_BCP%', @OutFilePath=N'%FilePath_sub%', @FileSuffix=N'_sub', @DistribDB=N'%DistributionDB%'" -osubexport.out
	if not %Errorlevel%==0 (@echo **** ERROR: Could not export merge system objects from subscriber & goto error)

	@echo.
	@echo    -------------------------------------
	@echo     BULK COPYING SYSSERVERS (Subscriber)
	@echo    -------------------------------------
	@echo.
	bcp master..sysservers out sysservers_sub.bcp -S%Subscriber% %SECLOG_S_BCP% -n
	if not %Errorlevel%==0 goto error

	osql %SECLOG_D% -S%Distributor% -n -b -d%DistributionDB% -Q"exec sp_addtocabfile @filepath = N'%cd%\sysservers_sub.bcp', @filename=N'sysservers_sub.bcp'"
	if not %Errorlevel%==0 (@echo **** ERROR: Could not add [sysservers] table to CAB table & goto error)
)

@echo.
@echo    -------------------------------------
@echo     GATHERING AGENT PROFILE INFORMATION
@echo    -------------------------------------
@echo.
@echo osql %SECLOG_D% -S%Distributor% -n -b -w4096 -d%DistributionDB% -Q"exec dbo.sp_agent_profiles @agent_type = N'MERGE'" -o"%cd%\agent_profiles.txt"
osql %SECLOG_D% -S%Distributor% -n -b -w4096 -d%DistributionDB% -Q"exec dbo.sp_agent_profiles @agent_type = N'MERGE'" -o"%cd%\agent_profiles.txt"
if not %Errorlevel%==0 (@echo **** ERROR: Failed to gather agent profile information & goto error)

osql %SECLOG_D% -S%Distributor% -n -b -d%DistributionDB% -Q"exec sp_addtocabfile @filepath = N'%cd%\agent_profiles.txt', @filename=N'agent_profiles.txt'"
if not %Errorlevel%==0 (@echo **** ERROR: Could not add agent profile output to CAB table & goto error)	


@echo.
@echo    ---------------------------------------
@echo     ANALYZING MERGE METADATA (Publisher)
@echo    ---------------------------------------
@echo.
osql %SECLOG_P% -S%Publisher% -n -b -w4096 -d%PublisherDB% -i%SCRIPT_DIR%\metadata_analysis.sql -o%filepath_pub%\metadata_pub.txt
if not %Errorlevel%==0 (@echo **** ERROR: Could not perform metadata analysis at publisher & goto error)

osql %SECLOG_D% -S%Distributor% -n -b -d%DistributionDB% -Q"exec sp_addtocabfile @filepath = N'%filepath_pub%\metadata_pub.txt', @filename=N'metadata_pub.txt'"
if not %Errorlevel%==0 (@echo **** ERROR: Could not add metadata analysis to CAB table & goto error)

@echo.
@echo    ----------------------------------------------
@echo     ANALYZING MERGE FILTER STRUCTURE (Publisher)
@echo    ----------------------------------------------
@echo.
osql %SECLOG_P% -S%Publisher% -n -b -w4096 -d%PublisherDB% -i%SCRIPT_DIR%\mergefilters.sql -o%filepath_pub%\mergefilters.txt
if not %Errorlevel%==0 (@echo **** ERROR: Could not perform filter analysis at publisher & goto error)

osql %SECLOG_D% -S%Distributor% -n -b -d%DistributionDB% -Q"exec sp_addtocabfile @filepath = N'%filepath_pub%\mergefilters.txt', @filename=N'mergefilters.txt'"
if not %Errorlevel%==0 (@echo **** ERROR: Could not add filter analysis to CAB table & goto error)

osql %SECLOG_P% -S%Publisher% -n -b -w4096 -d%PublisherDB% -i%SCRIPT_DIR%\mergeperf.sql -omergeperf.out
if not %Errorlevel%==0 (@echo **** ERROR: Could not create filter analysis procs at publisher & goto error)

osql %SECLOG_P% -S%Publisher% -n -b -w4096 -d%PublisherDB% -Q"exec proc_merge_diagnostic_report '%Publication%', 1" -o%FilePath_Pub%\mergeperf.txt
if not %Errorlevel%==0 (@echo **** ERROR: Could not perform merge performance analysis at publisher & goto error)

osql %SECLOG_D% -S%Distributor% -n -b -d%DistributionDB% -Q"exec sp_addtocabfile @filepath = N'%filepath_pub%\mergeperf.txt', @filename=N'mergeperf.txt'"
if not %Errorlevel%==0 (@echo **** ERROR: Could not add filter analysis to CAB table & goto error)

if %SkipSubscriber% EQU 0 (

	@echo.
	@echo    ---------------------------------------
	@echo     ANALYZING MERGE METADATA (Subscriber)
	@echo    ---------------------------------------
	@echo.
	osql %SECLOG_S% -S%Subscriber% -n -b -w4096 -d%SubscriberDB% -i%SCRIPT_DIR%\metadata_analysis.sql -o%filepath_sub%\metadata_sub.txt
	if not %Errorlevel%==0 (@echo **** ERROR: Could not perform metadata analysis at publisher & goto error)

	osql %SECLOG_D% -S%Distributor% -n -b -d%DistributionDB% -Q"exec sp_addtocabfile @filepath = N'%filepath_sub%\metadata_sub.txt', @filename=N'metadata_sub.txt'"
	if not %Errorlevel%==0 (@echo **** ERROR: Could not add metadata analysis to CAB table & goto error)
)

@echo.
@echo    ----------------------------------------------
@echo     ANALYZING MERGE ARTICLE INDEXES (PUBLISHER)
@echo    ----------------------------------------------
@echo.

osql %SECLOG_P% -S%Publisher% -n -b -w4096 -d%PublisherDB% -Q"exec sp_articleindexes N'MERGE'" -o%filepath_pub%\article_ndxs_pub.txt
if not %Errorlevel%==0 (@echo **** ERROR: Could not execute article index analysis proc at subscriber & goto error)

osql %SECLOG_D% -S%Distributor% -n -b -d%DistributionDB% -Q"exec sp_addtocabfile @filepath = N'%filepath_pub%\article_ndxs_pub.txt', @filename=N'article_ndxs_pub.txt'"
if not %Errorlevel%==0 (@echo **** ERROR: Could not add index analysis to CAB table & goto error)

if %SkipSubscriber% EQU 0 (

	@echo.
	@echo    ----------------------------------------------
	@echo     ANALYZING MERGE ARTICLE INDEXES (SUBSCRIBER)
	@echo    ----------------------------------------------
	@echo.

	osql %SECLOG_S% -S%Subscriber% -n -b -w4096 -d%SubscriberDB% -Q"exec sp_articleindexes N'MERGE'" -o%filepath_sub%\article_ndxs_sub.txt
	if not %Errorlevel%==0 (@echo **** ERROR: Could not execute article index analysis proc at subscriber & goto error)

	osql %SECLOG_D% -S%Distributor% -n -b -d%DistributionDB% -Q"exec sp_addtocabfile @filepath = N'%filepath_sub%\article_ndxs_sub.txt', @filename=N'article_ndxs_sub.txt'"
	if not %Errorlevel%==0 (@echo **** ERROR: Could not add index analysis to CAB table & goto error)
)

:make_cab
@echo.
@echo    -------------------
@echo     CREATING CAB FILE
@echo    -------------------
@echo.
if not  "%MAKECAB%"=="yes" goto cleanup

bcp %DistributionDB%..tblCabFiles out inventory.bcp -S%Distributor% %SECLOG_D_BCP% -n
if not %Errorlevel%==0 goto error

osql %SECLOG_D% -S%Distributor% -n -b -d%DistributionDB% -Q"exec sp_addtocabfile @filepath = N'%cd%\inventory.bcp', @filename=N'inventory.bcp'"
if not %Errorlevel%==0 (@echo **** ERROR: Could not add [inventory] table to CAB table & goto error)

@echo.
@echo.

osql %SECLOG_D% -S%Distributor% -n -b -d%DistributionDB% -Q"set nocount on select left([FileName], 65) 'Adding files to cabinet' from tblCabFiles order by [FileName]"
osql %SECLOG_D% -S%Distributor% -n -b -w4096 -d%DistributionDB% -Q"set nocount on select left([FileName], 65) 'File Name', left([FilePath], 65) 'Path' from tblCabFiles order by [FileName]" -oinventory.txt

@echo osql %SECLOG_D% -S%Distributor% -n -b -d%DistributionDB% -w5000 -Q"exec sp_gencabfile @filepath = N'%cd%\mergediag.cab'" -ogencab.out
osql %SECLOG_D% -S%Distributor% -n -b -d%DistributionDB% -w5000 -Q"exec sp_gencabfile @filepath = N'%cd%\mergediag.cab'" -ogencab.out
if not %Errorlevel%==0 (@echo **** ERROR: Could not create CAB file & goto error)

:cleanup
@echo.
@echo    -------------------
@echo     CLEANING UP
@echo    -------------------
@echo.

osql %SECLOG_P% -S%Publisher% -d%PublisherDB% -n -b -i%SCRIPT_DIR%\cleanup.sql -otemp.out
osql %SECLOG_D% -S%Distributor% -d%PublisherDB% -n -b -i%SCRIPT_DIR%\cleanup.sql -otemp.out

osql %SECLOG_P% -S%Publisher% -n -b -Q"exec master..xp_cmdshell 'net use %PublisherMappingLoc% /delete'" -otemp.out
osql %SECLOG_D% -S%Distributor% -n -b -Q"exec master..xp_cmdshell 'net use %DistributorMappingLoc% /delete'" -otemp.out

osql %SECLOG_P% -S%Publisher% -b -n -dmaster -Q"set nocount on if exists( select srvname from sysservers where srvname = N'mergediagdistrib' ) exec sp_dropserver N'mergediagdistrib'"
osql %SECLOG_S% -S%Subscriber% -b -n -dmaster -Q"set nocount on if exists( select srvname from sysservers where srvname = N'mergediagdistrib' ) exec sp_dropserver N'mergediagdistrib'"

@echo.
@echo.

osql %SECLOG_P% -S%Distributor% -n -b -Q"set nocount on select getdate() as 'Data Gather End Time'"
if not %Errorlevel%==0 (goto Error)

GOTO :endnow

:DeleteOldTraceFiles

osql %SECLOG_P% -S%Publisher% -n -b -odelpubfiles.out -Q"exec master.dbo.xp_cmdshell 'if exist %FilePath_pub%\*.* del %FilePath_pub%\*.*' "
if not %Errorlevel%==0 (@echo   **** ERROR:  Failed to Delete Files at Destination Folder at PUBLISHER & goto error)

osql %SECLOG_D% -S%Distributor% -n -b -odeldistfiles.out -Q"exec master.dbo.xp_cmdshell 'if exist %FilePath_dist%\*.* del %FilePath_dist%\*.*' "
if not %Errorlevel%==0 (@echo   **** ERROR:  Failed to Delete Files at Destination Folder at DISTRIBUTOR & goto error)

if %SkipSubscriber% EQU 0 (

	osql %SECLOG_S% -S%Subscriber% -n -b -odelsubfiles.out -Q"exec master.dbo.xp_cmdshell 'if exist %FilePath_sub%\*.* del %FilePath_sub%\*.*' "
	if not %Errorlevel%==0 (@echo   **** ERROR:  Failed to Delete Files at Destination Folder at SUBSCRIBER & goto error)
)

GOTO :EOF

:error
@echo.
@echo FINISHING %0 WITH 'FAILED' STATUS
if "%TraceStop%"=="1" call :traceStop
set RET=failed
GOTO :EOF


:endnow
set TracePub=
set TraceSub=
set SCRNAME=
set SECLOG_P=
set SECLOG_S=
set SECLOG_D=
set SECLOG_P_BCP=
set SECLOG_S_BCP=
set FilePath_pub=
set FilePath_dist=
set DistributionDB=
set ApplicationName=
set subid=
if exist temp.out del temp.out 

set Publisher=
set PublisherSecurityMode=
set PublisherDB=
set PublisherLogin=
set PublisherPassword=
set Publication=
set Distributor=
set DistributorLogin=
set DistributorPassword=
set DistributorSecurityMode=
set DistributionDB=

@echo.
@echo FINISHING %0 WITH 'PASSED' STATUS
set RET=

