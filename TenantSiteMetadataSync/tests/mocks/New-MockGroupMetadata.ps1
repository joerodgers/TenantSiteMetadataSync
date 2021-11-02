. $PSScriptRoot\New-MockValue.ps1

function New-MockGroupMetadata
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
        $mocks += @{ 
            GroupId                       = [PSCustomObject] @{ Type = [Guid];               Value = New-MockValue -TypeName Guid                   }
            DisplayName                   = [PSCustomObject] @{ Type = [string];             Value = New-MockValue -TypeName String   -IncludeNulls }
            IsDeleted                     = [PSCustomObject] @{ Type = [bool];               Value = New-MockValue -TypeName Boolean  -IncludeNulls }
            LastActivityDate              = [PSCustomObject] @{ Type = [Nullable[DateTime]]; Value = New-MockValue -TypeName DateTime -IncludeNulls }
            IsPublic                      = [PSCustomObject] @{ Type = [bool];               Value = New-MockValue -TypeName Boolean  -IncludeNulls }
            MemberCount                   = [PSCustomObject] @{ Type = [int];                Value = New-MockValue -TypeName Int32    -IncludeNulls }
            ExternalMemberCount           = [PSCustomObject] @{ Type = [int];                Value = New-MockValue -TypeName Int32    -IncludeNulls }
            ExchangeReceivedEmailCount    = [PSCustomObject] @{ Type = [int];                Value = New-MockValue -TypeName Int32    -IncludeNulls }
            SharePointActiveFileCount     = [PSCustomObject] @{ Type = [int];                Value = New-MockValue -TypeName Int32    -IncludeNulls }
            SharePointTotalFileCount      = [PSCustomObject] @{ Type = [int];                Value = New-MockValue -TypeName Int32    -IncludeNulls }
            YammerPostedMessageCount      = [PSCustomObject] @{ Type = [int];                Value = New-MockValue -TypeName Int32    -IncludeNulls }
            YammerReadMessageCount        = [PSCustomObject] @{ Type = [int];                Value = New-MockValue -TypeName Int32    -IncludeNulls }
            YammerLikedMessageCount       = [PSCustomObject] @{ Type = [int];                Value = New-MockValue -TypeName Int32    -IncludeNulls }
            ExchangeMailboxTotalItemCount = [PSCustomObject] @{ Type = [int];                Value = New-MockValue -TypeName Int32    -IncludeNulls } 
            ExchangeMailboxStorageUsed    = [PSCustomObject] @{ Type = [int];                Value = New-MockValue -TypeName Int64    -IncludeNulls }
        }
    }

    ,$mocks    
}