
IF OBJECT_ID('dbo.proc_GetSiteAdminByUserPrincipalName', 'P') IS NOT NULL
   DROP PROCEDURE dbo.proc_GetSiteAdminByUserPrincipalName
GO

CREATE PROCEDURE [dbo].[proc_GetSiteAdminByUserPrincipalName]
    @UserPrincipalName  nvarchar(500)
AS
BEGIN

    SELECT DISTINCT
        sm.*
    FROM
        SitesActive sm,
        SecondarySiteAdministrator ssa
    WHERE
        sm.SiteId = ssa.SiteId 
        AND ( ssa.LoginName = @UserPrincipalName COLLATE SQL_Latin1_General_CP1_CI_AS 
              or sm.SiteOwnerEmail = @UserPrincipalName COLLATE SQL_Latin1_General_CP1_CI_AS )
        OR  sm.GroupId IN (
            SELECT 
                ga.GroupId 
            FROM 
                GroupsActive ga, 
                GroupOwner gow 
            WHERE 
                ga.GroupId = gow.GroupId 
                AND gow.UserPrincipalName = @UserPrincipalName COLLATE SQL_Latin1_General_CP1_CI_AS
        )

END
GO