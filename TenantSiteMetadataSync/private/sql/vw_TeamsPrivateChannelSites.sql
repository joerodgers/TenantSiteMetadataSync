IF OBJECT_ID('dbo.TeamsPrivateChannelSites', 'V') IS NOT NULL
   DROP VIEW dbo.TeamsPrivateChannelSites
GO

CREATE VIEW dbo.TeamsPrivateChannelSites
AS
    SELECT
        *
    FROM 
        dbo.TVF_Sites_Active() 
    WHERE
        (TemplateName = 'TEAMCHANNEL#0' OR (GroupId = '00000000-0000-0000-0000-000000000000' AND RelatedGroupId IS NOT NULL AND GroupId <> RelatedGroupId))
GO
