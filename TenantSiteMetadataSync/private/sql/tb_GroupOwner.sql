IF OBJECT_ID('dbo.GroupOwner', 'U') IS NULL
BEGIN
 
    CREATE TABLE dbo.GroupOwner(
        [GroupId]           uniqueidentifier NOT NULL,
        [UserPrincipalName] nvarchar(500)    NOT NULL
    )

END

