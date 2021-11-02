. $PSScriptRoot\New-MockValue.ps1

function New-MockO365GroupCollection
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [int]$Quantity
    )

    $mocks = @()

    for( $x = 0; $x -lt $Quantity; $x++ )
    {
        $mocks += [PSCustomObject] @{ 
                    GroupId = New-MockValue -TypeName Guid
                  }
    }
 
    ,$mocks
}