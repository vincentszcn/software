if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[tblMergeObjects]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[tblMergeObjects]
go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_addmergeobjects]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_addmergeobjects]
go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_ExportMergeObjects]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_ExportMergeObjects]
go

--
-- Table holds the merge system tables that we're going to BCP out
--
create table tblMergeObjects
(
	[TableID] 	int identity(1,1),
	[TableName]	sysname
)
go

------------------------------------------------------------------------------------------------
--
-- PROCEDURE:	sp_addmergeobjects
--
-- DESCRIPTION:
--	Adds a standard set of merge system tables to the tblMergeObjects table in preparation
--	for a BCP out of the data in those tables by sp_exportmergeobjects
--
-- REVISION HISTORY:
--	RLS [07/15/2002] -- Created
--
--------------------------------------------------------------------------------------------------
create procedure [dbo].[sp_addmergeobjects] @svr_role nvarchar(3) /* Should be 'PUB' or 'SUB' */
as

set nocount on

if @svr_role is null or @svr_role not in ('PUB', 'SUB')
begin
	raiserror('Invalid server role type passed to procedure.', 16, 1)
	return(1)
end

--
-- A standard set of merge replication system objects
--
insert into tblMergeObjects values( 'sysobjects' )
insert into tblMergeObjects values( 'syscolumns' )
insert into tblMergeObjects values( 'sysmergearticles' )
insert into tblMergeObjects values( 'sysmergepublications' )
insert into tblMergeObjects values( 'sysmergesubscriptions' )
insert into tblMergeObjects values( 'sysmergesubsetfilters' )
insert into tblMergeObjects values( 'MSmerge_delete_conflicts' )
insert into tblMergeObjects values( 'sysmergeschemachange' )
insert into tblMergeObjects values( 'sysmergeschemaarticles' )
insert into tblMergeObjects values( 'MSmerge_replinfo' )
insert into tblMergeObjects values( 'tblVersionInfo' )

--
-- Get the conflict tables for the publication.  At some point conflict_table is null,
-- so we're going to skip those rows.  If there's no conflicts, we don't need it anyway.
--
if @svr_role = N'PUB'
begin
	insert into tblMergeObjects
	select conflict_table from sysmergearticles where conflict_table is not null
end
go


------------------------------------------------------------------------------------------------
--
-- PROCEDURE:	sp_exportmergeobjects
--
-- DESCRIPTION:
--	Actually does the BCP out of the merge system objects in tblMergeObjects via xp_cmdshell
--
-- REVISION HISTORY:
--	RLS [07/15/2002] -- Created
--
--------------------------------------------------------------------------------------------------
create procedure [dbo].[sp_ExportMergeObjects]	@ServerName  sysname,
						@SecurityStr nvarchar(75),
						@OutFilePath nvarchar(512),
						@FileSuffix  nvarchar(5),
						@DistribDB   sysname
as

set nocount on

declare @tablename sysname
declare @filepath  nvarchar(512)
declare @filename  nvarchar(256)
declare @dbname	   sysname
declare @distquery nvarchar(512)
declare @bcpcmd	   nvarchar(4000)

declare curBCP cursor forward_only for
select [TableName] from tblMergeObjects

open curBCP
fetch next from curBCP into @tablename

select @dbname = db_name()

--
-- Loop through the export table, constructing a BCP string for each file
-- Execute each one, and then fetch the next
--
while @@fetch_status = 0
begin

	--
	-- Don't append the suffix to conflict tables.
	--
	if @tablename like 'conflict%'
	begin
		select @filename = @tablename + N'.bcp'
	end
	else		
	begin
		select @filename = @tablename + @filesuffix + N'.bcp'
	end

	select @filepath = @OutFilePath + N'\' + @filename

	--
	-- Build the xp_cmdshell string to execute the BCP.
	--
	select @bcpcmd = N'exec master..xp_cmdshell ''bcp "' + @dbname + N'..' + quotename(@tablename)
	select @bcpcmd = @bcpcmd + N'" out "' + @filepath + N'" -n -S' + @ServerName + N' ' + @SecurityStr + N''''

	--
	-- We should have a linked server connection back to the distributor, so use that to 
	-- add the CAB files to the distributor's cab table.
	--
	select @distquery = N'exec mergediagdistrib.' + @DistribDB + '.dbo.sp_addtocabfile '
	select @distquery = @distquery + N'@filepath=N''' + @filepath + N''', @filename=N''' + @filename + N''''

	print @bcpcmd
	print @distquery
	
	exec(@bcpcmd)
	exec(@distquery)

	fetch next from curBCP into @tablename
end

--
-- Now BCP out the inventory table
--
select @bcpcmd = N'exec master..xp_cmdshell ''bcp ' + @dbname + N'..tblMergeObjects'
select @bcpcmd = @bcpcmd + N' out "' + @OutFilePath + N'\tblMergeObjects' + @FileSuffix + N'.bcp" -n -S'
select @bcpcmd = @bcpcmd +  + @ServerName + N' ' + @SecurityStr + N''''

print @bcpcmd
exec(@bcpcmd)

close curBCP
deallocate curBCP
go