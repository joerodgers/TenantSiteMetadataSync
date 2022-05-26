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
        [DatabaseConnectionInformation]
        $DatabaseConnectionInformation
    )

    begin
    {
        $counter = 0

        Start-SyncJobExecution -Name $PSCmdlet.MyInvocation.InvocationName -DatabaseConnectionInformation $DatabaseConnectionInformation
    }
    process
    {
        Write-PSFMessage -Level Verbose -Message "Querying $DatabaseName for group connected sites"
       
        if( $groups = @(Get-DataTable -Query "SELECT GroupId FROM GroupConnectedSites" -DatabaseConnectionInformation $DatabaseConnectionInformation -As 'PSObject') )
        {
            Write-PSFMessage -Level Verbose -Message "Discovered $($groups.Count) groups connected sites"

            try
            {
                Write-PSFMessage -Level Verbose -Message "Connecting to Microsoft Graph"
                $null = Connect-MgGraph -ClientId $ClientId -CertificateThumbprint $Thumbprint -TenantId "$Tenant.onmicrosoft.com" -ErrorAction Stop
            }
            catch
            {
                Write-PSFMessage -Level Critical -Message "Failed to connect to Microsoft Graph." -Exception $_.Exception
                return
            }

            foreach( $group in $groups )
            {
                $counter++ 

                Write-PSFMessage -Level Verbose -Message "$counter/$($groups.Count) - Processing Group: $($group.GroupId)"
                
                try
                {
                    Write-PSFMessage -Level Verbose -Message "Getting group owners from Microsoft Graph API for group: $($group.GroupId)"

                    $groupOwners = @( Get-MgGroupOwner -GroupId $group.GroupId -All -ErrorAction Stop )

                    Write-PSFMessage -Level Verbose -Message "Owner count: $($groupOwners.Count)"

                    if( $groupOwners.Count -gt 0 )
                    {
                        Write-PSFMessage -Level Verbose -Message "Removing group owners for group $($group.GroupId)"

                        Invoke-NonQuery -Query "EXEC proc_RemoveGroupOwnersByGroupId @GroupId = @GroupId" -DatabaseConnectionInformation $DatabaseConnectionInformation -Parameters @{ GroupId = $group.GroupId }

                        $parameters = @{}
                        $parameters.GroupId = $group.GroupId
                    
                        Write-PSFMessage -Level Verbose -Message "Adding Group Owners: $($groupOwners.AdditionalProperties.userPrincipalName -join ';')"

                        foreach( $groupOwner in $groupOwners )
                        {
                            $parameters.UserPrincipalName = $groupOwner.AdditionalProperties.userPrincipalName 
                            
                            try
                            {
                                Invoke-NonQuery -Query "EXEC proc_AddGroupOwnerByGroupId @GroupId = @GroupId, @UserPrincipalName = @UserPrincipalName" -DatabaseConnectionInformation $DatabaseConnectionInformation -Parameters $parameters
                            }
                            catch
                            {
                                Write-PSFMessage -Level Critical -Message "Error updating group owner information for group: '$($group.GroupId)'" -ErrorRecord $_
                            }
                        }
                    }
                    else
                    {
                        Write-PSFMessage -Level Verbose -Message "Group Owner count is zero, preserving existing owners"
                    }
                }
                catch
                {
                    Write-PSFMessage -Level Critical -Message "Error updating group membership" -ErrorRecord $_
                }
            }

            Write-PSFMessage -Level Verbose -Message "Import completed."

            Disconnect-MgGraph
        }
        else 
        {
            Write-PSFMessage -Level Verbose -Message "No groups found."
        }
    }
    end
    {
        Stop-SyncJobExecution -Name $PSCmdlet.MyInvocation.InvocationName -DatabaseConnectionInformation $DatabaseConnectionInformation 
    }
}