function Import-SiteCreationSources
{
<#
	.SYNOPSIS
		Imports tenant site creation source's Id (GUID) and DisplayName into the SQL database 

        Azure Active Directory Application Principal requires SharePoint > Application > Sites.FullControl
	
	.DESCRIPTION
		Imports tenant site creation source's Id (GUID) and DisplayName into the SQL database 

        Azure Active Directory Application Principal requires SharePoint > Application > Sites.FullControl

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
		PS C:\> Import-SiteCreationSources -ClientId <clientId> -Thumbprint <thumbprint> -Tenant <tenant> -DatabaseName <database name> -DatabaseServer <database server>
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

        Start-SyncJobExecution -Name $PSCmdlet.MyInvocation.InvocationName -DatabaseName $DatabaseName -DatabaseServer $DatabaseServer

        $query = "EXEC proc_AddOrUpdateSiteCreationSource @Id = @Id, @Source = @Source"
    }
    process
    {
        if( $connection = Connect-PnPOnline -Url "https://$Tenant-admin.sharepoint.com" -ClientId $ClientId -Thumbprint $Thumbprint -Tenant "$Tenant.onmicrosoft.com" -ReturnConnection $true )
        {
            Write-Verbose "$(Get-Date) - Reading site creation sources from tenant"

            $siteCreationSources = Invoke-PnPSPRestMethod -Method Get -Url "https://$tenant-admin.sharepoint.com/_api/SPO.Tenant/GetSPOSiteCreationSources" -Connection $connection | Select-Object -ExpandProperty value

            Disconnect-PnPOnline -Connection $connection 

            foreach( $siteCreationSource in $siteCreationSources )
            {
                $parameters = @{}
                $parameters.Id     = $siteCreationSource.Id
                $parameters.Source = $siteCreationSource.DisplayName
                
                Invoke-NonQuery -DatabaseName $DatabaseName -DatabaseServer $DatabaseServer -Query $query -Parameters $parameters
            }

            # these are not returned by the tenant

            Invoke-NonQuery -DatabaseName $DatabaseName -DatabaseServer $DatabaseServer -Query $query -Parameters @{ Id = "14D82EEC-204B-4C2F-B7E8-296A70DAB67E"; Source = "Microsoft Graph" }

            Invoke-NonQuery -DatabaseName $DatabaseName -DatabaseServer $DatabaseServer -Query $query -Parameters @{ Id = "5D9FFF84-5B34-4204-BC91-3AAF5F298C5D"; Source = "PnP Lookbook" }
        }
    }
    end
    {
        Stop-SyncJobExecution -Name $PSCmdlet.MyInvocation.InvocationName -ErrorCount $Error.Count -DatabaseName $DatabaseName -DatabaseServer $DatabaseServer
    }
}

