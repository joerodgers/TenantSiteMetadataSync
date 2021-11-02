IF OBJECT_ID('dbo.SitesRedirectors', 'V') IS NOT NULL
   DROP VIEW dbo.SitesRedirectors
GO

CREATE VIEW dbo.SitesRedirectors
AS
    SELECT        
        *
    FROM 
        dbo.TVF_Sites_Active()
    WHERE
        (TemplateName like 'RedirectSite%')
GO

