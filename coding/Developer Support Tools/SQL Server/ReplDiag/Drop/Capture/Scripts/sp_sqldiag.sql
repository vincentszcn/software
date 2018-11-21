USE master
GO
IF OBJECT_ID('dbo.sp_sqldiag') IS NOT NULL
  DROP PROC dbo.sp_sqldiag
GO
CREATE PROC dbo.sp_sqldiag 
	@UserName sysname=NULL, 
	@Password sysname=NULL, 
	@ExcludeErrorLogs bit=0, 
	@PerformDBCCStackDump bit=0, 
	@RetrieveClusterInfo bit=0
AS
SET NOCOUNT ON
IF (@UserName='/?') GOTO Help
DECLARE @cmd nvarchar(256), 
	@parms nvarchar(256),
	@InstanceName nvarchar(256), 
	@SQLPath nvarchar(256), 
	@ErrPath nvarchar(256), 
	@FileName nvarchar(256), 
	@RegKey nvarchar(256),
	@Len int,
	@Pos int

-- Get the instance name (use sp_executesql to keep from confusing SS 7.0)
IF (@@MICROSOFTVERSION >= 134217922 /* SS2K RTM */) BEGIN 
  BEGIN
   SELECT @cmd = N'SELECT @InstanceName = CAST(SERVERPROPERTY(''InstanceName'') AS sysname)',
   			  @parms = N'@InstanceName sysname OUT'
   EXEC dbo.sp_executesql @cmd, @parms, @InstanceName OUT
  END
END

-- Get the setup path for SQL Server
SET @RegKey='Software\Microsoft\'+ISNULL('Microsoft SQL Server\'+@InstanceName,'MSSQLServer')+'\Setup'
EXEC master.dbo.xp_regread N'HKEY_LOCAL_MACHINE',@RegKey,N'SQLPath',@SQLPath OUT

-- Get the errorlog path so that we can write the output there
SET @RegKey='Software\Microsoft\'+ISNULL('Microsoft SQL Server\'+@InstanceName,'MSSQLServer')+'\MSSQLServer\Parameters'
CREATE TABLE #keyvalues (keyvalue nvarchar(255) NOT NULL, keyvaluedata nvarchar(255) NULL)
INSERT #keyvalues EXEC master.dbo.xp_regenumvalues 'HKEY_LOCAL_MACHINE', @RegKey
IF (@@ERROR <> 0) BEGIN
	DROP TABLE #keyvalues
	RETURN -1
END
SELECT @ErrPath=SUBSTRING(keyvaluedata,3,255) FROM #keyvalues WHERE UPPER(LEFT(keyvaluedata,2))='-E'
DROP TABLE #keyvalues

-- We have the full path to the errorlog; remove the file name itself
SELECT @Len=LEN(@ErrPath)
SELECT @Pos=@Len
WHILE (SUBSTRING(@ErrPath,@Pos,1)<>'\') AND (@Pos<>1) BEGIN
  SET @Pos=@Pos-1
END
SET @ErrPath=LEFT(@ErrPath,@Pos)

-- Construct the call to sqldiag.exe and run it via xp_cmdshell
SET @FileName= @ErrPath + 'sp_sqldiag.txt'
SET @cmd='"'+@SQLPath+'\binn\sqldiag.exe" '+  
    CASE @ExcludeErrorLogs WHEN 1 THEN ' -X ' ELSE '' END+
    CASE @PerformDBCCStackDump WHEN 1 THEN ' -M ' ELSE '' END+
    CASE @RetrieveClusterInfo WHEN 1 THEN ' -C ' ELSE '' END+
    ' -O'+@FileName+ 
    CASE WHEN @UserName IS NULL THEN ' -E' ELSE ' -U'+@UserName+ISNULL(' -P'+@Password,'') END+ISNULL(' -I'+@InstanceName,'')
EXEC master.dbo.xp_cmdshell @cmd
-- Read the output file and return it as a result set
EXEC master.dbo.xp_readerrorlog -1, @Filename
RETURN 0
Help:
DECLARE @crlf char(2), @tabc char(1)
SET @crlf=char(13)+char(10)
SET @tabc=char(9)
PRINT 'sp_sqldiag -- Runs sqldiag from a query utility such as Query Analyzer'
PRINT @crlf+'Parameters:'
PRINT @tabc+'Parameter                  Type         Default                        Purpose'
PRINT @tabc+'-------------------------- ------------ ------------------------------ ------------------------------------------------------------------------------------------'
PRINT @tabc+'@UserName                  sysname      NULL                           Specifies the name of the user to login with (specify NULL to use Windows Authentication)'
PRINT @tabc+'@Password                  sysname      NULL                           Specifies the password to use (leave blank when using Windows Authentication)'
PRINT @tabc+'@ExcludeErrorLogs          bit          0                              Excludes error logs from the report'
PRINT @tabc+'@PerformDBCCStackDump      bit          0                              Includes a DBCC STACKDUMP with the report'
PRINT @tabc+'@RetrieveClusterInfo       bit          0                              Includes clustering info with the report'
PRINT @crlf+'Examples: '
PRINT @crlf+@tabc+'EXEC sp_sqldiag'
PRINT @crlf+@tabc+'EXEC sp_sqldiag ''sa'''
PRINT @crlf+@tabc+'EXEC sp_sqldiag @RetrieveClusterInfo=1'
PRINT @crlf+@tabc+'EXEC sp_sqldiag @ExcludeErrorLogs=1'
RETURN -1
GO
EXEC dbo.sp_sqldiag '/?'


