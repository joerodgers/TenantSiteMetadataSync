IF OBJECT_ID('dbo.TeamsActivePrivateChannels', 'V') IS NOT NULL
   DROP VIEW dbo.TeamsActivePrivateChannels
GO

CREATE VIEW dbo.TeamsActivePrivateChannels
AS
    SELECT
        *
    FROM 
        dbo.TVF_Sites_Active() 
    WHERE
        (TemplateName like 'TEAMCHANNEL%' OR (GroupId = '00000000-0000-0000-0000-000000000000' AND RelatedGroupId IS NOT NULL AND GroupId <> RelatedGroupId))
GO
