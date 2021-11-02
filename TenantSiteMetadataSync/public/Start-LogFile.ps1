function Start-LogFile
{
<#
    .SYNOPSIS
    Starts a new PowerShell transcript file in the specified path 

    .DESCRIPTION
    Starts a new PowerShell transcript file in the specified path. File name will include a timestamp to avoid name collisions. 

    .PARAMETER Path
    Directory path to create the log file in.

    .PARAMETER Name
    File name prefix.  Name will have a _<timestamp>.log suffix.

    .PARAMETER MessageLevel
    Logging level.  Default level is Verbose.

    .PARAMETER RetentionDays
    Days to retain logs.  Default is 7 days.

    .EXAMPLE
    PS C:\> Start-LogFile -Path "E:\Logs" -Name "Example"

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
        [PSFramework.Message.MessageLevel]$MessageLevel = [PSFramework.Message.MessageLevel]::Verbose,

        [Parameter(Mandatory=$false)]
        [ValidateRange(1,21)]
        [int]$RetentionDays = 7
    )

    begin
    {
        # info on message log level
        # https://github.com/PowershellFrameworkCollective/psframework/blob/e92578234204a61f81802959e622cfc9a9540cb5/library/PSFramework/Message/MessageLevel.cs

        # headers in desired order
        $headers = 'Timestamp', 'ComputerName', 'Username', 'File', 'FunctionName', 'Level', 'Line', 'Message', 'ModuleName'

        # file timestamp
        $timestamp = Get-Date -Format FileDateTime
        
        # full path to to log file
        $transcriptPath = Join-Path -Path $Path -ChildPath "$($Name)_$($timestamp).csv"
    }
    process
    {
        <#
            1-3 Direct verbose output to the user (using Write-Host)
            4-6 Output only visible when requesting extra verbosity (using Write-Verbose)
            1-9 Debugging information, written using Write-Debug
        #>

        Set-PSFLoggingProvider `
            -Name             'logfile' `
            -Enabled          $true `
            -FilePath         $transcriptPath `
            -Headers          $headers `
            -LogRetentionTime $RetentionDays `
            -MinLevel         ([int][PSFramework.Message.MessageLevel]::Critical) `
            -MaxLevel         ([int]$MessageLevel)

        Write-PSFMessage -Level Verbose -Message "Started new log file"
    }
    end
    {
    }
}
