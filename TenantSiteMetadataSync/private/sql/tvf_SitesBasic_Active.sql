IF OBJECT_ID('dbo.tvf_SitesBasic_Active', 'IF') IS NOT NULL
   DROP FUNCTION [dbo].[tvf_SitesBasic_Active]
GO

CREATE FUNCTION dbo.TVF_SitesBasic_Active
(
)
RETURNS TABLE AS RETURN

SELECT        
    SiteId, 
    SiteUrl
FROM    
    dbo.SiteMetadata with (nolock) 
WHERE
    (TimeDeleted IS NULL)
