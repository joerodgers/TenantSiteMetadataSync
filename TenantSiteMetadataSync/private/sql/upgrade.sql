/*
    08-27-2021 - Refactored views, removing any views using the old names
*/

-- delete ActiveSites View
IF OBJECT_ID('dbo.ActiveSites', 'V') IS NOT NULL
   DROP VIEW dbo.ActiveSites
GO

-- delete DeletedSites View
IF OBJECT_ID('dbo.DeletedSites', 'V') IS NOT NULL
   DROP VIEW dbo.DeletedSites
GO

-- delete AllGroupMetadata View
IF OBJECT_ID('dbo.AllGroupMetadata', 'V') IS NOT NULL
   DROP VIEW dbo.AllGroupMetadata
GO

-- delete LockedSites View
IF OBJECT_ID('dbo.LockedSites', 'V') IS NOT NULL
   DROP VIEW dbo.LockedSites
GO

-- delete TeamsSites View
IF OBJECT_ID('dbo.TeamsSites', 'V') IS NOT NULL
   DROP VIEW dbo.TeamsSites
GO

-- delete HubConnectedSites View
IF OBJECT_ID('dbo.HubConnectedSites', 'V') IS NOT NULL
   DROP VIEW dbo.HubConnectedSites
GO

-- delete ProjectSites View
IF OBJECT_ID('dbo.ProjectSites', 'V') IS NOT NULL
   DROP VIEW dbo.ProjectSites
GO

-- delete RedirectSites View
IF OBJECT_ID('dbo.RedirectSites', 'V') IS NOT NULL
   DROP VIEW dbo.RedirectSites
GO
