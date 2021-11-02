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
        [ScriptBlock]::Create( $String )
    }
}

