IF OBJECT_ID('dbo.TeamsSites', 'V') IS NOT NULL
   DROP VIEW dbo.TeamsSites
GO

CREATE VIEW [dbo].[TeamsSites]
AS
    SELECT
        *
    FROM 
        dbo.TVF_Sites_Active()
    WHERE
        (IsTeamsConnected = 1)
GO

