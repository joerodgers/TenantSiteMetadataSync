USE master
GO
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'TenantSiteMetadataSync')
    
    CREATE DATABASE [TenantSiteMetadataSync] 
    COLLATE SQL_Latin1_General_CP1_CI_AS;

GO
