function New-MockValue
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateSet('Boolean', 'String', 'Int32', 'Int64', 'Guid', 'Bit', 'DateTime')]
        [string]$TypeName,

        [Parameter(Mandatory=$false)]
        [switch]$IncludeNulls,

        [Parameter(Mandatory=$false)]
        [switch]$AsString
        )

    switch( $TypeName )
    {
        'Boolean'
        {
            $options = @($true, $false)
        }
        'String'
        {
            $options = @(-join ( (65..90) + (97..122) | Get-Random -Count 50 | ForEach-Object { [char]$_ } ))
        }
        'Int32'
        {
            $options = @(Get-Random -Minimum 0 -Maximum ([int]::MaxValue))
        }
        'Int64'
        {
            $options = @(Get-Random -Minimum 0 -Maximum ([long]::MaxValue))
        }
        'Guid'
        {
            $options = @([Guid]::NewGuid())
        }
        'Bit'
        {
            $options = @(0, 1)
        }
        'DateTime'
        {
            $options = @(Get-Date)
        }
    }

    if( $IncludeNulls.IsPresent )
    {
        $options += $null
    }

    $value = $options | Get-Random

    if( $null -eq $value )
    {
        return $value
    }

    if( $AsString.IsPresent )
    {
        return $value.ToString()
    }

    return $value
}
