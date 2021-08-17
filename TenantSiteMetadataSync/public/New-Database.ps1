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
        foreach( $path in $databases )
        {
            Write-Verbose "$(Get-Date) - Executing File: $($path.Fullname) "
            Invoke-Sqlcmd -InputFile $path.FullName -ServerInstance $ServerInstance
            if( -not $?) { return }
        }
    }
    end
    {
    }
}

