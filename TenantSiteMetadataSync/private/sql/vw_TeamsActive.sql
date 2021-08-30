IF OBJECT_ID('dbo.TeamsActive', 'V') IS NOT NULL
   DROP VIEW dbo.TeamsActive
GO

CREATE VIEW [dbo].[TeamsActive]
AS
    SELECT
        *
    FROM 
        dbo.TVF_Sites_Active()
    WHERE
        (IsTeamsConnected = 1)
GO

