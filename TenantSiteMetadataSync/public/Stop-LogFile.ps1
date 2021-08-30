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
        Set-PSFLoggingProvider -Name 'logfile' -Enabled $false
    }
    end
    {
    }
}
