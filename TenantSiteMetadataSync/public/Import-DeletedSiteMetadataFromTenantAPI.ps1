function Import-DeletedSiteMetadataFromTenantAPI
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
        [string]$DatabaseName,
        
        [Parameter(Mandatory=$true)]
        [string]$DatabaseServer
    )

    begin
    {
        $Error.Clear()

        $Tenant = $Tenant -replace ".onmicrosoft.com", ""

        Start-SyncJobExecution -Name $PSCmdlet.MyInvocation.InvocationName -DatabaseName $DatabaseName -DatabaseServer $DatabaseServer
    }
    process
    {
        $counter = 1

        Write-Verbose "$(Get-Date) - Reading sites from tenant recycle bin"

        if( $connection = Connect-PnPOnline -Url "https://$Tenant-admin.sharepoint.com" -ClientId $ClientId -Thumbprint $Thumbprint -Tenant "$Tenant.onmicrosoft.com" -ReturnConnection )
        {
            if( $tenantSites = Get-PnPTenantRecycleBinItem -Connection $connection )
            {
                foreach( $tenantSite in $tenantSites )
                {
                    try
                    {
                        Write-Verbose "$(Get-Date) - ($counter/$($tenantSites.Count)) Processing Deleted Site: $($tenantSite.Url)"

                        Update-SiteMetadata -DatabaseName $DatabaseName -DatabaseServer $DatabaseServer -SiteId $tenantSite.SiteId -SiteUrl $tenantSite.Url -TimeDeleted $tenantSite.DeletionTime
                    }
                    catch
                    {
                        Write-Error "$($PSCmdlet.MyInvocation.MyCommand) - Error updating Deleted SiteUrl='$($tenantSite.Url)'. Error: $($_)"
                    }

                    $counter++
                }
            }
        }
    }
    end
    {
        Stop-SyncJobExecution -Name $PSCmdlet.MyInvocation.InvocationName -ErrorCount $Error.Count -DatabaseName $DatabaseName -DatabaseServer $DatabaseServer
    }
}
