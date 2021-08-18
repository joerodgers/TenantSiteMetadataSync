function Start-LogFile
{
<#
	.SYNOPSIS
		Starts a new PowerShell transcript file in the specified path 

	.DESCRIPTION
		Starts a new PowerShell transcript file in the specified path. File name will include a timestamp to avoid name collisions. 

	.PARAMETER Path
		Directory path to create the log file in.
	
	.PARAMETER Path
		File name prefix.  Name will have a _<timestamp>.log suffix.

    .EXAMPLE
		PS C:\> Start-LogFile -Path "E:\Logs" -Name "Example"
#>
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
