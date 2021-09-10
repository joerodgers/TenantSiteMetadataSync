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
        Write-PSFMessage -Level Verbose -Message "Querying $DatabaseName for GROUP connected sites"
       
        if( $groups = @(Get-DataTable -Query "SELECT GroupId FROM GroupConnectedSites" -DatabaseName $DatabaseName -DatabaseServer $DatabaseServer -As 'PSObject') )
        {
            Write-PSFMessage -Level Verbose -Message "Discovered $($groups.Count) groups connected sites"

            Write-PSFMessage -Level Verbose -Message "Connecting to Microsoft Graph"

            $null = Connect-MgGraph -ClientId $ClientId -CertificateThumbprint $Thumbprint -TenantId "$Tenant.onmicrosoft.com"

            Write-PSFMessage -Level Verbose -Message "Connected to Microsoft Graph"

            foreach( $group in $groups )
            {
                Write-PSFMessage -Level Verbose -Message "$counter/$($groups.Count) - Processing Group: $($group.GroupId)"
                
                try
                {
                    Write-PSFMessage -Level Verbose -Message "Getting group owners from Microsoft Graph API"

                    $groupOwners = @(Get-MgGroupOwner -GroupId $group.GroupId -Top 500)

                    Write-PSFMessage -Level Verbose -Message "Owner count: $($groupOwners.Count)"

                    if( $groupOwners.Count -gt 0 )
                    {
                        Write-PSFMessage -Level Verbose -Message "Removing group owners for group $($group.GroupId)"

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
                                Write-PSFMessage -Level Verbose -Message "Error updating group membership for Group='$($group.GroupId)'" -Exception $_
                            }
                        }
                    }
                }
                catch
                {
                    Write-PSFMessage -Level Error -Message "Error updating group membership" -Exception $_
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

