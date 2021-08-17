IF OBJECT_ID('dbo.LockedSites', 'V') IS NOT NULL
   DROP VIEW dbo.LockedSites
GO

CREATE VIEW dbo.LockedSites
AS
    SELECT
        *
    FROM            
        dbo.TVF_Sites_Active()
    WHERE
        LockState <> 'Unlock' AND TemplateName <> 'RedirectSite#0'
GO
