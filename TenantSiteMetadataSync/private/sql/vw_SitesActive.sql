IF OBJECT_ID('dbo.SitesActive', 'V') IS NOT NULL
   DROP VIEW dbo.SitesActive
GO

CREATE VIEW dbo.SitesActive
AS
    SELECT        
        *
    FROM 
        dbo.TVF_Sites_Active()
GO

