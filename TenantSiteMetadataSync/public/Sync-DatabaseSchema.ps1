function Sync-DatabaseSchema
{
<#
    .SYNOPSIS
    Updates the database schema to match the module build. 

    .DESCRIPTION
    Updates the database schema to match the module build. 

    .PARAMETER DatabaseConnectionInformation
    Database Connection Information

    .EXAMPLE
    PS C:\> Update-DatabaseSchema -DatabaseConnectionInformation <database connection information> 
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
        $tables    = Get-ChildItem -Path "$PSScriptRoot\..\private\SQL" -Filter "tb_*.sql"
        $functions = Get-ChildItem -Path "$PSScriptRoot\..\private\SQL" -Filter "tvf_*.sql"
        $procs     = Get-ChildItem -Path "$PSScriptRoot\..\private\SQL" -Filter "proc_*.sql"
        $views     = Get-ChildItem -Path "$PSScriptRoot\..\private\SQL" -Filter "vw_*.sql"
        $upgrades  = Get-ChildItem -Path "$PSScriptRoot\..\private\SQL" -Filter "upgrade*.sql"
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

        foreach( $path in $tables )
        {
            Write-Verbose "$(Get-Date) - $($PSCmdlet.MyInvocation.MyCommand) - Executing table file: $($path.Fullname)"

            Invoke-Sqlcmd @parameters -InputFile $path.FullName

            if( -not $?) { return }
        }

        foreach( $path in $functions )
        {
            Write-Verbose "$(Get-Date) - $($PSCmdlet.MyInvocation.MyCommand) - Executing function file: $($path.Fullname)"

            Invoke-Sqlcmd @parameters -InputFile $path.FullName

            if( -not $?) { return }
        }

        foreach( $path in $procs )
        {
            Write-Verbose "$(Get-Date) - $($PSCmdlet.MyInvocation.MyCommand) - Executing proc file: $($path.Fullname)"

            Invoke-Sqlcmd @parameters -InputFile $path.FullName

            if( -not $?) { return }
        }

        foreach( $path in $views )
        {
            Write-Verbose "$(Get-Date) - $($PSCmdlet.MyInvocation.MyCommand) - Executing view file: $($path.Fullname)"

            Invoke-Sqlcmd @parameters -InputFile $path.FullName

            if( -not $?) { return }
        }

        foreach( $path in $upgrades )
        {
            Write-Verbose "$(Get-Date) - $($PSCmdlet.MyInvocation.MyCommand) - Executing upgrade file: $($path.Fullname)"

            Invoke-Sqlcmd @parameters -InputFile $path.FullName

            if( -not $?) { return }
        }
    }
    end
    {
    }
}


