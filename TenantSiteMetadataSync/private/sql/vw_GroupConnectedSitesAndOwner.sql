IF OBJECT_ID('dbo.GroupConnectedSitesAndOwner', 'V') IS NOT NULL
   DROP VIEW dbo.GroupConnectedSitesAndOwner
GO

CREATE VIEW dbo.GroupConnectedSitesAndOwner
AS
    SELECT
         DISTINCT
        GCS.[SiteUrl]
        ,GCS.TimeCreated
        ,GCS.IsTeamsConnected
        ,GM.*
        ,STUFF((SELECT N', ' + UserPrincipalName FROM GroupOwner WHERE GroupId = O.GroupId FOR XML PATH(''),TYPE).value('text()[1]','nvarchar(max)'),1,2,N'') AS 'GroupOwners'
    FROM 
        GroupConnectedSites GCS
        FULL OUTER JOIN
        GroupOwner O
        ON GCS.GroupId = O.GroupId
        FULL OUTER JOIN
        GroupMetadata GM
        ON GM.GroupId = GCS.GroupId
GO
