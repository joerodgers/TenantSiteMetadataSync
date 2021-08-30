IF OBJECT_ID('dbo.SitesHubConnected', 'V') IS NOT NULL
   DROP VIEW dbo.SitesHubConnected
GO

CREATE VIEW dbo.SitesHubConnected
AS
    SELECT
        *
    FROM            
        dbo.TVF_Sites_Active()
    WHERE
        (HubSiteId IS NOT NULL) AND (HubSiteId <> '00000000-0000-0000-0000-000000000000')
GO
