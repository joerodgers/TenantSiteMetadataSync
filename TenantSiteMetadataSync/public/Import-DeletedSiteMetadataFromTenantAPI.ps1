function Import-DeletedSiteMetadataFromTenantAPI
{
<#
	.SYNOPSIS
		Imports metadata about site collections that are in the tenant's recycle bin. 
	
	.DESCRIPTION
		Imports metadata, specifically the 'TimeDeleted' property about site collections that are in the tenant's recycle bin. 
	
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
	
	.EXAMPLE
		PS C:\> Import-DeletedSiteMetadataFromTenantAPI -ClientId <clientId> -Thumbprint <thumbprint> -Tenant <tenant> -DatabaseName <database name> -DatabaseServer <database server>
	
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

        Write-Verbose "$(Get-Date) - $($PSCmdlet.MyInvocation.MyCommand) - Reading sites from tenant recycle bin"

        if( $connection = Connect-PnPOnline -Url "https://$Tenant-admin.sharepoint.com" -ClientId $ClientId -Thumbprint $Thumbprint -Tenant "$Tenant.onmicrosoft.com" -ReturnConnection:$True )
        {
            if( $tenantSites = Get-PnPTenantRecycleBinItem -Connection $connection )
            {
                foreach( $tenantSite in $tenantSites )
                {
                    try
                    {
                        Write-Verbose "$(Get-Date) - $($PSCmdlet.MyInvocation.MyCommand) - ($counter/$($tenantSites.Count)) Processing Url: $($tenantSite.Url)"

                        Update-SiteMetadata -DatabaseName $DatabaseName -DatabaseServer $DatabaseServer -SiteId $tenantSite.SiteId -SiteUrl $tenantSite.Url -TimeDeleted $tenantSite.DeletionTime
                    }
                    catch
                    {
                        Write-Error "$($PSCmdlet.MyInvocation.MyCommand) - Error updating deleted site. SiteUrl='$($tenantSite.Url)'. Error='$($_)'"
                    }

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
