. $PSScriptRoot\New-MockValue.ps1

function New-MockO365GroupOwnerCollection
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
                    AdditionalProperties = [PSCustomObject] @{ 
                                               userPrincipalName = New-MockValue -TypeName String
                                           } 
                  }
    }
 
    ,$mocks
}
