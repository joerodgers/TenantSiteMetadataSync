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
                SiteId       = [Guid]::NewGuid()
                Url          = "https://mock.sharepoint.com/sites/site$x"
                DeletionTime = [DateTime]::Now.AddDays($x * -1)
            }
    }

    return $mocks
}
