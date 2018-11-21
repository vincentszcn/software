if not defined TRACE @echo off
set SCRNAME=%0

REM Created by Alejanmi on 03/13/2002
REM
REM Modified for TRAN gatherer by Ryanston on 07/10/2002
REM
REM		++ Capture distribution database backup
REM		++ Gather publisher-specific TRAN tables:
REM			  -- sysarticles
REM			  -- syspublications
REM			  -- syssubscriptions
REM			  -- sysarticleupdates
REM			  -- sysobjects
REM			  -- sysservers
REM		++ Optionally gather ::fn_dblog() commands and T-log details
REM		++ Optionally script out publisher-side database schema
REM		++ Packages to CAB file for easy upload to Microsoft
REM

@echo.
@echo ******************************************************
@echo  TRANSACTIONAL REPLICATION DATA GATHERING TOOL                                
@echo ******************************************************
@echo.
@echo  Gathers important information from transactional  
@echo  replication system tables and database backups.
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
if not defined PublisherSecurityMode	@echo   **** ERROR:  VARIABLE PublisherSecurityMode IS NOT DEFINED & goto error
if not defined PublisherDB				@echo   **** ERROR:  VARIABLE PublisherDB IS NOT DEFINED & goto error
if not defined Publication				@echo   **** ERROR:  VARIABLE Publication IS NOT DEFINED & goto error
if not defined Distributor				@echo   **** ERROR:  VARIABLE Distributor IS NOT DEFINED & goto error
if not defined DistributorSecurityMode	@echo   **** ERROR:  VARIABLE DistributorSecurityMode IS NOT DEFINED & goto error
if not defined DistributionDB			@echo   **** ERROR:  VARIABLE DistributionDB IS NOT DEFINED & goto error

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
	
@echo.
@echo     ----------------------------------------
@echo      VERIFYING CONNECTIONS TO THE SERVERS 
@echo     ----------------------------------------

osql %SECLOG_P% -S%Publisher% -n -b -d%PublisherDB% -Q"print 'Connection Succeeded to %Publisher% Server - %PublisherDB% DB' "
if not %Errorlevel%==0 (@echo   **** ERROR:  Connection to %Publisher% - %PublisherDB% did not succeed  & goto error)

osql %SECLOG_D% -S%Distributor% -n -b -d%DistributionDB% -Q"print 'Connection Succeeded to %Distributor% Server - %DistributionDB% DB' "
if not %Errorlevel%==0 (@echo   **** ERROR:  Connection to %Distributor% - %DistributionDB% did not succeed  & goto error)

osql %SECLOG_P% -S%Publisher% -n -b -Q"if CHARINDEX ('Microsoft SQL Server  2000 - 8.0', @@version) <> 1 RAISERROR ('    Error Verifying Publisher MS SQL Server Version Installed',16,1)"
if not %Errorlevel%==0 (@echo   **** ERROR:  Verify %Publisher% Server has MS SQL Server 2000 or MS SQL Server 2000 Service Pack & goto error)

osql %SECLOG_D% -S%Distributor% -n -b -Q"if CHARINDEX ('Microsoft SQL Server  2000 - 8.0', @@version) <> 1 RAISERROR ('    Error Verifying Distributor MS SQL Server Version Installed',16,1)"
if not %Errorlevel%==0 (@echo   **** ERROR:  Verify %Distributor% Server has MS SQL Server 2000 or MS SQL Server 2000 Service Pack & goto error)

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

osql %SECLOG_D% -S%Distributor% -n -b -Q"exec master..xp_cmdshell 'net use %DistributorMappingLoc% /delete'" -onetusedistdel.out
osql %SECLOG_D% -S%Distributor% -n -b -Q"exec master..xp_cmdshell 'net use %DistributorMappingLoc% %DistributorUNC%'" -onetusedistset.out

@echo.
@echo     ---------------------------
@echo      DELETING OLD DATA FILES
@echo     ---------------------------

set FilePath_pub=%PublisherMappingLoc%\ReplDiagnostics\Publisher
set FilePath_dist=%DistributorMappingLoc%\ReplDiagnostics\Distributor

@echo Publisher File Location:	    %FilePath_pub%
@echo Distributor File Location:    %FilePath_dist%

call :DeleteOldTraceFiles


@echo.
@echo     ---------------------------
@echo      CREATING HELPER OBJECTS
@echo     ---------------------------

osql %SECLOG_P% -S%Distributor% -d%DistributionDB% -n -b -i%SCRIPT_DIR%\sharedinstall.sql -o%FilePath_pub%\sharedinstall.out
if not %Errorlevel%==0 (@echo   **** ERROR:  Could not create shared procedures at distributor & goto error)

osql %SECLOG_P% -S%Publisher% -d%PublisherDB% -n -b -i%SCRIPT_DIR%\sharedinstall.sql -o%FilePath_pub%\sharedinstall.out
if not %Errorlevel%==0 (@echo   **** ERROR:  Could not create shared installation procedures at publisher & goto error)

osql %SECLOG_P% -S%Publisher% -b -n -d%PublisherDB% -i%SCRIPT_DIR%\sp_sqldiag.sql -o%FilePath_pub%\sqldiag_setup.out
if not %Errorlevel%==0 (@echo **** ERROR: Failed to set up SQLDIAG report procedure at publisher & goto error)

osql %SECLOG_D% -S%Distributor% -b -n -d%DistributionDB% -i%SCRIPT_DIR%\sp_sqldiag.sql -o%FilePath_dist%\sqldiag_setup.out
if not %Errorlevel%==0 (@echo **** ERROR: Failed to set up SQLDIAG report procedure at distributor & goto error)

osql %SECLOG_P% -S%Publisher% -d%PublisherDB% -n -b -i%SCRIPT_DIR%\traninstall.sql -o%FilePath_pub%\traninstall.out
if not %Errorlevel%==0 (@echo   **** ERROR:  Could not create transactional install procedures at publisher & goto error)

osql %SECLOG_D% -S%Distributor% -d%DistributionDB% -n -b -i%SCRIPT_DIR%\traninstall.sql -o%FilePath_dist%\traninstall.out
if not %Errorlevel%==0 (@echo   **** ERROR:  Could not create transactional install procedures at distributor & goto error)


@echo.
@echo     -------------------------------------
@echo      CREATING DISTRIBUTOR LINKED SERVER
@echo     -------------------------------------

osql %SECLOG_P% -S%Publisher% -b -n -dmaster -Q"set nocount on if exists( select srvname from sysservers where srvname = N'trandiagdistrib' ) exec sp_dropserver N'trandiagdistrib'"

osql %SECLOG_P% -S%Publisher% -b -n -dmaster -Q"set nocount on exec sp_addlinkedserver @server=N'TranDiagDistrib', @srvproduct=N'', @provider=N'SQLOLEDB', @datasrc=N'%Distributor%'"
if not %Errorlevel%==0 (@echo **** ERROR: Failed to create distributor linked server at publisher & goto error)

osql %SECLOG_P% -S%Publisher% -b -n -dmaster -Q"set nocount on exec sp_serveroption @server=N'TranDiagDistrib', @optname=N'RPC OUT', @optvalue=N'TRUE'"
if not %Errorlevel%==0 (@echo **** ERROR: Failed to set RPC OUT for publisher->distributor linked server & goto error)



@echo.
@echo     ------------------------------
@echo      GETTING VERSION INFORMATION
@echo     ------------------------------

osql %SECLOG_P% -S%Publisher% -d%PublisherDB% -n -b -Q"exec dbo.sp_getversioninfo" -ogetverpub.out
if not %Errorlevel%==0 (@echo   **** ERROR:  Could not retreive version information from publisher & goto error)

bcp %PublisherDB%..tblVersionInfo out %FilePath_pub%\tblVersionInfo_pub.bcp -S%Publisher% %SECLOG_P_BCP% -n
if not %Errorlevel%==0 goto error

osql %SECLOG_D% -S%Distributor% -n -b -d%DistributionDB% -Q"exec sp_addtocabfile @filepath = N'%FilePath_pub%\tblVersionInfo_pub.bcp', @filename = N'tblVersionInfo_pub.bcp'"
if not %Errorlevel%==0 (@echo **** Could not add publisher's version information table to CAB table & goto error)


osql %SECLOG_P% -S%Distributor% -d%DistributionDB% -n -b -Q"exec dbo.sp_getversioninfo" -ogetverdist.out
if not %Errorlevel%==0 (@echo   **** ERROR:  Could not retreive version information from distributor & goto error)

bcp %DistributionDB%..tblVersionInfo out %FilePath_dist%\tblVersionInfo_dist.bcp -S%Distributor% %SECLOG_D_BCP% -n
if not %Errorlevel%==0 goto error

osql %SECLOG_D% -S%Distributor% -n -b -d%DistributionDB% -Q"exec sp_addtocabfile @filepath = N'%FilePath_dist%\tblVersionInfo_dist.bcp', @filename = N'tblVersionInfo_dist.bcp'"
if not %Errorlevel%==0 (@echo **** Could not add distributor's version information table to CAB table & goto error)


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
	
	osql %SECLOG_D% -S%Distributor% -n -b -w4096 -d%DistributionDB% -Q"exec dbo.sp_addtranobjects_distributor @distribution_db = N'%DistributionDB%', @add_dist_tables = 0" -odist_tables.out
	if not %Errorlevel%==0 (@echo **** ERROR: Failed to add distribution database tables to output & goto error)	
	
	goto :BackupPublisher
	
	)
	
if %GetDistributionDB% EQU 0 (

	REM
	REM	We need to BCP out the necessary distribution database tables
	REM This is really everything except MSrepl_commands and MSrepl_transactions
	REM
	
	@echo.
	@echo    ----------------------------------------
	@echo     BULK COPYING DISTRIBUTOR SYSTEM TABLES
	@echo    ----------------------------------------
	@echo.
	osql %SECLOG_D% -S%Distributor% -n -b -w4096 -d%DistributionDB% -Q"exec dbo.sp_addtranobjects_distributor @distribution_db = N'%DistributionDB%', @add_dist_tables = 1" -odist_tables.out
	if not %Errorlevel%==0 (@echo **** ERROR: Failed to add distribution database tables to output & goto error)
	
	osql %SECLOG_P% -S%Distributor% -n -b -w4096 -d%DistributionDB% -Q"exec dbo.sp_exportobjects @ServerName = N'%Distributor%', @SecurityStr = N'%SECLOG_D_BCP%', @OutFilePath=N'%FilePath_Dist%', @FileSuffix=NULL, @DistribDB=N'%DistributionDB%'" -odistexport.out
	if not %Errorlevel%==0 (@echo **** ERROR: Failed to export distributor database tables & goto error)		

	)
	
:BackupPublisher

if %GetPublisherDB% EQU 1 (

	@echo.
	@echo     ------------------------------
	@echo      BACKING UP PUBLICATION DB
	@echo     ------------------------------

	osql %SECLOG_P% -S%Publisher% -n -b -d%PublisherDB% -Q"BACKUP DATABASE %PublisherDB% TO DISK = N'%FilePath_pub%\PublisherDB.bak'"
	if not %Errorlevel%==0 (@echo **** ERROR: Failed to back up publisher database & goto error)
	
	osql %SECLOG_D% -S%Distributor% -n -b -d%DistributionDB% -Q"exec sp_addtocabfile @filepath = N'%FilePath_pub%\PublisherDB.bak', @filename=N'PublisherDB.bak'"
	if not %Errorlevel%==0 (@echo **** ERROR: Could not add publication database to CAB table & goto error)	
	
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

@echo.
@echo     --------------------------------------
@echo      GENERATING REPLICATION SCRIPTS
@echo     --------------------------------------

@echo %EXE_DIR%\scriptrepl -S%Distributor% -D%PublisherDB% -N%Publication% %SECLOG_SCRIPT% -o%cd%
%EXE_DIR%\scriptrepl -S%Distributor% -D%PublisherDB% -N%Publication% %SECLOG_SCRIPT% -o%cd%
if not %Errorlevel%==0 (@echo **** ERROR:  Could not generate replication scripts & goto error)

osql %SECLOG_D% -S%Distributor% -n -b -d%DistributionDB% -Q"exec sp_addtocabfile @filepath = N'%cd%\replscript.sql', @filename=N'replscript.sql'"	
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
@echo %EXE_DIR%\dumpel.exe -f %cd%\%Publisher%_evt_sys.txt -l system -c -s \\%Publisher%
%EXE_DIR%\dumpel.exe -f %cd%\%Publisher%_evt_sys.txt -l system -c -s \\%Publisher%

osql %SECLOG_D% -S%Distributor% -n -b -d%DistributionDB% -Q"exec sp_addtocabfile @filepath = N'%cd%\%Publisher%_evt_sys.txt', @filename=N'%Publisher%_evt_sys.txt'"
if not %Errorlevel%==0 (@echo **** ERROR: Could not add Publisher system event log to CAB table & goto error)

@echo.
@echo RETRIEVING APPLICATION EVENT LOG...
@echo %EXE_DIR%\dumpel.exe -f %cd%\%Publisher%_evt_app.txt -l application -c -s \\%Publisher%
%EXE_DIR%\dumpel.exe -f %cd%\%Publisher%_evt_app.txt -l application -c -s \\%Publisher%

osql %SECLOG_D% -S%Distributor% -n -b -d%DistributionDB% -Q"exec sp_addtocabfile @filepath = N'%cd%\%Publisher%_evt_app.txt', @filename=N'%Publisher%_evt_app.txt'"
if not %Errorlevel%==0 (@echo **** ERROR: Could not add Publisher application event log to CAB table & goto error)

if "%Publisher%"=="%Distributor%" (@echo **** Skipping Distributor SQLDIAG and Event Logs (it is the same server as the Publisher) & goto GetLogInfo)

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
@echo %EXE_DIR%\dumpel.exe -f %cd%\%Distributor%_evt_sys.txt -l system -c -s \\%Distributor%
%EXE_DIR%\dumpel.exe -f %cd%\%Publisher%_evt_sys.txt -l system -c -s \\%Distributor%

osql %SECLOG_D% -S%Distributor% -n -b -d%DistributionDB% -Q"exec sp_addtocabfile @filepath = N'%cd%\%Distributor%_evt_sys.txt', @filename=N'%Distributor%_evt_sys.txt'"
if not %Errorlevel%==0 (@echo **** ERROR: Could not add Distributor system event log to CAB table & goto error)

@echo.
@echo RETRIEVING APPLICATION EVENT LOG...
@echo %EXE_DIR%\dumpel.exe -f %cd%\%Distributor%_evt_app.txt -l application -c -s \\%Distributor%
%EXE_DIR%\dumpel.exe -f %cd%\%Distributor%_evt_app.txt -l application -c -s \\%Distributor%

osql %SECLOG_D% -S%Distributor% -n -b -d%DistributionDB% -Q"exec sp_addtocabfile @filepath = N'%cd%\%Distributor%_evt_app.txt', @filename=N'%Distributor%_evt_app.txt'"
if not %Errorlevel%==0 (@echo **** ERROR: Could not add Distributor application event log to CAB table & goto error)

GetLogInfo:

if %GetLogInfo% EQU 1 (

	osql %SECLOG_P% -S%Publisher% -d%PublisherDB% -Q"exec dbo.sp_getdbtable" -odbtable.out
	if not %Errorlevel%==0 (@echo   **** ERROR:  Could not get DBTABLE information from publisher & goto error)
	
	osql %SECLOG_P% -S%Publisher% -d%PublisherDB% -Q"insert into dbo.tblReplCounters exec dbo.sp_replcounters" -oreplcntrs.out
	if not %Errorlevel%==0 (@echo   **** ERROR:  Could not get sp_replcounters information from publisher & goto error)

	osql %SECLOG_P% -S%Publisher% -d%PublisherDB% -Q"exec dbo.sp_getrepltrans" -ogetrepltrans.out
	if not %Errorlevel%==0 (@echo   **** ERROR:  Could not get sp_repltrans information from publisher & goto error)
	
	@echo.
	@echo     -------------------------------------
	@echo      BULK COPYING DBCC DBTABLE OUTPUT
	@echo     -------------------------------------
	@echo.
	
	bcp %PublisherDB%..tblDBTABLE out tbldbtable.bcp -S%Publisher% %SECLOG_P_BCP% -n
	if not %Errorlevel%==0 goto error

	osql %SECLOG_D% -S%Distributor% -n -b -d%DistributionDB% -Q"exec sp_addtocabfile @filepath = N'%cd%\tbldbtable.bcp', @filename=N'tbldbtable.bcp'"
	if not %Errorlevel%==0 (@echo **** ERROR: Could not add DBCC DBTABLE output to CAB table & goto error)


	@echo.
	@echo    -------------------------------------
	@echo     BULK COPYING REPLCOUNTERS OUTPUT
	@echo    -------------------------------------
	@echo.
	
	bcp %PublisherDB%..tblReplCounters out tblreplcounters.bcp -S%Publisher% %SECLOG_P_BCP% -n
	if not %Errorlevel%==0 goto error

	osql %SECLOG_D% -S%Distributor% -n -b -d%DistributionDB% -Q"exec sp_addtocabfile @filepath = N'%cd%\tblreplcounters.bcp', @filename=N'tblreplcounters.bcp'"
	if not %Errorlevel%==0 (@echo **** ERROR: Could not add [sp_replcounters] output to CAB table & goto error)
	
	@echo.
	@echo    -------------------------------------
	@echo     BULK COPYING REPLTRANS OUTPUT
	@echo    -------------------------------------
	@echo.
	
	bcp %PublisherDB%..tblReplTrans out tblReplTrans.bcp -S%Publisher% %SECLOG_P_BCP% -n
	if not %Errorlevel%==0 goto error

	osql %SECLOG_D% -S%Distributor% -n -b -d%DistributionDB% -Q"exec sp_addtocabfile @filepath = N'%cd%\tblReplTrans.bcp', @filename=N'tblrepltrans.bcp'"
	if not %Errorlevel%==0 (@echo **** ERROR: Could not add [tblReplTrans] output to CAB table & goto error)	
	
	)

@echo.
@echo    -------------------------------------
@echo     BULK COPYING PUBLISHER TABLES
@echo    -------------------------------------
@echo.
osql %SECLOG_P% -S%Publisher% -n -b -w4096 -d%PublisherDB% -Q"exec dbo.sp_addtranobjects_publisher @publisher_db = N'%PublisherDB%'" -opub_tables.out
if not %Errorlevel%==0 (@echo **** ERROR: Failed to add publisher database tables to output & goto error)

osql %SECLOG_P% -S%Publisher% -n -b -w4096 -d%PublisherDB% -Q"exec dbo.sp_exportobjects @ServerName = N'%Publisher%', @SecurityStr = N'%SECLOG_P_BCP%', @OutFilePath=N'%FilePath_Pub%', @FileSuffix=NULL, @DistribDB=N'%DistributionDB%'" -opubexport.out
if not %Errorlevel%==0 (@echo **** ERROR: Failed to export publisher database tables & goto error)

@echo.
@echo    -------------------------------------
@echo     GATHERING AGENT PROFILE INFORMATION
@echo    -------------------------------------
@echo.
osql %SECLOG_D% -S%Distributor% -n -b -w4096 -d%DistributionDB% -Q"exec dbo.sp_agent_profiles @agent_type = N'TRAN'" -o%cd%\agent_profiles.txt
if not %Errorlevel%==0 (@echo **** ERROR: Failed to gather agent profile information & goto error)

osql %SECLOG_D% -S%Distributor% -n -b -d%DistributionDB% -Q"exec sp_addtocabfile @filepath = N'%cd%\agent_profiles.txt', @filename=N'agent_profiles.txt'"
if not %Errorlevel%==0 (@echo **** ERROR: Could not add agent profile output to CAB table & goto error)	


@echo.
@echo    ---------------------------------------
@echo     ANALYZING ARTICLE INDEXES
@echo    ---------------------------------------
@echo.

osql %SECLOG_P% -S%Publisher% -n -b -w4096 -d%PublisherDB% -Q"exec sp_articleindexes N'TRAN'" -o%filepath_pub%\article_ndxs.txt
if not %Errorlevel%==0 (@echo **** ERROR: Could not execute article index analysis proc at subscriber & goto error)

osql %SECLOG_D% -S%Distributor% -n -b -d%DistributionDB% -Q"exec sp_addtocabfile @filepath = N'%filepath_pub%\article_ndxs.txt', @filename=N'article_ndxs_pub.txt'"
if not %Errorlevel%==0 (@echo **** ERROR: Could not add index analysis to CAB table & goto error)

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

osql %SECLOG_D% -S%Distributor% -n -b -d%DistributionDB% -Q"set nocount on select left([FileName], 35) 'Adding files to cabinet' from tblCabFiles order by [FileID]"

osql %SECLOG_D% -S%Distributor% -n -b -d%DistributionDB% -Q"exec sp_gencabfile @filepath = N'%cd%\trandiag.cab'" -ogencab.out
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

@echo.
@echo.

osql %SECLOG_P% -S%Distributor% -n -b -Q"set nocount on select getdate() as 'Data Gather End Time'"
if not %Errorlevel%==0 (goto Error)


GOTO :endnow

:DeleteOldTraceFiles
osql %SECLOG_P% -S%Publisher% -n -b -otemp.out -Q"exec master.dbo.xp_cmdshell 'if not exist %FilePath_pub% MD %FilePath_pub%' "
if not %Errorlevel%==0 (@echo   **** ERROR:  Failed to Make Destination Folder at PUBLISHER & goto error)

osql %SECLOG_P% -S%Publisher% -n -b -otemp.out -Q"exec master.dbo.xp_cmdshell 'if exist %FilePath_pub%\*.bak del %FilePath_pub%\*.bak' "
if not %Errorlevel%==0 (@echo   **** ERROR:  Failed to Delete Files at Destination Folder at PUBLISHER & goto error)

osql %SECLOG_D% -S%Distributor% -n -b -otemp.out -Q"exec master.dbo.xp_cmdshell 'if not exist %FilePath_dist% MD %FilePath_dist%' "
if not %Errorlevel%==0 (@echo   **** ERROR:  Failed to Make Destination Folder at DISTRIBUTOR & goto error)

osql %SECLOG_D% -S%Distributor% -n -b -otemp.out -Q"exec master.dbo.xp_cmdshell 'if exist %FilePath_dist%\*.bak del %FilePath_dist%\*.bak' "
if not %Errorlevel%==0 (@echo   **** ERROR:  Failed to Delete Files at Destination Folder at DISTRIBUTOR & goto error)

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

