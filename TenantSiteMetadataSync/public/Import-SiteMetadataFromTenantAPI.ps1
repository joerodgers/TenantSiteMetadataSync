function Import-SiteMetadataFromTenantAPI
{
<#
	.SYNOPSIS
		Imports tenant site metadata from the tenant API into the SQL database.

        Azure Active Directory Application Principal requires SharePoint > Application > Sites.FullControl
	
	.DESCRIPTION
		Imports tenant site metadata from the tenant API into the SQL database.

        Azure Active Directory Application Principal requires SharePoint > Application > Sites.FullControl

    .PARAMETER ClientId
		Azure Active Directory Application Principal Client/Application Id
	
	.PARAMETER Thumbprint
		Thumbprint of certificate associated with the Azure Active Directory Application Principal
	
	.PARAMETER Tenant
		Name of the O365 Tenant
	
	.PARAMETER DatabaseName
		The SQL Server database name
	
	.PARAMETER DatabaseServer
		Name of the SQL Server database server, including the instance name (if applicable).
	
	.PARAMETER Template
		Optional template name to filter API results.  Valid values are 'APPCATALOG#0', 'BICenterSite#0', 'EDISC#0', 'EHS#1', 'PWA#0', 'SPSMSITEHOST#0', 'SRCHCEN#0', 'BLANKINTERNET#0', 'STS#-1', 'TEAMCHANNEL#0', 'RedirectSite#0', 'SITEPAGEPUBLISHING#0', 'STS#3', 'GROUP#0', 'STS#0'

	.PARAMETER DetailedImport
		Optional parameter to include detailed information during the import.  This option will add the following data to the import: 
            ConditionalAccessPolicy
            SensitivityLabel
            SiteId
            SiteOwnerEmail
            SiteOwnerName
            RelatedGroupId
            TimeCreated

        This option will drastically increase the execution time as it requries additionl requests to each tenant site being imported.

	.PARAMETER IncludeOneDriveSites
        Switch to include OneDrive for Business sites in the import process.

    .EXAMPLE
		PS C:\> Import-SiteMetadataFromTenantAPI -ClientId <clientId> -Thumbprint <thumbprint> -Tenant <tenant> -DatabaseName <database name> -DatabaseServer <database server>

    .EXAMPLE
		PS C:\> Import-SiteMetadataFromTenantAPI -ClientId <clientId> -Thumbprint <thumbprint> -Tenant <tenant> -DatabaseName <database name> -DatabaseServer <database server> -Template 'TEAMCHANNEL#0'

    .EXAMPLE
		PS C:\> Import-SiteMetadataFromTenantAPI -ClientId <clientId> -Thumbprint <thumbprint> -Tenant <tenant> -DatabaseName <database name> -DatabaseServer <database server> -DetailedImport

    .EXAMPLE
		PS C:\> Import-SiteMetadataFromTenantAPI -ClientId <clientId> -Thumbprint <thumbprint> -Tenant <tenant> -DatabaseName <database name> -DatabaseServer <database server> -Template 'TEAMCHANNEL#0' -DetailedImport
#>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [string]$ClientId,

        [Parameter(Mandatory=$true)]
        [string]$Thumbprint,

        [Parameter(Mandatory=$true)]
        [string]$Tenant,

        [Parameter(Mandatory=$true)]
        [string]$DatabaseName,
        
        [Parameter(Mandatory=$true)]
        [string]$DatabaseServer,

        [Parameter(Mandatory=$false)]
        [ValidateSet( 'APPCATALOG#0', 'BICenterSite#0', 'EDISC#0', 'EHS#1', 'PWA#0', 'SPSMSITEHOST#0', 'SRCHCEN#0', 'BLANKINTERNET#0', 'STS#-1', 'TEAMCHANNEL#0', 'RedirectSite#0', 'SITEPAGEPUBLISHING#0', 'STS#3', 'GROUP#0', 'STS#0' )]
        [string]$Template,

        [Parameter(Mandatory=$false)]
        [switch]$DetailedImport,

        [Parameter(Mandatory=$false)]
        [switch]$IncludeOneDriveSites
    )

    begin
    {
        $Error.Clear()

        Start-SyncJobExecution -Name $PSCmdlet.MyInvocation.InvocationName -DatabaseName $DatabaseName -DatabaseServer $DatabaseServer
    }
    process
    {
        Write-Verbose "$(Get-Date) - $($PSCmdlet.MyInvocation.MyCommand) - Connecting to SharePoint Online Tenant"

        if( $connection = Connect-PnPOnline -Url "https://$Tenant-admin.sharepoint.com" -ClientId $ClientId -Thumbprint $Thumbprint -Tenant "$Tenant.onmicrosoft.com" -ReturnConnection:$True )
        {
            $parameters = @{}
            $parameters.Connection = $connection

            if( $PSBoundParameters.ContainsKey( "Template" ) )
            {
                $parameters.Template = $Template
            }   

            if( $IncludeOneDriveSites.IsPresent )
            {
                $parameters.IncludeOneDriveSites = $true
            }   

            Write-Verbose "$(Get-Date) - $($PSCmdlet.MyInvocation.MyCommand) - Querying tenant for sites."

            # query the tenant
            $tenantSites = Get-PnPTenantSite @parameters 

            $tenantContext = Get-PnPContext

            # process each site
            foreach( $tenantSite in $tenantSites )
            {
                Write-Verbose "$(Get-Date) - $($PSCmdlet.MyInvocation.MyCommand) - Processsing $($tenantSite.Url)"

                $parameters = @{}
                $parameters.DatabaseName   = $DatabaseName
                $parameters.DatabaseServer = $DatabaseServer

                # these properties are returned by default
                $parameters.DenyAddAndCustomizePages = $tenantSite.DenyAddAndCustomizePages.ToString()
                $parameters.GroupId                  = $tenantSite.GroupId
                $parameters.HubSiteId                = $tenantSite.HubSiteId
                $parameters.LastItemModifiedDate     = $tenantSite.LastContentModifiedDate
                $parameters.LockState                = $tenantSite.LockState.ToString()
                $parameters.PWAEnabled               = ($null -ne $tenantSite.PWAEnabled -and $tenantSite.PWAEnabled.ToString() -eq "Enabled") 
                $parameters.SiteUrl                  = $tenantSite.Url
                $parameters.State                    = Get-SiteState | Where-Object -Property State -eq $tenantSite.Status | Select-Object -ExpandProperty Id
                $parameters.StorageQuota             = $tenantsite.StorageQuota * 1MB         # CONVERT FROM MB to BYTES
                $parameters.StorageUsed              = $tenantsite.StorageUsageCurrent * 1MB  # CONVERT FROM MB to BYTES
                $parameters.TemplateName             = $tenantsite.Template
                $parameters.Title                    = $tenantsite.Title
                $parameters.SharingCapability        = $tenantSite.SharingCapability.ToString()

                if( $tenantSite | Get-Member -Name IsTeamsConnected )
                {
                    $parameters.IsTeamsConnected = $tenantSite.IsTeamsConnected
                }

                # process details is specified
                if( $DetailedImport.IsPresent )
                {
                    # clone the current context
                    $siteContext = Copy-Context -Context $tenantContext -Url $tenantSite.Url

                    # set the context to the new site
                    Set-PnPContext -Context $siteContext

                    # pull site and web details
                    $site = Get-PnPSite -Includes Owner, Id, RelatedGroupId, ConditionalAccessPolicy, SensitivityLabel
                    $web  = Get-PnPWeb  -Includes Created
                
                    # add detailed properties to the parameter set
                    $parameters.ConditionalAccessPolicy = $site.ConditionalAccessPolicy
                    $parameters.SensitivityLabel        = $site.SensitivityLabel.ToString()
                    $parameters.SiteId                  = $site.Id
                    $parameters.SiteOwnerEmail          = $site.Owner.Email
                    $parameters.SiteOwnerName           = $site.Owner.Title
                    $parameters.RelatedGroupId          = $site.RelatedGroupId.ToString()
                    $parameters.TimeCreated             = $web.Created
                }

                Update-SiteMetadata @parameters
            }

            Disconnect-PnPOnline -Connection $connection
        }
    }
    end
    {
        Stop-SyncJobExecution -Name $PSCmdlet.MyInvocation.InvocationName -ErrorCount $Error.Count -DatabaseName $DatabaseName -DatabaseServer $DatabaseServer
    }
}

