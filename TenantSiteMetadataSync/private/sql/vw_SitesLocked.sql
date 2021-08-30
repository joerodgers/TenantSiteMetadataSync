IF OBJECT_ID('dbo.SitesLocked', 'V') IS NOT NULL
   DROP VIEW dbo.SitesLocked
GO

CREATE VIEW dbo.SitesLocked
AS
    SELECT
        *
    FROM            
        dbo.TVF_Sites_Active()
    WHERE
        LockState <> 'Unlock' AND TemplateName <> 'RedirectSite#0'
GO
