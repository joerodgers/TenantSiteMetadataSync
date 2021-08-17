function Stop-SyncJobExecution
{
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

