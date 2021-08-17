IF OBJECT_ID('dbo.ActiveSites', 'V') IS NOT NULL
   DROP VIEW dbo.ActiveSites
GO

CREATE VIEW dbo.ActiveSites
AS
    SELECT        
        *
    FROM 
        dbo.TVF_Sites_Active()
GO

