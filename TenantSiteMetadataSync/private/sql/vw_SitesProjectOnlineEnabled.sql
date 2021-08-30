IF OBJECT_ID('dbo.SitesProjectOnlineEnabled', 'V') IS NOT NULL
   DROP VIEW dbo.SitesProjectOnlineEnabled
GO

CREATE VIEW dbo.SitesProjectOnlineEnabled
AS
    SELECT
        *
    FROM            
        dbo.TVF_Sites_Active()
    WHERE
        (PWAEnabled = 1)
GO

