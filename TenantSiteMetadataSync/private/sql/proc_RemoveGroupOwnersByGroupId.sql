IF OBJECT_ID('dbo.proc_RemoveGroupOwnersByGroupId', 'P') IS NOT NULL
   DROP PROCEDURE dbo.proc_RemoveGroupOwnersByGroupId
GO

CREATE PROCEDURE dbo.proc_RemoveGroupOwnersByGroupId
	@GroupId    uniqueidentifier
AS
BEGIN
        DELETE FROM 
            dbo.GroupOwner
        WHERE
            GroupId = @GroupId
END
GO
