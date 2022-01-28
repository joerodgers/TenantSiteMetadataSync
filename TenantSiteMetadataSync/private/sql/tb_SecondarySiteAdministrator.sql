IF OBJECT_ID('dbo.SecondarySiteAdministrator', 'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[SecondarySiteAdministrator](
        [SiteId]               uniqueidentifier NOT NULL FOREIGN KEY REFERENCES SiteMetadata(SiteId),
        [LoginName]            nvarchar(500)    NOT NULL,
        [IsUserPrincipal]      bit              NOT NULL,
        [PrincipalDisplayName] nvarchar(500)    NOT NULL,
        CONSTRAINT [PK_SecondarySiteAdministrator] PRIMARY KEY CLUSTERED ([SiteId] ASC, [LoginName] ASC)
    )
END
