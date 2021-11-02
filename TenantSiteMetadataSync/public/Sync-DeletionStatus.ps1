function Sync-DeletionStatus
{
<#
    .SYNOPSIS
    Updates the deleted status of sites based on sites being restored from the tenant recycle bin or moved into the recycle bin. 

    .DESCRIPTION
    Updates the deleted status of sites based on sites being restored from the tenant recycle bin or moved into the recycle bin. 

    .PARAMETER ClientId
    Azure Active Directory Application Principal Client/Application Id

    .PARAMETER Thumbprint
    Thumbprint of certificate associated with the Azure Active Directory Application Principal

    .PARAMETER Tenant
    Name of the O365 Tenant

    .PARAMETER DatabaseConnectionInformation
    Database Connection Information

    .EXAMPLE
    PS C:\> Sync-DeletionStatus -ClientId <clientId> -Thumbprint <thumbprint> -Tenant <tenant> -DatabaseConnectionInformation <database connection information>
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
        $DatabaseConnectionInformation
    )

    begin    
    {
        $tenantSites = $activeSites = $deletedSites = $null

        $Error.Clear()

        Start-SyncJobExecution -Name $PSCmdlet.MyInvocation.InvocationName -DatabaseConnectionInformation $DatabaseConnectionInformation 
    }
    process
    {
        Write-PSFMessage -Level Verbose -Message "Connecting to SharePoint Online Tenant"

        if( $connection = Connect-PnPOnline -Url "https://$Tenant-admin.sharepoint.com" -ClientId $ClientId -Thumbprint $Thumbprint -Tenant "$Tenant.onmicrosoft.com" -ReturnConnection )
        {
            Write-PSFMessage -Level Verbose -Message "Querying tenant for sites"

            $tenantSites = Get-PnPTenantSite -IncludeOneDriveSites -Connection $connection | Select-Object -ExpandProperty Url | ConvertTo-NormalizedUrl

            $tenantSites += Get-HiddenSiteUrl -Tenant $Tenant | ConvertTo-NormalizedUrl

            Disconnect-PnPOnline -Connection $connection

            Write-PSFMessage -Level Verbose -Message "Querying database for all active sites"

            $activeSites = Get-DataTable -DatabaseName $DatabaseName -DatabaseServer $DatabaseServer -Query "SELECT SiteId, SiteUrl FROM SitesActive"
        
            Write-PSFMessage -Level Verbose -Message "Querying database for all deleted sites"

            $deletedSites = Get-DataTable -DatabaseName $DatabaseName -DatabaseServer $DatabaseServer -Query "SELECT SiteId, SiteUrl FROM SitesDeleted"

            # mark sites as deleted if they are not in tenant list anymore and are not marked as deleted in the database
            foreach( $activeSite in $activeSites )
            {
                if( $tenantSites -notcontains $activeSite.SiteUrl )
                {
                    Write-PSFMessage -Level Verbose -Message "Marking $($activeSite.SiteUrl) as deleted"
                    Update-SiteMetadata  -DatabaseConnectionInformation $DatabaseConnectionInformation -SiteId $activeSite.SiteId -SiteUrl $activeSite.SiteUrl -TimeDeleted ([System.Data.SqlTypes.SqlDateTime]::MinValue)
                }
            }

            # mark sites as not deleted if they are present in tenant list
            foreach( $deletedSite in $deletedSites )
            {
                if( $tenantSites -contains $deletedSite.SiteUrl )
                {
                    Write-PSFMessage -Level Verbose -Message "Marking $($activeSite.SiteUrl) as not deleted"
                    Invoke-NonQuery -DatabaseConnectionInformation $DatabaseConnectionInformation -Query "UPDATE SiteMetadata SET TimeDeleted = NULL WHERE @SiteId = @SiteId" -Parameters @{ SiteId = $deletedSite.SiteId }
                }
            }
        }
    }
    end
    {
        Stop-SyncJobExecution -Name $PSCmdlet.MyInvocation.InvocationName -ErrorCount $Error.Count -DatabaseConnectionInformation $DatabaseConnectionInformation 
    }
}
