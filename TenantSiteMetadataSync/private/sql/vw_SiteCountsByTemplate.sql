IF OBJECT_ID('dbo.SiteCountsByTemplate', 'V') IS NOT NULL
   DROP VIEW dbo.SiteCountsByTemplate
GO

CREATE VIEW dbo.SiteCountsByTemplate
AS
    SELECT
        TemplateName, COUNT(*) AS 'Count'
    FROM            
        dbo.TVF_Sites_Active()
    GROUP BY    
        TemplateName
GO
