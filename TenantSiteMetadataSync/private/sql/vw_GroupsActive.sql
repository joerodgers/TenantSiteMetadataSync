IF OBJECT_ID('dbo.GroupsActive', 'V') IS NOT NULL
    DROP VIEW dbo.GroupsActive
GO

CREATE VIEW dbo.GroupsActive
AS
    SELECT
        DISTINCT
        TVF_GroupSites_Active.*
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
        TVF_GroupSites_Active() TVF_GroupSites_Active
        LEFT OUTER JOIN GroupMetadata
        ON TVF_GroupSites_Active.GroupId = GroupMetadata.GroupId 
GO
