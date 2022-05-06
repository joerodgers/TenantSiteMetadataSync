IF OBJECT_ID('dbo.GroupConnectedSites', 'V') IS NOT NULL
   DROP VIEW dbo.GroupConnectedSites
GO

CREATE VIEW dbo.GroupConnectedSites
AS
    SELECT        
        *
    FROM    
        dbo.TVF_GroupSites_Active()
GO