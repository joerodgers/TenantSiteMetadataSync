IF OBJECT_ID('dbo.ConditionalAccessPolicyType', 'U') IS NULL
BEGIN

    CREATE TABLE dbo.ConditionalAccessPolicyType(
        [Id]       int          NOT NULL,
        [TypeName] nvarchar(50) NOT NULL,
        CONSTRAINT PK_ConditionalAccessPolicyTypeId PRIMARY KEY (Id)
    )

    INSERT INTO [ConditionalAccessPolicyType] (Id, TypeName) VALUES (0,  'Allow Full Access')
    INSERT INTO [ConditionalAccessPolicyType] (Id, TypeName) VALUES (1,  'Allow Limited Access')
    INSERT INTO [ConditionalAccessPolicyType] (Id, TypeName) VALUES (2,  'Block Access')
    INSERT INTO [ConditionalAccessPolicyType] (Id, TypeName) VALUES (3,  'Authentication Context')

END
