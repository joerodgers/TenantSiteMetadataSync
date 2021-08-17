function Start-SyncJobExecution
{
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

