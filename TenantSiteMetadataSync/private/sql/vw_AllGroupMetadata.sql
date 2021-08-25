IF OBJECT_ID('dbo.AllGroupMetadata', 'V') IS NOT NULL
   DROP VIEW dbo.AllGroupMetadata
GO

CREATE VIEW dbo.AllGroupMetadata
AS
    SELECT
         DISTINCT
         GCS.[SiteUrl]
        ,GCS.TimeCreated
        ,GCS.IsTeamsConnected
        ,GM.*
    FROM 
        TVF_GroupSites_Active() GCS
        FULL OUTER JOIN
        GroupMetadata GM
        ON GM.GroupId = GCS.GroupId
GO
