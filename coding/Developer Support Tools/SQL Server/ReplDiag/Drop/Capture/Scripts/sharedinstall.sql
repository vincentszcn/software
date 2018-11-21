
------------------------------------------------------------------------------------------------
--
-- FILENAME:	sharedinstall.sql
-- 
-- DESCRIPTION:
--	Procedures shared between merge and transactional gatherer files.
--
-- REVISION HISTORY:
--	RLS [07/11/2002] -- Created
--  	RLS [07/14/2002] -- Added work for data import
-- 
------------------------------------------------------------------------------------------------ 

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_addtocabfile]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_addtocabfile]
go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_gencabfile]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_gencabfile]
go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_getversioninfo]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_getversioninfo]
go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[tblCabFiles]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[tblCabFiles]
go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[tblVersionInfo]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[tblVersionInfo]
go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_articleindexes]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_articleindexes]
go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_agent_profiles]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_agent_profiles]
go

--
-- The table that holds our file names for the call to xp_makecab
--
create table [dbo].[tblCabFiles]
(
	[FileID]	integer identity(1,1),
	[FilePath]	nvarchar(512) NOT NULL,
	[FileName]	nvarchar(128) NOT NULL
)
go

--
-- Version information table, holding the output of xp_msver
--
create table tblVersionInfo
(
	[server]	  varchar(50) NULL,
	[indexID] 	  integer,
	[Name]  	  varchar(255),
	[internal_value]  integer,
	[character_value] varchar(255)
)
go


------------------------------------------------------------------------------------------------
--
-- PROCEDURE:	sp_addtocabfile
--
-- DESCRIPTION:
--	Procedure called by a client to prepare a set of files for archival in a CAB format via
--	the xp_makecab extended stored procedure.  
--
-- REVISION HISTORY:
--	RLS [07/11/2002] -- Created
--
--------------------------------------------------------------------------------------------------
raiserror( 'Creating procedure [sp_addtocabfile]', 1, 1 )
go

create procedure [dbo].[sp_addtocabfile]	@filepath nvarchar(512),
						@filename nvarchar(128)
as

set nocount on

--
-- Make sure the file doesn't already exist in our table
--
if not exists( select * from tblCabFiles where [FileName] = @filename )
begin
	
	--
	-- Do the insert && handle any errors.
	--
	insert into dbo.tblCabFiles( FilePath, FileName )	values( @filepath, @filename )

	if @@error <> 0
	begin
		raiserror( 'Error adding file to cab archive table.', 16, 1 )
		return 1
	end
end

return 0
go


------------------------------------------------------------------------------------------------
--
-- PROCEDURE:	sp_gencabfile
--
-- DESCRIPTION:
--	Procedure loops over the files in the tblCabFiles table and generates a call to xp_makecab
--	to actually create the CAB file at the location specified by the @filepath parameter
--
-- REVISION HISTORY:
--	RLS [07/11/2002] -- Created
--
--------------------------------------------------------------------------------------------------

raiserror( 'Creating procedure [sp_gencabfile]', 1, 1 )
go

create procedure sp_gencabfile @filepath nvarchar(512)
as

set nocount on

declare @strMakeCab	varchar(8000)		-- The actual xp_makecab procedure call
declare @strFileName	varchar(8000)		-- The name of the file to add to the cabinet
declare @nFileID	integer			-- The ID of the parameter to xp_makecab
declare @strFileParm	varchar(8000)		-- Temporary holding location for parameters
declare @strFilePath	varchar(8000)

--
-- Declare the cursor to loop over the tblCabFiles table
-- gathering the files to add to the cabinet
--
declare curCabFiles cursor fast_forward for
select FileID, FilePath from tblCabFiles order by FileID

open curCabFiles
fetch next from curCabFiles into @nFileID, @strFileName

select @strMakeCab = N'exec master..xp_makecab @cabfilename = ''' + @filepath + ''', @compressionmode = ''MSzip'', @verboselevel=1'

while @@fetch_status = 0
begin
	
	--
	-- Build the file name string and concat it to the makecab call
	--
	print 'Adding [' + @strFileName + '] to CAB file.'

	select @strFilePath = ', @filepath' + cast(@nFileID as varchar) + ' = ''' + @strFileName + ''''
	print @strFilePath

	select @strMakeCab = @strMakeCab + @strFilePath

	--
	-- Get the next file from the table
	--
	fetch next from curCabFiles into @nFileID, @strFileName

end

close curCabFiles
deallocate curCabFiles

select len(@strMakeCab)
print @strMakeCab
exec(@strMakeCab)
go



------------------------------------------------------------------------------------------------
--
-- PROCEDURE:	sp_getversioninfo
--
-- DESCRIPTION:
--	Populates tblVersionInfo with the output of xp_msver
--
-- REVISION HISTORY:
--	RLS [08/02/2002] -- Created
--
--------------------------------------------------------------------------------------------------

raiserror( 'Creating procedure [sp_getversioninfo]', 1, 1 )
go

create procedure sp_getversioninfo @server nvarchar(50) = null
as

set nocount on

--
-- Insert xp_msver into the version table
--
insert into dbo.tblVersionInfo( [indexID], [name], [internal_value], [character_value] )
exec master.dbo.xp_msver

--
-- Update the table with the server information
--
if @server is not null
begin
	update dbo.tblVersionInfo set [server] = @server where [server] is null
end
go



------------------------------------------------------------------------------------------------
--
-- PROCEDURE:	sp_articleindexes
--
-- DESCRIPTION:
--	Returns information on the index structure of published tables
--
-- REVISION HISTORY:
--	RLS [08/02/2002] -- Created
--
--------------------------------------------------------------------------------------------------

raiserror( 'Creating procedure [sp_articleindexes]', 1, 1 )
go

create procedure [dbo].[sp_articleindexes] @repl_type nvarchar(5)	/* Should be either TRAN, MERGE, or BOTH */
as

set nocount on

create table #tbl_helpindex
(
	[index_name] sysname,
	[index_desc] varchar(210),
	[index_keys] nvarchar(2078)
)

create table #tbl_indexes
(
	[PubName]	sysname,
	[ArticleName] 	sysname,	[ArticleID]	integer,
	[IndexName]	sysname null,
	[IndexID]	integer null,
	[IndexDesc]	varchar(210) null,
	[IndexKeys]	nvarchar(2078) null,
	[StatsDate]	datetime,
	[ReplType]	nvarchar(50)
)

declare @articleName  sysname

if @repl_type not in ( N'MERGE', N'TRAN', N'BOTH' )
begin
	raiserror( N'Invalid replication type specified', 16, 1 )
	return(1)
end

--
-- Reduce the lock overhead on the actual base system tables by inserting into a temp table
--
if @repl_type = N'MERGE' or @repl_type = N'BOTH'
begin
	if exists(select * from sysobjects where name = N'sysmergearticles')
	begin
		insert into #tbl_indexes( [PubName], [ArticleName], [ArticleId], [IndexName], [IndexID], [StatsDate], [ReplType] )
		select 	P.[name], A.[name], A.[objid], I.[name], I.[indid], 
			stats_date(A.[objid], I.[indid]) 'StatsDate', N'Merge'
		from 	sysmergearticles A (nolock)
			join sysmergepublications P (nolock) on A.[pubid] = P.[pubid]
			join sysindexes I (nolock) on A.[objid] = I.[id]
		where	I.[indid] > 0 
		  and 	I.[indid] < 255 
		  and   (I.[status] & 64) = 0
	end
end

if @repl_type = N'TRAN' or @repl_type = N'BOTH'
begin
	if exists(select * from sysobjects where name = N'sysarticles')
	begin
		insert into #tbl_indexes( [PubName], [ArticleName], [ArticleId], [IndexName], [IndexID], [StatsDate], [ReplType] )
		select 	P.[name], A.[name], A.[objid], I.[name], I.[indid], 
			stats_date(A.[objid], I.[indid]) 'StatsDate', N'Transactional'
		from 	sysarticles A (nolock)
			join syspublications P (nolock) on P.[pubid] = A.[pubid]
			join sysindexes I (nolock) on A.[objid] = I.[id]
		where	I.[indid] > 0 
		  and 	I.[indid] < 255 
		  and   (I.[status] & 64) = 0
	end
end

declare curArticles cursor fast_forward 
for 
	select [ArticleName] from #tbl_indexes

open curArticles
fetch next from curArticles into @articleName

while @@fetch_status = 0
begin
	insert into #tbl_helpindex exec sp_helpindex @articleName
	fetch next from curArticles into @articleName
end

close curArticles
deallocate curArticles

--
-- Update our table with the sp_helpindex information
--
update 	#tbl_indexes
set 	[IndexDesc] = HI.[index_desc],
    	[IndexKeys] = HI.[index_keys]
from	#tbl_helpindex HI join #tbl_indexes I on HI.[index_name] = I.[IndexName]

print '--'
print '-- Index structure for published articles'
print '--'
select 	left([PubName], 35) 'Publication Name',
	left([ArticleName], 35) 'Article Name',
	left([IndexName], 35) 'Index Name',
	[IndexID] 'ID',
	left([IndexDesc], 75) 'Description',
	left([IndexKeys], 25) 'Index Keys',
	[StatsDate] 'Last Stats Update',
	datediff(dd, [StatsDate], getdate()) 'Days Since Last Stats Update'
from 	#tbl_indexes

if( select count(*) from #tbl_indexes where [StatsDate] is null ) > 0
begin
	print ''
	print '--'
	print '-- WARNING:  Articles without updated stats, or aged statistics (> 7 days)'
	print '--'
	select 	left([PubName], 35) 'Publication Name',
		left([ArticleName], 35) 'Article Name',
		left([IndexName], 35 ) 'Index Name',
		left([IndexDesc], 75) 'Description'
	from 	#tbl_indexes
	where	[StatsDate] is null
	   or	datediff(dd, [StatsDate], getdate()) > 7
	
	print ''
	print '--'
	select 	N'UPDATE STATISTICS ' + [ArticleName] + N' ' + [IndexName] + ' WITH FULLSCAN' as '-- Suggested UPDATE STATISTICS statements' 
	from 	#tbl_indexes 
	where 	[StatsDate] is null
	   or	datediff(dd, [StatsDate], getdate()) > 7
end

drop table #tbl_indexes
drop table #tbl_helpindex
go

------------------------------------------------------------------------------------------------
--
-- PROCEDURE:	sp_articleindexes
--
-- DESCRIPTION:
--	Returns information on the index structure of published tables
--
-- REVISION HISTORY:
--	RLS [08/02/2002] -- Created
--
--------------------------------------------------------------------------------------------------

raiserror( 'Creating procedure [sp_agentprofiles]', 1, 1 )
go


create procedure [dbo].[sp_agent_profiles] @agent_type nvarchar(15)
as

set nocount on

if @agent_type not in ('Distribution', 'Logreader', 'Merge', 'Snapshot', 'QueueReader', 'All', 'TRAN' )
begin
	raiserror( 'Invalid replication agent type specified.', 16, 1 )
	return(1)
end

--
-- This is really just a simple join between a couple of tables in MSDB and the agent tables
-- in the distribution database
--
if @agent_type in ( 'Distribution', 'All', 'Tran' )
begin

	print '--'
	print '-- Distribution Agent Profiles'
	print '--'

	select 	A.[id] as 'Agent ID',
		left( A.[name], 75 ) as 'Agent Name',
		left(P.[Profile_Name], 35) as 'Profile Name',
		left(PRMS.[Parameter_Name], 35) as 'Parameter Name',
		left(PRMS.[Value], 15) as 'Param Value'
	from 	distribution.dbo.MSdistribution_agents A (nolock)
		join msdb.dbo.MSagent_profiles P (nolock) on P.profile_id = A.profile_id
		join msdb.dbo.MSagent_parameters PRMS (nolock) on P.profile_id = PRMS.profile_id
	order by A.[id], PRMS.[parameter_name]

end

if @agent_type in ( 'LogReader', 'All', 'Tran' )
begin

	print '--'
	print '-- Log Reader Agent Profiles'
	print '--'

	select 	A.[id] as 'Agent ID',
		left( A.[name], 75 ) as 'Agent Name',
		left(P.[Profile_Name], 35) as 'Profile Name',
		left(PRMS.[Parameter_Name], 35) as 'Parameter Name',
		left(PRMS.[Value], 15) as 'Param Value'
	from 	distribution.dbo.MSLogreader_agents A (nolock)
		join msdb.dbo.MSagent_profiles P (nolock) on P.profile_id = A.profile_id
		join msdb.dbo.MSagent_parameters PRMS (nolock) on P.profile_id = PRMS.profile_id
	order by A.[id], PRMS.[parameter_name]

end

if @agent_type in ( 'Snapshot', 'All', 'Tran', 'Merge' )
begin

	print '--'
	print '-- Snapshot Agent Profiles'
	print '--'

	select 	A.[id] as 'Agent ID',
		left( A.[name], 75 ) as 'Agent Name',
		left(P.[Profile_Name], 35) as 'Profile Name',
		left(PRMS.[Parameter_Name], 35) as 'Parameter Name',
		left(PRMS.[Value], 15) as 'Param Value'
	from 	distribution.dbo.MSsnapshot_agents A (nolock)
		join msdb.dbo.MSagent_profiles P (nolock) on P.profile_id = A.profile_id
		join msdb.dbo.MSagent_parameters PRMS (nolock) on P.profile_id = PRMS.profile_id
	order by A.[id], PRMS.[parameter_name]

end

if @agent_type in ( 'QueueReader', 'All', 'Tran' )
begin

	print '--'
	print '-- Queue Reader Agent Profiles'
	print '--'

	select 	A.[id] as 'Agent ID',
		left( A.[name], 75 ) as 'Agent Name',
		left(P.[Profile_Name], 35) as 'Profile Name',
		left(PRMS.[Parameter_Name], 35) as 'Parameter Name',
		left(PRMS.[Value], 15) as 'Param Value'
	from 	distribution.dbo.MSqreader_agents A (nolock)
		join msdb.dbo.MSagent_profiles P (nolock) on P.profile_id = A.profile_id
		join msdb.dbo.MSagent_parameters PRMS (nolock) on P.profile_id = PRMS.profile_id
	order by A.[id], PRMS.[parameter_name]

end

if @agent_type in ( 'Merge', 'All' )
begin

	print '--'
	print '-- Merge Agent Profiles'
	print '--'

	select 	A.[id] as 'Agent ID',
		left(A.[name], 75) as 'Agent Name',
		left(P.[Profile_Name], 35) as 'Profile Name',
		left(PRMS.[Parameter_Name], 35) as 'Parameter Name',
		left(PRMS.[Value], 15) as 'Param Value'
	from 	distribution.dbo.MSmerge_agents A (nolock)
		join msdb.dbo.MSagent_profiles P (nolock) on P.profile_id = A.profile_id
		join msdb.dbo.MSagent_parameters PRMS (nolock) on P.profile_id = PRMS.profile_id
	order by A.[id], PRMS.[parameter_name]

end
go