function Update-DatabaseSchema
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
        [string]$Database
    )

    begin
    {
        $tables    = Get-ChildItem -Path "$PSScriptRoot\..\private\SQL" -Filter "tb_*.sql"
        $functions = Get-ChildItem -Path "$PSScriptRoot\..\private\SQL" -Filter "tvf_*.sql"
        $procs     = Get-ChildItem -Path "$PSScriptRoot\..\private\SQL" -Filter "procs_*.sql"
        $views     = Get-ChildItem -Path "$PSScriptRoot\..\private\SQL" -Filter "vw_*.sql"
    }
    process
    {   
        foreach( $path in $tables )
        {
            Write-Verbose "$(Get-Date) - Executing File: $($path.Fullname)"
            Invoke-Sqlcmd -InputFile $path.FullName -ServerInstance $DatabaseName -Database $Database
            if( -not $?) { return }
        }

        foreach( $path in $functions )
        {
            Write-Verbose "$(Get-Date) - Executing File: $($path.Fullname)"
            Invoke-Sqlcmd -InputFile $path.FullName -ServerInstance $DatabaseName -Database $Database
            if( -not $?) { return }
        }

        foreach( $path in $procs )
        {
            Write-Verbose "$(Get-Date) - Executing File: $($path.Fullname)"
            Invoke-Sqlcmd -InputFile $path.FullName -ServerInstance $DatabaseName -Database $Database
            if( -not $?) { return }
        }

        foreach( $path in $views )
        {
            Write-Verbose "$(Get-Date) - Executing File: $($path.Fullname)"
            Invoke-Sqlcmd -InputFile $path.FullName -ServerInstance $DatabaseName -Database $Database
            if( -not $?) { return }
        }
    }
    end
    {
    }
}


