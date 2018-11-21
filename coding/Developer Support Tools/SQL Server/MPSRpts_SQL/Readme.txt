Microsoft Product Support Reporting Tool version 8.1 for SQL Server, last updated 4/15/03
===============================================================================================

PURPOSE:
========
The MPS Reporting Tool is utilized to gather detailed information regarding a systems current
configuration. The data collected will assist the Microsoft Support Professional with fault isolation. 

The reporting tool DOES NOT make any registry changes or modifications to the operating system.
Please see the section for PACKAGE CONTENTS and DIRECTORY STRUCTURE for details on what is copied
to the system and what directories are made.  Please consult the Microsoft Support Professional that 
you are working with to determine if they want you to run MPS Reporting Tool on all nodes in the Cluster.

USAGE:
======
This package supports Windows XP, Windows NT 4.0, Windows 2000, and Windows 2003. On execution of the package the
product type is detected to determine which commands will be utilized to collect information.

This version supports both standard servers and Server Clusters.

Please logon to the system with the SQL server service account before executing the tool, 
failure to do so can result in having to re-execute the tool under that context.

NOTES:
======
Average completion times for the MPS Reporting Tool are in the range of 5 to 20 minutes. Including the LDIFDE 
servicePrincipleName search can extend the process running time dependent on domain size. If for some reason 
the data collection process is not completing try running the tool during non-peak usage times. 

Some common areas that prevent data collection to complete or take an excessive amount of time:

1. A corrupted Event Log can hang DUMPEL.EXE.
2. Very large event logs can take a long time to dump. The Security log can become very large if Auditing is enabled.
3. Many of the utilities require that RPC (Remote Procedure Call) be operating at some capacity.
4. Disk/Controller problems can prevent inventory of various files hanging or slowing down the process.
5. If Quick Edit is enabled, if you select any text in the "Command" Windows it will effectively pause the MPS 
Reports.  Press the "ESC" key to exit out and let the MPS Reports continue

Utilize the %ComputerName%_PROGRESS.TXT file to determine which process is not completing. Correcting any
issue that prevents the MPS Reports from completing in some cases resolves the issue that prompted the need 
for the utility to be run. 

It is required that the currently logged on user have Administrative rights in order to allow for proper
operations of the MPS Reporting Tool.

If you have any questions regarding the usage or operations of the MPS Reporting Tool consult with the
Microsoft Support Professional you are working with.

PACKAGE CONTENTS:
=================
2000.cmd		- Contains all commands to run if machine is running Windows 2000. 
adsutil.vbs		- IIS administrative script normally found in the %drive%:Inetpub\AdminScripts folder.
CHECKSYM.EXE		- Utility that gathers version and symbol information from executable files
Checksym.txt 		- Readme file for CHECKSYM.EXE.
Checksym_EULA.RTF	- EULA for Checksym.exe.
CHOICE.EXE   		- Resource Kit utility.
CLUSMPS.EXE  		- Utility to capture Cluster specific information.
DBGHELP.DLL  		- Support file for CHECKSYM.EXE
Diskinfo.exe 		- Disk Information Utility.
DISKMAP.EXE  		- Disk Information Utility.
DMDiag.exe   		- Disk Information Utility.
DOSDEV.EXE   		- Utility to capture Drive Letter to Device mapping.
Dotnet_Dcdiag.exe	- Dcdiag.exe renamed for OS version, performs Domain Controller Diagnostics
Dotnet_Netdiag.exe	- Netdiag.exe renamed for OS version, performs Network Diagnostics
Drvman.exe   		- Utility that gathers Printer Driver information.
DUMPEL.EXE   		- Utility to dump the event logs in TXT format.
DumpEVT.exe  		- Utility to dump the event logs in EVT format.
EULA.TXT     		- End-User License Agreement for this tool.
Finish.cmd   		- Contains all commands necessary to build the cab file.
FltrFind.exe		- Utility that gathers information about upper and lower filters installed on a machine.
FTDMPNT.EXE  		- Utility that dumps out Disk Information such as disk signature.
GETVER.EXE   		- Utility used to determine version of Windows NT running.
GPRESULT.EXE 		- Resource Kit utility to dump the Group Policies on this box.
Htdump.exe		- Utility that detects whether a processor is HyperThreading capable.
Kerbcheck.cmd		- Genereates Kerberos specific information.
LDIFDE.EXE   		- Domain Controller Directory Exchange tool.
LDIFDE_Decoding.txt	- Expalins how to decode ldifde reports to discover server delegation.
MAKECAB.EXE  		- Utility to package reports.
MPSRpt.cmd   		- Command script used to create all the reports.
MSDBI60.DLL  		- Support file for CHECKSYM.EXE.
MSVCRT.DLL   		- Support file for CHECKSYM.EXE.  		
Net.cmd	     		- Contains all commands to run if machine is running Widnows Server 2003.
Netxp.exe		- Network Diagnostics for Windows XP, 2003
NT4.cmd      		- Contains all commands to run if machine is running Windows NT 4.
OEMINBOX.EXE 		- Resource Kit utility to dump all of the printer information.
PnpEnum.exe  		- Utility that gathers information in the Enum key in the registry.
PSAPI.DLL    		- Support file for CHECKSYM.EXE.
PSTAT40.EXE  		- Resource Kit utility to dump running processes and device drivers 4.0.
PSTAT50.EXE  		- Resource Kit utility to dump running processes and device drivers 2000.
QFECHECK.EXE 		- Resource Kit utility to dump out a list of installed hotfixes (Windows 2000 only).
README.TXT   		- This file.
REG.EXE      		- Resource Kit utility to dump registry values.
SaveLogBottom.exe	- Utility that saves the bottom few logs in a Dr. Watson log.
SECINSPECT.EXE  	- Disk Information Utility.
SQL.cmd    		- Generates SQL Specific Reports.
SQL.TXT      		- Additional information on what to do with this information plus additional requests.
Tapedrive.vbs		- Utility that will tell us all about the Tape Drive on the machine.
UnsgnDrv.exe 		- Utility that gathers signed and unsigned drivers on the machine.
W2K_Dcdiag.exe		- Dcdiag.exe renamed for OS version, performs Domain Controller Diagnostics
W2K_Netdiag.exe		- Netdiag.exe renamed for OS version, performs Network Diagnostics
XP.cmd       		- Contains all commands to run if machine is running Windows XP.


DIRECTORY STRUCTURE:
====================
%SystemRoot%\MPSReports---|
			  |-- SQLServer --|	
                                          |-- Bin
                                          |-- Report --|
                                                       |-- Cab 
                                                       |-- SQLSpecific


ADDITIONAL INFORMATION:
=======================
Two .CAB files will be generated for your convenience in the 
%systemroot%\MPSReports\Cluster\Report\Cab directory called 
%Computername%_MPSReports.CAB an %Computername%_SQL.CAB. The CAB file will contain the reports generated by
the MPS Reporting Tool. Please send the cab file to the Microsoft Support Professional
who is working on your support incident.

WHAT IS COLLECTED on my system?
===============================
The scripts create a variety of reports in the %SYSTEMROOT%\MPSReports\Report and Report\SQLSpecifc directories.

%ComputerName%_BOOT_INI.TXT			Copy of the BOOT.INI for the system
%ComputerName%_CLUSTER.LOG			Copy of the Cluster Log
%ComputerName%_CLUSTER.OML.TXT			Copy of the Cluster.OML file from the Cluster Folder.  Windows 2003 only
%Computername%_CLUSTER_BAK.LOG			Copy of the Cluster.Log.Bak if created
%ComputerName%_CLUSTER_CHKDSK.LOG		Copy of the ChkDsk.Log files from the Cluster Folder
%ComputerName%_CLUSTER_CLCFGSRV			Copy of the Cluster Configuration Log. Windows 2003 only
%ComputerName%_CLUSTER_DIR.CSV			List the contents of the Cluster Folder to capture version information
%ComputerName%_CLUSTER_DIR.TXT			List the contents of the Cluster Folder to capture version information
%ComputerName%_CLUSTER_MPS_INFORMATION.TXT	Information on the cluster such resource types, priority,and dependencies
%ComputerName%_CLUSTER_PROPERTIES.TXT		List of Private Properties of Resources
%ComputerName%_CLUSTER_REGISTRY.HIV		Copy of the Cluster Registry
%ComputerName%_CLUSTER_RESOURCES.TXT		List of Cluster Resources and state
%ComputerName%_Comsetup.log			Copy of Com+ Setup log file.
%Computername%_CurrentControlSet.HIV		Copy of the CurrentControlSet registry hive.
%Computername%_CURRENTVERSION_MDAC_REG.TXT	Current MDAC registration.
%ComputerName%_DBerr.txt (removed)		Copy of the SP Catalog logging file.
%ComputerName%_DCDIAG.TXT			Domain Controiller Diagnostics Information
%Computername%_DEFAULT_INST_SQLDIAG.txt		SQL Server 2000 Diagnostics tool results for a default instance.
%ComputerName%_DISK_INFORMATION.TXT (removed)	Drive Letter to physical disk mapping
%ComputerName%_DISK_INFORMATION.TXT (removed)	Saves out information on Disk in the System.
%ComputerName%_Diskinfo.txt (removed) 		Low level look at MBR, PBS, and MFT.
%ComputerName%_Diskmap.txt (removed)		Low level look at MBR, and PBS.
%ComputerName%_DMDiag.log (removed)  		Dynamic Disk Log.
%COMPUTERNAME%_DNS.log				DNS Debug logs
%ComputerName%_DOSDevices.txt	  		Hardware PCI Information.
%ComputerName%_DriverQuery.txt	  		Tells If the installed Drivers are signed or not.
%ComputerName%_Drivers.csv	  		Comma Seperated file of a checksym of the drivers.
%ComputerName%_DRIVERS.TXT [.CSV]		Output of the %SystemRoot%\System32\Drivers directory.
%ComputerName%_Drvman.txt	  		Output of Drvman.exe for printer driver information installed.
%ComputerName%_DrWatson.log	  		Bottom few logs from the Dr. Watson log file.
%ComputerName%_EVENT_LOG_application.txt [.EVT]	Output of the Application Event Log.
%ComputerName%_EVENT_LOG_security.txt [.EVT]	Output of the Security Event Log.
%ComputerName%_EVENT_LOG_system.txt [.EVT]	Output of the System Event Log.
%ComputerName%_Filters.txt (removed)		List of the Upper and Lower filters installed.	
%ComputerName%_FTDMPNT.txt (removed)  		Diskprobe look of MBR and PBS of each drive.
%ComputerName%_GPResult.txt	  		Log from a run of the GP result command to tell which policies were applied to the machine.
%ComputerName%_HCUpdate.log (removed)  		Hardware Compatibility Update Log.
%ComputerName%_HOTFIX.TXT			A simple directory listing of directory names for installed hotfixes
%Computername%_HOTFIXREG.TXT			Listing of the HOTFIX Key from the registry
%ComputerName%_HyperThread.txt (removed)	File that Tells If the processors in the machine are HyperThreading capable.
%ComputerName%_IIS*.log	  			IIS log file for whichever version is installed on the machine.
%ComputerName%_Internet_Settings_Key.txt	Registry entries for the Internet Settings information provided through IE.
%Computername%_LDIFDE.TXT			LDIFDE Active Directory reporting of SPN name, SAMAccountName and servicePrincipleName (last variable only reported if a domain administrator is the login executing the tool)
%Computername%_MDAC_ADO_DLL.TXT [.CSV}		MDAC ADO DLL listing
%Computername%_MDAC_CurrentControlSet.TXT	MDAC text listing of CurrentControlSet
%Computername%_MDAC_DASETUP.TXT			MDAC dasetup log
%Computername%_MDAC_DAHOTFIX.TXT		MDAC hotfix listing
%Computername%_MDAC_ExceptionComponents.TXT	MDAC listing of the MDAC exception components
%Computername%_MDAC_MSADC_DLL.TXT [.CSV}	MDAC DLL listing
%Computername%_MDAC_OLEDB_DLL.TXT [.CSV]	MDAC OLEDB DLL listing
%Computername%_MDAC_GAC_SYSTEM_DATA.TXT		MDAC GAC system data
%Computername%_MDAC_GAC_SYSTEM_XML.TXT		MDAC GAC system XML data
%Computername%_Microsoft.HIV			Copy of the current Microsoft registry hive
%ComputerName%_MISC.txt				Copy of Environment variables, shares, and other MISC information
%ComputerName%_MountedDevices.txt (removed)  	Copy of the Mounted Devices Key from the registry.
%ComputerName%_MSINFO.nfo			Windows 2000 and Windows 2003 
%Computername%_ORACLE_MDAC_REG.TXT		Oracle MDAC registration
%ComputerName%_Net.txt	  			Networking information file.
%COMPUTERNAME%_NETDIAG.TXT			Network Diagnostics, currently disabled by default. To use remove rem statements
%ComputerName%_NetSetup.log	  		Log of events when joining a domain.
%ComputerName%_NI.txt				Output of various components for Network related information
%Computername%_NLB_INFORMATION.txt		Output from WLBS /display
%ComputerName%_NTAuthenticationProviders.TXT	Listing of the IIS server NT Authentication methods
%ComputerName%_NtBtLog.txt	  		If boot logging enabled this is the log file for it.
%ComputerName%_Ocgen.log (removed)
%ComputerName%_OLEDB_DLL.TXT [.CSV]		Output of the \program files\common files\system\ole db for all .dll files.
%ComputerName%_PNPEnum.txt (removed)  		file that lists all the PNP Devices and their GUIDS.
%ComputerName%_Print.txt (removed)  		Registry of Print Keys.
%ComputerName%_PrintDrivers.txt(removed)	List of all printer Drivers installed and versions.
%ComputerName%_Printkey.txt(removed)  		Registry of Print Keys.
%ComputerName%_PROCESS.TXT [.CSV]		Output of the currently running processes on the system.
%ComputerName%_PROGRESS.TXT			MPS Reporting Progress log.
%ComputerName%_PSTAT.TXT			Output of a list of processes and active device drivers.
%Computername%_QPROCESS.TXT			Output for Terminal Server processes. Windows 2000/.NET only.
%Computername%_QUSER.TXT			Output for Terminal Server current users. Windows 2000/.NET only.
%Computername%_QWINSTA.TXT			Output for Terminal Server Win Station Information. Windows 2000/.NET only.
%ComputerName%_RECOVERY.TXT (removed)		HKLM\System\CurrentControlSet\Control\CrashControl(see %Computername%_CurrentControlSet.HIV)
%Computername%_Running_Services.txt		List of currently running services
%ComputerName%_Schdlgu.txt	  		Task Scheduler tasks.
%ComputerName%_SCHED.csv			Output from the scheduler command AT.EXE 
%ComputerName%_SCHEDLGU.TXT			Scheduled Task Log Windows 2000 and Windows 2003
%ComputerName%_SESSIONMANAGER.HIV (removed)	HKLM\System\CurrentControlSet\Control\Session Manager (see %Computername%_CurrentControlSet.HIV)
%ComputerName%_Setup.log	  		Current SQL Server Setup.log on the machine in the config directory.
%ComputerName%_SetupAct.log (removed)  		Setup Activity Log.
%ComputerName%_SetupApi.log	  		Setup log file.
%ComputerName%_SetupErr.log	  		Setup Error log file.
%ComputerName%_SetupLog.txt (removed)  		Setup log file.
%ComputerName%_Spool.txt (removed)  		Text file of printer Drivers installed.
%Computername%_SQLCLSTR.TXT			SQL Server cluster setup log.
%Computername%_SQL_COM_BINN.TXT [.CSV]		File listing and versioning of the common SQL Server directory
%Computername%_SQL_DEFAULT_BINN.TXT [.CSV]	Output of the C:\Program Files\Microsoft SQL Server\MSSQL\Binn directory version and symbol information from executable files
%Computername%_SQL_Servers.txt			Registry reported InstalledInstances
%Computername%_SQLSP.TXT [SP#.TXT]		SQL Server service pack setup log, up to the last 5 logs included.
%Computername%_SQLSTP.TXT [STP#.TXT		SQL Server setup log, up to the last 10 logs included.
%ComputerName%_SYSTEM32_DLL.TXT [.CSV]		Output of the Windows NT System32 directory for all .DLL files.
%ComputerName%_SYSTEM32_EXE.TXT [.CSV]		Output of the Windows NT System32 directory for all .EXE files.
%ComputerName%_TapeDrive.txt	  		Output of TapeDrive.vbs with Tape Drive Information.
%ComputerName%_Tsoc.log	  			TS log file.
%ComputerName%_Uninstall.txt (removed) 		Registry information for installed applications.
%ComputerName%_Upgrade.txt (removed)  		Log of upgrade progress.
%ComputerName%_Vminst.log	  		Log from Virtual machine installation.
%ComputerName%_Wiadebug.log (removed)  		Windows Imaging Log.
%ComputerName%_Wiaservc.log (removed)  		Windows Imaging Service Log.
%ComputerName%_WindowsUpdate.log	  	Log file created by Windows Update Service.
%ComputerName%_Winmsd.nfo	  		NFO format of Winmsd.
%ComputerName%_winmsd.TXT			Windows NT 4.0
%ComputerName%_Winnt32.log	  		Log of events when Winnt32 was run.
%ComputerName%_Wsdu.log	  			Windows Update log file.
%USERNAME%_%ComputerName%_LDIFDE.TXT		LDIFDE report for current user
DOMAINWIDE_LDIFDE_for_%USERDOMAIN%.TXT		LDIFDE report for entire domain

HISTORY:
========

Version    Changes
-------    ---------------------------------------------------------------
  8.1	   - Fixed error causing event log gathering to fail, removed several reports (25) as noted above, 
             removed extra registry hive reports which is already gathered in the Microsoft and 
             CurrentControlSet hives, added timer to Kerberos report menu defaulting to not run
             reports after 5 seconds. Added Netdiag and DCDiag reporting
             Updated file versioning properties on installation executable.
  8.0	   - Added Kerberos/SSPI information gathering, File version and symbol information for default instance, 
	     version and symbol information for QL Server 8.0 COM folder, SQLDIAG for default instance and support
	     for the following operating systems, NT4, Windows XP, Windows 2000, Windows 2003.
	     Directory structure changed to provide SQL folder instead of using cluster folder as was previously done.
  7.0      - No longer have FULL/LITE versions, only run a single version.  GETTYPE.EXE is no 
             longer used detect version information, simply look at a VER output.  Added CLUSMPS
             to gather Cluster information.  Added DOSDEV to capture additional Disk information.
             Capture CHKDSK logs that Cluster Service generates in a more readable manner.  Removed
             unneeded and duplicate information. Contains all information gathered by MDAC MPS 
             Reporting Tool
  6.0f     - Enhanced MDAC gathering capability with addition of Oracle information gathering
  6.0e     - Added MDAC gathering capability
  6.0d     - Changed tools behavior so that only previously generated MPS Reports are deleted on re-execution of the tool
           - Modified where to start copying the SQL query and requested SAN configuration information   
  6.0c     - Added HKLM\Software\ODBC as requested.
  6.0b     - Modified cmd files so that only the 0-MPSRpt.cmd and 5- commands have to be updated
             if the base MPSRPT_@001_Cluster.EXE is updated. 
           - Changed name to reflect new year and version
           - Added SAN configuration confirmation request to COMPLETE.TXT
  6.0a     - Added date sorted %systemroot% *.log listing in the SQL cab file
           - Increased number of sqlsp logs collected from 0-5 to 0-9
           - Added request for Compaq Survey level 3 reports to the complete.txt
  6.0	   - Modified event log formatting
           - Brought version in line with MPSRPTS_2001_CLUSTER.EXE
           - Modified SQL query to place SP_CONFIGURE at the top of the report
  3.0      - Revised based on the MPSRPTS_2001_CLUSTER.EXE version 6.0.
             Detects previous copy of MPS Reports and prompts to delete, also removes previous SQL reporting structure. 
             Integrated version numbering into executable for easy version distinction.
  	     Separate CAB files for Cluster ( %ComputerName%_MPSReports_Cluster.CAB ) and 
	     SQL ( %ComputerName%_SQL.CAB ) to keep size and purpose isolated.
	     Returned to the original directory structure, SQL Server specific information now gathered
             in SQL Folder under %SystemRoot%\MPSReports\Cluster.
	     netstat now ran per OS and includes -o parameter for .Net servers to return PID information.
	     %ComputerName%-MISC.txt now includes listing of localgroup administrators.
  2.0b     - Modified Network gathering to include both "netstat -a" and "netstat -an"Version Changes.
  2.0a     - Added SQL Service Pack log gathering.
  2.0	   - Changed location from %SystemRoot%\MPSReports\Cluster to %SystemRoot%\MPSReports\SQL
             Renamed from MPSRPTS_2000_SQL_CLUSTER.EXE to MPSRPTS_2000_SQL.EXE.
  1.0      - Initial version, based on version 5.0 of the Cluster MPS reporting tool.
