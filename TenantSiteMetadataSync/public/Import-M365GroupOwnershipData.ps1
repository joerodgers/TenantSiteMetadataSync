function Import-M365GroupOwnershipData
{
<#
	.SYNOPSIS
		Uses the Graph API to read O365/M365 Group owner metadata and imports the data into the SQL database.  
        
        Azure Active Directory Application Principal requires Graph > Application > GroupMember.Read.All permissions.
	
	.DESCRIPTION
		Uses the Graph API to read O365/M365 Group owner metadata and imports the data into the SQL database.  

        Azure Active Directory Application Principal requires Graph > Application > GroupMember.Read.All permissions.
	
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
		PS C:\> Import-M365GroupOwnershipData -ClientId <clientId> -Thumbprint <thumbprint> -Tenant <tenant> -DatabaseName <database name> -DatabaseServer <database server>
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

        $counter = 1

        Start-SyncJobExecution -Name $PSCmdlet.MyInvocation.InvocationName -DatabaseName $DatabaseName -DatabaseServer $DatabaseServer
    }
    process
    {
        Write-Verbose "$(Get-Date) - $($PSCmdlet.MyInvocation.MyCommand) - Querying for group connected sites"
        
        if( $groups = Get-DataTable -Query "SELECT GroupId FROM GroupConnectedSites" -DatabaseName $DatabaseName -DatabaseServer $DatabaseServer )
        {
            Write-Verbose "$(Get-Date) - $($PSCmdlet.MyInvocation.MyCommand) - Discovered $($groups.Count) groups connected sites"

            Write-Verbose "$(Get-Date) - $($PSCmdlet.MyInvocation.MyCommand) - Connecting to Microsoft Graph"

            $null = Connect-MgGraph -ClientId $ClientId -CertificateThumbprint $Thumbprint -TenantId "$Tenant.onmicrosoft.com"

            Write-Verbose "$(Get-Date) - $($PSCmdlet.MyInvocation.MyCommand) - Connected to Microsoft Graph"

            foreach( $group in $groups )
            {
                Write-Verbose "$(Get-Date) - $($PSCmdlet.MyInvocation.MyCommand) - $counter/$($groups.Count) - Processing Group: $($group.GroupId)"
                
                try
                {
                    Write-Verbose "$(Get-Date) - $($PSCmdlet.MyInvocation.MyCommand) - Getting group owners from Graph API"

                    $groupOwners = @(Get-MgGroupOwner -GroupId $group.GroupId -Top 500)

                    Write-Verbose "$(Get-Date) - $($PSCmdlet.MyInvocation.MyCommand) - Owner count: $($groupOwners.Count)"

                    if( $groupOwners.Count -gt 0 )
                    {
                        Write-Verbose "$(Get-Date) - $($PSCmdlet.MyInvocation.MyCommand) - Removing group owners for group $($group.GroupId)"

                        Invoke-NonQuery -Query "EXEC proc_RemoveGroupOwnersByGroupId @GroupId = @GroupId" -DatabaseName $DatabaseName -DatabaseServer $DatabaseServer -Parameters @{ GroupId = $group.GroupId }

                        $parameters = @{}
                        $parameters.GroupId = $group.GroupId
                    
                        foreach( $groupOwner in $groupOwners )
                        {
                            $parameters.UserPrincipalName = $groupOwner.AdditionalProperties.userPrincipalName 
                            
                            try
                            {
                                Write-Verbose "$(Get-Date) - $($PSCmdlet.MyInvocation.MyCommand) - Add group owner $($parameters.UserPrincipalName) for group $($group.GroupId)"

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

