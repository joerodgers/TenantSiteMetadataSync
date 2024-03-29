﻿function Import-SiteCreationSource
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

    .PARAMETER DatabaseConnectionInformation
    Database Connection Information

    .EXAMPLE
    PS C:\> Import-SiteCreationSource -ClientId <clientId> -Thumbprint <thumbprint> -Tenant <tenant> -DatabaseConnectionInformation <database connection information>
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

        $query = "EXEC proc_AddOrUpdateSiteCreationSource @Id = @Id, @Source = @Source"

        $uri = "https://$tenant-admin.sharepoint.com/_api/SPO.Tenant/GetSPOSiteCreationSources"

        $additionalSources = @{ Id = "14D82EEC-204B-4C2F-B7E8-296A70DAB67E"; DisplayName = "Microsoft Graph" },
                             @{ Id = "5D9FFF84-5B34-4204-BC91-3AAF5F298C5D"; DisplayName = "PnP Lookbook"    }
    }
    process
    {
        Write-PSFMessage -Level Verbose -Message "Connecting to SharePoint Online Tenant"

        if( $connection = Connect-PnPOnline -Url "https://$Tenant-admin.sharepoint.com" -ClientId $ClientId -Thumbprint $Thumbprint -Tenant "$Tenant.onmicrosoft.com" -ReturnConnection:$True )
        {
            Write-PSFMessage -Level Verbose -Message "Requesting site creation sources from SharePoint Tenant REST API"
            
            $siteCreationSources = Invoke-PnPSPRestMethod -Method Get -Url $uri -Connection $connection | Select-Object -ExpandProperty value

            Write-PSFMessage -Level Verbose -Message "Received $($siteCreationSources.Count) creation sources from SharePoint Tenant REST API"

            $siteCreationSources += $additionalSources

            Disconnect-PnPOnline -Connection $connection 

            foreach( $siteCreationSource in $siteCreationSources )
            {
                $parameters = @{}
                $parameters.Id     = $siteCreationSource.Id
                $parameters.Source = $siteCreationSource.DisplayName
                
                Invoke-NonQuery -DatabaseConnectionInformation $DatabaseConnectionInformation -Query $query -Parameters $parameters
            }
        }
    }
    end
    {
        Stop-SyncJobExecution -Name $PSCmdlet.MyInvocation.InvocationName -DatabaseConnectionInformation $DatabaseConnectionInformation 
    }
}

