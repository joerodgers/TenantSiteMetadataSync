. $PSScriptRoot\New-MockValue.ps1

function New-MockUsageAccountReportData
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [int]$Quantity,

        [Parameter(Mandatory=$true)]
        [ValidateSet('SharePoint', 'OneDrive', 'M365Group')]
        [string]$ReportType,

        [Parameter(Mandatory=$true)]
        [ValidateSet('v1.0', 'beta')]
        [string]$ApiVersion
    )

    $mocks = @()

    for( $x = 0; $x -lt $Quantity; $x++ )
    {
        if( $ReportType -eq "M365Group" )
        {
            $mocks += [PSCustomObject] @{
                        'Group Id'                             = New-MockValue -TypeName Guid -AsString
                        'Group Display Name'                   = New-MockValue -TypeName String
                        'Is Deleted'                           = New-MockValue -TypeName Boolean -AsString
                        'Group Type'                           = "Public", "Private" | Get-Random
                        'Member Count'                         = New-MockValue -TypeName Int32
                        'External Member Count'                = New-MockValue -TypeName Int32
                        'Exchange Received Email Count'        = New-MockValue -TypeName Int32
                        'SharePoint Active File Count'         = New-MockValue -TypeName Int32
                        'SharePoint Total File Count'          = New-MockValue -TypeName Int32
                        'SharePoint Site Storage Used (Byte)'  = New-MockValue -TypeName Int64
                        'Yammer Posted Message Count'          = New-MockValue -TypeName Int32
                        'Yammer Read Message Count'            = New-MockValue -TypeName Int32
                        'Yammer Liked Message Count'           = New-MockValue -TypeName Int32
                        'Exchange Mailbox Total Item Count'    = New-MockValue -TypeName Int32
                        'Exchange Mailbox Storage Used (Byte)' = New-MockValue -TypeName Int64
                        'Last Activity Date'                   = New-MockValue -TypeName DateTime -IncludeNulls
                    }
        }
        elseif( $ReportType -eq "SharePoint" )
        {
            $mock = [PSCustomObject] @{
                'Site URL'                 = New-MockValue -TypeName String
                'File Count'               = New-MockValue -TypeName Int32
                'Storage Allocated (Byte)' = New-MockValue -TypeName Int32
                'Storage Used (Byte)'      = New-MockValue -TypeName Int32
                'Owner Display Name'       = New-MockValue -TypeName String
                'Last Activity Date'       = New-MockValue -TypeName DateTime -IncludeNulls -AsString
                'Site Id'                  = New-MockValue -TypeName Guid -AsString
                'Visited Page Count'       = New-MockValue -TypeName Int32
                'Page View Count'          = New-MockValue -TypeName Int32
            }

            if( $ApiVersion -eq "beta" )
            {
                $mock | Add-Member -MemberType NoteProperty -Name 'Site Sensitivity Label Id'    -Value New-MockValue -TypeName DateTime -IncludeNulls -AsString
                $mock | Add-Member -MemberType NoteProperty -Name 'Company Link Count'           -Value New-MockValue -TypeName Int32
                $mock | Add-Member -MemberType NoteProperty -Name 'Anonymous Link Count'         -Value New-MockValue -TypeName Int32
                $mock | Add-Member -MemberType NoteProperty -Name 'Secure Link For Guest Count'  -Value New-MockValue -TypeName Int32
                $mock | Add-Member -MemberType NoteProperty -Name 'Secure Link For Member Count' -Value New-MockValue -TypeName Int32
            }

            $mocks += $mock
        }
        elseif( $ReportType -eq "OneDrive" ) 
        {
            $mocks += [PSCustomObject] @{
                'Site URL'                 = New-MockValue -TypeName String
                'File Count'               = New-MockValue -TypeName Int32
                'Storage Allocated (Byte)' = New-MockValue -TypeName Int32
                'Storage Used (Byte)'      = New-MockValue -TypeName Int32
                'Owner Display Name'       = New-MockValue -TypeName String
                'Last Activity Date'       = New-MockValue -TypeName DateTime -IncludeNull -AsString
            }
        }
    }

    ,$mocks
}