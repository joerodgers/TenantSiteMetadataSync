IF OBJECT_ID('dbo.SyncJobExecutionTime', 'V') IS NOT NULL
   DROP VIEW dbo.SyncJobExecutionTime
GO

CREATE VIEW dbo.SyncJobExecutionTime
AS
    SELECT
        [Name],
        [Started],
        [Finished],
        CASE WHEN ([Started] IS NOT NULL AND [Finished] IS NOT NULL) THEN DATEDIFF(MINUTE, [Started], [Finished]) ELSE NULL END AS TotalMinutes,
        [LastFinished],
        ErrorCount
    FROM            
        dbo.SyncJob
GO
