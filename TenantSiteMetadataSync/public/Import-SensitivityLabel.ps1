function Import-SensitivityLabel
{
<#
    .SYNOPSIS
    Imports tenant sensitivity label's Id (GUID) and Name into the SQL database 

    Azure Active Directory Application Principal requires Graph > Application > InformationProtectionPolicy.Read.All

    .DESCRIPTION
    Imports tenant sensitivity label's Id and Name into the SQL database 

    Azure Active Directory Application Principal requires Graph > Application > InformationProtectionPolicy.Read.All

    .PARAMETER ClientId
    Azure Active Directory Application Principal Client/Application Id

    .PARAMETER Thumbprint
    Thumbprint of certificate associated with the Azure Active Directory Application Principal

    .PARAMETER Tenant
    Name of the O365 Tenant

    .PARAMETER DatabaseConnectionInformation
    Database Connection Information

    .EXAMPLE
    PS C:\> Import-SensitivityLabel -ClientId <clientId> -Thumbprint <thumbprint> -Tenant <tenant> -DatabaseConnectionInformation <database connection information>
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

        $query = "EXEC proc_AddOrUpdateSensitivityLabel @Id = @Id, @Label = @Label"

        $uri = "https://graph.microsoft.com/beta/informationProtection/policy/labels"
    }
    process
    {
        Write-PSFMessage -Level Verbose -Message "Connecting to SharePoint Online Tenant"

        if( $connection = Connect-PnPOnline -Url "https://$Tenant-admin.sharepoint.com" -ClientId $ClientId -Thumbprint $Thumbprint -Tenant "$Tenant.onmicrosoft.com" -ReturnConnection:$True )
        {
            if( $token = Get-PnPGraphAccessToken -Connection $connection )
            {
                Write-PSFMessage -Level Verbose -Message "Reading sensitivity labels from Graph"
                Write-PSFMessage -Level Verbose -Message "Requesting labels from Microsoft Graph API"

                $labels = Invoke-RestMethod -Method Get -Uri $uri -Headers @{ Authorization = "Bearer $token" } | Select-Object -ExpandProperty value

                Write-PSFMessage -Level Verbose -Message "Received $($labels.Count) labels from Microsoft Graph API"

                foreach( $label in $labels )
                {
                    $parameters = @{}
                    $parameters.Id    = $label.Id
                    $parameters.Label = $label.Name
                
                    Invoke-NonQuery -DatabaseConnectionInformation $DatabaseConnectionInformation -Query $query -Parameters $parameters
                }
            }

            Disconnect-PnPOnline -Connection $connection
        }
    }
    end
    {
        Stop-SyncJobExecution -Name $PSCmdlet.MyInvocation.InvocationName -DatabaseConnectionInformation $DatabaseConnectionInformation 
    }
}
