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
        [string]$Name,

        [Parameter(Mandatory=$false)]
        [switch]$TrimExistingLogFiles,

        [Parameter(Mandatory=$false)]
        [ValidateRange(1,21)]
        [int]$RetentionDays = 7
    )

    begin
    {
    }
    process
    {
        Stop-LogFile

        $timestamp = Get-Date -Format FileDateTime
        
        $transcriptPath = Join-Path -Path $Path -ChildPath "$($Name)_$($timestamp).log"

        if( $TrimExistingLogFiles.IsPresent )
        {
            Get-ChildItem -Path $Path -Filter "$($Name)_*.log" | 
                Where-Object -Property Name -match "$($Name)_\d{8}T\d{10}.log" | 
                    Where-Object -Property LastWriteTime -le ([DateTime]::Today.AddDays($RetentionDays * -1)) | 
                        Remove-Item -Force -Confirm:$false
        }

        Write-Verbose "$(Get-Date) - $($PSCmdlet.MyInvocation.MyCommand) - Starting transcript log at $transcriptPath"

        $null = Start-Transcript -Path $transcriptPath
    }
    end
    {
    }
}
