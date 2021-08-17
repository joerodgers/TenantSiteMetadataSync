IF OBJECT_ID('dbo.OneDriveForBusinessSitesLimited', 'V') IS NOT NULL
   DROP VIEW dbo.OneDriveForBusinessSitesLimited
GO

CREATE VIEW dbo.OneDriveForBusinessSitesLimited
AS
    SELECT
        SiteUrl, 
        SiteOwnerEmail, 
        SiteOwnerName,
        NumOfFiles,
        StorageUsed
    FROM            
        dbo.OneDriveForBusinessSites
GO
