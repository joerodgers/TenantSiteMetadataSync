IF OBJECT_ID('dbo.proc_StopSyncJobExecution', 'P') IS NOT NULL
   DROP PROCEDURE dbo.proc_StopSyncJobExecution
GO

CREATE PROCEDURE dbo.proc_StopSyncJobExecution
    @Name       nvarchar(50),
    @ErrorCount int
AS
BEGIN

    IF NOT EXISTS(SELECT 1 FROM dbo.SyncJob WHERE [Name] = @Name)
    BEGIN
        INSERT INTO dbo.SyncJob (
            [Name], 
            [Started],
            [Finished],
            [LastFinished],
            ErrorCount) 
        VALUES (
            @Name, 
            NULL,
            GETDATE(),
            GETDATE(),
            @ErrorCount)
    END
    ELSE
    BEGIN
        UPDATE 
            dbo.SyncJob 
        SET 
            [Finished]     = GETDATE(),
            [LastFinished] = GETDATE(),
            ErrorCount = 0
        WHERE
            [Name] = @Name 
    END
END
GO
