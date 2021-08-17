IF OBJECT_ID('dbo.DeletedSites', 'V') IS NOT NULL
   DROP VIEW dbo.DeletedSites
GO

CREATE VIEW dbo.DeletedSites
AS
    SELECT
        *
    FROM
        dbo.TVF_Sites_Deleted()
GO
