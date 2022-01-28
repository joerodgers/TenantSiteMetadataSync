function Import-SecondarySiteAdmin
{
<#
    .SYNOPSIS
    Imports metadata about site collections that are in the tenant's recycle bin. 

    .DESCRIPTION
    Imports metadata, specifically the 'TimeDeleted' property about site collections that are in the tenant's recycle bin. 

    .PARAMETER ClientId
    Azure Active Directory Application Principal Client/Application Id

    .PARAMETER Thumbprint
    Thumbprint of certificate associated with the Azure Active Directory Application Principal

    .PARAMETER Tenant
    Name of the O365 Tenant

    .PARAMETER DatabaseConnectionInformation
    The SQL Server database connection details

    .EXAMPLE
    PS C:\> Import-DeletedSiteMetadataFromTenantAPI -ClientId <clientId> -Thumbprint <thumbprint> -Tenant <tenant> -DatabaseConnectionInformation <database connection object>
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
        $Error.Clear()

        $Tenant = $Tenant -replace ".onmicrosoft.com", ""

        Start-SyncJobExecution -Name $PSCmdlet.MyInvocation.InvocationName -DatabaseConnectionInformation $DatabaseConnectionInformation 
    }
    process
    {
        Write-PSFMessage -Level Verbose -Message "Connecting to https://$Tenant-admin.sharepoint.com"

        if( $connection = Connect-PnPOnline -Url "https://$Tenant-admin.sharepoint.com" -ClientId $ClientId -Thumbprint $Thumbprint -Tenant "$Tenant.onmicrosoft.com" -ReturnConnection:$True )
        {
            Write-PSFMessage -Level Verbose -Message "Querying dbo.SitesActive"

            if( $sites = Get-DataTable -Query "SELECT SiteUrl, SiteId FROM dbo.SitesActive (nolock) WHERE LockState = 'Unlock'" -DatabaseConnectionInformation $DatabaseConnectionInformation -As 'PSObject') 
            {
                Write-PSFMessage -Level Debug -Message "Discovered $($sites.Count) active site collections"

                $counter = 1

                foreach( $site in $sites )
                {
                    Write-PSFMessage -Level Verbose -Message "($counter/$($sites.Count)) Processing SiteUrl: $($site.SiteUrl), ID:$($site.SiteId)"

                    try
                    {
                        $secondaryAdministratorsFieldsDataJSON = '{{ "secondaryAdministratorsFieldsData":  {{"siteId":  "{0}" }}}}' -f $site.SiteId

                        $secondaryAdministrators = Invoke-PnPSPRestMethod -Method Post -Url "https://$tenant-admin.sharepoint.com/_api/SPO.Tenant/GetSiteSecondaryAdministrators" -Content $secondaryAdministratorsFieldsDataJSON | Select-Object -ExpandProperty value

                        if( $secondaryAdministrators )
                        {
                            Write-PSFMessage -Level Verbose -Message "Removing all listed administrators"

                            # drop existing secondary admins
                            Invoke-NonQuery -Query "EXEC proc_RemoveSecondarySiteAdminsBySiteId @SiteId = @SiteId" -DatabaseConnectionInformation $DatabaseConnectionInformation -Parameters @{ SiteId = $site.SiteId.ToString() }

                            # add new secondary admins
                            foreach( $secondaryAdministrator in $secondaryAdministrators )
                            {
                                Write-PSFMessage -Level Verbose -Message "Adding administrator: $($secondaryAdministrator.loginName)"

                                $parameters = @{}
                                $parameters.DatabaseConnectionInformation = $DatabaseConnectionInformation
                                $parameters.Query                         = "EXEC proc_AddSecondarySiteAdminBySiteId @SiteId = @SiteId, @LoginName = @LoginName, @IsUserPrincipal = @IsUserPrincipal, @PrincipalDisplayName = @PrincipalDisplayName"

                                # user principal
                                if( -not [string]::IsNullOrWhiteSpace($secondaryAdministrator.UserPrincipalName) )
                                {
                                    $parameters.Parameters = @{ 
                                        SiteId               = $site.SiteId
                                        LoginName            = $secondaryAdministrator.UserPrincipalName
                                        IsUserPrincipal      = $true
                                        PrincipalDisplayName = $secondaryAdministrator.Name 
                                    }

                                    Invoke-NonQuery @parameters
                                }
                                # group principal
                                elseif( -not [string]::IsNullOrWhiteSpace($secondaryAdministrator.loginName) )
                                {
                                    $parameters.Parameters = @{ 
                                        SiteId               = $site.SiteId
                                        LoginName            = $secondaryAdministrator.loginName
                                        IsUserPrincipal      = $false
                                        PrincipalDisplayName = $secondaryAdministrator.Name 
                                    }

                                    Invoke-NonQuery @parameters
                                }

                            }
                        }
                        else
                        {
                            Write-PSFMessage -Level Verbose -Message "No secondary site admins found for site collection: $($site.SiteId)"
                        }
                    }
                    catch
                    {
                        Write-PSFMessage -Level Critical -Message "Error updating secondary admins for site. SiteId='$($site.SiteId)'" -Exception $_.Exception
                    }

                    $counter++
                }
            }
            
            Disconnect-PnPOnline -Connection $connection
        }
    }
    end
    {
        Stop-SyncJobExecution -Name $PSCmdlet.MyInvocation.InvocationName -ErrorCount $Error.Count -DatabaseConnectionInformation $DatabaseConnectionInformation 
    }
}
