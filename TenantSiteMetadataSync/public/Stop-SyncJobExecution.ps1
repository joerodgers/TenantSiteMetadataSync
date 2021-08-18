function Stop-SyncJobExecution
{
<#
	.SYNOPSIS
        Updates an entry with the provided Name in SyncJob table current completion time and the count of any errors in the global $error array 

	.DESCRIPTION
        Updates an entry with the provided Name in SyncJob table current completion time and the count of any errors in the global $error array 

	.PARAMETER Name
		Name of the operation
	
	.PARAMETER DatabaseName
		The SQL Server database name
	
	.PARAMETER DatabaseServer
		Name of the SQL Server database server, including the instance name (if applicable).

    .EXAMPLE
		PS C:\> Stop-SyncJobExecution -Name <job name> -DatabaseName <database name> -DatabaseServer <database server> 
#>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [string]$Name,

        [Parameter(Mandatory=$true)]
        [string]$DatabaseName,
        
        [Parameter(Mandatory=$true)]
        [string]$DatabaseServer,

        [Parameter(Mandatory=$false)]
        [int]$ErrorCount = $Error.Count
    )
    
    begin
    {
        $query = "EXEC proc_StopSyncJobExecution @Name = @Name @ErrorCount = @ErrorCount"
    }
    process
    {
        Invoke-NonQuery -DatabaseName $DatabaseName -DatabaseServer $DatabaseServer -Query $query -Parameters @{ Name = $Name; ErrorCount = $ErrorCount }
    }
    end
    {
    }
}

