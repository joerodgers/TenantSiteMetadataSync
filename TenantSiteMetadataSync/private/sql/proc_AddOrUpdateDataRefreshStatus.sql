IF OBJECT_ID('dbo.proc_AddOrUpdateDataRefreshStatus', 'P') IS NOT NULL
   DROP PROCEDURE dbo.proc_AddOrUpdateDataRefreshStatus
GO

CREATE PROCEDURE dbo.proc_AddOrUpdateDataRefreshStatus
    @Name       nvarchar(50),
    @Started    datetime2(7),
    @Finished   datetime2(7),
    @ErrorCount int
AS
BEGIN

    IF NOT EXISTS( SELECT 1 FROM dbo.DataRefreshStatus WHERE [Name] = @Name)
    BEGIN
        INSERT INTO dbo.DataRefreshStatus (
            [Name], 
            [Started],
            [Finished],
            [LastFinished],
            ErrorCount) 
        VALUES (
            @Name, 
            @Started,
            @Finished,
            @Finished,
            @ErrorCount)
    END
    ELSE
    BEGIN
        UPDATE 
            dbo.DataRefreshStatus 
        SET 
            [Started] = CASE WHEN (@Started IS NULL) THEN [Started] ELSE @Started END,
            [Finished] = @Finished,
            [LastFinished] = CASE WHEN (@Finished IS NULL) THEN [LastFinished] ELSE @Finished END,
            ErrorCount = @ErrorCount
        WHERE
            [Name] = @Name 
    END
END
GO
