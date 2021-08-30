IF OBJECT_ID('dbo.GroupsDeleted', 'V') IS NOT NULL
    DROP VIEW dbo.GroupsDeleted
GO

CREATE VIEW dbo.GroupsDeleted
AS
    SELECT
        DISTINCT
        TVF_GroupSites_Deleted.*
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
        TVF_GroupSites_Deleted() TVF_GroupSites_Deleted
        LEFT OUTER JOIN GroupMetadata
        ON TVF_GroupSites_Deleted.GroupId = GroupMetadata.GroupId 
GO
