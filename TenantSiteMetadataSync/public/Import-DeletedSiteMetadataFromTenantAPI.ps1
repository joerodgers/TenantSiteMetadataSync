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

    .PARAMETER DatabaseConnectionInformation
    The SQL Server database connection details

    .EXAMPLE
    PS C:\> Import-DeletedSiteMetadataFromTenantAPI -ClientId <clientId> -Thumbprint <thumbprint> -Tenant <tenant> -DatabaseConnectionInformation <database connection object>
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
        $Error.Clear()

        $Tenant = $Tenant -replace ".onmicrosoft.com", ""

        Start-SyncJobExecution -Name $PSCmdlet.MyInvocation.InvocationName -DatabaseConnectionInformation $DatabaseConnectionInformation 
    }
    process
    {
        Write-PSFMessage -Level Verbose -Message "Connecting to SharePoint Online Tenant"

        if( $connection = Connect-PnPOnline -Url "https://$Tenant-admin.sharepoint.com" -ClientId $ClientId -Thumbprint $Thumbprint -Tenant "$Tenant.onmicrosoft.com" -ReturnConnection:$True )
        {
            Write-PSFMessage -Level Verbose -Message "Querying tenant for deleted site collections"

            $tenantSites = @(Get-PnPTenantDeletedSite -IncludePersonalSite:$true -Limit 1000000 -Connection $connection)

            Write-PSFMessage -Level Debug -Message "Discovered $($tenantSites.Count) deleted site collections"

            $counter = 1

            foreach( $tenantSite in $tenantSites )
            {
                try
                {
                    Write-PSFMessage -Level Debug -Message "($counter/$($tenantSites.Count)) Processing Url: $($tenantSite.Url)"

                    Update-SiteMetadata -DatabaseConnectionInformation $DatabaseConnectionInformation -SiteId $tenantSite.SiteId -SiteUrl $tenantSite.Url -TimeDeleted $tenantSite.DeletionTime
                }
                catch
                {
                    Write-PSFMessage -Level Error -Message "Error updating deleted site. SiteUrl='$($tenantSite.Url)'" -Exception $_.Exception
                }

                $counter++
            }

            Disconnect-PnPOnline -Connection $connection
        }
    }
    end
    {
        Stop-SyncJobExecution -Name $PSCmdlet.MyInvocation.InvocationName -ErrorCount $Error.Count -DatabaseConnectionInformation $DatabaseConnectionInformation 
    }
}
