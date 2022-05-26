IF OBJECT_ID('dbo.GroupConnectedSitesAndOwner', 'V') IS NOT NULL
    DROP VIEW dbo.GroupConnectedSitesAndOwner
GO

CREATE VIEW dbo.GroupConnectedSitesAndOwner
AS
    SELECT DISTINCT
         GCS.*
        ,STUFF
        (
            (SELECT 
                ';' + UserPrincipalName 
             FROM
                GroupOwner
             WHERE
                GroupId = O.GroupId 
             FOR XML PATH('')
            ),
             1,
             1,
             ''
        ) AS 'GroupOwners'
    FROM
        dbo.TVF_GroupSites_Active() GCS
        LEFT JOIN
        GroupOwner O
        ON GCS.GroupId = O.GroupId

GO