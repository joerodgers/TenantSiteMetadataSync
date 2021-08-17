IF OBJECT_ID('dbo.GroupMetadata', 'U') IS NULL
BEGIN

    CREATE TABLE dbo.GroupMetadata
    (
        [GroupId]                       uniqueidentifier,
        [DisplayName]                   nvarchar(255) NULL,
        [IsDeleted]                     bit           NULL,
        [LastActivityDate]              datetime2(7)  NULL,
        [IsPublic]                      bit           NULL,
        [MemberCount]                   int           NULL,
        [ExternalMemberCount]           int           NULL,
        [ExchangeReceivedEmailCount]    int           NULL, 
        [SharePointActiveFileCount]     int           NULL,
        [SharePointTotalFileCount]      int           NULL,
        [YammerPostedMessageCount]      int           NULL,
        [YammerReadMessageCount]        int           NULL,
        [YammerLikedMessageCount]       int           NULL,
        [ExchangeMailboxTotalItemCount] int           NULL,
        [ExchangeMailboxStorageUsed]    bigint        NULL,
        CONSTRAINT PK_GroupMetadata_GroupId PRIMARY KEY (GroupId)
    )

END
