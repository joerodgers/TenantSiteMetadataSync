function New-Database
{
<#
    .SYNOPSIS
    Creates the required 'TenantSiteMetadataSync' SQL database


    .DESCRIPTION
    Creates the required 'TenantSiteMetadataSync' SQL database

    .PARAMETER DatabaseServer
    Name of the SQL Server database server, including the instance name (if applicable).

    .EXAMPLE
    PS C:\> New-Database -DatabaseServer <database server>
#>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [DatabaseConnectionInformation]
        $DatabaseConnectionInformation
    )

    begin
    {
        $databases = Get-ChildItem -Path "$PSScriptRoot\..\private\SQL" -Filter "db_*.sql"
    }
    process
    {
        if( $DatabaseConnectionInformation -is [TrustedConnectionDatabaseConnectionInformation] )
        {
            $parameters = @{ 
                ServerInstance = $DatabaseConnectionInformation.DatabaseServer
                Database       = $DatabaseConnectionInformation.DatabaseName
            }
        }
        elseif ( $DatabaseConnectionInformation -is [SqlAuthenticationDatabaseConnectionInformation] )
        {
            $parameters = @{ 
                ServerInstance = $DatabaseConnectionInformation.DatabaseServer
                Database       = $DatabaseConnectionInformation.DatabaseName
                UserName       = $DatabaseConnectionInformation.SqlCredential.UserId
                Password       = $DatabaseConnectionInformation.SqlCredential.Password | ConvertFrom-SecureString -AsPlainText
            }
        }
        elseif ( $DatabaseConnectionInformation -is [ServicePrincipalDatabaseConnectionInformation] )
        {
            $accessToken = New-AzureSqlAccessToken `
                                -ClientId     $DatabaseConnectionInformation.ClientId `
                                -ClientSecret $DatabaseConnectionInformation.ClientSecret `
                                -TenantId     $DatabaseConnectionInformation.TenantId

            $parameters = @{ 
                ServerInstance = $DatabaseConnectionInformation.DatabaseServer
                Database       = $DatabaseConnectionInformation.DatabaseName
                AccessToken    = $accessToken
            }
        }

        foreach( $path in $databases )
        {
            Write-Verbose "$(Get-Date) - $($PSCmdlet.MyInvocation.MyCommand) - Executing File: $($path.Fullname)"

            Invoke-Sqlcmd @parameters -InputFile $path.FullName

            if( -not $?) { return }
        }
    }
    end
    {
    }
}

