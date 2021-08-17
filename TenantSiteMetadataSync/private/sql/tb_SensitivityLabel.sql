IF OBJECT_ID('dbo.SensitivityLabel', 'U') IS NULL
BEGIN

    CREATE TABLE dbo.SensitivityLabel(
        [Id]    [uniqueidentifier] NOT NULL,
        [Label] [nvarchar](100)    NOT NULL,
        CONSTRAINT PK_SensitivityLabelId PRIMARY KEY (Id)
    )

    INSERT INTO [SensitivityLabel] (Id, Label) VALUES ('00000000-0000-0000-0000-000000000000',  'None')

END
