IF OBJECT_ID('dbo.proc_AddSecondarySiteAdminBySiteId', 'P') IS NOT NULL
   DROP PROCEDURE dbo.proc_AddSecondarySiteAdminBySiteId
GO

/*
CREATE PROCEDURE dbo.proc_AddSecondarySiteAdminBySiteId
    @SiteId            uniqueidentifier,
    @UserPrincipalName nvarchar(500)
AS
BEGIN

    IF NOT EXISTS(SELECT 1 FROM dbo.SecondarySiteAdministrator WHERE SiteId = @SiteId AND UserPrincipalName = @UserPrincipalName)
    BEGIN
        INSERT INTO dbo.SecondarySiteAdministrator (
            SiteId, 
            UserPrincipalName) 
        VALUES (
            @SiteId, 
            @UserPrincipalName)
    END

END
GO

*/

CREATE PROCEDURE dbo.proc_AddSecondarySiteAdminBySiteId
    @SiteId               uniqueidentifier,
    @LoginName            nvarchar(500),
    @IsUserPrincipal      bit,
    @PrincipalDisplayName nvarchar(500)
AS
BEGIN

    IF NOT EXISTS(SELECT 1 FROM dbo.SecondarySiteAdministrator WHERE SiteId = @SiteId AND LoginName = @LoginName)
    BEGIN
        INSERT INTO dbo.SecondarySiteAdministrator (
            SiteId, 
            LoginName,
            IsUserPrincipal,
            PrincipalDisplayName) 
        VALUES (
            @SiteId, 
            @LoginName,
            @IsUserPrincipal,
            @PrincipalDisplayName) 
    END

END
GO
