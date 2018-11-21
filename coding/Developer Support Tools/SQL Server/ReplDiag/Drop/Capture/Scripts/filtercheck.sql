/***************************************************************************
FilterCheck.sql
Owner: Li Zhang (SQL)
History:

Description:
	The tool does the following:
		Checking existence of subset filter and join filters on the same article 
		Checking existence of multiple join filters on the same article 
		Checking existence of circular join filters in articles 
		Finding deepest join filter chains of articles 
		Checking reference to un-published tables in article filters 

******************************************************************************/

set nocount on

if DATABASEPROPERTYEX(DB_NAME(), 'IsMergePublished') = 0
  begin
    print 'Current database is not published for merge replication.'
    goto done
  end

print ' '
print '--'
print '-- Checking existence of subset filter and join filters on the same article'
print '--'
print ' '

select 'pubname' = p.name, 'artname' = a.name 
into #multiplefilters1
from sysmergearticles a, sysmergesubsetfilters f, sysmergepublications p
where a.artid = f.artid 
and a.pubid = f.pubid
and a.subset_filterclause is not null 
and a.subset_filterclause <> ''
and a.pubid = p.pubid

if exists (select * from #multiplefilters1)
  begin
    print 'The following articles have both subset filter and join filters. The logical relationship of these '
    print 'filters is OR and will be implemented as UNION in the article view. This may have performance impact.'
    print 'You may wish to consider re-implementing them.'
    print ' '
    select 'Publication Name' = pubname, 'Article Name' = artname
      from #multiplefilters1
    print ' '
  end

drop table #multiplefilters1


print '--'
print '-- Checking existence of multiple join filters on the same article ...'
print '--'
print ' '

select f.pubid, f.artid
into #multiplefilters2
from sysmergesubsetfilters f
group by f.pubid, f.artid
having count(*) > 1

if exists (select * from #multiplefilters2)
  begin
    print 'The following articles have multiple join filters. The logical relationship of these filters is OR '
    print 'and will be implemented as UNION in the article view. This may have performance impact. '
    print ' '
    select 'Publication Name' = p.name, 'Article Name' = a.name, 'Join Article Name' = f.join_articlename, 'Filter Name' = f.filtername
      from #multiplefilters2 m, sysmergearticles a, sysmergesubsetfilters f, sysmergepublications p
     where m.artid = a.artid
       and m.pubid = a.pubid
       and m.artid = f.artid
       and m.pubid = f.pubid
       and p.pubid = m.pubid
     order by 1, 2 
    print ' '
  end

drop table #multiplefilters2

print '--'
print '-- Checking existence of circular join filters in articles ...'
print '--'
print ' '

select distinct 'pubname' = p.name, 'artname' = a.name, f.join_articlename, 'level' = NULL
into #multiplefilters3
from sysmergesubsetfilters f, sysmergepublications p, sysmergearticles a
where f.pubid = a.pubid
  and f.artid = a.artid
  and f.pubid = p.pubid

declare @level int
select @level = 0
while @level = 0 OR @@rowcount > 0
  begin
    select @level = @level + 1
    update m3a
       set m3a.level = @level
      from #multiplefilters3 m3a
     where m3a.level is NULL 
       and m3a.join_articlename not in (select artname from #multiplefilters3 m3b 
					where m3b.level is NULL and m3a.pubname = m3b.pubname)
  end

select @level = 0
while @level = 0 OR @@rowcount > 0
  begin
    select @level = @level - 1
    update m3a
       set m3a.level = @level
      from #multiplefilters3 m3a
     where m3a.level is NULL 
       and m3a.artname not in (select join_articlename from #multiplefilters3 m3b 
					where m3b.level is NULL and m3a.pubname = m3b.pubname)
  end

if exists (select * from #multiplefilters3 where level is NULL)
  begin
    print 'The following articles have circular join filters with other articles. This may have performance impact. '
    print ' '
    select 'Publication Name' = pubname, 'Article Name' = artname, 'Join Article Name' = join_articlename
      from #multiplefilters3 
     where level is NULL
     order by 1, 2, 3
    print ' '
  end

print '--'
print '-- Finding deepest join filter chains of articles ...'
print '-- '
print ' '

declare @max int, @min int, @start int, @end int, @pubname sysname, @artname sysname, @sequence int
select @max = max(level), @min = min(level) from #multiplefilters3
where level is not null
if @max >= 0 - @min 
  select @start = @max, @end = 1
else
  select @start = -1, @end = @min

declare #cursor_deepest_articles cursor for
select pubname, artname from #multiplefilters3 where level = @start

print 'The following artile sets have the deepest level join filters in the database. '
print ' '

select @sequence = 1
open #cursor_deepest_articles
fetch #cursor_deepest_articles into @pubname, @artname
while @@fetch_status <> -1
  begin
    create table #articlechain (id int identity primary key, pubname sysname, artname sysname)
    insert #articlechain (pubname, artname) values (@pubname, @artname)
    if @max >= 0 - @min 
      select @start = @max, @end = 1
    else
      select @start = -1, @end = @min

    while @start >= @end
      begin
        select @artname = join_articlename 
          from #multiplefilters3 
         where level = @start
           and artname = @artname
           and pubname = @pubname
        insert #articlechain (pubname, artname) values (@pubname, @artname)
        select @start = @start - 1
      end
    print 'Article Set #' + convert(varchar(32), @sequence)
    print ' '
    select 'Publication Name' = pubname, 'Article Name ' = artname from #articlechain order by id desc
    print ' '
    drop table #articlechain
    fetch #cursor_deepest_articles into @pubname, @artname
    select @sequence = @sequence + 1
  end
deallocate #cursor_deepest_articles

drop table #multiplefilters3


print '-- '
print '-- Checking reference to un-published tables in article filters ...'
print '-- '
print ' '

declare #csr_filtered_articles cursor for 
select a.pubid, a.artid, a.sync_objid
from sysmergearticles a
where a.subset_filterclause <> '' 
and a.subset_filterclause is not null 
or exists 
(select * from sysmergesubsetfilters f 
where a.artid = f.artid and a.pubid = f.pubid)

create table #filter_article_dependencies (objid int primary key, expanded bit null)

declare @pubid uniqueidentifier, @artid uniqueidentifier, @sync_objid int

open #csr_filtered_articles
fetch #csr_filtered_articles into @pubid, @artid, @sync_objid
while @@fetch_status <> -1
  begin
    truncate table #filter_article_dependencies
    insert #filter_article_dependencies (objid, expanded) values (@sync_objid, NULL)
    while exists (select * from #filter_article_dependencies where expanded IS NULL)
      begin
        insert #filter_article_dependencies (objid, expanded)
        select distinct d.depid, 0 
          from sysdepends d, #filter_article_dependencies f 
         where d.id = f.objid
           and f.expanded IS NULL
           and not exists (select * from #filter_article_dependencies f2 
                            where f2.objid = d.depid)
        update #filter_article_dependencies set expanded = 1 where expanded IS NULL 
        update #filter_article_dependencies set expanded = NULL where expanded = 0
      end
    select f.objid
      into #nonpublishedtables
      from #filter_article_dependencies f, sysobjects o
     where f.objid = o.id
       and o.xtype = 'U'
       and f.objid not in (select objid from sysmergearticles where pubid = @pubid)

    if exists (select * from #nonpublishedtables)
      begin
        select @pubname = name from sysmergepublications where pubid = @pubid
        select @artname = name from sysmergearticles where pubid = @pubid and artid = @artid
        print ' '
        raiserror('Publication [%s] article [%s] references in its subset or join filter(s) ', 0, -1, @pubname, @artname)
        raiserror('the following tables that are not published. This may cause unexpected results at the subscriber.', 0, -1)
        select 'Table name' = object_name(objid) from #nonpublishedtables
      end
    drop table #nonpublishedtables
    fetch #csr_filtered_articles into @pubid, @artid, @sync_objid
  end
deallocate #csr_filtered_articles
drop table #filter_article_dependencies

done:
