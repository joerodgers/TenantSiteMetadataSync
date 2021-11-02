USE master
GO
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'TenantSiteMetadataSync')
    CREATE DATABASE [TenantSiteMetadataSync]
GO
