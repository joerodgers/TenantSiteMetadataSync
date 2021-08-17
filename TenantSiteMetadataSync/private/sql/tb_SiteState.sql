IF OBJECT_ID('dbo.SiteState', 'U') IS NULL
BEGIN

    CREATE TABLE dbo.SiteState(
        [Id]    [int]          NOT NULL,
        [State] [nvarchar](50) NOT NULL,
        CONSTRAINT PK_SiteStateId PRIMARY KEY (Id)
    )

    INSERT INTO [SiteState] (Id, State) VALUES (-1,  'Unknown')
    INSERT INTO [SiteState] (Id, State) VALUES ( 0,  'Creating')
    INSERT INTO [SiteState] (Id, State) VALUES ( 1,  'Active')
    INSERT INTO [SiteState] (Id, State) VALUES ( 2,  'Updating')
    INSERT INTO [SiteState] (Id, State) VALUES ( 3,  'Renaming')
    INSERT INTO [SiteState] (Id, State) VALUES ( 4,  'Error')
    INSERT INTO [SiteState] (Id, State) VALUES ( 5,  'Deleted')
    INSERT INTO [SiteState] (Id, State) VALUES ( 6,  'Deleting')
    INSERT INTO [SiteState] (Id, State) VALUES ( 7,  'Recycling')
    INSERT INTO [SiteState] (Id, State) VALUES ( 8,  'Recyled')
    INSERT INTO [SiteState] (Id, State) VALUES ( 9,  'Restoring')
    INSERT INTO [SiteState] (Id, State) VALUES ( 10, 'Recreating')
    INSERT INTO [SiteState] (Id, State) VALUES ( 11, 'New')

END
