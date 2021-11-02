. $PSScriptRoot\New-MockValue.ps1

function New-MockDeletedSiteCollection
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
        $mocks += 
            @{
                SiteId       = New-MockValue -TypeName Guid
                Url          = New-MockValue -TypeName String
                DeletionTime = New-MockValue -TypeName DateTime
            }
    }

    ,$mocks
}
