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
        [string]$DatabaseServer
    )

    begin
    {
        $databases = Get-ChildItem -Path "$PSScriptRoot\..\private\SQL" -Filter "db_*.sql"
    }
    process
    {
        foreach( $path in $databases )
        {
            Write-Verbose "$(Get-Date) - $($PSCmdlet.MyInvocation.MyCommand) - Executing File: $($path.Fullname)"

            Invoke-Sqlcmd -InputFile $path.FullName -ServerInstance $DatabaseServer
            if( -not $?) { return }
        }
    }
    end
    {
    }
}

