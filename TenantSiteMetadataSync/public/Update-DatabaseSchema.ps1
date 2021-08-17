function Update-DatabaseSchema
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [string]$ServerInstance,

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
        $tables | Foreach-Object {
            Write-Verbose "$(Get-Date) - Executing File: $($_.Fullname) "
            Invoke-Sqlcmd -InputFile $_.FullName -ServerInstance $ServerInstance -Database $Database
            if( -not $?) { return }
        }

        $functions | Foreach-Object {
            Write-Verbose "$(Get-Date) - Executing File: $($_.Fullname) "
            Invoke-Sqlcmd -InputFile $_.FullName -ServerInstance $ServerInstance -Database $Database
            if( -not $?) { return }
        }

        $procs | Foreach-Object {
            Write-Verbose "$(Get-Date) - Executing File: $($_.Fullname) "
            Invoke-Sqlcmd -InputFile $_.FullName -ServerInstance $ServerInstance -Database $Database
            if( -not $?) { return }
        }

        $views | Foreach-Object {
            Write-Verbose "$(Get-Date) - Executing File: $($_.Fullname) "
            Invoke-Sqlcmd -InputFile $_.FullName -ServerInstance $ServerInstance -Database $Database
            if( -not $?) { return }
        }
    }
    end
    {
    }
}


