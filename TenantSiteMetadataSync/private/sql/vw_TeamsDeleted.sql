IF OBJECT_ID('dbo.TeamsDeleted', 'V') IS NOT NULL
   DROP VIEW dbo.TeamsDeleted
GO

CREATE VIEW [dbo].[TeamsDeleted]
AS
    SELECT
        *
    FROM 
        dbo.TVF_Sites_Deleted()
    WHERE
        (IsTeamsConnected = 1)
GO

