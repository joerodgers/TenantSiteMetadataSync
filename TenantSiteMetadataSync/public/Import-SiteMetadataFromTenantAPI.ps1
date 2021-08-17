function Import-SiteMetadataFromTenantAPI
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [string]$Tenant,

        [Parameter(Mandatory=$true)]
        [string]$ClientId,

        [Parameter(Mandatory=$true)]
        [string]$Thumbprint,

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
        if( $connection = Connect-PnPOnline -Url "https://$Tenant-admin.sharepoint.com" -ClientId $ClientId -Thumbprint $Thumbprint -Tenant "$Tenant.onmicrosoft.com" -ReturnConnection )
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

            # query the tenant
            $tenantSites = Get-PnPTenantSite @parameters 

            Disconnect-PnPOnline -Connection $connection

            # process each site
            foreach( $tenantSite in $tenantSites )
            {
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
                    # connect to indvidual site
                    if( $connection = Connect-PnPOnline -Url $tenantSite.Url -ClientId $ClientId -Thumbprint $Thumbprint -Tenant "$Tenant.onmicrosoft.com" -ReturnConnection )
                    {
                        $site = Get-PnPSite -Includes Owner, Id, RelatedGroupId, ConditionalAccessPolicy, SensitivityLabel -Connection $connection
                        $web  = Get-PnPWeb  -Includes Created -Connection $connection
                   
                        $parameters.ConditionalAccessPolicy = $site.ConditionalAccessPolicy
                        $parameters.SensitivityLabel        = $site.SensitivityLabel.ToString()
                        $parameters.SiteId                  = $site.Id
                        $parameters.SiteOwnerEmail          = $site.Owner.Email
                        $parameters.SiteOwnerName           = $site.Owner.Title
                        $parameters.RelatedGroupId          = $site.RelatedGroupId.ToString()
                        $parameters.TimeCreated             = $web.Created

                        Disconnect-PnPOnline -Connection $connection
                    }
                }

                Update-SiteMetadata @parameters
            }
        }
    }
    end
    {
        Stop-SyncJobExecution -Name $PSCmdlet.MyInvocation.InvocationName -ErrorCount $Error.Count -DatabaseName $DatabaseName -DatabaseServer $DatabaseServer
    }
}

