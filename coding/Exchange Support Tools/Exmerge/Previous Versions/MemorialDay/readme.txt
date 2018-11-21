Solution to update incorrect Memorial Day appointments in Exchange Server Mailboxes
====================================================================================

Following is a solution to update the incorrect Memorial Day appointments.
This solution uses an updated version of Mailbox Merge Program (EXMERGE.EXE)

The solution works in two steps

I) Removing incorrect appointments: In this stage the program logs into every mailbox and moves all appointments (in the Calendar folder)
to a PST file.

II) Adding new appointments: In this stage the program copies appointments from the supplied MemorialDay.pst file to each mailbox.


Step to Execute
================

1) Copy the supplied files to a directory, say C:\EXMERGE

2) Edit the ExMerge-Removing-Items.ini file 
   a) Update the SourceServerName entry with the Exchange server name.
      By default, the program will operate against all mailboxes on this server.

   b) Change the DataDirectoryName entry to point to a location where the program can create PST files for each mailbox it processes.
      These PST files will contain every items (in this case appointment) that is removed from the server.
      Each PST file created will be around 70K, so depending on the number of mailboxes on the server, this directory will need to have 
      sufficient free disk space.

3) Edit the ExMerge-Importing-Appmt.ini
   a) Update the DestServerName entry with an Exchange Server name.
      By default, the program will operate against all mailboxes on this server.

   b) Update the DataDirectoryName.
      This is the directory that should contain the MemorialDay.Pst file.

4) At a command prompt change to the C:\EXMERGE directory.

5) Run the following command:
   
   exmerge -f exmerge-removing-items.ini -b -d

   After this process has completed, all appointments with the Subject "Memorial Day" will be removed from the Calendar folder of each mailbox processed.

6) Run the following command:
   
   exmerge -f exmerge-importing-appmt.ini -b -d

   After this process has completed, each mailbox should contain the correct "Memorial Day" appointments.



SPECIFYING WHICH MAILBOXES TO PROCESS
=====================================
By default the program will operate on all mailboxes on the specified server.
If you wish to specify only certain mailboxes to be processed, follow the steps below.

1) Create a test file (mailboxes.txt)
2) Enter the full distinguished name of each mailbox, each on a separate line.
3) In the two ini files update the FileContainingListOfMailboxes entry with mailboxes.txt 

The program should now read this file and operate on only these mailboxes.

You can specify mailboxes on different servers, also.
Hence this is a way to operate on mailboxes on different servers, instead of running on instance of the 
program for each server.

You can get the required text file (mailboxes.txt) by performing a directory export, using the Exchange Admin program.
Then manipulate the csv file created by the export, removing all data, except the object-dn.

 