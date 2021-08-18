function Import-SensitivityLabel
{
    # requires InformationProtectionPolicy.Read.All

    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [string]$Tenant,

        [Parameter(Mandatory=$true)]
        [string]$ClientId,

        [Parameter(Mandatory=$true)]
        [string]$Thumbprint,

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
