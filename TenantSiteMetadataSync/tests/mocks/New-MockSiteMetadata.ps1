. $PSScriptRoot\New-MockValue.ps1

function New-MockSiteMetadata
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
            AnonymousLinkCount       = [PSCustomObject] @{ Type = [int32];              Value = New-MockValue -TypeName Int32    -IncludeNulls }
            CompanyLinkCount         = [PSCustomObject] @{ Type = [int32];              Value = New-MockValue -TypeName Int32    -IncludeNulls }
            FileViewedOrEdited       = [PSCustomObject] @{ Type = [int32];              Value = New-MockValue -TypeName Int32    -IncludeNulls }
            MemberLinkCount          = [PSCustomObject] @{ Type = [int32];              Value = New-MockValue -TypeName Int32    -IncludeNulls }
            NumOfFiles               = [PSCustomObject] @{ Type = [int32];              Value = New-MockValue -TypeName Int32    -IncludeNulls }
            PagesVisited             = [PSCustomObject] @{ Type = [int32];              Value = New-MockValue -TypeName Int32    -IncludeNulls }
            PageViews                = [PSCustomObject] @{ Type = [int32];              Value = New-MockValue -TypeName Int32    -IncludeNulls }
            GuestLinkCount           = [PSCustomObject] @{ Type = [int32];              Value = New-MockValue -TypeName Int32    -IncludeNulls }
            State                    = [PSCustomObject] @{ Type = [int32];              Value = (-1..11 | Get-Random)                          } 
            ConditionalAccessPolicy  = [PSCustomObject] @{ Type = [int32];              Value = (0, 1, 2 , 3 | Get-Random)                     }
            StorageQuota             = [PSCustomObject] @{ Type = [int64];              Value = New-MockValue -TypeName Int64    -IncludeNulls }
            StorageUsed              = [PSCustomObject] @{ Type = [int64];              Value = New-MockValue -TypeName Int64    -IncludeNulls }
            IsGroupConnected         = [PSCustomObject] @{ Type = [bool];               Value = New-MockValue -TypeName Boolean  -IncludeNulls }
            IsTeamsConnected         = [PSCustomObject] @{ Type = [bool];               Value = New-MockValue -TypeName Boolean  -IncludeNulls }
            PWAEnabled               = [PSCustomObject] @{ Type = [bool];               Value = New-MockValue -TypeName Boolean  -IncludeNulls }
            HubSiteId                = [PSCustomObject] @{ Type = [Guid];               Value = New-MockValue -TypeName Guid     -IncludeNulls }
            RelatedGroupId           = [PSCustomObject] @{ Type = [Guid];               Value = New-MockValue -TypeName Guid     -IncludeNulls }
            SensitivityLabel         = [PSCustomObject] @{ Type = [Guid];               Value = New-MockValue -TypeName Guid     -IncludeNulls }
            SiteCreationSource       = [PSCustomObject] @{ Type = [Guid];               Value = New-MockValue -TypeName Guid     -IncludeNulls }
            SiteId                   = [PSCustomObject] @{ Type = [Guid];               Value = New-MockValue -TypeName Guid     -IncludeNulls }
            GroupId                  = [PSCustomObject] @{ Type = [Guid];               Value = New-MockValue -TypeName Guid     -IncludeNulls }  
            LockState                = [PSCustomObject] @{ Type = [string];             Value = New-MockValue -TypeName String   -IncludeNulls }
            Initiator                = [PSCustomObject] @{ Type = [string];             Value = New-MockValue -TypeName String   -IncludeNulls }
            CreatedBy                = [PSCustomObject] @{ Type = [string];             Value = New-MockValue -TypeName String   -IncludeNulls }
            DenyAddAndCustomizePages = [PSCustomObject] @{ Type = [string];             Value = New-MockValue -TypeName String   -IncludeNulls }
            SharingCapability        = [PSCustomObject] @{ Type = [string];             Value = New-MockValue -TypeName String   -IncludeNulls }
            SiteOwnerEmail           = [PSCustomObject] @{ Type = [string];             Value = New-MockValue -TypeName String   -IncludeNulls }
            SiteOwnerName            = [PSCustomObject] @{ Type = [string];             Value = New-MockValue -TypeName String   -IncludeNulls }
            SiteUrl                  = [PSCustomObject] @{ Type = [string];             Value = New-MockValue -TypeName String                 }
            Title                    = [PSCustomObject] @{ Type = [string];             Value = New-MockValue -TypeName String   -IncludeNulls }
            TemplateName             = [PSCustomObject] @{ Type = [string];             Value = New-MockValue -TypeName String   -IncludeNulls }
            TimeCreated              = [PSCustomObject] @{ Type = [Nullable[DateTime]]; Value = New-MockValue -TypeName DateTime -IncludeNulls }
            TimeDeleted              = [PSCustomObject] @{ Type = [Nullable[DateTime]]; Value = New-MockValue -TypeName DateTime -IncludeNulls }
            LastActivityOn           = [PSCustomObject] @{ Type = [Nullable[DateTime]]; Value = New-MockValue -TypeName DateTime -IncludeNulls }
            LastItemModifiedDate     = [PSCustomObject] @{ Type = [Nullable[DateTime]]; Value = New-MockValue -TypeName DateTime -IncludeNulls }
        }
    }

    ,$mocks    
}