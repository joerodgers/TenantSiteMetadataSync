#requires -Modules @{ ModuleName="PnP.PowerShell";         ModuleVersion="1.7.0" }
#requires -Modules @{ ModuleName="Posh-SSH";               ModuleVersion="2.3.0" }
#requires -Modules @{ ModuleName="TenantSiteMetadataSync"; ModuleVersion="1.0.0" }
#requires -Modules @{ ModuleName="Microsoft.Graph.Groups"; ModuleVersion="1.5.0" }

param
(
    [Parameter(Mandatory=$false)]
    [switch]$ImportUsageAccountData,

    [Parameter(Mandatory=$false)]
    [switch]$ImportSharePointTenantListData,

    [Parameter(Mandatory=$false)]
    [switch]$ImportSharePointTenantAPIData,

    [Parameter(Mandatory=$false)]
    [switch]$ImportDetailedSharePointTenantAPIData,

    [Parameter(Mandatory=$false)]
    [switch]$ImportM365GroupOwnershipData
)

# ImportUsageAccountData
if( $ImportUsageAccountData.IsPresent )
{
    $Error.Clear()

    $operation = "Operation - Import Usage Account Data"

    Start-LogFile -Path $transcriptDirectoryPath -Name "ImportUsageAccountData"

    Start-SyncJobExecution -Name $operation -DatabaseName $databaseName -DatabaseServer $databaseServer

    Write-Host "$(Get-Date) - Starting Operation: ImportUsageAccountData"

    # import usage data for OD4B sites from Graph API reports
    Import-MicrosoftGraphUsageAccountReportData -ReportType OneDrive -Period 30 -ApiVersion v1.0 -ClientId $clientId -Thumbprint $thumbprint -Tenant $tenant -DatabaseName $databaseName -DatabaseServer $databaseServer

    # import usage data for SharePoint sites from Graph API reports
    Import-MicrosoftGraphUsageAccountReportData -ReportType SharePoint -Period 30 -ApiVersion beta -ClientId $clientId -Thumbprint $thumbprint -Tenant $tenant -DatabaseName $databaseName -DatabaseServer $databaseServer

    # import usage data for M365 groups from Graph API reports
    Import-MicrosoftGraphUsageAccountReportData -ReportType M365Group -Period 30 -ApiVersion v1.0 -ClientId $clientId -Thumbprint $thumbprint -Tenant $tenant -DatabaseName $databaseName -DatabaseServer $databaseServer

    Write-Host "$(Get-Date) - Completed Operation: ImportUsageAccountData"

    Stop-SyncJobExecution -Name $operation -DatabaseName $databaseName -DatabaseServer $databaseServer

    Stop-LogFile
}



# ImportSharePointTenantListData
if( $ImportSharePointTenantListData.IsPresent )
{
    $Error.Clear()

    $operation = "Operation - Import SharePoint Tenant List Data"

    Start-LogFile -Path $transcriptDirectoryPath -Name "ImportSharePointTenantListData"

    Start-SyncJobExecution -Name $operation -DatabaseName $databaseName -DatabaseServer $databaseServer

    Write-Host "$(Get-Date) - Starting $operation"

    # import the guid/name mappings for sensitivity labels
    Import-SensitivityLabel -ClientId $clientId -Thumbprint $thumbprint -Tenant $tenant -DatabaseName $databaseName -DatabaseServer $databaseServer

    # import the guid/name mappings for site creation sources
    Import-SiteCreationSources -ClientId $clientId -Thumbprint $thumbprint -Tenant $tenant -DatabaseName $databaseName -DatabaseServer $databaseServer

    # full sync from tenant admin lists
    Import-SiteMetadataFromTenantAdminList -ClientId $clientId -Thumbprint $thumbprint -Tenant $tenant -DatabaseName $databaseName -DatabaseServer $databaseServer -AdminList AllSitesAggregatedSiteCollections
    
    Import-SiteMetadataFromTenantAdminList -ClientId $clientId -Thumbprint $thumbprint -Tenant $tenant -DatabaseName $databaseName -DatabaseServer $databaseServer -AdminList AggregatedSiteCollections

    Write-Host "$(Get-Date) - Completed $operation"

    Stop-SyncJobExecution -Name $operation -DatabaseName $databaseName -DatabaseServer $databaseServer

    Stop-LogFile
}


# ImportSharePointTenantAPIData
if( $ImportSharePointTenantAPIData.IsPresent )
{
    $Error.Clear()

    $operation = "Operation - Import SharePoint Tenant API Data"

    Start-LogFile -Path $transcriptDirectoryPath -Name "ImportSharePointTenantAPIData"

    Start-SyncJobExecution -Name $operation -DatabaseName $databaseName -DatabaseServer $databaseServer

    Write-Host "$(Get-Date) - Starting $operation"

    # make sure our deletion states are sync'd between the tenant and database
    Update-DeletionStatus -ClientId $clientId -Thumbprint $thumbprint -Tenant $tenant -DatabaseName $databaseName -DatabaseServer $databaseServer

    # import additional data about deleted sites from SharePoint tenant
    Import-DeletedSiteMetadataFromTenantAPI -ClientId $clientId -Thumbprint $thumbprint -Tenant $tenant -DatabaseName $databaseName -DatabaseServer $databaseServer

    # import additional data about active sites from SharePoint tenant
    Import-SiteMetadataFromTenantAPI -ClientId $clientId -Thumbprint $thumbprint -Tenant $tenant -DatabaseName $databaseName -DatabaseServer $databaseServer

    Write-Host "$(Get-Date) - Completed $operation"

    Stop-SyncJobExecution -Name $operation -DatabaseName $databaseName -DatabaseServer $databaseServer

    Stop-LogFile
}


# ImportDetailedSharePointTenantAPIData
if( $ImportDetailedSharePointTenantAPIData.IsPresent )
{
    $Error.Clear()

    $operation = "Operation - Import Detailed SharePoint Tenant API Data"

    Start-LogFile -Path $transcriptDirectoryPath -Name "ImportSharePointTenantAPIData"

    Start-SyncJobExecution -Name $operation -DatabaseName $databaseName -DatabaseServer $databaseServer

    Write-Host "$(Get-Date) - Starting $operation"

    # VERY long running operation on large tenants
    Import-SiteMetadataFromTenantAPI -DetailedImport -ClientId $clientId -Thumbprint $thumbprint -Tenant $tenant -DatabaseName $databaseName -DatabaseServer $databaseServer

    Write-Host "$(Get-Date) - Completed $operation"

    Stop-SyncJobExecution -Name $operation -DatabaseName $databaseName -DatabaseServer $databaseServer

    Stop-LogFile
}


# ImportM365GroupOwnershipData
if( $ImportM365GroupOwnershipData.IsPresent )
{
    $Error.Clear()

    $operation = "Operation - Import M365 Group Ownership Data"

    Start-LogFile -Path $transcriptDirectoryPath -Name "$ImportM365GroupOwnershipData"

    Start-SyncJobExecution -Name $operation -DatabaseName $databaseName -DatabaseServer $databaseServer

    Write-Host "$(Get-Date) - Starting $operation"

    # import the M365 group ownership
    Import-M365GroupOwnershipData -ClientId $clientId -Thumbprint $thumbprint -Tenant $tenant -DatabaseName $databaseName -DatabaseServer $databaseServer

    Write-Host "$(Get-Date) - Completed $operation"

    Stop-SyncJobExecution -Name $operation -DatabaseName $databaseName -DatabaseServer $databaseServer

    Stop-LogFile
}

