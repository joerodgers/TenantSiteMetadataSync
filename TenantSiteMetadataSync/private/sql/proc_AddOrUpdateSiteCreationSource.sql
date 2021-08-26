IF OBJECT_ID('dbo.proc_AddOrUpdateSiteCreationSource', 'P') IS NOT NULL
   DROP PROCEDURE dbo.proc_AddOrUpdateSiteCreationSource
GO

CREATE PROCEDURE dbo.proc_AddOrUpdateSiteCreationSource
	@Id     uniqueidentifier,
	@Source nvarchar(50)
AS
BEGIN

    IF NOT EXISTS( SELECT 1 FROM  dbo.SiteCreationSource WHERE Id = @Id)
    BEGIN
        INSERT INTO dbo.SiteCreationSource (
            Id, 
            Source) 
        VALUES (
            @Id, 
            @Source)
    END
    ELSE
    BEGIN
        UPDATE 
            dbo.SiteCreationSource 
        SET 
            Source = @Source
        WHERE
            Id = @Id 
    END
END
GO
