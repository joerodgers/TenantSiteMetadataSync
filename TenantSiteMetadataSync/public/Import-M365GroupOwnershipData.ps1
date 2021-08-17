function Import-M365GroupOwnershipData
{
    # requires GroupMember.Read.All

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

        $counter = 1

        Start-SyncJobExecution -Name $PSCmdlet.MyInvocation.InvocationName -DatabaseName $DatabaseName -DatabaseServer $DatabaseServer
    }
    process
    {
        if( $groups = Get-DataTable -Query "SELECT GroupId FROM GroupConnectedSites" -DatabaseName $DatabaseName -DatabaseServer $DatabaseServer )
        {
            Write-Verbose "$(Get-Date) - $($PSCmdlet.MyInvocation.MyCommand) - Discovered $($groups.Count) Groups"

            $null = Connect-MgGraph -ClientId $ClientId -CertificateThumbprint $Thumbprint -TenantId "$Tenant.onmicrosoft.com"

            foreach( $group in $groups )
            {
                Write-Verbose "$(Get-Date) - $($PSCmdlet.MyInvocation.MyCommand) - $counter/$($groups.Count) - Processing Group: $($group.GroupId)"
                
                try
                {
                    $groupOwners = @(Get-MgGroupOwner -GroupId $group.GroupId -Top 500)

                    Write-Verbose "$(Get-Date) - $($PSCmdlet.MyInvocation.MyCommand) - Owner count: $($groupOwners.Count)"

                    if( $groupOwners.Count -gt 0 )
                    {
                        Invoke-NonQuery -Query "EXEC proc_RemoveGroupOwnersByGroupId @GroupId = @GroupId" -DatabaseName $DatabaseName -DatabaseServer $DatabaseServer -Parameters @{ GroupId = $group.GroupId }

                        $parameters = @{}
                        $parameters.GroupId = $group.GroupId
                    
                        foreach( $groupOwner in $groupOwners )
                        {
                            $parameters.UserPrincipalName = $groupOwner.AdditionalProperties.userPrincipalName 
                            
                            try
                            {
                                Invoke-NonQuery -Query "EXEC proc_AddGroupOwnerByGroupId @GroupId = @GroupId, @UserPrincipalName = @UserPrincipalName" -DatabaseName $DatabaseName -DatabaseServer $DatabaseServer -Parameters $parameters
                            }
                            catch
                            {
                                Write-Error "$($PSCmdlet.MyInvocation.MyCommand) - Error updating group membership for Group='$($group.GroupId)'. Error: $($_)"
                            }
                        }
                    }
                }
                catch
                {
                    Write-Error $_
                }
                
                $counter++

            }

            Disconnect-MgGraph
        }
    }
    end
    {
        Stop-SyncJobExecution -Name $PSCmdlet.MyInvocation.InvocationName -ErrorCount $Error.Count -DatabaseName $DatabaseName -DatabaseServer $DatabaseServer
    }
}

