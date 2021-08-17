function Import-SiteMetadataFromTenantAdminList
{
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
        [ValidateSet("AggregatedSiteCollections", "AllSitesAggregatedSiteCollections" )]
        [string]$AdminList,

        [Parameter(Mandatory=$true)]
        [string]$DatabaseName,
        
        [Parameter(Mandatory=$true)]
        [string]$DatabaseServer
    )

    begin
    {
        $Error.Clear()

        Start-SyncJobExecution -Name $PSCmdlet.MyInvocation.InvocationName -DatabaseName $DatabaseName -DatabaseServer $DatabaseServer

        $counter = 1
    }
    process
    {
        if( $connection = Connect-PnPOnline -Url "https://$Tenant-admin.sharepoint.com" -ClientId $ClientId -Thumbprint $Thumbprint -Tenant "$Tenant.onmicrosoft.com" -ReturnConnection $true )
        {
            if( $AdminList -eq "AggregatedSiteCollections" )
            {
                $fields = "FileViewedOrEdited", "GroupId", "HubSiteId", "Initiator", "IsGroupConnected", "LastActivityOn", "NumOfFiles", "PagesVisited", "PageViews", "SensitivityLabel", "SiteCreationSource", "SiteId", "SiteUrl", "State", "StorageUsed", "TimeDeleted", "LastItemModifiedDate", "SiteFlags"

                $items = Get-PnPListItem -List "DO_NOT_DELETE_SPLIST_TENANTADMIN_AGGREGATED_SITECOLLECTIONS" -PageSize 5000 -Fields $fields -Connection $connection

                foreach( $item in $items )
                {
                    Write-Verbose "$(Get-Date) - ($counter/$($items.Count)) Processing Id: $($item.Id)"

                    $parameters = @{}
                    $parameters.DatabaseName         = $DatabaseName
                    $parameters.DatabaseServer       = $DatabaseServer
                    $parameters.FileViewedOrEdited   = $item.FieldValues["FileViewedOrEdited"]
                    $parameters.Initiator            = $item.FieldValues["Initiator"]
                    $parameters.IsGroupConnected     = $item.FieldValues["IsGroupConnected"]
                    $parameters.LastActivityOn       = $item.FieldValues["LastActivityOn"]
                    $parameters.LastItemModifiedDate = $item.FieldValues["LastItemModifiedDate"]
                    $parameters.NumOfFiles           = $item.FieldValues["NumOfFiles"]
                    $parameters.PagesVisited         = $item.FieldValues["PagesVisited"]
                    $parameters.PageViews            = $item.FieldValues["PageViews"]
                    $parameters.SiteCreationSource   = $item.FieldValues["SiteCreationSource"]
                    $parameters.SiteId               = $item.FieldValues["SiteId"]
                    $parameters.SiteUrl              = $item.FieldValues["SiteUrl"]
                    $parameters.StorageUsed          = $item.FieldValues["StorageUsed"]
                    $parameters.TimeDeleted          = $item.FieldValues["TimeDeleted"]
                    $parameters.IsTeamsConnected     = $item.FieldValues["SiteFlags"] -eq 1
                    $parameters.State                = -1

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
                $fields = "ConditionalAccessPolicy", "CreatedBy", "DeletedBy", "LastItemModifiedDate", "SiteOwnerEmail", "SiteOwnerName", "StorageQuota", "SiteId", "SiteUrl", "TemplateName", "TimeCreated", "Title"

                $items = Get-PnPListItem -List "DO_NOT_DELETE_SPLIST_TENANTADMIN_ALL_SITES_AGGREGATED_SITECOLLECTIONS" -PageSize 5000 -Fields $fields -Connection $connection

                foreach( $item in $items )
                {
                    Write-Verbose "$(Get-Date) - ($counter/$($items.Count)) Processing Id: $($item.Id)"

                    $parameters = @{}
                    $parameters.DatabaseName            = $DatabaseName
                    $parameters.DatabaseServer          = $DatabaseServer
                    $parameters.ConditionalAccessPolicy = $item.FieldValues["ConditionalAccessPolicy"]
                    $parameters.CreatedBy               = $item.FieldValues["CreatedBy"]
                    $parameters.DeletedBy               = $item.FieldValues["DeletedBy"]
                    $parameters.SiteOwnerEmail          = $item.FieldValues["SiteOwnerEmail"]
                    $parameters.SiteOwnerName           = $item.FieldValues["SiteOwnerName"]
                    $parameters.StorageQuota            = $item.FieldValues["StorageQuota"]
                    $parameters.SiteId                  = $item.FieldValues["SiteId"]
                    $parameters.SiteUrl                 = $item.FieldValues["SiteUrl"]
                    $parameters.TemplateName            = $item.FieldValues["TemplateName"]
                    $parameters.TimeCreated             = $item.FieldValues["TimeCreated"]
                    $parameters.Title                   = $item.FieldValues["Title"]

                    Update-SiteMetadata @parameters

                    $counter++
                }
            }

            Disconnect-PnPOnline -Connection $connection
        }
    }
    end
    {
        Stop-SyncJobExecution -Name $PSCmdlet.MyInvocation.InvocationName -ErrorCount $Error.Count -DatabaseName $DatabaseName -DatabaseServer $DatabaseServer
    }
}

