function Start-LogFile
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [string]$Path,

        [Parameter(Mandatory=$true)]
        [string]$Name
    )

    begin
    {
    }
    process
    {
        Stop-LogFile

        $timestamp = Get-Date -Format FileDateTime
        
        $transcriptPath = Join-Path -Path $Path -ChildPath "$($Name)_$($timestamp).log"

        Start-Transcript -Path $transcriptPath
    }
    end
    {
    }
}
