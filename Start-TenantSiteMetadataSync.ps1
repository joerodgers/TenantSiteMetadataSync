#requires -Modules @{ ModuleName="PnP.PowerShell";         ModuleVersion="1.7.0"   }
#requires -Modules @{ ModuleName="TenantSiteMetadataSync"; ModuleVersion="1.0.0"   }
#requires -Modules @{ ModuleName="Microsoft.Graph.Groups"; ModuleVersion="1.0.1"   }
#requires -Modules @{ ModuleName="PSFramework";            ModuleVersion="1.6.205" }

[CmdletBinding(DefaultParameterSetName='TrustedConnection')]
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
    [string]$TranscriptDirectoryPath = (Join-Path -Path $PSScriptRoot -ChildPath "Logs"),

    [Parameter(Mandatory=$false,ParameterSetName='SqlAuthentication')]
    [string]$DatabaseUserName,

    [Parameter(Mandatory=$false,ParameterSetName='SqlAuthentication')]
    [SecureString]$DatabaseUserPassword,

    [Parameter(Mandatory=$false,ParameterSetName='AzureServicePrincipal')]
    [Guid]$AzureSqlServicePrincipalClientId,

    [Parameter(Mandatory=$false,ParameterSetName='AzureServicePrincipal')]
    [SecureString]$AzureSqlServicePrincipalClientSecret,

    [Parameter(Mandatory=$false,ParameterSetName='AzureServicePrincipal')]
    [Guid]$TenantId
)

if( $PSVersionTable.PSVersion.Major -ge 7 )
{
    # set powershell 7+ proxy
    [System.Net.Http.HttpClient]::DefaultProxy.Credentials = [System.Net.CredentialCache]::DefaultCredentials
}
else
{
    # set powershell 5 proxy
    [System.Net.WebRequest]::DefaultWebProxy.Credentials = [System.Net.CredentialCache]::DefaultCredentials 
}

$parameters = @{}
$parameters.DatabaseName   = $DatabaseName
$parameters.DatabaseServer = $DatabaseServer

switch -Exact ( $PScmdlet.ParameterSetName )
{
    "TrustedConnection"
    {
        # no action required
        break
    }
    "SqlAuthentication"
    {
        $parameters.UserName = $DatabaseUserName
        $parameters.Password = $DatabaseUserPassword
        $parameters.Encrypt  = $true
        break
    }
    "AzureServicePrincipal"
    {
        $parameters.ClientId     = $AzureSqlServicePrincipalClientId
        $parameters.ClientSecret = $AzureSqlServicePrincipalClientSecret
        $parameters.TenantId     = $TenantId
        $parameters.Encrypt      = $true
        break
    }
}

$databaseConnectionInformation = New-TSMSSqlServerDatabaseConnectionInformation @parameters

# disable default 'filesystem' logging provider
Set-PSFLoggingProvider -Name 'filesystem' -Enabled $false

# ImportUsageAccountData
if( $ImportUsageAccountData.IsPresent )
{
    $Error.Clear()

    $operation = "Operation - Import Usage Account Data"

    Start-TSMSLogFile -Path $TranscriptDirectoryPath -Name "ImportUsageAccountData" -MessageLevel ([PSFramework.Message.MessageLevel]::Verbose)

    Start-TSMSSyncJobExecution -Name $operation -DatabaseConnectionInformation $databaseConnectionInformation

    Write-Host "$(Get-Date) - Starting Operation: ImportUsageAccountData"

    # import usage data for OD4B sites from Graph API reports
    Import-TSMSMicrosoftGraphUsageAccountReportData `
        -ReportType     "OneDrive" `
        -Period         30 `
        -ApiVersion     "v1.0" `
        -ClientId       $ClientId `
        -Thumbprint     $Thumbprint `
        -Tenant         $Tenant `
        -DatabaseConnectionInformation $databaseConnectionInformation

    # import usage data for SharePoint sites from Graph API reports
    Import-TSMSMicrosoftGraphUsageAccountReportData `
        -ReportType     "SharePoint" `
        -Period         30 `
        -ApiVersion     "beta" `
        -ClientId       $ClientId `
        -Thumbprint     $Thumbprint `
        -Tenant         $Tenant `
        -DatabaseConnectionInformation $databaseConnectionInformation

    # import usage data for M365 groups from Graph API reports
    Import-TSMSMicrosoftGraphUsageAccountReportData `
        -ReportType     "M365Group" `
        -Period         30 `
        -ApiVersion     "v1.0" `
        -ClientId       $ClientId `
        -Thumbprint     $Thumbprint `
        -Tenant         $Tenant `
        -DatabaseConnectionInformation $databaseConnectionInformation

    Write-Host "$(Get-Date) - Completed Operation: ImportUsageAccountData"

    Stop-TSMSSyncJobExecution -Name $operation -DatabaseConnectionInformation $databaseConnectionInformation

    Stop-TSMSLogFile
}


# ImportSharePointTenantListData
if( $ImportSharePointTenantListData.IsPresent )
{
    try
    {
        $Error.Clear()

        $operation = "Operation - ImportSharePointTenantListData"
    
        Start-TSMSLogFile -Path $transcriptDirectoryPath -Name "ImportSharePointTenantListData" -MessageLevel ([PSFramework.Message.MessageLevel]::Verbose)
    
        Start-TSMSSyncJobExecution -Name $operation -DatabaseConnectionInformation $databaseConnectionInformation
    
        Write-Host "$(Get-Date) - Starting $operation"
    
        # import the guid/name mappings for sensitivity labels
        Import-TSMSSensitivityLabel `
            -ClientId       $ClientId `
            -Thumbprint     $Thumbprint `
            -Tenant         $Tenant `
            -DatabaseConnectionInformation $databaseConnectionInformation

        # import the guid/name mappings for site creation sources
        Import-TSMSSiteCreationSources `
            -ClientId       $ClientId `
            -Thumbprint     $Thumbprint `
            -Tenant         $Tenant `
            -DatabaseConnectionInformation $databaseConnectionInformation

        # full sync from tenant admin lists
        Import-TSMSSiteMetadataFromTenantAdminList `
            -AdminList      "AllSitesAggregatedSiteCollections" `
            -ClientId       $ClientId `
            -Thumbprint     $Thumbprint `
            -Tenant         $Tenant `
            -DatabaseConnectionInformation $databaseConnectionInformation

        Import-TSMSSiteMetadataFromTenantAdminList `
            -AdminList      "AggregatedSiteCollections" `
            -ClientId       $ClientId `
            -Thumbprint     $Thumbprint `
            -Tenant         $Tenant `
            -DatabaseConnectionInformation $databaseConnectionInformation

        Write-Host "$(Get-Date) - Completed $operation"
    
    }
    finally
    {
        Stop-TSMSSyncJobExecution -Name $operation -DatabaseConnectionInformation $databaseConnectionInformation

        Stop-TSMSLogFile
    }
}


# ImportSharePointTenantAPIData
if( $ImportSharePointTenantAPIData.IsPresent )
{
    try 
    {
        $Error.Clear()

        $operation = "Operation - ImportSharePointTenantAPIData"
    
        Start-TSMSLogFile -Path $transcriptDirectoryPath -Name "ImportSharePointTenantAPIData" -MessageLevel ([PSFramework.Message.MessageLevel]::Verbose)
    
        Start-TSMSSyncJobExecution -Name $operation -DatabaseConnectionInformation $databaseConnectionInformation
    
        Write-Host "$(Get-Date) - Starting $operation"
    
        # make sure our deletion states are sync'd between the tenant and database
        Sync-TSMSDeletionStatus `
            -ClientId       $ClientId `
            -Thumbprint     $Thumbprint `
            -Tenant         $Tenant `
            -DatabaseConnectionInformation $databaseConnectionInformation

        # import additional data about deleted sites from SharePoint tenant
        Import-TSMSDeletedSiteMetadataFromTenantAPI `
            -ClientId       $ClientId `
            -Thumbprint     $Thumbprint `
            -Tenant         $Tenant `
            -DatabaseConnectionInformation $databaseConnectionInformation

        # import additional data about active sites from SharePoint tenant
        Import-TSMSSiteMetadataFromTenantAPI `
            -ClientId       $ClientId `
            -Thumbprint     $Thumbprint `
            -Tenant         $Tenant `
            -DatabaseConnectionInformation $databaseConnectionInformation

        Write-Host "$(Get-Date) - Completed $operation"
            
    }
    finally
    {
        Stop-TSMSSyncJobExecution -Name $operation -DatabaseConnectionInformation $databaseConnectionInformation

        Stop-TSMSLogFile
    }
}


# ImportDetailedSharePointTenantAPIData
if( $ImportDetailedSharePointTenantAPIData.IsPresent )
{
    try 
    {
        $Error.Clear()

        $operation = "Operation - ImportDetailedSharePointTenantAPIData"
    
        Start-TSMSLogFile -Path $transcriptDirectoryPath -Name "ImportSharePointTenantAPIData" -MessageLevel ([PSFramework.Message.MessageLevel]::Verbose)
    
        Start-TSMSSyncJobExecution -Name $operation -DatabaseConnectionInformation $databaseConnectionInformation
    
        Write-Host "$(Get-Date) - Starting $operation"
    
        # VERY long running operation on large tenants
        Import-TSMSSiteMetadataFromTenantAPI `
            -DetailedImport `
            -ClientId       $ClientId `
            -Thumbprint     $Thumbprint `
            -Tenant         $Tenant `
            -DatabaseConnectionInformation $databaseConnectionInformation

        Write-Host "$(Get-Date) - Completed $operation"
    }
    finally
    {
        Stop-TSMSSyncJobExecution -Name $operation -DatabaseConnectionInformation $databaseConnectionInformation

        Stop-TSMSLogFile
    }
}


# ImportM365GroupOwnershipData
if( $ImportM365GroupOwnershipData.IsPresent )
{
    try 
    {
        $Error.Clear()

        $operation = "Operation - ImportM365GroupOwnershipData"
    
        Start-TSMSLogFile -Path $transcriptDirectoryPath -Name "ImportM365GroupOwnershipData" -MessageLevel ([PSFramework.Message.MessageLevel]::Verbose)
    
        Start-TSMSSyncJobExecution -Name $operation -DatabaseConnectionInformation $databaseConnectionInformation
    
        Write-Host "$(Get-Date) - Starting $operation"
    
        # import the M365 group ownership
        Import-TSMSM365GroupOwnershipData `
            -ClientId       $ClientId `
            -Thumbprint     $Thumbprint `
            -Tenant         $Tenant `
            -DatabaseConnectionInformation $databaseConnectionInformation

        Write-Host "$(Get-Date) - Completed $operation"
    }
    finally
    {
        Stop-TSMSSyncJobExecution -Name $operation -DatabaseConnectionInformation $databaseConnectionInformation

        Stop-TSMSLogFile
    }
}

