IF OBJECT_ID('dbo.SitesBasicDeleted', 'V') IS NOT NULL
   DROP VIEW dbo.SitesBasicDeleted
GO

CREATE VIEW dbo.SitesBasicDeleted
AS
    SELECT
        *
    FROM
        dbo.TVF_SitesBasic_Deleted()
GO
