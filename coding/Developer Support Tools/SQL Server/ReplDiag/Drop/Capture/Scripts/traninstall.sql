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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_getlsn]') and OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
drop function [dbo].[fn_getLSN]
go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_getdbtable]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_getdbtable]
go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_getrepltrans]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_getrepltrans]
go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[tblDBTABLE]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[tblDBTABLE]
go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[tblReplCounters]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[tblReplCounters]
go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[tblReplTrans]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[tblReplTrans]
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

--
-- This table holds the output of DBCC DBTABLE WITH TABLERESULTS
--
create table [dbo].[tblDBTABLE]
(
	[ParentObj]	nvarchar(255),
	[Object]	nvarchar(512),
	[Field]		nvarchar(512),
	[Value]		nvarchar(512)
)
go

--
-- Holds the output of sp_replcounters
-- This is not populated by procedure, but directly from trangather.cmd
--
create table [dbo].[tblReplCounters]
(
	[DatabaseName]		sysname,
	[ReplicatedTrans]	integer,
	[ReplicationRate]	float,
	[ReplLatency]		float,
	[ReplBeginLSN]		binary(10),
	[ReplEndLSN]		binary(10)
)
go

--
-- Holds the output of sp_repltrans stored procedure
-- Populated directly from stored procedure
--
create table [dbo].[tblReplTrans]
(
	[xdesid]			varbinary(16),
	[xact_seqno]		varbinary(16),
	[convert_xdesid]	varchar(75),
	[convert_xactseqno]	varchar(75),
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


------------------------------------------------------------------------------------------------
--
-- FUNCTION:	fn_getLSN()
--
-- DESCRIPTION:
--	Function definition that accepts an LSN in the form presented to us by the
--	transactional replication system tables, and returns it in a form usable
--	by fn_dblog() or DBCC LOG
--	
-- REVISION HISTORY:
--	RLS [03/25/200] -- Created
--
------------------------------------------------------------------------------------------------
create function [dbo].[fn_getLSN]
( 
	@xactparam varbinary(10),	-- Parameter from the replication tables
	@format    varchar(10) 		-- 'HEX' or 'DECIMAL'
)
returns varchar( 32 )
as

begin

declare @klsnseqno	integer		-- constant byte count for LSN::seqno member
declare @klsnoffset	integer		-- constant byte count for LSN::offset
declare @klsnslotid	integer		-- constant byte count for LSN::slotid

declare @iseqno		integer		-- the integer representation of the seqno for the begin LSN
declare @ioffset	integer		-- the integer representation of the offset of the begin LSN
declare @islotid	integer		-- the integer representation of the slotid of the begin LSN

declare @strReturn	varchar(32)	-- the return string

	-- 
	-- These are some constants for walking the LSN value returned to us 
	-- from MSrepl_commands and MSrepl_transactions.
	--
	set @klsnseqno	= 4
	set @klsnoffset	= 4
	set @klsnslotid	= 2

	--
	-- Dummy output for failure condition
	-- 
	select @strReturn = '0:0:0'

	--
	-- Set up the basics for our return values
	--
	select @iseqno  = convert( varbinary, substring( @xactparam, 1, @klsnseqno ) )
	select @ioffset = convert( varbinary, substring( @xactparam, @klsnseqno + 1, @klsnoffset ) )
	select @islotid = convert( varbinary, substring( @xactparam, @klsnseqno + @klsnoffset + 1, @klsnslotid ) )

	--
	-- If we ask for hex, use fn_varbintohexstr() to give us a readable varbinary string
	--
	if UPPER(@format) = N'HEX'
	    begin

		declare @hex_seqno  varchar(10)
		declare @hex_offset varchar(10)
		declare @hex_slotid varchar(10)

		select @hex_seqno  = master.dbo.fn_varbintohexstr( @iseqno )
		select @hex_offset = master.dbo.fn_varbintohexstr( @ioffset )
		select @hex_slotid = master.dbo.fn_varbintohexstr( @islotid )

		select @strReturn = '0x' + right(@hex_seqno, 8) + ':' + right(@hex_offset, 8) + ':' + right(@hex_slotid, 4)
		
	    end

	--
	-- If we ask for decimal, just output the conversion to varchar
	--
	else if upper( @format ) = N'DECIMAL'
	     begin

			select @strReturn = convert( varchar, @iseqno ) + ':' + convert( varchar, @ioffset ) + ':' + convert( varchar, @islotid )

	     end

	--
	-- A failure is defined as a return of 0:0:0
	--
	return @strReturn

end
go



------------------------------------------------------------------------------------------------
--
-- PROCEDURE:	sp_getdbtable
--
-- DESCRIPTION:
--	Procedure called at the publisher to retreive the output of DBCC DBTABLE.
--
-- REVISION HISTORY:
--	RLS [07/11/2002] -- Created
--
--------------------------------------------------------------------------------------------------
create procedure [dbo].[sp_getdbtable]
as

set nocount on

declare @database	sysname
declare @strExec	nvarchar(4000)

--
-- Build the string to exec in the current database
--
select @database = db_name()
select @strExec	 = N'dbcc dbtable(' + @database + N') with tableresults'

--
-- Exec the string into the tblDBTABLE table.
--
insert into dbo.tblDBTABLE exec( @strExec )
go

------------------------------------------------------------------------------------------------
--
-- PROCEDURE:	sp_getrepltrans
--
-- DESCRIPTION:
--	Procedure called at the publisher to retreive the output of sp_repltrans.
--
-- REVISION HISTORY:
--	RLS [07/11/2002] -- Created
--
--------------------------------------------------------------------------------------------------
create procedure [dbo].[sp_getrepltrans]
as

set nocount on

--
-- Exec the stored procedure into the tblReplTrans table
--
insert into dbo.tblReplTrans( xdesid, xact_seqno ) exec sp_repltrans

--
-- Update that table with a friendly representation of the begin and commit LSNs from fn_getLSN
--
update dbo.tblReplTrans 
set [convert_xdesid] = dbo.fn_getlsn( [xdesid], 'HEX' ),
    [convert_xactseqno] = dbo.fn_getlsn( [xact_seqno], 'HEX' )
go