IF OBJECT_ID('dbo.OneDriveForBusinessSitesDeleted', 'V') IS NOT NULL
   DROP VIEW dbo.OneDriveForBusinessSitesDeleted
GO

CREATE VIEW dbo.OneDriveForBusinessSitesDeleted
AS
    SELECT
        *
    FROM
        dbo.TVF_Sites_Deleted()
    WHERE
        (TemplateName LIKE 'SPSPERS%')
GO

