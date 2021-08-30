IF OBJECT_ID('dbo.SitesAll', 'V') IS NOT NULL
   DROP VIEW dbo.SitesAll
GO

CREATE VIEW dbo.SitesAll
AS
    SELECT        
        *
    FROM 
        dbo.TVF_Sites_All()
GO

