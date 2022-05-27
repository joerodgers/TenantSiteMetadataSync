IF OBJECT_ID('dbo.TVF_SitesBasic_Deleted', 'IF') IS NOT NULL
   DROP FUNCTION dbo.TVF_SitesBasic_Deleted
GO

CREATE FUNCTION dbo.TVF_SitesBasic_Deleted
(
)
RETURNS TABLE AS RETURN

SELECT
    SiteId, 
    SiteUrl
FROM
    dbo.SiteMetadata with (nolock)
WHERE
    (TimeDeleted IS NOT NULL)
