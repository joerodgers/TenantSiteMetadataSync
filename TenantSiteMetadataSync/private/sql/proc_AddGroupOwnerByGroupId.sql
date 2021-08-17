IF OBJECT_ID('dbo.proc_AddGroupOwnerByGroupId', 'P') IS NOT NULL
   DROP PROCEDURE dbo.proc_AddGroupOwnerByGroupId
GO

CREATE PROCEDURE dbo.proc_AddGroupOwnerByGroupId
    @GroupId           uniqueidentifier,
    @UserPrincipalName nvarchar(500)
AS
BEGIN

    IF NOT EXISTS(SELECT 1 FROM dbo.GroupOwner WHERE GroupId = @GroupId AND UserPrincipalName = @UserPrincipalName)
    BEGIN
        INSERT INTO dbo.GroupOwner (
            GroupId, 
            UserPrincipalName) 
        VALUES (
            @GroupId, 
            @UserPrincipalName)
    END

END
GO

