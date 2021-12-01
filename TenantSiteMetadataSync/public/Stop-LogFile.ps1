function Stop-LogFile
{
<#
    .SYNOPSIS
    Silently stops any running PowerShell transcripts 

    .DESCRIPTION
    Silently stops any running PowerShell transcripts 

    .EXAMPLE
    PS C:\> Stop-LogFile
#>
    [CmdletBinding()]
    param
    (
    )

    begin
    {
    }
    process
    {
        Wait-PSFMessage -Timeout "30s" -Terminate # wait up to 30 seconds to termine the logging runspace

        Set-PSFLoggingProvider -Name 'logfile' -Enabled $false
    }
    end
    {
    }
}
