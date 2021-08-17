﻿function Update-DeletionStatus
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
        [string]$DatabaseServer
    )

    begin
    {
        $tenantSites = $activeSites = $deletedSites = $null

        $Error.Clear()

        Start-SyncJobExecution -Name $PSCmdlet.MyInvocation.InvocationName -DatabaseName $DatabaseName -DatabaseServer $DatabaseServer
    }
    process
    {
        if( $connection = Connect-PnPOnline -Url "https://$Tenant-admin.sharepoint.com" -ClientId $ClientId -Thumbprint $Thumbprint -Tenant "$Tenant.onmicrosoft.com" -ReturnConnection )
        {
            Write-Verbose "$(Get-Date) - Querying tenant for all sites"
            
            $tenantSites = Get-PnPTenantSite -IncludeOneDriveSites -Connection $connection | Select-Object -ExpandProperty Url | ConvertTo-NormalizedUrl

            $tenantSites += Get-HiddenSiteUrl -Tenant $Tenant | ConvertTo-NormalizedUrl

            Disconnect-PnPOnline -Connection $connection

            Write-Verbose "$(Get-Date) - Querying database for all active sites"

            $activeSites = Get-DataTable -DatabaseName $DatabaseName -DatabaseServer $DatabaseServer -Query "SELECT SiteId, SiteUrl FROM ActiveSites"
        
            Write-Verbose "$(Get-Date) - Querying database for all deleted sites"

            $deletedSites = Get-DataTable -DatabaseName $DatabaseName -DatabaseServer $DatabaseServer -Query "SELECT SiteId, SiteUrl FROM DeletedSites"

            # mark sites as deleted if they are not in tenant list anymore and are not marked as deleted in the database

            foreach( $activeSite in $activeSites )
            {
                if( $tenantSites -notcontains $activeSite.SiteUrl )
                {
                    Write-Verbose "$(Get-Date) - Marking $($activeSite.SiteUrl) as deleted"

                    Update-SiteMetadata -DatabaseName $DatabaseName -DatabaseServer $DatabaseServer -SiteId $activeSite.SiteId -SiteUrl $activeSite.SiteUrl -TimeDeleted ([System.Data.SqlTypes.SqlDateTime]::MinValue)
                }
            }


            # mark sites as not deleted if they are present in tenant list

            foreach( $deletedSite in $deletedSites )
            {
                if( $tenantSites -contains $deletedSite.SiteUrl )
                {
                    Write-Verbose "$(Get-Date) - Marking $($deletedSite.SiteUrl) as not deleted"

                    $query = "UPDATE SiteMetadata SET TimeDeleted = NULL WHERE @SiteId = @SiteId"

                    Invoke-NonQuery -DatabaseName $DatabaseName -DatabaseServer $DatabaseServer -Query $query -Parameters @{ SiteId = $deletedSite.SiteId }
                }
            }

        }
    }
    end
    {
        Update-DataRefreshStatus -Name $PSCmdlet.MyInvocation.InvocationName -Finished -ErrorCount $Error.Count -DatabaseName $DatabaseName -DatabaseServer $DatabaseServer
    }
}

