IF OBJECT_ID('dbo.SitesDeleted', 'V') IS NOT NULL
   DROP VIEW dbo.SitesDeleted
GO

CREATE VIEW dbo.SitesDeleted
AS
    SELECT
        *
    FROM
        dbo.TVF_Sites_Deleted()
GO
