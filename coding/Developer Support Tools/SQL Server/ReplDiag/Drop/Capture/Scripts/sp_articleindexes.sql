
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_articleindexes]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_articleindexes]
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