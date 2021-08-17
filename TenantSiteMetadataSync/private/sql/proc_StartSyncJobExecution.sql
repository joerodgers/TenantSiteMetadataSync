IF OBJECT_ID('dbo.proc_StartSyncJobExecution', 'P') IS NOT NULL
   DROP PROCEDURE dbo.proc_StartSyncJobExecution
GO

CREATE PROCEDURE dbo.proc_StartSyncJobExecution
    @Name nvarchar(50)
AS
BEGIN

    IF NOT EXISTS( SELECT 1 FROM dbo.SyncJob WHERE [Name] = @Name)
    BEGIN
        INSERT INTO dbo.SyncJob (
            [Name], 
            [Started],
            [Finished],
            [LastFinished],
            ErrorCount) 
        VALUES (
            @Name, 
            GETDATE(),
            NULL,
            NULL,
            0)
    END
    ELSE
    BEGIN
        UPDATE 
            dbo.SyncJob 
        SET 
            [Started]  = GETDATE(),
            [Finished] = NULL,
            ErrorCount = 0
        WHERE
            [Name] = @Name 
    END
END
GO
