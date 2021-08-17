IF OBJECT_ID('dbo.SyncJob', 'U') IS NULL
BEGIN

    CREATE TABLE dbo.SyncJob(
        [Name]         nvarchar(100) NOT NULL,
        [Started]      smalldatetime,
        [Finished]     smalldatetime,
        [LastFinished] smalldatetime,
        [ErrorCount]   int,
        CONSTRAINT PK_SyncJobTimerName PRIMARY KEY (Name)
    )

END

