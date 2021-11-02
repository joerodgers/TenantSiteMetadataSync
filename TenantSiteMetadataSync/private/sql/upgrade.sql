﻿/*
    08-27-2021 - Refactored views, removing any views using the old names
*/

-- delete ActiveSites View
IF OBJECT_ID('dbo.ActiveSites', 'V') IS NOT NULL
   DROP VIEW dbo.ActiveSites
GO

-- delete DeletedSites View
IF OBJECT_ID('dbo.DeletedSites', 'V') IS NOT NULL
   DROP VIEW dbo.DeletedSites
GO

-- delete AllGroupMetadata View
IF OBJECT_ID('dbo.AllGroupMetadata', 'V') IS NOT NULL
   DROP VIEW dbo.AllGroupMetadata
GO

-- delete LockedSites View
IF OBJECT_ID('dbo.LockedSites', 'V') IS NOT NULL
   DROP VIEW dbo.LockedSites
GO

-- delete TeamsSites View
IF OBJECT_ID('dbo.TeamsSites', 'V') IS NOT NULL
   DROP VIEW dbo.TeamsSites
GO

-- delete HubConnectedSites View
IF OBJECT_ID('dbo.HubConnectedSites', 'V') IS NOT NULL
   DROP VIEW dbo.HubConnectedSites
GO

-- delete ProjectSites View
IF OBJECT_ID('dbo.ProjectSites', 'V') IS NOT NULL
   DROP VIEW dbo.ProjectSites
GO

-- delete RedirectSites View
IF OBJECT_ID('dbo.RedirectSites', 'V') IS NOT NULL
   DROP VIEW dbo.RedirectSites
GO


-- drop SiteMetadata.SharedExternallyyFileCount column
IF EXISTS(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'SiteMetadata' AND COLUMN_NAME = 'SharedExternallyyFileCount' ) 
BEGIN
    ALTER TABLE dbo.SiteMetadata DROP COLUMN SharedExternallyyFileCount;
END

-- drop SiteMetadata.SharedInternallyFileCount column
IF EXISTS(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'SiteMetadata' AND COLUMN_NAME = 'SharedInternallyFileCount' ) 
BEGIN
    ALTER TABLE dbo.SiteMetadata DROP COLUMN SharedInternallyFileCount;
END

-- drop SiteMetadata.SyncedFileCount column
IF EXISTS(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'SiteMetadata' AND COLUMN_NAME = 'SyncedFileCount' ) 
BEGIN
    ALTER TABLE dbo.SiteMetadata DROP COLUMN SyncedFileCount;
END

-- drop SiteMetadata.StorageUsedPercentage column
IF EXISTS(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'SiteMetadata' AND COLUMN_NAME = 'StorageUsedPercentage' ) 
BEGIN
    ALTER TABLE dbo.SiteMetadata DROP COLUMN StorageUsedPercentage;
END

-- drop SiteMetadata.IsRestorable column
IF EXISTS(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'SiteMetadata' AND COLUMN_NAME = 'IsRestorable' ) 
BEGIN
    ALTER TABLE dbo.SiteMetadata DROP COLUMN IsRestorable;
END

-- drop SiteMetadata.LastWebActivityOn column
IF EXISTS(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'SiteMetadata' AND COLUMN_NAME = 'LastWebActivityOn' ) 
BEGIN
    ALTER TABLE dbo.SiteMetadata DROP COLUMN LastWebActivityOn;
END

