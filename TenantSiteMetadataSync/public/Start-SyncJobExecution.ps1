function Start-SyncJobExecution
{
<#
    .SYNOPSIS
    Adds an entry into the SyncJob table with the provided name and current start time.

    .DESCRIPTION
    Adds an entry into the SyncJob table with the provided name and current start time.  You will use the same job name to mark the job exection with a completion time in the SyncJob table.

    .PARAMETER Name
    Name of the operation

    .PARAMETER DatabaseConnectionInformation
    Database Connection Information

    .EXAMPLE
    PS C:\> Start-SyncJobExecution -Name <job name> -DatabaseConnectionInformation <database connection information>
#>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [string]$Name,

        [Parameter(Mandatory=$true)]
        [DatabaseConnectionInformation]
        $DatabaseConnectionInformation
    )
    
    begin
    {
    }
    process
    {
        Invoke-NonQuery `
            -DatabaseConnectionInformation $DatabaseConnectionInformation `
            -Query "EXEC proc_StartSyncJobExecution @Name = @Name" `
            -Parameters @{ Name = $Name }

        $Global:Error.Clear()
    }
    end
    {
    }
}

