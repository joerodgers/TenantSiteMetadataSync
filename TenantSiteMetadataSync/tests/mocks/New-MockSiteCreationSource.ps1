. $PSScriptRoot\New-MockValue.ps1

function New-MockSiteCreationSource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [int]$Quantity
    )

    $mocks = @()

    if( $Quantity -le 2 )
    {
        $Quantity = 0
    }

    for( $x = 0; $x -lt $Quantity; $x++ )
    {
        $mocks += [PSCustomObject] @{ 
                    Id          = New-MockValue -TypeName Guid
                    DisplayName = New-MockValue -TypeName String
                  }
    }

    # hardcoded value that will always be added to the database
    $mocks += [PSCustomObject] @{ 
        Id          = "14D82EEC-204B-4C2F-B7E8-296A70DAB67E"
        DisplayName = "Microsoft Graph"
    }

    # hardcoded value that will always be added to the database
    $mocks += [PSCustomObject] @{ 
        Id          = "5D9FFF84-5B34-4204-BC91-3AAF5F298C5D"
        DisplayName = "PnP Lookbook"
    }
  
    [PSCustomObject] @{
        value = $mocks
    }
}
