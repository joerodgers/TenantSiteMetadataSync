IF OBJECT_ID('dbo.SiteCreationSource', 'U') IS NULL
BEGIN

    CREATE TABLE dbo.SiteCreationSource(
        [Id]     uniqueidentifier NOT NULL,
        [Source] nvarchar(50)     NOT NULL,
        CONSTRAINT PK_SiteCreationSourceId PRIMARY KEY (Id)
    )

END

