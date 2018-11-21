=========
CHECKSYM
========

OVERVIEW
--------
Checksym is a symbol checking facility that allows an individual to verify that they 
have correct symbols (DBG, DBG/PDB, and PDB files) for processes and files on their 
system, and to assist them in location of files that don't match.  This can be 
useful in anticipation of having to debug a local or remote process.  

In addition, Checksym offers support for situations where a person (PSS engineer) 
will need to perform a debug of a customer's environment, or analyze a user.dmp 
file produced in a customer environment.  In this situation, you need symbols 
that will match those that would be necessary for the remote environment.  
Checksym was written to aid both of these situations.

FEATURES
--------
* Runs on Windows NT 4.0, Windows 2000, Windows XP
* Support for verifying symbols for VC7/VS.NET
* Support for verifying symbols for PE64 binaries
* Interogates running process(es) for all modules loaded
* Interogates files on a specified path (with optional recursion)
* Interogates files in a DMP file (kernel, user, mini-dumps)
* Can obtain version info for all files interogated
* Can obtain symbol information necessary for symbol verification
* Can output to a CSV file (which can later be read in - useful for remote
  debug scenarios)

==========================
INSTALLATION INSTRUCTIONS
==========================
Best method:
- Install the Debugger package from http://dbg (internally), or
  http://www.microsoft.com/ddk/debugging (externally)
- Copy CHECKSYM.EXE and MSDIA20.DLL to the same directory

Alternate method (stand-alone utility)
- Create an installation directory
- Copy CHECKSYM.EXE into the installation directory
- Copy DBGHELP.DLL, DBGENG.DLL, SYMSRV.DLL and MSDIA20.DLL into your installation directory
- Windows NT 4.0 ONLY - Copy PSAPI.DLL into the installation directory

==========================
HELP INFORMATION
==========================

CheckSym.exe -???   (Output Follows)

*******************************************************************************
CHECKSYM V2.2.7 - Symbol Verification Program            - gregwi@microsoft.com
*******************************************************************************

This version is supported for Windows NT 4.0, Windows 2000 and Windows XP

DESCRIPTION:

This program can be used to verify that you have proper symbol files
(*.DBG and/or *.PDB) on your system for the processes you have running, and
for symbol files on your filesystem.  This program can also be used to
collect information regarding these modules and output this to a file.
The output file can then be given to another party (Microsoft Product
Support Services) where they can use the file to verify that they have
proper symbols for debugging your environment.

Obtaining online help:

CHECKSYM -?      : Simple help usage
CHECKSYM -???    : Complete help usage (this screen)

Usage:

CHECKSYM [COLLECTION OPTIONS] [INFORMATION CHECKING OPTIONS] [OUTPUT OPTIONS]

***** COLLECTION OPTIONS *****

At least one collection option must be specified.  The following options are
currently supported.

   -P <Argument> : Collect Information From Running Processes

                   When used in conjunction with -O the output file will
                   contain information about your running system.  This
                   operation should not interfere with the operation of
                   running processes.

                   <Argument> = [ * | Process ID (pid) | Process Name ]

                   Multiple arguments can be combined together to query
                   multiple PIDs or processes.  Separate each argument with
                   a semi-colon.

                   For example,

                   -P 123;234;NOTEPAD.EXE;CMD.EXE

                   would return only these four process matches.

                   To query all running processes, specify the wildcard
                   character '*'.  To specify a specific process, you can
                   provide the Process ID (as a decimal value), or the Process
                   Name (eg. notepad.exe).  If you use the Process Name as the
                   argument, and multiple instances of that process are
                   running they will all be inspected.

              -D : Collect Information from Running Device Drivers

                   This option will obtain information for all device drivers
                   (*.SYS files) running on the current system.

-F[<blank>|1|2] <File/Dir Path>: Collect Information From File System

                   This option will allow you to obtain module information
                   for modules on the specified path.  Multiple paths may be
                   provided, separated by semicolons.  This input method is
                   useful for situations where the module(s) is not loaded by
                   an active process.  (Eg. Perhaps a process is unable to start
                   or perhaps you simply want to collect information.)
                   about files from a particular directory location.)

                   -F or -F1 : (Default) A file or directory may be provided.  If
                               a file is specified, it is evaluted.  If a directory
                               is provided then the files matching any provided wild-
                               cards are searched.

                   -F2       : Same as -F except recursion will be used.

                   PSEUDO-ENVIRONMENT VARIABLES

                   Checksym supports environment variables used where ever paths
                   are provided (i.e. %systemroot% is a valid environment variable).
                   Checksym also supports a limited set of "pseudo-environment"
                   variables which you can provide in an location a normal environment
                   variable is allowed.  These pseudo-environment variables expand
                   into the appropriate installation directory for the product they
                   are associated with.

                   Here are all the pseudo-environment variables currently supported:

                   %EXCHSRVR%   = Microsoft Exchange Server
                   %IE% = Microsoft Internet Explorer
                   %INETSRV%    = Microsoft Internet Information Services
                   %OFFICE2000% = Microsoft Office 2000
                   %OFFICEXP%   = Microsoft Office XP
                   %SMSSERVER%  = Microsoft SMS Server
                   %SNASERVER%  = Microsoft SNA Server
                   %SQLSERVER%  = Microsoft SQL Server
                   %WSPSRV%     = Microsoft Winsock Proxy Server

                   In addition to the above listed pseudo-environment variables, checksym
                   can be instructed to query registry values to determine a path.  Just
                   enclose a registry value path within % symbols and checksym will "expand"
                   the registry value.  Here are example usages:

                   %HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Money\10.0\MoneyPath%
                   %HKLM\SOFTWARE\Microsoft\Money\10.0\MoneyPath%

  -I <File Path> : Collect Information from a Saved Checksym Generated CSV File

                   This input method is useful when you want to evaluate
                   whether you have proper symbols for modules on a different
                   system.  Most commonly this is useful for preparing to do a
                   remote debug of a remote system.  The use of -I prohibits
                   the use of other collection options.

  -Z <File Path> : Collect Information from a DMP File

                   This input method is useful when you have a DMP file and
                   to ensure that you have matching symbols for it.  Checksym
                   tries to determine as much information as possible to
                   in finding good symbols.  If a module name can not be
                   determined (mostly with modules that only use PDB files),
                   the module will be listed as "IMAGE<Virtual Address>".

   -MATCH <Text> : Collect Modules that match text only

                   This option allows you to restrict searching/collection to
                   include only those modules that match the provided text.

***** INFORMATION CHECKING OPTIONS *****

              -S : Collect/Display Symbol Information From Modules

                   This option is used to indicate that symbol information
                   should be collected and displayed from every module analyzed.
                   In order to verify proper symbols, symbol information must
                   be gathered.  It is possible to collect symbol information
                   without verifying it.  This case is usually used with the -O
                   option to produce a saved CheckSym generated CSV file.
                   Omitting -S and -V could direct CheckSym to collect only
                   version information (if -R is specified), or no information
                   (if no information checking options are specified.

              -R : Collect Version and File-System Information From Modules

                   This option requests checksym to collect the following
                   information from the file-system and version information
                   structure (if any):

                        File Version
                        Company Name
                        File Description
                        File Size (bytes)
                        File Date/Time

 -V[<blank>|1|2] : Verify Symbols for Modules

                   This option uses the symbol information gathered (-S option)
                   to verify that proper symbols exist (as found along the
                   symbol path.  Use of -V implies -S when module collection is
                   initiated.  There are different levels of symbol
                   verification:

                   -V or -V1 : (Default) This treats symbol files that match
                               the module's time/date stamp, but have an wrong
                               checksum or size of image as valid symbols.  This
                               is the default behavior and these symbols are
                               typically valid.  (Localization processes often
                               cause the size of image and/or checksum to be altered
                               but the symbol file is still valid.

                   -V2       : Only if checksum, size of image AND time/date stamp
                               match is the symbol considered valid.

-Y[I][<blank>|1|2] <Symbol Path> : Verify Symbols Using This Symbol Path

                   This is a semi-colon separated search path for looking for
                   symbols.  This path is searched with the -V option.  -Y now
                   supports the use of SYMSRV for symbol searching.  An
                   example usage would be a symbol path that resembles:

                   -Y SYMSRV*SYMSRV.DLL*\\SYMBOLS\SYMBOLS

                   Or this more compact form which expands to the one above:
                   -Y SRV*\\SYMBOLS\SYMBOLS

                   The default value is %systemroot%\symbols

                   -YI       : This option allows you to specify a text file
                               which contains the symbol paths you would like
                               to use.  Many people create a text file of their
                               favorite symbol paths, use this option to specify
                               that file.

                               Example:
                               -YI C:\temp\MySymbolPaths.txt

                               You can specify modifers to -YI but they must follow
                               the -YI option (i.e. -YI2 for recursion of all the
                               paths specified by the symbol path file).

                   -Y        : (Default) This searches for symbols in the
                               symbol paths using the behavior typical of the
                               debuggers.

                   NOTE: For the options below you can add the numbers together
                         to specify combinations of options.  -Y7 would be all of
                         the combinations for example.

                   -Y1       : This searches for symbols using only the provided
                               symbol path and does not use other locations found
                               such as those found in the Debug Directories section
                               of the PE image.

                   -Y2       : This searches for symbols in the symbol paths
                               provided using a recursive search algorithm.
                               This option is most useful when used with -B to
                               build a symbol tree.

                   -Y4       : This searches for symbols in the symbol paths
                               but for DBG files does NOT use the entry in
                               the MISC section of the image.

-EXEPATH <Exe Path> : Verify Symbols for Modules Using Executable Path

                   Minidump files require that the actual matching binary images
                   are present.  If a dumpfile is being opened and an EXEPATH is
                   is not specified, Checksym will default the EXEPATH to the
                   symbol path.

          -NOISY : Output internal paths used during search for symbols

         -SOURCE : Symbols with Source are PREFERRED (search behavior change)

                   This option directs CheckSym to continue searching until a
                   symbol is found with Source Info if possible.  Normally,
                   CheckSym terminates searching when any matching symbol is
                   found.  This option forces CheckSym to continue searching
                   for source enabled symbols which can result in longer
                   searches potentially.

     -SOURCEONLY : Symbols with Source are REQUIRED (search behavior change)

                   This option directs CheckSym to continue searching until a
                   symbol is found with Source Info.  A symbol is considered
                   a match only if it also contains Source Info.

       -NOSOURCE : Symbols with Source are NOT ALLOWED (search behavior change)

                   This option directs CheckSym to continue searching until a
                   symbol is found with no Source Info.  A symbol is considered
                   a match only if it does NOT contain Source Info.

                   Using this option with -B can be a useful way to create a symbol
                   tree for customers since it would limit the symbols to those
                   without Source Info (proprietary information).

***** OUTPUT OPTIONS *****

 -B <Symbol Dir> : Build a Symbol Tree of Matching Symbols

                   This option will create a new symbol tree for ALL matching
                   symbols that are found through the verification process
                   (-v option). This option is particularly useful when used
                   with the -Y option when many symbol paths are specified
                   and you want to build a single tree for a debug.

        -BYIMAGE : Copy Matching Symbols Adjacent to Modules

                   This option will copy matching symbols next to the module
                   it matches.  This can be useful for interoperability with some
                   debuggers that have difficulties finding matching symbols
                   using a symbol tree or symbol path.

           -PERF : Display Preferred Load Address vs Actual Load Address

                   There is a performance penalty when a module does not load
                   at it's preferred load address.  Tools like REBASE.EXE can
                   be used to change the preferred load address.  After using
                   REBASE.EXE, BIND.EXE can be used to fixup import tables for
                   more performance improvements.

   -Q[<blank>|2] : Quiet modes (no screen output, or minimal screen output)

                   The default behavior is to print out the data to the
                   console window (stdout).  If the process terminates with an
                   error, it will print out these (overriding -Q).

                   -Q2       : This option prints out a module ONLY if a symbol
                               problem exists.  (Not completely quiet mode!)

-O[<blank>|1|2] <File Path> : Output Collected Module Information To a CSV File

                   For this file to to be used as input (-I) to verify good
                   symbols for this system, the -S option should also be used.

                   -O or -O1 : (Default)  This output mode requires that the
                               file does not exist.

                   -O2       : Specifying a -O2 will allow the output file
                               to be OVERWRITTEN if it exists.

              -T : Task List Output

                   Prints out a task list on the local machine (similar to the
                   TLIST utility).  This option implies the use of -P (querying
                   the local system for active processes.  You can provide the
                   -P command explicitly (if you want to provide an argument,
                   for instance).  If -P is not specified explicitly, then it
                   defaults to -P *.  Also, -T overrides -Q since TLIST
                   behavior is to print to the console window.

             -KB : Dump Call Stack

                   This command will produce a call stack and exit the application.
                   This is very useful when examining a user.dmp file to produce a
                   quick callstack for analysis.

***** TYPICAL USAGE EXAMPLES *****

You want to verify the symbols for files in a directory (%SYSTEMROOT%\SYSTEM32)
in the default symbol directory (%SYSTEMROOT%\SYMBOLS)

     CHECKSYM -F %SYSTEMROOT%\SYSTEM32 -V

You want to do the same search, but for only executables...

     CHECKSYM -F %SYSTEMROOT%\SYSTEM32\*.EXE -V

You want to search a directory using multiple symbol paths...

     CHECKSYM -F %SYSTEMROOT%\SYSTEM32\ -V -Y V:\nt40sp4;V:\nt40rtm

You want to know what modules are loaded for a process (and the path to each)
Start NOTEPAD.EXE, and then type:

     CHECKSYM -P NOTEPAD.EXE

You want to know if you have good symbols for a process (notepad.exe).

     CHECKSYM -P NOTEPAD.EXE -V

You want to know the file version for every module loaded by a process.

     CHECKSYM -P NOTEPAD.EXE -R

You want to know if you have good symbols for ALL processes on your machine.

     CHECKSYM -P * -V

***** ADVANCED USAGE EXAMPLES *****

You are going to prepare to debug a remote system, and you want to ensure
that you have good symbols locally for debugging the remote system.  You want
to verify this prior to initiating the debug session.

Use checksym twice, once on the remote system to gather information and create
an output file, and then once on your system using the output file created
as an input argument.

For example, run this on the remote system

     CHECKSYM -P * -S -R -O C:\TEMP\PROCESSES.CSV

The C:\TEMP\PROCESSES.CSV file will contain a wealth of information about
the processes that were running, and the modules loaded by every process.

Now, get the output file from the remote system, and copy it locally.  Then

run CHECKSYM again, using the file as an input argument...

     CHECKSYM -I C:\TEMP\PROCESSES.CSV -V

Another useful option is -B (build a symbol tree).  It allows you to update
or create a symbol tree that contains matching symbols.  If you have to use
many symbol paths in order to have correct symbols available to a debugger,
can use the -B option to build a single symbol tree to simplify debugging.

     CHECKSYM -P * -B C:\MySymbols -V -Y V:\Nt4;V:\Nt4Sp6a;V:\NtHotfixes

***** DEFAULT BEHAVIOR *****

The default behavior of CHECKSYM when no arguments are provided is:

CHECKSYM -?    (Display simple help)

======================
RELEASE HISTORY
======================
Version 2.7 - Addressed assumptions about the SizeOfOptionalHeader in a PE image (Windows Bug: 721926)

Version 2.6 - Added -KB option to dump a callstack for a provided (-z) DMP file
            - Added support for expansion of registry values provided between % delims.
            
Version 2.2 - Fixed problems with Recursive Searching where PDB files were not properly
              verified and the number of "Total # Verification Errors Found" was sometimes
              improperly set when using the -Y2 option.
            - When a path is inaccessible due to access rights, and error message telling
              you this will be visible
            - The -P option now supports multiple arguments separated by semi-colons
            - Changed the way checksym uses SYMSRV to call a new DBGHELP.DLL function
              SymFindFileInPath() which abstracts my use of SYMSRV.DLL behind a standard
              Win32 API.  (This implies checksym should not be as susceptible to failures
              when changes to SYMSRV.DLL are made in the future, if changes are made.)
            - Added new "sep=," entry to exported CSV file to fix regional locale settings
              (Users in Germany use a semi-colon as a list separator, so this entry removes ambiguity).
            - The -R option now returns version info for modules in DMP files!
            - Support for -SOURCEONLY/-SOURCE/-NOSOURCE switches to control search behavior            
            - Used CopyFileEx() for copying symbols to symbol tree... this allows for both            
              restartable copies (if the symbol file copy failed), and for progress dots!
            - Multiple arguments supported by -P (i.e. -P notepad.exe;1313)
            - Changed default behavior when no arguments are provided to (checksym -?)
            - Added new output for errors received by checksym when trying to find symbols
              (specifically errors like -- Access Denied or The network path was not found.)
            - The -F option no longer defaults to recursion... to get recursion you must provide
              the number 2 (-F2) which is the same as the usage for -Y (which offers recursion
              with -Y2.	
            - You can now pass a text file with your symbol path (for those of you
              that have a textfile that contains your favorite symbol locations.  To
              do this you use -YI <path to symbolfile>.
            - This version should be able to work with VC 7.0 and VS.NET symbols provided
              you also copy the MSDIA20.DLL file to the same directory as checksym.							

Version 2.1 - New version (Windows 2000 version is now 2.0).
            - New recursive search offered for with the -y2 option... the symbol tree(s)
              offered by -y2 will be recursively searched for matching symbols... given
              how many people construct symbol trees, this may be a real convenience...
            - When building a symbol tree (with -b), any symbol copied to your symbol
              tree will be printed during the verify process so you can see where it
              came from... useful when you have many symbol paths and you want the
              visual indicator of what version it is based on where it came from...
            - This version no longer requires MSDBI60.DLL (or uses MSDBI.DLL).  This
              version is statically linked to msdbi60l.lib which removes the DLL
              dependency (at the expense of image-size).
            - Added support for returning ERRORLEVELS!  The errorlevel value is equal
              to the number of failures in verification that were found.  (I also added
              an output line that prints the results of verification...)
            - Fixed an access violation when reading a CSV file (with Modules Data)
              and ALSO doing a -F option.
            - Included a new -SQL2 option for querying an upgraded Symbol Tree Format
              (preliminary). This new format handles PDB files as well as DBG files...
            - Fixed crashing bug when using -SQL options (race-condition in COM Uninitialize)
            - Includes a new -D option to query for device drivers on local system
            - Supports MEMORY.DMP files now... point to them with -Z just like USER.DMP files
            - Supports SYMSRV DLLs (such as SYMSRV.DLL).  Provide a SYMSRV argument on the
              symbol path, like CHECKSYM -P -V -Y SYMSRV*SYMSRV.DLL*\\server\share
            - New CSV output format (new column) to support SYMSRV searches with remotely
              collected data.
            - Added support for Windows Proxy Server

              %WSPSRV%
                    Obtained from:
                            KEY - "SYSTEM\CurrentControlSet\Services\WSPSrv\Parameters"
                            VALUE - "InstallRoot"

Version 1.9 - Unicode Build is now the official build (Win98 support may come back
              at a future data - use Version 1.8 if you require it now).
			- Added support for USER.DMP files produced with modules linked by
			  LINK 6.20 and higher (this linker version creates a PE module 
			  that has the path to the PDB file in the user-mode address space.  
			  This should reduce the frequency of seeing MOD<Address> names....
			- Fixed crashing bugs related to DMP files and -I/-O options (we don't
			  allow -Z and -I, but -Z and -O are cool... and work now).

Version 1.8 - COMMAND LINE CHANGE!!!  (This version has changed the command-line
              option for symbols from -Z to -Y).  It was always my intention to
              use the SAME command-line options as WinDbg and i386kd/ntsd where
              possible.  For some reason, my choice of -Z for symbols (which was
              wrong) was not noticed until just recently.  To achieve better
              consistency, this program was changed.

			- The ability to load a user.dmp file was added as option -Z (the
              same value used by i386kd and windbg

Version 1.7.5 - CSV output file is not produced unless "some" data is collected
            - CSV output file now contains "DBG Pointer" (pointer to DBG file found
              in the MISC section of the Debug Directories entry), and "Product Version".
            - Fixed problem where directories were provided with a trailing '\' character
            - Prints out info for DBG and PDB files it fails to find (so you know what
              is being searched for.
            - Added support for the use of "pseudo-environment" variables.  These act
			  just like environment variables (you use them in provided paths), but they
			  cause Checksym to query the registry to translate the string (this is
			  product specific and very likely version specific.  Supported strings 
			  include:

              %EXCHSRVR%
                    Obtained from:
                            KEY - "SOFTWARE\Microsoft\Exchange\Setup"
                            VALUE - "Services"

              %SNASERVER%
                    Obtained from:
                            KEY - "SOFTWARE\Microsoft\Sna Server\CurrentVersion"
                            VALUE - "PathName"

              %SQLSERVER%
                    Obtained from:
                            KEY - "SOFTWARE\Microsoft\MSSQLServer\Setup"
                            VALUE - "SQLPath"

			  %SMSSERVER"
                    Obtained from:
                            KEY - "SOFTWARE\Microsoft\SMS\Identification"
                            VALUE - "Installation Directory"

              %INETSRV%
                    Obtained from:
                            KEY - "SOFTWARE\Microsoft\INetStp"
                            VALUE - "InstallPath"

              This should make it easier to gather info for backoffice products...

			  CHECKSYM -F %EXCHSRVR%\BIN -S -R -O OUTPUT.CSV -Q

Version 1.7 - An X86 and an Alpha Build are built...
            - Help has been worked again.  Bad arguments are reported, and a suggestion
              follows on how to obtain more help (it used to immediately dump the help
              which is now pages long -- which obscures the source of the problem as you
              watch it sailing off the top of your screen.)
            - "-O2" was created to allow the output file to overwrite an existing file (default behavior 
              is to fail if output file exists already).  
            - "-E" option added (this is used only by IIS Exception Monitor and will remain 
              undocumented.  It influences the data in any output file generated).
            - Improvements made to file version collection.  Some modules don't carry the
              file version info where they should (in the FIXEDFILEINFO section)
            - Files discovered with "-F" option are now returned with their FULL path, not
              a potentially relative path...
            - Checks were added to ensure that paths provided aren't too long
            - Correct help to indicate that CHECKSYM supports semi-colon delimited paths (not colons)
            - Added progress dots during verify mode
            - Added the ability to search for a specific process name or process ID when
              reading in an input file... in other words, you could produce a monster big
              output.csv file from a customer machine... then take the file locally and issue
              the command (checksym -i output.csv -p myapp.exe -v) and checksym would only
              return information for matching process(es) of the name myapp.exe.

Version 1.6 - This version uses MSVCRT.DLL, and the redistributable MSDBI60.DLL
            - Fixes crash when attempting to import a CSV file
            - Improved Help screens (more read-able)... I have a simple help -?
              and an expanded help -??? option.

Version 1.5 - First major public release (added support for building symbol tree -B)

Version 1.4 - Further improved support for Windows 95/98, added support for -SQL

Version 1.3 - Added Support for scanning the Filesystem (-F option)

Version 1.2 - Support for Windows 95/98 added

Version 1.1 - Create module cache (improved performance dramatically)

Version 1.0 - First version (queries local processes only)

