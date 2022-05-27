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
        Start-SyncJobExecution -Name $PSCmdlet.MyInvocation.InvocationName -DatabaseConnectionInformation $DatabaseConnectionInformation 
    }
    process
    {
        Write-PSFMessage -Level Verbose -Message "Connecting to SharePoint Online Tenant"

        if( $connection = Connect-PnPOnline -Url "https://$Tenant-admin.sharepoint.com" -ClientId $ClientId -Thumbprint $Thumbprint -Tenant "$Tenant.onmicrosoft.com" -ReturnConnection )
        {
            Write-PSFMessage -Level Verbose -Message "Querying tenant for all SharePoint and OneDrive sites"

            $tenantSitesUrls  = Get-PnPTenantSite -IncludeOneDriveSites -Connection $connection | Select-Object -ExpandProperty Url | ConvertTo-NormalizedUrl
            $tenantSitesUrls += Get-HiddenSiteUrl -Tenant $Tenant | ConvertTo-NormalizedUrl

            Write-PSFMessage -Level Verbose -Message "Querying database for all active and deleted sites"

            $activeSiteUrls  = Get-DataTable -DatabaseConnectionInformation $DatabaseConnectionInformation -Query "SELECT SiteUrl FROM SitesBasicActive"  | Select-Object -ExpandProperty "SiteUrl"
            $deletedSiteUrls = Get-DataTable -DatabaseConnectionInformation $DatabaseConnectionInformation -Query "SELECT SiteUrl FROM SitesBasicDeleted" | Select-Object -ExpandProperty "SiteUrl"

            Write-PSFMessage -Level Verbose -Message "Comparing tenant site list to active site list"

            # get all active sites that are not in the tenant site list
            $siteUrls = @(Compare-Object -ReferenceObject $tenantSitesUrls -DifferenceObject $activeSiteUrls | Where-Object -Property "SideIndicator" -eq "=>" | Select-Object -ExpandProperty "InputObject")

            Write-PSFMessage -Level Verbose -Message "Found $($siteUrls.Count) sites to mark as deleted"

            # mark each active site found as deleted
            foreach( $siteUrl in $siteUrls )
            {
                Write-PSFMessage -Level Verbose -Message "Marking $siteUrl as deleted"
                Update-SiteMetadata -DatabaseConnectionInformation $DatabaseConnectionInformation -SiteUrl $siteUrl -TimeDeleted ([System.Data.SqlTypes.SqlDateTime]::MinValue)
            }

            Write-PSFMessage -Level Verbose -Message "Comparing tenant site list to deleted site list"

            # get all deleted sites that are in the tenant site list
            $siteUrls = @(Compare-Object -ReferenceObject $tenantSitesUrls -DifferenceObject $deletedSiteUrls -IncludeEqual | Where-Object -Property "SideIndicator" -eq "==" | Select-Object -ExpandProperty "InputObject")

            Write-PSFMessage -Level Verbose -Message "Found $($siteUrls.Count) sites to mark as not deleted"

            foreach( $siteUrl in $siteUrls )
            {
                Write-PSFMessage -Level Verbose -Message "Marking $siteUrl as not deleted"
                Invoke-NonQuery -DatabaseConnectionInformation $DatabaseConnectionInformation -Query "UPDATE SiteMetadata SET TimeDeleted = NULL, DeletedBy = NULL WHERE @SiteUrl = @SiteUrl AND TimeDeleted IS NOT NULL" -Parameters @{ SiteUrl = $siteUrl }
            }
        }
    }
    end
    {
        Stop-SyncJobExecution -Name $PSCmdlet.MyInvocation.InvocationName -DatabaseConnectionInformation $DatabaseConnectionInformation 
    }
}
