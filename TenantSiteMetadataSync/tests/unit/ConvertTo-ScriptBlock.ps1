function ConvertTo-ScriptBlock
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
        [string]$String
    )

    process
    {
        $scriptBlock = [ScriptBlock]::Create( $String )

        Write-Verbose "Script Block: '$($scriptBlock.ToString())'"
    
        $scriptBlock
    }
}

