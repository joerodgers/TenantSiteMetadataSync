IF OBJECT_ID('dbo.TVF_Sites_Active', 'IF') IS NOT NULL
   DROP FUNCTION [dbo].[TVF_Sites_Active]
GO

CREATE FUNCTION dbo.TVF_Sites_Active
(
)
RETURNS TABLE AS RETURN

SELECT        
    PT.TypeName AS 'ConditionalAccessPolicy', 
    SM.CreatedBy, 
    SM.DeletedBy, 
    SM.DenyAddAndCustomizePages,
    SM.FileViewedOrEdited, 
    SM.GroupId, 
    SM.RelatedGroupId, 
    SM.HubSiteId, 
    SM.Initiator, 
    CASE WHEN SM.IsGroupConnected IS NULL THEN 0 ELSE SM.IsGroupConnected END AS 'IsGroupConnected',
    CASE WHEN SM.IsTeamsConnected IS NULL THEN 0 ELSE SM.IsTeamsConnected END AS 'IsTeamsConnected',
    SM.LastActivityOn, 
    SM.LastItemModifiedDate, 
    SM.LockState,
    SM.NumOfFiles, 
    SM.PagesVisited, 
    SM.PageViews, 
    CASE WHEN SM.PWAEnabled IS NULL THEN 0 ELSE SM.PWAEnabled END AS 'PWAEnabled',
    SL.Label AS 'SensitivityLabel', 
    SM.SharingCapability,
    SM.SiteId, 
    SM.SiteOwnerEmail, 
    SM.SiteOwnerName, 
    SM.SiteOwnerUserPrincipalName, 
    SM.SiteUrl, 
    SS.[State] AS 'SiteState', 
    SCS.Source AS 'SiteCreationSource',
    SM.StorageQuota, 
    SM.StorageUsed, 
    SM.TemplateName, 
    SM.TimeCreated, 
    SM.TimeDeleted, 
    SM.Title,
    SM.AnonymousLinkCount,
    SM.CompanyLinkCount,
    SM.GuestLinkCount,
    SM.MemberLinkCount
FROM    
    dbo.SiteMetadata AS SM 
    LEFT JOIN
    dbo.SiteState AS SS ON ISNULL(SM.State, -1) = ISNULL(SS.Id, -1)
    LEFT JOIN
    dbo.SiteCreationSource AS SCS ON ISNULL(SM.SiteCreationSource, '00000000-0000-0000-0000-000000000000') = ISNULL(SCS.Id, '00000000-0000-0000-0000-000000000000')
    LEFT JOIN
    dbo.SensitivityLabel AS SL ON ISNULL(SM.SensitivityLabel, '00000000-0000-0000-0000-000000000000') =  ISNULL(SL.Id, '00000000-0000-0000-0000-000000000000')
    LEFT JOIN
    dbo.ConditionalAccessPolicyType PT ON ISNULL(SM.ConditionalAccessPolicy, 0) =  ISNULL(PT.Id, 0)
WHERE
    (TimeDeleted IS NULL)
