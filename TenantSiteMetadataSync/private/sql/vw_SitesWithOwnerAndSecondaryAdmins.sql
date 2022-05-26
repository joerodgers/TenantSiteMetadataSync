IF OBJECT_ID('dbo.SitesWithOwnerAndSecondaryAdmins', 'V') IS NOT NULL
DROP VIEW dbo.SitesWithOwnerAndSecondaryAdmins
GO

CREATE VIEW dbo.SitesWithOwnerAndSecondaryAdmins
AS
    SELECT DISTINCT
        SA.*
        ,STUFF
        (
            (SELECT 
                N';' + LoginName 
             FROM 
                SecondarySiteAdministrator 
             WHERE
                SiteId = SCA.SiteId AND IsUserPrincipal = 1
             FOR XML PATH('')
            ), 
            1, 
            1,
            ''
        ) AS 'SiteCollectionAdminUserPrincpalNames'
        ,STUFF
        (
            (SELECT 
                N';' + Replace(LoginName, 'c:0t.c|tenant|', '')
             FROM 
                SecondarySiteAdministrator 
             WHERE 
                SiteId = SCA.SiteId AND IsUserPrincipal = 0
             FOR XML PATH('')
            ), 
            1,
            1, 
            ''
        ) AS 'SiteCollectionAdminGroupIds'
    FROM
        dbo.TVF_Sites_Active() SA
        LEFT JOIN
        SecondarySiteAdministrator SCA
        ON SA.SiteId = SCA.SiteId
GO
