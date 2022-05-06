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

    .PARAMETER DatabaseConnectionInformation
    Database Connection Information

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
    PS C:\> Import-SiteMetadataFromTenantAPI -ClientId <clientId> -Thumbprint <thumbprint> -Tenant <tenant> -DatabaseConnectionInformation <database connection information>

    .EXAMPLE
    PS C:\> Import-SiteMetadataFromTenantAPI -ClientId <clientId> -Thumbprint <thumbprint> -Tenant <tenant> -DatabaseConnectionInformation <database connection information> -Template 'TEAMCHANNEL#0'

    .EXAMPLE
    PS C:\> Import-SiteMetadataFromTenantAPI -ClientId <clientId> -Thumbprint <thumbprint> -Tenant <tenant> -DatabaseConnectionInformation <database connection information> -DetailedImport

    .EXAMPLE
    PS C:\> Import-SiteMetadataFromTenantAPI -ClientId <clientId> -Thumbprint <thumbprint> -Tenant <tenant> -DatabaseConnectionInformation <database connection information> -Template 'TEAMCHANNEL#0' -DetailedImport
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
        [DatabaseConnectionInformation]
        $DatabaseConnectionInformation,

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

        Start-SyncJobExecution -Name $PSCmdlet.MyInvocation.InvocationName -DatabaseConnectionInformation $DatabaseConnectionInformation
    }
    process
    {
        Write-PSFMessage -Level Verbose -Message "Connecting to SharePoint Online Tenant"

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

            Write-PSFMessage -Level Verbose -Message "Querying tenant for sites."

            # query the tenant
            $tenantSites = Get-PnPTenantSite @parameters 

            $tenantContext = Get-PnPContext

            $counter = 1

            # process each site
            foreach( $tenantSite in $tenantSites )
            {
                Write-PSFMessage -Level Debug -Message "Processsing $($tenantSite.Url)"

                $parameters = @{}
                $parameters.DatabaseConnectionInformation   = $DatabaseConnectionInformation

                # these properties are returned by default
                $parameters.DenyAddAndCustomizePages = $tenantSite.DenyAddAndCustomizePages.ToString()
                $parameters.GroupId                  = $tenantSite.GroupId
                $parameters.HubSiteId                = $tenantSite.HubSiteId
                $parameters.LastItemModifiedDate     = $tenantSite.LastContentModifiedDate
                $parameters.LockState                = $tenantSite.LockState.ToString()
                $parameters.PWAEnabled               = ($null -ne $tenantSite.PWAEnabled -and $tenantSite.PWAEnabled.ToString() -eq "Enabled") 
                $parameters.SiteUrl                  = $tenantSite.Url
                $parameters.State                    = (Get-SiteState -StateName $tenantSite.Status).Id
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
                    if( $tenantSite.LockState.ToString() -eq "NoAccess" )
                    {
                        Write-PSFMessage -Level Warning -Message "Skipping detailed request for site $($tenantSite.Url). Site lock status is '$($tenantSite.LockState.ToString())'"
                    }
                    else
                    {
                        Set-PnPContext -Context $tenantContext

                        # pull site and web details
                        $siteDetail = Get-PnPTenantSite -Identity $tenantSite.Url
    
                        # clone the current context
                        $siteContext = Copy-Context -Context $tenantContext -Url $tenantSite.Url
    
                        # set the context to the new site
                        Set-PnPContext -Context $siteContext
    
                        $site = Get-PnPSite -Includes Id, RelatedGroupId -Connection $connection
                        $web  = Get-PnPWeb  -Includes Created -Connection $connection
                    
                        <# The following properties are returned by a direct request for an individual site
    
                            AllowDownloadingNonWebViewableFiles
                            AllowEditing
                            BlockDownloadLinksFileType
                            ConditionalAccessPolicy
                            Description
                            DisableAppViews
                            DisableCompanyWideSharingLinks
                            DisableFlows
                            LimitedAccessFileType
                            Owner
                            OwnerEmail
                            OwnerLoginName
                            OwnerName
                            ProtectionLevelName
                            SandboxedCodeActivationCapability
                            SensitivityLabel
                            WebsCount
                        #>
    
                        # add detailed properties to the parameter set
                        $parameters.ConditionalAccessPolicy = $siteDetail.ConditionalAccessPolicy
                        $parameters.SiteId                  = $site.Id
                        $parameters.SiteOwnerEmail          = $siteDetail.OwnerEmail
                        $parameters.SiteOwnerName           = $siteDetail.OwnerName
                        $parameters.TimeCreated             = $web.Created
                        
                        if( $siteDetail.SensitivityLabel )
                        {
                            $parameters.SensitivityLabel = $siteDetail.SensitivityLabel
                        }
    
                        if( $siteDetail.RelatedGroupId )
                        {
                            $parameters.RelatedGroupId = $site.RelatedGroupId
                        }
                    }
                }

                try 
                {
                    Update-SiteMetadata @parameters
                }
                catch
                {
                    Stop-PSFFunction -Message "Failed to update site metatadata for $($tenantSite.Url)" -ErrorRecord $_
                }


                if( $counter -eq ($tenantsites.Count) -or ($counter % 100) -eq 0 )
                {
                    Write-PSFMessage -Level Verbose -Message "Processed $counter of $($tenantSites.Count) sites"
                }

                $counter++
            }

            Disconnect-PnPOnline -Connection $connection
        }

        # query for all SiteOwnerUserPrincipalName that are null
        $sql1 = "SELECT DISTINCT 
                    SiteOwnerEmail 
                    FROM 
                    SiteMetadata 
                    WHERE 
                    SiteOwnerEmail IS NOT NULL
                    AND SiteOwnerEmail <> ''
                    AND IsGroupConnected = 0
                    AND SiteOwnerEmail NOT LIKE '%#ext#@%'
                    AND SiteOwnerUserPrincipalName IS NULL"

        # update SiteOwnerUserPrincipalName with any existing rows that has a matching SiteOwnerEmail value
        $sql2 = "UPDATE
                        SiteMetadata
                    SET 
                        SiteOwnerUserPrincipalName = (SELECT DISTINCT SiteOwnerUserPrincipalName WHERE SiteOwnerEmail = @SiteOwnerEmail)
                    WHERE
                        SiteOwnerEmail = @SiteOwnerEmail"

        # update SiteOwnerUserPrincipalName with provided value
        $sql3 = "UPDATE
                        SiteMetadata
                    SET 
                        SiteOwnerUserPrincipalName = @SiteOwnerUserPrincipalName
                    WHERE
                        SiteOwnerEmail = @SiteOwnerEmail"

        Write-PSFMessage -Level Verbose -Message "Updating SiteOwnerUserPrincipalName values"

        if( $results = @(Get-DataTable -Query $sql1 -DatabaseConnectionInformation $DatabaseConnectionInformation -As 'PSObject') )
        {
            Write-PSFMessage -Level Verbose -Message "Found $($results.Count) site owners with a null SiteOwnerUserPrincipalName"

            # update all rows in the table that already have the same email address
            foreach( $result in $results )
            {
                Invoke-NonQuery `
                    -DatabaseConnectionInformation $DatabaseConnectionInformation `
                    -Query $sql2 `
                    -Parameters @{ SiteOwnerEmail = $result.SiteOwnerEmail }
            }
        }

        if( $results = @(Get-DataTable -Query $sql1 -DatabaseConnectionInformation $DatabaseConnectionInformation -As 'PSObject') )
        {
            $null = Connect-MgGraph -ClientId $ClientId -CertificateThumbprint $Thumbprint -TenantId "$Tenant.onmicrosoft.com"

            Write-PSFMessage -Level Verbose -Message "Found $($results.Count) remaining site owners with a null SiteOwnerUserPrincipalName"

            # update all rows in the table that have a matching proxy address
            foreach( $result in $results )
            {
                if( $graphUser = Get-MgUser -Filter "proxyAddresses/any(x:x eq 'smtp:$($result.SiteOwnerEmail)')" -Property "UserPrincipalName" )
                {
                    Invoke-NonQuery `
                        -DatabaseConnectionInformation $DatabaseConnectionInformation `
                        -Query $sql3 `
                        -Parameters @{ SiteOwnerUserPrincipalName = $graphUser.UserPrincipalName; SiteOwnerEmail = $result.SiteOwnerEmail }
                }
            }
        }

    }
    end
    {
        Stop-SyncJobExecution -Name $PSCmdlet.MyInvocation.InvocationName -ErrorCount $Error.Count -DatabaseConnectionInformation $DatabaseConnectionInformation
    }
}
