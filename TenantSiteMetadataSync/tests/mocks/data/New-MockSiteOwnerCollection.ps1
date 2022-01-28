function New-MockSiteOwnerCollection
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
        $mocks += [PSCustomObject] @{ value = [PSCustomObject] @{ UserPrincipalName = "johndoe$x@contoso.com" } }
    }
 
    ,$mocks
}