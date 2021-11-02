. $PSScriptRoot\New-MockValue.ps1


function New-MockDatabaseSchemaFile
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
        $mocks +=   [PSCustomObject] @{
                        FullName = Join-Path -Path $PSScriptRoot -ChildPath (New-MockValue -TypeName String)
                    }
    }

    ,$mocks
}

