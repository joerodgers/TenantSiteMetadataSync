function Get-FileEncoding 
{
    <#
        .SYNOPSIS
        Tests a file for encoding.

        .DESCRIPTION
        Tests a file for encoding.

        .PARAMETER Path
        The file to test
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [string]
        $Path
    )

    begin
    {
        $reader = $null
    }
    process
    {
        if( -not (Test-Path -LiteralPath $Path -PathType Leaf)) 
        {
            $ex = New-Object System.Management.Automation.ItemNotFoundException( "Cannot find path '$Path' because it does not exist." )
            $category = [System.Management.Automation.ErrorCategory]::ObjectNotFound
            $errRecord = New-Object System.Management.Automation.ErrorRecord( $ex, 'PathNotFound', $category, $Path)
            $psCmdlet.WriteError($errRecord)
            return
        }

        try
        {
            $reader = New-Object System.IO.StreamReader( $Path, [System.Text.Encoding]::Default, $true)

            $null = $reader.Peek()
            
            return $reader.CurrentEncoding.EncodingName
        }
        finally
        {
            if( $null -ne $reader )
            {
                $reader.Close()
                $reader.Dispose()
            }
        }
    }
    end
    {
    }
}
