function Import-SiteMetadataFromTenantAdminList
{
<#
    .SYNOPSIS
    Imports tenant site metadata from the tenant site hidden lists (DO_NOT_DELETE_SPLIST_TENANTADMIN_AGGREGATED_SITECOLLECTIONS and DO_NOT_DELETE_SPLIST_TENANTADMIN_ALL_SITES_AGGREGATED_SITECOLLECTIONS) 
    into the SQL database.

    Azure Active Directory Application Principal requires SharePoint > Application > Sites.FullControl

    .DESCRIPTION
    Imports tenant site metadata from the tenant site hidden lists (DO_NOT_DELETE_SPLIST_TENANTADMIN_AGGREGATED_SITECOLLECTIONS and DO_NOT_DELETE_SPLIST_TENANTADMIN_ALL_SITES_AGGREGATED_SITECOLLECTIONS) 
    into the SQL database.

    Azure Active Directory Application Principal requires SharePoint > Application > Sites.FullControl

    .PARAMETER AdminList
    The list to target as the input source.  Valid values are AggregatedSiteCollections and AllSitesAggregatedSiteCollections

    .PARAMETER ClientId
    Azure Active Directory Application Principal Client/Application Id

    .PARAMETER Thumbprint
    Thumbprint of certificate associated with the Azure Active Directory Application Principal

    .PARAMETER Tenant
    Name of the O365 Tenant

    .PARAMETER DatabaseConnectionInformation
    Database Connection Information

    .EXAMPLE
    PS C:\> Import-SiteMetadataFromTenantAdminList -ClientId <clientId> -Thumbprint <thumbprint> -Tenant <tenant> -DatabaseConnectionInformation <database connection information>
#>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateSet("AggregatedSiteCollections", "AllSitesAggregatedSiteCollections" )]
        [string]$AdminList,

        [Parameter(Mandatory=$true)]
        [string]$ClientId,
        
        [Parameter(Mandatory=$true)]
        [string]$Thumbprint,

        [Parameter(Mandatory=$true)]
        [string]$Tenant,

        [Parameter(Mandatory=$true)]
        [DatabaseConnectionInformation]
        $DatabaseConnectionInformation
    )

    begin
    {
        $Error.Clear()

        Start-SyncJobExecution -Name $PSCmdlet.MyInvocation.InvocationName -DatabaseConnectionInformation $DatabaseConnectionInformation

        $counter = 1

        if( $AdminList -eq "AggregatedSiteCollections" )
        {
            $listTitle = "DO_NOT_DELETE_SPLIST_TENANTADMIN_AGGREGATED_SITECOLLECTIONS"
            $fields    = "FileViewedOrEdited", "GroupId", "HubSiteId", "Initiator", "IsGroupConnected", "LastActivityOn", "NumOfFiles", "PagesVisited", "PageViews", "SensitivityLabel", "SiteCreationSource", "SiteId", "SiteUrl", "State", "StorageUsed", "TimeDeleted", "LastItemModifiedDate", "SiteFlags"
        }
        else 
        {
            $listTitle = "DO_NOT_DELETE_SPLIST_TENANTADMIN_ALL_SITES_AGGREGATED_SITECOLLECTIONS"
            $fields = "ConditionalAccessPolicy", "CreatedBy", "DeletedBy", "LastItemModifiedDate", "SiteOwnerEmail", "SiteOwnerName", "StorageQuota", "SiteId", "SiteUrl", "TemplateName", "TimeCreated", "Title"
        }
    }
    process
    {
        Write-PSFMessage -Level Verbose -Message "Connecting to SharePoint Online Tenant"

        if( $connection = Connect-PnPOnline -Url "https://$Tenant-admin.sharepoint.com" -ClientId $ClientId -Thumbprint $Thumbprint -Tenant "$Tenant.onmicrosoft.com" -ReturnConnection:$True )
        {
            Write-PSFMessage -Level Verbose -Message "Reading list items from list '$listTitle'"

            $items = Get-PnPListItem -List $listTitle -PageSize 5000 -Fields $fields -Connection $connection

            Write-PSFMessage -Level Verbose -Message "Read $($items.Count) list items from list '$listTitle'"

            Disconnect-PnPOnline -Connection $connection

            if( $AdminList -eq "AggregatedSiteCollections" )
            {
                foreach( $item in $items )
                {
                    Write-PSFMessage -Level Debug -Message "($counter/$($items.Count)) Item Id='$($item.Id)'. List = 'AllSitesAggregatedSiteCollections'"

                    $parameters = @{}
                    $parameters.DatabaseConnectionInformation = $DatabaseConnectionInformation
                    $parameters.FileViewedOrEdited   = $item.FieldValues["FileViewedOrEdited"]
                    $parameters.Initiator            = $item.FieldValues["Initiator"]
                    $parameters.LastActivityOn       = $item.FieldValues["LastActivityOn"]
                    $parameters.LastItemModifiedDate = $item.FieldValues["LastItemModifiedDate"]
                    $parameters.NumOfFiles           = $item.FieldValues["NumOfFiles"]
                    $parameters.PagesVisited         = $item.FieldValues["PagesVisited"]
                    $parameters.PageViews            = $item.FieldValues["PageViews"]
                    $parameters.SiteId               = $item.FieldValues["SiteId"]
                    $parameters.SiteUrl              = $item.FieldValues["SiteUrl"]
                    $parameters.StorageUsed          = $item.FieldValues["StorageUsed"]
                    $parameters.TimeDeleted          = $item.FieldValues["TimeDeleted"]
                    $parameters.IsTeamsConnected     = $item.FieldValues["SiteFlags"] -eq 1
                    # $parameters.State                = -1 # "unknown"

                    if( -not [string]::IsNullOrWhiteSpace($item.FieldValues["IsGroupConnected"]) )
                    {
                        $parameters.IsGroupConnected = $item.FieldValues["IsGroupConnected"]
                    }

                    if( -not [string]::IsNullOrWhiteSpace($item.FieldValues["SiteCreationSource"]) )
                    {
                        $parameters.SiteCreationSource = $item.FieldValues["SiteCreationSource"]
                    }

                    if( -not [string]::IsNullOrWhiteSpace($item.FieldValues["State"]) )
                    {
                        $parameters.State = [int]::Parse($item.FieldValues["State"])
                    }

                    if( $item.FieldValues["SensitivityLabel"] )
                    {
                        $parameters.SensitivityLabel = [Guid]::Parse($item.FieldValues["SensitivityLabel"])
                    }

                    if( $item.FieldValues["GroupId"] )
                    {
                        $parameters.GroupId = [Guid]::Parse($item.FieldValues["GroupId"])
                    }

                    if( $item.FieldValues["HubSiteId"] )
                    {
                        $parameters.HubSiteId = $item.FieldValues["HubSiteId"]
                    }

                    Update-SiteMetadata @parameters

                    $counter++
                }
            }
            elseif( $AdminList -eq "AllSitesAggregatedSiteCollections" )
            {
                foreach( $item in $items )
                {
                    Write-PSFMessage -Level Debug -Message "($counter/$($items.Count)) Item Id='$($item.Id)'. List = 'AllSitesAggregatedSiteCollections'"

                    $parameters = @{}
                    $parameters.DatabaseConnectionInformation = $DatabaseConnectionInformation
                    $parameters.ConditionalAccessPolicy       = $item.FieldValues["ConditionalAccessPolicy"]
                    $parameters.CreatedBy                     = $item.FieldValues["CreatedBy"]                    
                    $parameters.SiteOwnerEmail                = $item.FieldValues["SiteOwnerEmail"]
                    $parameters.SiteOwnerName                 = $item.FieldValues["SiteOwnerName"]
                    $parameters.StorageQuota                  = $item.FieldValues["StorageQuota"]
                    $parameters.SiteId                        = $item.FieldValues["SiteId"]
                    $parameters.SiteUrl                       = $item.FieldValues["SiteUrl"]
                    $parameters.TemplateName                  = $item.FieldValues["TemplateName"]
                    $parameters.TimeCreated                   = $item.FieldValues["TimeCreated"]
                    $parameters.Title                         = $item.FieldValues["Title"]

                    if( $item.FieldValues["DeletedBy"] )
                    {
                        $parameters.DeletedBy = $item.FieldValues["DeletedBy"]
                    }

                    Update-SiteMetadata @parameters

                    $counter++
                }
            }

            # query for all SiteOwnerUserPrincipalName that are null
            $sql1 = "SELECT DISTINCT 
                        SiteOwnerEmail 
                     FROM 
                        SiteMetadata 
                     WHERE 
                            SiteOwnerUserPrincipalName IS NULL
                        AND SiteOwnerEmail IS NOT NULL
                        AND SiteOwnerEmail <> ''
                        AND IsGroupConnected = 0
                        AND SiteOwnerEmail NOT LIKE '%#ext#@%'"

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
                    if( $graphUser = Get-MgUser -Filter "proxyAddresses/any(x:x eq 'smtp:$($result.SiteOwnerEmail)')" -Property "UserPrincipalName" -Top 1 )
                    {
                        Invoke-NonQuery `
                            -DatabaseConnectionInformation $DatabaseConnectionInformation `
                            -Query $sql3 `
                            -Parameters @{ SiteOwnerUserPrincipalName = $graphUser.UserPrincipalName; SiteOwnerEmail = $result.SiteOwnerEmail }
                    }
                }
            }
        }
    }
    end
    {
        Stop-SyncJobExecution -Name $PSCmdlet.MyInvocation.InvocationName -ErrorCount $Error.Count -DatabaseConnectionInformation $DatabaseConnectionInformation
    }
}

