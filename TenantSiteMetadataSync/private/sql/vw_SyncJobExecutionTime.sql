IF OBJECT_ID('dbo.SyncJobExecutionTime', 'V') IS NOT NULL
   DROP VIEW dbo.SyncJobExecutionTime
GO

CREATE VIEW dbo.SyncJobExecutionTime
AS
    SELECT TOP 1000
         [Name]
        ,[Started]
        ,[Finished]
        ,CASE WHEN LastExecutionElapsedTime IS NOT NULL THEN CONVERT(varchar, [LastExecutionElapsedTime] / 86400 ) + ':' + CONVERT(varchar, DATEADD(ms, ( [LastExecutionElapsedTime] % 86400 ) * 1000, 0), 108) ELSE '' END AS 'LastExecutionElapsedTime'
        ,[ErrorCount]
    FROM 
        [dbo].[SyncJob]
    ORDER BY
        [Name]
GO
