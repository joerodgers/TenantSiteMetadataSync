IF OBJECT_ID('dbo.SyncJob', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.SyncJob(
        [Name]                     nvarchar(100) NOT NULL,
        [Started]                  datetime2(0),
        [Finished]                 datetime2(0),
        [LastExecutionElapsedTime] bigint,
        [ErrorCount]               int,
        CONSTRAINT PK_SyncJobTimerName PRIMARY KEY (Name)
    )
END
