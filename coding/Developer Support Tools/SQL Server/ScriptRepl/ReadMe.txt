========================================================================
    COMMAND-LINE REPLICATION SCRIPTING UTILITY
========================================================================

CURRENT VERSION:	1.5
LAST BUILD DATE:	7/21/2002
OWNER:				ryanston

Command-line utility to generate SQL Server 2000 replication scripts
from the command-line, rather than from SEM.  Uses simple SQL-DMO
calls to generate the final script.  Parameters are as follows:

usage:  scriptrepl /option [value] /option [value] ...
Generates a replication script for the SQL Server specified.
Options ('/?' shows this screen; '-' may be substituted for '/'):

	/S publisher server name
	/D publisher database name
	/N publication name (optional)
	/E <use trusted connection instead of /U /P>
	/U user name
	/U password
	/O output directory
	
The tool automatically generates a replication script named 'replscripts.sql'.
If not specified, the output file will be in the current directory, with
the replscript.sql file name.