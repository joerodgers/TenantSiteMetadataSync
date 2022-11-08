@{
    # Script module or binary module file associated with this manifest.
    RootModule = 'TenantSiteMetadataSync.psm1'

    # Version number of this module.
    ModuleVersion = '1.2.2.11'

    # ID used to uniquely identify this module
    GUID = '8c45bd42-02af-4f18-a8d8-0d5e891790df'

    # Description of the functionality provided by this module
    Description = 'Module to sync tenant site metadata to a local SQL server database'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion = '7.1'

    # import classes
    ScriptsToProcess = ".\classes\DatabaseConnectionInformation.ps1"

    # Modules that must be imported into the global environment prior to importing this module
    RequiredModules = @{ModuleName="SqlServer";                             ModuleVersion  = "21.1.18256" },
                      @{ModuleName="Microsoft.Graph.Groups";                ModuleVersion  = "1.0.1"      },
                      @{ModuleName="PnP.PowerShell";                        MaximumVersion = "1.10.0"     },
                      @{ModuleName="PSFramework";                           ModuleVersion  = "1.6.205"    }
                      
    # Functions to export from this module
    FunctionsToExport = 'Import-M365GroupOwnershipData',
                        'Import-DeletedSiteMetadataFromTenantAPI',
                        'Import-MicrosoftGraphUsageAccountReportData',
                        'Import-SensitivityLabel',
                        'Import-SiteCreationSource',
                        'Import-SiteMetadataFromTenantAdminList',
                        'Import-SiteMetadataFromTenantAPI',
                        'New-Database',
                        'Start-LogFile',
                        'Start-SyncJobExecution',
                        'Stop-LogFile',
                        'Stop-SyncJobExecution',
                        'Sync-DatabaseSchema',
                        'Sync-DeletionStatus',
                        'New-SqlServerDatabaseConnectionInformation',
                        'Import-SecondarySiteAdmin'

    DefaultCommandPrefix = 'TSMS'
}
