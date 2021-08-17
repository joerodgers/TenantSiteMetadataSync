IF OBJECT_ID('dbo.OneDriveForBusinessSites', 'V') IS NOT NULL
   DROP VIEW dbo.OneDriveForBusinessSites
GO

CREATE VIEW dbo.OneDriveForBusinessSites
AS
    SELECT
        *
    FROM            
        dbo.TVF_Sites_Active()
    WHERE
        (TemplateName like 'SPSPERS%')
GO
