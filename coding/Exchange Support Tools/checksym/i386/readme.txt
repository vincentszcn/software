Checksym has moved to the use of a MSI Install package.  

Simplest install:
=================
Just double-click from explorer to invoke the installer.

Heavier install:
================
For older systems, the MSI package may not be sufficient.  The system may require an updated InstMsiW.Exe (NT 4.0)
in order to install the MSI package.  (InstMsiA.Exe is for Win9x and was removed from this install since Win9x is
not supported by CheckSym at this time.)

If you provide all the files in the directory and tell the customer to invoke setup.exe, it will update the Windows
Installer if necessary...

Greg