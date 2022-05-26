IF OBJECT_ID('dbo.proc_StartSyncJobExecution', 'P') IS NOT NULL
   DROP PROCEDURE dbo.proc_StartSyncJobExecution
GO

CREATE PROCEDURE dbo.proc_StartSyncJobExecution
    @Name nvarchar(100)
AS
BEGIN

    IF NOT EXISTS( SELECT 1 FROM dbo.SyncJob WHERE [Name] = @Name)
    BEGIN
        INSERT INTO dbo.SyncJob (
            [Name], 
            [Started],
            [ErrorCount]
        ) 
        VALUES (
            @Name, 
            GETDATE(),
            0
        )
    END
    ELSE
    BEGIN

        UPDATE 
            dbo.SyncJob 
        SET 
            [Started]    = GETDATE(),
            [Finished]   = NULL,
            [ErrorCount] = 0,
            -- support sql 2012, DATEDIFF_BIG not available until SQL Server 2016
            -- [LastExecutionElapsedTime] = CASE WHEN [Started] IS NOT NULL AND [Finished] IS NOT NULL THEN DATEDIFF_BIG( SECOND, @d1, @d2) ELSE LastExecutionElapsedTime END
            [LastExecutionElapsedTime] = CASE WHEN [Started] IS NOT NULL AND [Finished] IS NOT NULL THEN DATEDIFF( SECOND,[Started], [Finished] ) ELSE LastExecutionElapsedTime END
        WHERE
            [Name] = @Name 
    END
END
GO
