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
	
	.PARAMETER DatabaseName
		The SQL Server database name
	
	.PARAMETER DatabaseServer
		Name of the SQL Server database server, including the instance name (if applicable).
	
	.EXAMPLE
		PS C:\> Import-SensitivityLabel -ClientId <clientId> -Thumbprint <thumbprint> -Tenant <tenant> -DatabaseName <database name> -DatabaseServer <database server>
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

        $query = "EXEC proc_AddOrUpdateSensitivityLabel @Id = @Id, @Label = @Label"

        $uri = "https://graph.microsoft.com/beta/informationProtection/policy/labels"
    }
    process
    {
        if( $connection = Connect-PnPOnline -Url "https://$Tenant-admin.sharepoint.com" -ClientId $ClientId -Thumbprint $Thumbprint -Tenant "$Tenant.onmicrosoft.com" -ReturnConnection $true )
        {
            if( $token = Get-PnPGraphAccessToken -Connection $connection )
            {
                Write-Verbose "$(Get-Date) - Reading sensitivity labels from Graph"

                $labels = Invoke-RestMethod -Method Get -Uri $uri -Headers @{ Authorization = "Bearer $token" } | Select-Object -ExpandProperty value

                foreach( $label in $labels )
                {
                    $parameters = @{}
                    $parameters.Id    = $label.Id
                    $parameters.Label = $label.Name
                
                    Invoke-NonQuery -DatabaseName $DatabaseName -DatabaseServer $DatabaseServer -Query $query -Parameters $parameters
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
