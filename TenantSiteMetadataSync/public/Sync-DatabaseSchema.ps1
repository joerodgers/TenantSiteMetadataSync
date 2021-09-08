function Sync-DatabaseSchema
{
<#
    .SYNOPSIS
    Updates the database schema to match the module build. 

    .DESCRIPTION
    Updates the database schema to match the module build. 

    .PARAMETER DatabaseName
    The SQL Server database name

    .PARAMETER DatabaseServer
    Name of the SQL Server database server, including the instance name (if applicable).

    .EXAMPLE
    PS C:\> Update-DatabaseSchema -DatabaseName <database name> -DatabaseServer <database server> 
#>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [string]$DatabaseName,

        [Parameter(Mandatory=$true)]
        [string]$DatabaseServer
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
        foreach( $path in $tables )
        {
            Write-Verbose "$(Get-Date) - $($PSCmdlet.MyInvocation.MyCommand) - Executing table file: $($path.Fullname)"

            Invoke-Sqlcmd -InputFile $path.FullName -ServerInstance $DatabaseServer -Database $DatabaseName
            if( -not $?) { return }
        }

        foreach( $path in $functions )
        {
            Write-Verbose "$(Get-Date) - $($PSCmdlet.MyInvocation.MyCommand) - Executing function file: $($path.Fullname)"

            Invoke-Sqlcmd -InputFile $path.FullName -ServerInstance $DatabaseServer -Database $DatabaseName
            if( -not $?) { return }
        }

        foreach( $path in $procs )
        {
            Write-Verbose "$(Get-Date) - $($PSCmdlet.MyInvocation.MyCommand) - Executing proc file: $($path.Fullname)"

            Invoke-Sqlcmd -InputFile $path.FullName -ServerInstance $DatabaseServer -Database $DatabaseName
            if( -not $?) { return }
        }

        foreach( $path in $views )
        {
            Write-Verbose "$(Get-Date) - $($PSCmdlet.MyInvocation.MyCommand) - Executing view file: $($path.Fullname)"

            Invoke-Sqlcmd -InputFile $path.FullName -ServerInstance $DatabaseServer -Database $DatabaseName
            if( -not $?) { return }
        }

        foreach( $path in $upgrades )
        {
            Write-Verbose "$(Get-Date) - $($PSCmdlet.MyInvocation.MyCommand) - Executing upgrade file: $($path.Fullname)"

            Invoke-Sqlcmd -InputFile $path.FullName -ServerInstance $DatabaseServer -Database $DatabaseName
            if( -not $?) { return }
        }
    }
    end
    {
    }
}


