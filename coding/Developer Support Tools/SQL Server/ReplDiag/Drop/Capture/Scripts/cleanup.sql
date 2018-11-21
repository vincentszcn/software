

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_addtocabfile]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_addtocabfile]
go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_gencabfile]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_gencabfile]
go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_getversioninfo]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_getversioninfo]
go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_articleindexes]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_articleindexes]
go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_addtranobjects_publisher]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_addtranobjects_publisher]
go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_addtranobjects_distributor]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_addtranobjects_distributor]
go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_exportobjects]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_exportobjects]
go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_getdbtable]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_getdbtable]
go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_getrepltrans]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_getrepltrans]
go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_addmergeobjects]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_addmergeobjects]
go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_ExportMergeObjects]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_ExportMergeObjects]
go



if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_getlsn]') and OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
drop function [dbo].[fn_getLSN]
go


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[tblCabFiles]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[tblCabFiles]
go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[tblVersionInfo]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[tblVersionInfo]
go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[tblTranObjects]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[tblTranObjects]
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[tblMergeObjects]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[tblMergeObjects]
go

