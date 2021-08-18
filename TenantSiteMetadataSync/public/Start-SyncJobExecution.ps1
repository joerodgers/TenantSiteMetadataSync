function Start-SyncJobExecution
{
<#
	.SYNOPSIS
        Adds an entry into the SyncJob table with the provided name and current start time.

	.DESCRIPTION
        Adds an entry into the SyncJob table with the provided name and current start time.

	.PARAMETER Name
		Name of the operation
	
	.PARAMETER DatabaseName
		The SQL Server database name
	
	.PARAMETER DatabaseServer
		Name of the SQL Server database server, including the instance name (if applicable).

    .EXAMPLE
		PS C:\> Start-SyncJobExecution -Name <job name> -DatabaseName <database name> -DatabaseServer <database server> 
#>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [string]$Name,

        [Parameter(Mandatory=$true)]
        [string]$DatabaseName,
        
        [Parameter(Mandatory=$true)]
        [string]$DatabaseServer
    )
    
    begin
    {
        $query = "EXEC proc_StartSyncJobExecution @Name = @Name"
    }
    process
    {
        Invoke-NonQuery -DatabaseName $DatabaseName -DatabaseServer $DatabaseServer -Query $query -Parameters @{ Name = $Name }
    }
    end
    {
    }
}

