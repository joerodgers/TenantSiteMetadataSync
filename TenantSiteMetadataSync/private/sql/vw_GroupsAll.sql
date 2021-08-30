IF OBJECT_ID('dbo.GroupsAll', 'V') IS NOT NULL
    DROP VIEW dbo.GroupsAll
GO

CREATE VIEW dbo.GroupsAll
AS
    SELECT
        DISTINCT
        TVF_GroupSites_All.*
        ,GroupMetadata.IsPublic
        ,GroupMetadata.MemberCount
        ,GroupMetadata.ExternalMemberCount
        ,GroupMetadata.ExchangeReceivedEmailCount
        ,GroupMetadata.SharePointActiveFileCount
        ,GroupMetadata.SharePointTotalFileCount
        ,GroupMetadata.YammerPostedMessageCount
        ,GroupMetadata.YammerReadMessageCount
        ,GroupMetadata.YammerLikedMessageCount
        ,GroupMetadata.ExchangeMailboxTotalItemCount
        ,GroupMetadata.ExchangeMailboxStorageUsed
    FROM 
        TVF_GroupSites_All() TVF_GroupSites_All
        LEFT OUTER JOIN GroupMetadata
        ON TVF_GroupSites_All.GroupId = GroupMetadata.GroupId 
GO
