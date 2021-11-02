. $PSScriptRoot\New-MockValue.ps1

function New-MockAggregatedSiteCollectionListData
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateSet( 'AggregatedSiteCollections', 'AllSitesAggregatedSiteCollections' )]
        [string]$AdminList,

        [Parameter(Mandatory=$true)]
        [int]$ListItemCount
    )

    $mocks = @()

    for( $x=0; $x -lt $ListItemCount; $x++ )
    {
        if( $AdminList -eq "AggregatedSiteCollections" )
        {
            $mocks += [PSCustomObject] @{
                Id = New-MockValue -TypeName Int32
                FieldValues = @{ 
                        FileViewedOrEdited   = New-MockValue -TypeName Int32
                        Initiator            = New-MockValue -TypeName String
                        IsGroupConnected     = New-MockValue -TypeName Boolean
                        LastActivityOn       = New-MockValue -TypeName DateTime
                        LastItemModifiedDate = New-MockValue -TypeName DateTime
                        NumOfFiles           = New-MockValue -TypeName Int32
                        PagesVisited         = New-MockValue -TypeName Int32
                        PageViews            = New-MockValue -TypeName Int32
                        SiteCreationSource   = New-MockValue -TypeName Guid
                        SiteId               = New-MockValue -TypeName Guid
                        SiteUrl              = New-MockValue -TypeName String
                        StorageUsed          = New-MockValue -TypeName Int64
                        TimeDeleted          = $null
                        SiteFlags            = New-MockValue -TypeName Bit
                        State                = "", "1" | Get-Random
                        SensitivityLabel     = New-MockValue -TypeName Guid -IncludeNulls
                        GroupId              = New-MockValue -TypeName Guid -IncludeNulls
                        HubSiteId            = New-MockValue -TypeName Guid -IncludeNulls
                }
            }
        }
        elseif( $AdminList -eq "AllSitesAggregatedSiteCollections" )
        {
            $mocks += [PSCustomObject] @{
                Id = New-MockValue -TypeName Int64
                FieldValues = @{ 
                    ConditionalAccessPolicy = 0
                    CreatedBy               = New-MockValue -TypeName String
                    DeletedBy               = New-MockValue -TypeName String
                    SiteOwnerEmail          = New-MockValue -TypeName String
                    SiteOwnerName           = New-MockValue -TypeName String
                    StorageQuota            = New-MockValue -TypeName Int64
                    SiteId                  = New-MockValue -TypeName Guid
                    SiteUrl                 = New-MockValue -TypeName String
                    TemplateName            = "GROUP#0", "STS#0", "STS#3" | Get-Random 
                    TimeCreated             = New-MockValue -TypeName DateTime
                    Title                   = New-MockValue -TypeName String
                }
            }
        }
    }

    ,$mocks
}