/*
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

-- add SiteMetadata.SiteOwnerUserPrincipalName column
IF NOT EXISTS(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'SiteMetadata' AND COLUMN_NAME = 'SiteOwnerUserPrincipalName' ) 
BEGIN
    ALTER TABLE dbo.SiteMetadata ADD SiteOwnerUserPrincipalName nvarchar(255) NULL;
END

-- drop SiteMetadata.LastListActivityOn column
IF EXISTS(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'SiteMetadata' AND COLUMN_NAME = 'LastListActivityOn' ) 
BEGIN
    ALTER TABLE dbo.SiteMetadata DROP COLUMN LastListActivityOn;
END

-- add SyncJob.LastExecutionElapsedTime column
IF NOT EXISTS(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'SyncJob' AND COLUMN_NAME = 'LastExecutionElapsedTime' ) 
BEGIN
    
    DROP TABLE dbo.SyncJob;

    CREATE TABLE dbo.SyncJob(
        [Name]                     nvarchar(100) NOT NULL,
        [Started]                  datetime2(0),
        [Finished]                 datetime2(0),
        [LastExecutionElapsedTime] bigint,
        [ErrorCount]               int,
        CONSTRAINT PK_SyncJobName PRIMARY KEY (Name)
    )

END

-- ensure the database collation is case insensitive
USE master
GO
IF EXISTS (SELECT name FROM sys.databases WHERE name = N'TenantSiteMetadataSync')
BEGIN

   DECLARE @databaseCollation nvarchar(100)
   SELECT  @databaseCollation = collation_name FROM sys.databases WHERE NAME = N'TenantSiteMetadataSync'
   
   IF ( @databaseCollation <> 'SQL_Latin1_General_CP1_CI_AS' )
   BEGIN
   PRINT 'ALTERTING'
         ALTER DATABASE TenantSiteMetadataSync COLLATE SQL_Latin1_General_CP1_CI_AS;
   END
END