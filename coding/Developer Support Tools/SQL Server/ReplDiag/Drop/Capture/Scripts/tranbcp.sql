if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[tblTranObjects]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[tblTranObjects]
go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_addtranobjects_publisher]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_addtranobjects_publisher]

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_addtranobjects_distributor]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_addtranobjects_distributor]
go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_exportobjects]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_exportobjects]
go

--
-- Table holds the merge system tables that we're going to BCP out
--
create table [dbo].[tblTranObjects]
(
	[TableID] 	int identity(1,1),	-- Arbitrary ID for the table entry
	[TableName]	sysname,		-- The actual table name.
	[DatabaseName]	sysname			-- The name of the database.
)
go

--------------------------------------------------------------------------------------------------
--
-- PROCEDURE:	sp_addtranobjects_publisher
--
-- DESCRIPTION:
--	Adds a standard set of transactional system tables (publisher-side) to the export table.
--
-- REVISION HISTORY:
--	RLS [08/03/2002] -- Created
--
--------------------------------------------------------------------------------------------------
create procedure [dbo].[sp_addtranobjects_publisher]	@publisher_db sysname
as

set nocount on

--
-- A standard set of Tran replication system objects
--
insert into tblTranObjects values( 'sysobjects', @publisher_db )
insert into tblTranObjects values( 'syscolumns', @publisher_db )

insert into tblTranObjects values( 'sysservers', N'master' )

insert into tblTranObjects values( 'sysarticles', @publisher_db )
insert into tblTranObjects values( 'syspublications', @publisher_db )
insert into tblTranObjects values( 'syssubscriptions', @publisher_db )
insert into tblTranObjects values( 'sysarticleupdates', @publisher_db )
go

------------------------------------------------------------------------------------------------
--
-- PROCEDURE:	sp_addtranobjects_distributor
--
-- DESCRIPTION:
--	Adds a standard set of transactional system tables (dist.-side) to the export table.
--
-- REVISION HISTORY:
--	RLS [08/03/2002] -- Created
--
--------------------------------------------------------------------------------------------------
create procedure [dbo].[sp_addtranobjects_distributor]	@distribution_db sysname,
							@add_dist_tables bit
as

set nocount on

insert into tblTranObjects values( 'sysservers', N'master' )
insert into tblTranObjects values( 'tblVersionInfo', @distribution_db )

if @add_dist_tables = 1
begin
	insert into tblTranObjects values( 'MSarticles', @distribution_db )
	insert into tblTranObjects values( 'MSpublications', @distribution_db )
	insert into tblTranObjects values( 'MSsubscriptions', @distribution_db )
	insert into tblTranObjects values( 'MSpublisher_databases', @distribution_db )
	insert into tblTranObjects values( 'MSdistribution_agents', @distribution_db )
	insert into tblTranObjects values( 'MSlogreader_agents', @distribution_db )
	insert into tblTranObjects values( 'MSsnapshot_agents', @distribution_db )
	insert into tblTranObjects values( 'MSqreader_agents', @distribution_db )
	insert into tblTranObjects values( 'MSdistribution_history', @distribution_db )
	insert into tblTranObjects values( 'MSlogreader_history', @distribution_db )
	insert into tblTranObjects values( 'MSsnapshot_history', @distribution_db )
	insert into tblTranObjects values( 'MSqreader_history', @distribution_db )
	insert into tblTranObjects values( 'MSrepl_errors', @distribution_db )
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
create procedure [dbo].[sp_exportobjects]	@ServerName  sysname,
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

--
-- Make sure the export table exists
--
if not exists( select * from tblTranObjects )
begin
	raiserror(N'Cannot find export objects table.', 16, 1)
	return(1)
end

declare curBCP cursor forward_only for
select [TableName], [DatabaseName] from tblTranObjects

open curBCP
fetch next from curBCP into @tablename, @dbname

--
-- Loop through the export table, constructing a BCP string for each file
-- Execute each one, and then fetch the next
--
while @@fetch_status = 0
begin

	if @filesuffix is not null
		select @filename = @tablename + @filesuffix + N'.bcp'
	else
		select @filename = @tablename + N'.bcp'

	select @filepath = @OutFilePath + N'\' + @filename

	select @bcpcmd = N'exec master..xp_cmdshell ''bcp "' + @dbname + N'..' + quotename(@tablename)

	if @filesuffix is not null
		select @bcpcmd = @bcpcmd + N'" out "' + @OutFilePath + N'\' + @tablename + @FileSuffix + N'.bcp" -n -S'
	else
		select @bcpcmd = @bcpcmd + N'" out "' + @OutFilePath + N'\' + @tablename + N'.bcp" -n -S'
	
	select @bcpcmd = @bcpcmd +  + @ServerName + N' ' + @SecurityStr + N''''

	--
	-- Make sure that the distributor linked server exists
	--
	if not exists(select * from master.dbo.sysservers where srvname = N'trandiagdistrib')
	begin
		raiserror(N'Linked server to distributor not found.', 16, 1)
		return(1)
	end

	--
	-- We should have a linked server connection back to the distributor, so use that to 
	-- add the CAB files to the distributor's cab table.
	--
	select @distquery = N'exec trandiagdistrib.' + @DistribDB + '.dbo.sp_addtocabfile '
	select @distquery = @distquery + N'@filepath=N''' + @filepath + N''', @filename=N''' + @filename + N''''

	print '*** BCP COMMAND:  ' + @bcpcmd
	print '*** DISTRIBUTION COMMAND:  ' + @distquery
	
	exec(@bcpcmd)
	exec(@distquery)

	fetch next from curBCP into @tablename, @dbname
end

--
-- Now BCP out the inventory table
--
select @bcpcmd = N'exec master..xp_cmdshell ''bcp ' + @dbname + N'..tblTranObjects'

if @filesuffix is not null
	select @bcpcmd = @bcpcmd + N' out "' + @OutFilePath + N'\tblTranObjects' + @FileSuffix + N'.bcp" -n -S'
else
	select @bcpcmd = @bcpcmd + N' out "' + @OutFilePath + N'\tblTranObjects' + N'.bcp" -n -S'

select @bcpcmd = @bcpcmd +  + @ServerName + N' ' + @SecurityStr + N''''

print '*** BCP COMMAND:  ' + @bcpcmd
exec(@bcpcmd)

close curBCP
deallocate curBCP
go