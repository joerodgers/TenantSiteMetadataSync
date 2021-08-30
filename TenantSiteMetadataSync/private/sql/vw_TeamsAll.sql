IF OBJECT_ID('dbo.TeamsAll', 'V') IS NOT NULL
   DROP VIEW dbo.TeamsAll
GO

CREATE VIEW [dbo].[TeamsAll]
AS
    SELECT
        *
    FROM 
        dbo.TVF_Sites_All()
    WHERE
        (IsTeamsConnected = 1)
GO

