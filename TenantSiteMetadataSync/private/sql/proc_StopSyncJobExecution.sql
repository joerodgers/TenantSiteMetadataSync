IF OBJECT_ID('dbo.proc_StopSyncJobExecution', 'P') IS NOT NULL
   DROP PROCEDURE dbo.proc_StopSyncJobExecution
GO

CREATE PROCEDURE dbo.proc_StopSyncJobExecution
    @Name       nvarchar(100),
    @ErrorCount int
AS
BEGIN

    IF NOT EXISTS(SELECT 1 FROM dbo.SyncJob WHERE [Name] = @Name)
    BEGIN
        INSERT INTO dbo.SyncJob 
        (
            [Name],
            [Started]
        ) 
        VALUES
        (
            @Name,
            GETDATE()
        )
    END

    UPDATE 
        dbo.SyncJob 
    SET 
        [Finished] = GETDATE(),
        ErrorCount = @ErrorCount
    WHERE
        [Name] = @Name 

END
GO
