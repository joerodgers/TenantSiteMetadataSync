#requires -Modules @{ ModuleName="PnP.PowerShell";         ModuleVersion="1.7.0" }
#requires -Modules @{ ModuleName="Posh-SSH";               ModuleVersion="2.3.0" }
#requires -Modules @{ ModuleName="TenantSiteMetadataSync"; ModuleVersion="1.0.0" }
#requires -Modules @{ ModuleName="Microsoft.Graph.Groups"; ModuleVersion="1.0.1" }

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
    [switch]$ImportM365GroupOwnershipData,

    [Parameter(Mandatory=$true)]
    [string]$DatabaseServer,

    [Parameter(Mandatory=$true)]
    [string]$DatabaseName,

    [Parameter(Mandatory=$true)]
    [string]$ClientId,

    [Parameter(Mandatory=$true)]
    [string]$Thumbprint,

    [Parameter(Mandatory=$true)]
    [string]$Tenant,

    [Parameter(Mandatory=$false)]
    [string]$TranscriptDirectoryPath = (Join-Path -Path $PSScriptRoot -ChildPath "Logs")
)

# ImportUsageAccountData
if( $ImportUsageAccountData.IsPresent )
{
    $Error.Clear()

    $operation = "Operation - Import Usage Account Data"

    Start-TSMSLogFile -Path $TranscriptDirectoryPath -Name "ImportUsageAccountData" -TrimExistingLogFiles

    Start-TSMSSyncJobExecution -Name $operation -DatabaseName $DatabaseName -DatabaseServer $DatabaseServer

    Write-Host "$(Get-Date) - Starting Operation: ImportUsageAccountData"

    # import usage data for OD4B sites from Graph API reports
    Import-TSMSMicrosoftGraphUsageAccountReportData `
        -ReportType     "OneDrive" `
        -Period         30 `
        -ApiVersion     "v1.0" `
        -ClientId       $ClientId `
        -Thumbprint     $Thumbprint `
        -Tenant         $Tenant `
        -DatabaseName   $DatabaseName `
        -DatabaseServer $DatabaseServer -Verbose

    # import usage data for SharePoint sites from Graph API reports
    Import-TSMSMicrosoftGraphUsageAccountReportData `
        -ReportType     "SharePoint" `
        -Period         30 `
        -ApiVersion     "beta" `
        -ClientId       $ClientId `
        -Thumbprint     $Thumbprint `
        -Tenant         $Tenant `
        -DatabaseName   $DatabaseName `
        -DatabaseServer $DatabaseServer -Verbose

    # import usage data for M365 groups from Graph API reports
    Import-TSMSMicrosoftGraphUsageAccountReportData `
        -ReportType     "M365Group" `
        -Period         30 `
        -ApiVersion     "v1.0" `
        -ClientId       $ClientId `
        -Thumbprint     $Thumbprint `
        -Tenant         $Tenant `
        -DatabaseName   $DatabaseName `
        -DatabaseServer $DatabaseServer -Verbose

    Write-Host "$(Get-Date) - Completed Operation: ImportUsageAccountData"

    Stop-TSMSSyncJobExecution -Name $operation -DatabaseName $DatabaseName -DatabaseServer $DatabaseServer

    Stop-TSMSLogFile
}


# ImportSharePointTenantListData
if( $ImportSharePointTenantListData.IsPresent )
{
    try
    {
        $Error.Clear()

        $operation = "Operation - Import SharePoint Tenant List Data"
    
        Start-TSMSLogFile -Path $transcriptDirectoryPath -Name "ImportSharePointTenantListData" -TrimExistingLogFiles
    
        Start-TSMSSyncJobExecution -Name $operation -DatabaseName $DatabaseName -DatabaseServer $DatabaseServer
    
        Write-Host "$(Get-Date) - Starting $operation"
    
        # import the guid/name mappings for sensitivity labels
        Import-TSMSSensitivityLabel `
            -ClientId       $ClientId `
            -Thumbprint     $Thumbprint `
            -Tenant         $Tenant `
            -DatabaseName   $DatabaseName `
            -DatabaseServer $DatabaseServer -Verbose
    
        # import the guid/name mappings for site creation sources
        Import-TSMSSiteCreationSources `
            -ClientId       $ClientId `
            -Thumbprint     $Thumbprint `
            -Tenant         $Tenant `
            -DatabaseName   $DatabaseName `
            -DatabaseServer $DatabaseServer -Verbose
    
        # full sync from tenant admin lists
        Import-TSMSSiteMetadataFromTenantAdminList `
            -AdminList      "AllSitesAggregatedSiteCollections" `
            -ClientId       $ClientId `
            -Thumbprint     $Thumbprint `
            -Tenant         $Tenant `
            -DatabaseName   $DatabaseName `
            -DatabaseServer $DatabaseServer  -Verbose
        
        Import-TSMSSiteMetadataFromTenantAdminList `
            -AdminList      "AggregatedSiteCollections" `
            -ClientId       $ClientId `
            -Thumbprint     $Thumbprint `
            -Tenant         $Tenant `
            -DatabaseName   $DatabaseName `
            -DatabaseServer $DatabaseServer  -Verbose
    
        Write-Host "$(Get-Date) - Completed $operation"
    
    }
    finally
    {
        Stop-TSMSSyncJobExecution -Name $operation -DatabaseName $DatabaseName -DatabaseServer $DatabaseServer

        Stop-TSMSLogFile
    }
}


# ImportSharePointTenantAPIData
if( $ImportSharePointTenantAPIData.IsPresent )
{
    try 
    {
        $Error.Clear()

        $operation = "Operation - Import SharePoint Tenant API Data"
    
        Start-TSMSLogFile -Path $transcriptDirectoryPath -Name "ImportSharePointTenantAPIData" -TrimExistingLogFiles
    
        Start-TSMSSyncJobExecution -Name $operation -DatabaseName $DatabaseName -DatabaseServer $DatabaseServer
    
        Write-Host "$(Get-Date) - Starting $operation"
    
        # make sure our deletion states are sync'd between the tenant and database
        Update-TSMSDeletionStatus `
            -ClientId       $ClientId `
            -Thumbprint     $Thumbprint `
            -Tenant         $Tenant `
            -DatabaseName   $DatabaseName `
            -DatabaseServer $DatabaseServer
    
        # import additional data about deleted sites from SharePoint tenant
        Import-TSMSDeletedSiteMetadataFromTenantAPI `
            -ClientId       $ClientId `
            -Thumbprint     $Thumbprint `
            -Tenant         $Tenant `
            -DatabaseName   $DatabaseName `
            -DatabaseServer $DatabaseServer
    
        # import additional data about active sites from SharePoint tenant
        Import-TSMSSiteMetadataFromTenantAPI `
            -ClientId       $ClientId `
            -Thumbprint     $Thumbprint `
            -Tenant         $Tenant `
            -DatabaseName   $DatabaseName `
            -DatabaseServer $DatabaseServer
    
        Write-Host "$(Get-Date) - Completed $operation"
            
    }
    finally
    {
        Stop-TSMSSyncJobExecution -Name $operation -DatabaseName $DatabaseName -DatabaseServer $DatabaseServer

        Stop-TSMSLogFile
    }
}


# ImportDetailedSharePointTenantAPIData
if( $ImportDetailedSharePointTenantAPIData.IsPresent )
{
    try 
    {
        $Error.Clear()

        $operation = "Operation - Import Detailed SharePoint Tenant API Data"
    
        Start-TSMSLogFile -Path $transcriptDirectoryPath -Name "ImportSharePointTenantAPIData" -TrimExistingLogFiles
    
        Start-TSMSSyncJobExecution -Name $operation -DatabaseName $DatabaseName -DatabaseServer $DatabaseServer
    
        Write-Host "$(Get-Date) - Starting $operation"
    
        # VERY long running operation on large tenants
        Import-TSMSSiteMetadataFromTenantAPI `
            -DetailedImport `
            -ClientId       $ClientId `
            -Thumbprint     $Thumbprint `
            -Tenant         $Tenant `
            -DatabaseName   $DatabaseName `
            -DatabaseServer $DatabaseServer
    
    
        Write-Host "$(Get-Date) - Completed $operation"
    }
    finally
    {
        Stop-TSMSSyncJobExecution -Name $operation -DatabaseName $DatabaseName -DatabaseServer $DatabaseServer

        Stop-TSMSLogFile
    }
}


# ImportM365GroupOwnershipData
if( $ImportM365GroupOwnershipData.IsPresent )
{
    try 
    {
        $Error.Clear()

        $operation = "Operation - Import M365 Group Ownership Data"
    
        Start-TSMSLogFile -Path $transcriptDirectoryPath -Name "$ImportM365GroupOwnershipData" -TrimExistingLogFiles
    
        Start-TSMSSyncJobExecution -Name $operation -DatabaseName $DatabaseName -DatabaseServer $DatabaseServer
    
        Write-Host "$(Get-Date) - Starting $operation"
    
        # import the M365 group ownership
        Import-TSMSM365GroupOwnershipData `
            -ClientId       $ClientId `
            -Thumbprint     $Thumbprint `
            -Tenant         $Tenant `
            -DatabaseName   $DatabaseName `
            -DatabaseServer $DatabaseServer
    
        Write-Host "$(Get-Date) - Completed $operation"
    }
    finally
    {
        Stop-TSMSSyncJobExecution -Name $operation -DatabaseName $DatabaseName -DatabaseServer $DatabaseServer

        Stop-TSMSLogFile
    }
}

