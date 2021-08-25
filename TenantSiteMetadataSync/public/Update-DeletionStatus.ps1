﻿function Update-DeletionStatus
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
	
	.PARAMETER DatabaseName
		The SQL Server database name
	
	.PARAMETER DatabaseServer
		Name of the SQL Server database server, including the instance name (if applicable).
	
	.EXAMPLE
		PS C:\> Update-DeletionStatus -ClientId <clientId> -Thumbprint <thumbprint> -Tenant <tenant> -DatabaseName <database name> -DatabaseServer <database server>
	
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
        $tenantSites = $activeSites = $deletedSites = $null

        $Error.Clear()

        Start-SyncJobExecution -Name $PSCmdlet.MyInvocation.InvocationName -DatabaseName $DatabaseName -DatabaseServer $DatabaseServer
    }
    process
    {
        Write-Verbose "$(Get-Date) - $($PSCmdlet.MyInvocation.MyCommand) - Connecting to SharePoint Online Tenant"

        if( $connection = Connect-PnPOnline -Url "https://$Tenant-admin.sharepoint.com" -ClientId $ClientId -Thumbprint $Thumbprint -Tenant "$Tenant.onmicrosoft.com" -ReturnConnection )
        {
            Write-Verbose "$(Get-Date) - $($PSCmdlet.MyInvocation.MyCommand) - Querying tenant for sites"

            $tenantSites = Get-PnPTenantSite -IncludeOneDriveSites -Connection $connection | Select-Object -ExpandProperty Url | ConvertTo-NormalizedUrl

            $tenantSites += Get-HiddenSiteUrl -Tenant $Tenant | ConvertTo-NormalizedUrl

            Disconnect-PnPOnline -Connection $connection

            Write-Verbose "$(Get-Date) - $($PSCmdlet.MyInvocation.MyCommand) - Querying database for all active sites"

            $activeSites = Get-DataTable -DatabaseName $DatabaseName -DatabaseServer $DatabaseServer -Query "SELECT SiteId, SiteUrl FROM ActiveSites"
        
            Write-Verbose "$(Get-Date) - $($PSCmdlet.MyInvocation.MyCommand) - Querying database for all deleted sites"

            $deletedSites = Get-DataTable -DatabaseName $DatabaseName -DatabaseServer $DatabaseServer -Query "SELECT SiteId, SiteUrl FROM DeletedSites"

            # mark sites as deleted if they are not in tenant list anymore and are not marked as deleted in the database
            foreach( $activeSite in $activeSites )
            {
                if( $tenantSites -notcontains $activeSite.SiteUrl )
                {
                    Write-Verbose "$(Get-Date) - $($PSCmdlet.MyInvocation.MyCommand) - Marking $($activeSite.SiteUrl) as deleted"

                    Update-SiteMetadata -DatabaseName $DatabaseName -DatabaseServer $DatabaseServer -SiteId $activeSite.SiteId -SiteUrl $activeSite.SiteUrl -TimeDeleted ([System.Data.SqlTypes.SqlDateTime]::MinValue)
                }
            }


            # mark sites as not deleted if they are present in tenant list
            foreach( $deletedSite in $deletedSites )
            {
                if( $tenantSites -contains $deletedSite.SiteUrl )
                {
                    Write-Verbose "$(Get-Date) - $($PSCmdlet.MyInvocation.MyCommand) - Marking $($activeSite.SiteUrl) as not deleted"

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

