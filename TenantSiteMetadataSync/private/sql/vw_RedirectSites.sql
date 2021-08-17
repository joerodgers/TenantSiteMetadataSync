IF OBJECT_ID('dbo.RedirectSites', 'V') IS NOT NULL
   DROP VIEW dbo.RedirectSites
GO

CREATE VIEW dbo.RedirectSites
AS
    SELECT        
        *
    FROM 
        dbo.TVF_Sites_Active()
    WHERE
        (TemplateName = 'RedirectSite#0')
GO

