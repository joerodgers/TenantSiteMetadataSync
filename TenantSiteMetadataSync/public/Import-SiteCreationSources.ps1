function Import-SiteCreationSources
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

        Start-SyncJobExecution -Name $PSCmdlet.MyInvocation.InvocationName -DatabaseName $DatabaseName -DatabaseServer $DatabaseServer

        $query = "EXEC proc_AddOrUpdateSiteCreationSource @Id = @Id, @Source = @Source"
    }
    process
    {
        if( $connection = Connect-PnPOnline -Url "https://$Tenant-admin.sharepoint.com" -ClientId $ClientId -Thumbprint $Thumbprint -Tenant "$Tenant.onmicrosoft.com" -ReturnConnection )
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

