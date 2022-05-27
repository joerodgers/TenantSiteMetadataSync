IF OBJECT_ID('dbo.SitesBasicActive', 'V') IS NOT NULL
   DROP VIEW dbo.SitesBasicActive
GO

CREATE VIEW dbo.SitesBasicActive
AS
    SELECT        
        *
    FROM 
        dbo.TVF_SitesBasic_Active()
GO

