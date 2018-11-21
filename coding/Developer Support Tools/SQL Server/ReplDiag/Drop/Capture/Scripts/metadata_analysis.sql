set nocount on

declare @contents_size 	  integer
declare @tombstone_size	  integer
declare @genhistory_size  integer
declare @guidnull	  uniqueidentifier

select @guidnull = '00000000-0000-0000-0000-000000000000'

--
-- First, get a basic view of the size of the metadata tables
--
select @contents_size 	= count(*) from MSmerge_contents (nolock)
select @tombstone_size	= count(*) from MSmerge_tombstone (nolock)
select @genhistory_size = count(*) from MSmerge_genhistory (nolock)

print '--'
print '-- Metadata table sizes'
print '--'
select	@contents_size 'MSmerge_contents',
	@tombstone_size 'MSmerge_tombstone',
	@genhistory_size 'MSmerge_genhistory'


--
-- Do some basic generation analysis
--
print '--'
print '-- Generation Basics'
print '--'
select	left(A.[name], 25) 'Article Name', GH.generation 'Generation', 
	GH.coldate 'Generation Date', GH.art_nick 'Article Nickname'
from	sysmergearticles A join MSmerge_genhistory GH on A.nickname = GH.art_nick


--
-- Do some basic generation size analysis
--
print '--'
print '-- Generation sizes'
print '--'
select	GH.generation, GH.guidsrc,
	count(GH.generation) 'Generation Size', 
	left(A.[name], 35) as 'Article Name'
from	MSmerge_genhistory GH (nolock)	
	join MSmerge_contents C (nolock) on C.generation = GH.generation
	join sysmergearticles A (nolock) on A.nickname = GH.art_nick
group by GH.generation, GH.guidsrc, A.name
order by count(GH.generation) desc


--
-- Classify generations
--
print '--'
print '-- Generation classification'
print '--'
select	generation, guidsrc, guidlocal,
	'GenType' = case
		when guidlocal = @guidnull 	then 'OPEN'
		when guidsrc = guidsrc	 	then 'CLOSED, LOCAL'
		when guidsrc <> guidlocal	then 'CLOSED, REMOTE'
	end
from	MSmerge_genhistory
order by coldate, generation


--
-- Information on aged generations
--
declare @publication	sysname
declare @pubid		uniqueidentifier
declare @retention	integer
declare @expire_date	datetime
declare @threshold	integer

declare curPubs cursor fast_forward for
select [name], [retention], [pubid] from sysmergepublications (nolock)

open curPubs
fetch next from curPubs into @publication, @retention, @pubid

--
-- Analyze generations that will expire in 5 days
--
select @threshold = 5

while @@fetch_status = 0
begin

	select @expire_date = dateadd(dd, @retention, dateadd(dd, @threshold, getdate()))

	print '--'
	print '-- Metadata Cleanup Analysis:  ' + @publication + ' (' + cast(@pubid as varchar(255)) + ')'
	print '-- Expiration date (within ' + cast(@threshold as varchar) + N' days):  ' + cast(@expire_date as varchar)
	print '--'

	--
	-- Get the generations for articles in that publication
	--
	select 	GH.generation 'Generation', left(A.name, 25) 'Article Name', 
		count(C.generation) 'Est. Contents Rows', 
		count(T.generation) 'Est. Tombstone Rows',
		GH.coldate 'Generation Coldate'
	from 	MSmerge_genhistory GH (nolock)
		join sysmergearticles A (nolock) on A.nickname = GH.art_nick
		join Msmerge_contents C (nolock) on C.generation = GH.generation
		join Msmerge_tombstone T (nolock) on T.generation = GH.generation
	where	A.pubid = @pubid
	  and	GH.coldate < @expire_date
	group by GH.generation, A.name, GH.coldate

	fetch next from curPubs into @publication, @retention, @pubid
end
	
close curPubs
deallocate curPubs


--
-- What generations participate in filter changes?
--
print '--'
print '-- Partition Change Analysis'
print '--'
select	generation, 
	'Partition Change' = case
		when partchangegen <> 0 then 'SUBSET FILTER CHANGE'
		when joinchangegen <> 0 then 'JOIN FILTER CHANGE'
	end
from	MSmerge_contents (nolock)
where	joinchangegen is not null
  and	partchangegen is not null