IF OBJECT_ID('dbo.SitesWithOwnerAndSecondaryAdmins', 'V') IS NOT NULL
DROP VIEW dbo.SitesWithOwnerAndSecondaryAdmins
GO

CREATE VIEW dbo.SitesWithOwnerAndSecondaryAdmins
AS
    SELECT DISTINCT
        SM.*
        ,STUFF
        (
            (SELECT 
                N';' + LoginName 
             FROM 
                SecondarySiteAdministrator 
             WHERE 
                SiteId = SCA.SiteId 
             FOR XML PATH('')
            ), 1, 1, ''
        ) AS 'SiteCollectionAdminUserPrincpalNames'
    FROM 
        dbo.TVF_Sites_Active() SA
        FULL OUTER JOIN
        SecondarySiteAdministrator SCA
        ON SA.SiteId = SCA.SiteId
        FULL OUTER JOIN
        SiteMetadata SM
        ON SM.SiteId = SA.SiteId
GO