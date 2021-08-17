function New-Database
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [string]$ServerInstance
    )

    begin
    {
        $databases = Get-ChildItem -Path "$PSScriptRoot\..\private\SQL\db_*.sql"
    }
    process
    {
        $databases | Foreach-Object {
            Write-Verbose "$(Get-Date) - Executing File: $($_.Fullname) "
            Invoke-Sqlcmd -InputFile $_.FullName -ServerInstance $ServerInstance
            if( -not $?) { return }
        }
    }
    end
    {
    }
}

