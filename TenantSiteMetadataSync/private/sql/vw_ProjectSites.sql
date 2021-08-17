IF OBJECT_ID('dbo.ProjectSites', 'V') IS NOT NULL
   DROP VIEW dbo.ProjectSites
GO

CREATE VIEW dbo.ProjectSites
AS
    SELECT
        *
    FROM            
        dbo.TVF_Sites_Active()
    WHERE
        (PWAEnabled = 1)
GO

