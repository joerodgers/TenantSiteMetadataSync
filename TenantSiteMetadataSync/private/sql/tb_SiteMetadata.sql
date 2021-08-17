IF OBJECT_ID('dbo.SiteMetadata', 'U') IS NULL
BEGIN

    CREATE TABLE dbo.SiteMetadata(
        [AnonymousLinkCount]         int              NULL,
        [CompanyLinkCount]           int              NULL,
        [ConditionalAccessPolicy]    int              NULL,
        [CreatedBy]                  nvarchar(255)    NULL,
        [DeletedBy]                  nvarchar(255)    NULL,
        [DenyAddAndCustomizePages]   nvarchar(50)     NULL,
        [FileViewedOrEdited]         int              NULL,
        [GroupId]                    uniqueidentifier NULL,
        [GuestLinkCount]             int              NULL,
        [HasEveryoneOrEEEU]          bit              NULL,
        [HasLegalHold]               bit              NULL,
        [HubSiteId]                  uniqueidentifier NULL,
        [Initiator]                  nvarchar(255)    NULL,
        [IsGroupConnected]           bit              NULL,
        [IsRestorable]               bit              NULL,
        [LastActivityOn]             date             NULL,
        [LastItemModifiedDate]       datetime2(7)     NULL,
        [LastListActivityOn]         datetime2(7)     NULL,
        [LastWebActivityOn]          datetime2(7)     NULL,
        [LockState]                  nvarchar(50)     NULL,
        [MemberLinkCount]            int              NULL,
        [NumOfFiles]                 int              NULL, 
        [PagesVisited]               int              NULL,
        [PageViews]                  int              NULL,
        [PWAEnabled]                 bit              NULL,
        [SensitivityLabel]           uniqueidentifier NULL,
        [SharedInternallyFileCount]  int              NULL,
        [SharedExternallyyFileCount] int              NULL,
        [SharingCapability]          nvarchar(50)     NULL,
        [SiteCreationSource]         uniqueidentifier NULL,
        [SiteId]                     uniqueidentifier NOT NULL,
        [SiteOwnerEmail]             nvarchar(255)    NULL,
        [SiteOwnerName]              nvarchar(255)    NULL,
        [SiteUrl]                    nvarchar(450)    NOT NULL,
        [State]                      int              NULL,
        [StorageQuota]               bigint           NULL, 
        [StorageUsed]                bigint           NULL,
        [StorageUsedPercentage]      decimal(18, 0)   NULL,
        [SyncedFileCount]            int              NULL,
        [TemplateName]               nvarchar(255)    NULL,
        [TimeCreated]                datetime2(7)     NULL,
        [TimeDeleted]                datetime2(7)     NULL,
        [Title]                      nvarchar(255)    NULL,
        CONSTRAINT PK_SiteMetadata_SiteId PRIMARY KEY (SiteId)
    )

END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_SiteMetadata_SiteUrl')
BEGIN
    CREATE INDEX [IX_SiteMetadata_SiteUrl] ON [dbo].[SiteMetadata]([SiteUrl]) ON [PRIMARY]
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_SiteMetadata_TemplateName')
BEGIN
    CREATE INDEX [IX_SiteMetadata_TemplateName] ON [dbo].[SiteMetadata]([TemplateName]) ON [PRIMARY]
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_SiteMetadata_GroupId')
BEGIN
    CREATE INDEX [IX_SiteMetadata_GroupId] ON [dbo].[SiteMetadata]([GroupId]) ON [PRIMARY]
END








IF NOT EXISTS (SELECT * FROM sys.objects WHERE type = 'U' AND OBJECT_ID = OBJECT_ID('dbo.LegalHold'))
BEGIN

    CREATE TABLE [dbo].[LegalHold](
        [UserName]      nvarchar(50) NOT NULL,
        [DateAdded]     date         NOT NULL,
        [DateRefreshed] date         NOT NULL,
        CONSTRAINT PK_LegalHoldUserName PRIMARY KEY (UserName)
    )

END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE type = 'U' AND OBJECT_ID = OBJECT_ID('dbo.LeftBusiness'))
BEGIN

    CREATE TABLE [dbo].[LeftBusiness](
        [UserName] nvarchar(50) NOT NULL,
        [DateLeft] date         NOT NULL,
        CONSTRAINT PK_LeftBusinessUserName PRIMARY KEY (UserName)
    )

END






