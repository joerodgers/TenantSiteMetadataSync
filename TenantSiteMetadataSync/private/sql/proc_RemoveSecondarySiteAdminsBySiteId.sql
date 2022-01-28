IF OBJECT_ID('dbo.proc_RemoveSecondarySiteAdminsBySiteId', 'P') IS NOT NULL
   DROP PROCEDURE dbo.proc_RemoveSecondarySiteAdminsBySiteId
GO

CREATE PROCEDURE dbo.proc_RemoveSecondarySiteAdminsBySiteId
	@SiteId  uniqueidentifier
AS
BEGIN
        DELETE FROM 
            dbo.SecondarySiteAdministrator
        WHERE
            SiteId = @SiteId
END
GO
