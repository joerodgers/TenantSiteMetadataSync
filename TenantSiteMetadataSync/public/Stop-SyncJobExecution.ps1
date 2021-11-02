function Stop-SyncJobExecution
{
<#
    .SYNOPSIS
    Updates an entry with the provided Name in SyncJob table current completion time and the count of any errors in the global $error array 

    .DESCRIPTION
    Updates an entry with the provided Name in SyncJob table current completion time and the count of any errors in the global $error array 

    .PARAMETER Name
    Name of the operation

    .PARAMETER DatabaseConnectionInformation
    Database Connection Information

    .EXAMPLE
    PS C:\> Stop-SyncJobExecution -Name <job name> -DatabaseConnectionInformation <database connection information>
#>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [string]$Name,

        [Parameter(Mandatory=$true)]
        [DatabaseConnectionInformation]
        $DatabaseConnectionInformation,

        [Parameter(Mandatory=$false)]
        [int]$ErrorCount = $Error.Count
    )
    
    begin
    {
    }
    process
    {
        Invoke-NonQuery `
            -DatabaseConnectionInformation $DatabaseConnectionInformation `
            -Query "EXEC proc_StopSyncJobExecution @Name = @Name, @ErrorCount = @ErrorCount" `
            -Parameters @{ Name = $Name; ErrorCount = $ErrorCount }
    }
    end
    {
    }
}

