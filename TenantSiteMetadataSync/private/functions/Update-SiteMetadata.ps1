function Update-SiteMetadata
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [DatabaseConnectionInformation]
        $DatabaseConnectionInformation,

        [Parameter(Mandatory=$false)]
        [ValidateRange("NonNegative")]
        [int]$AnonymousLinkCount,
        
        [Parameter(Mandatory=$false)]
        [ValidateRange("NonNegative")]
        [int]$CompanyLinkCount,

        [Parameter(Mandatory=$false)]
        [ValidateRange(0,3)]
        [int]$ConditionalAccessPolicy,

        [Parameter(Mandatory=$false)]
        [string]$CreatedBy,

        [Parameter(Mandatory=$false)]
        [string]$DeletedBy,

        [Parameter(Mandatory=$false)]
        [string]$DenyAddAndCustomizePages,

        [Parameter(Mandatory=$false)]
        [ValidateRange("NonNegative")]
        [int]$FileViewedOrEdited,

        [Parameter(Mandatory=$false)]
        [Guid]$GroupId,

        [Parameter(Mandatory=$false)]
        [ValidateRange("NonNegative")]
        [int]$GuestLinkCount,

        [Parameter(Mandatory=$false)]
        [Guid]$HubSiteId,

        [Parameter(Mandatory=$false)]
        [string]$Initiator,

        [Parameter(Mandatory=$false)]
        [bool]$IsGroupConnected,

        [Parameter(Mandatory=$false)]
        [bool]$IsTeamsConnected,

        [Parameter(Mandatory=$false)]
        [Nullable[DateTime]]$LastActivityOn,

        [Parameter(Mandatory=$false)]
        [Nullable[DateTime]]$LastItemModifiedDate,

        [Parameter(Mandatory=$false)]
        [string]$LockState,

        [Parameter(Mandatory=$false)]
        [ValidateRange("NonNegative")]
        [int]$MemberLinkCount,

        [Parameter(Mandatory=$false)]
        [ValidateRange("NonNegative")]
        [int]$NumOfFiles,

        [Parameter(Mandatory=$false)]
        [ValidateRange("NonNegative")]
        [int]$PagesVisited,

        [Parameter(Mandatory=$false)]
        [ValidateRange("NonNegative")]
        [int]$PageViews,

        [Parameter(Mandatory=$false)]
        [bool]$PWAEnabled,

        [Parameter(Mandatory=$false)]
        [Guid]$RelatedGroupId,

        [Parameter(Mandatory=$false)]
        [Guid]$SensitivityLabel,

        [Parameter(Mandatory=$false)]
        [string]$SharingCapability,

        [Parameter(Mandatory=$false)]
        [Guid]$SiteCreationSource,

        [Parameter(Mandatory=$false)]
        [Guid]$SiteId,

        [Parameter(Mandatory=$false)]
        [string]$SiteOwnerEmail,

        [Parameter(Mandatory=$false)]
        [string]$SiteOwnerName,

        [Parameter(Mandatory=$true)]
        [string]$SiteUrl,

        [Parameter(Mandatory=$false)]
        [ValidateRange(-1,11)]
        [int]$State,

        [Parameter(Mandatory=$false)]
        [ValidateRange("NonNegative")]
        [long]$StorageQuota,

        [Parameter(Mandatory=$false)]
        [ValidateRange("NonNegative")]
        [long]$StorageUsed,

        [Parameter(Mandatory=$false)]
        [string]$TemplateName,

        [Parameter(Mandatory=$false)]
        [Nullable[DateTime]]$TimeCreated,

        [Parameter(Mandatory=$false)]
        [Nullable[DateTime]]$TimeDeleted,

        [Parameter(Mandatory=$false)]
        [string]$Title
    )

    begin
    {
        $sb = New-Object System.Text.StringBuilder("EXEC proc_AddOrUpdateSiteMetadata ")

        $parameters = @{}

        $PSBoundParameters["SiteUrl"] = $PSBoundParameters["SiteUrl"].ToString().TrimEnd('/')
    }
    process
    {
        foreach( $PSBoundParameter in $PSBoundParameters.GetEnumerator() )
        {
            if( $PSBoundParameter.Key -eq "DatabaseConnectionInformation" )
            {
                continue
            }

            if( $null -ne $PSBoundParameter.Value )
            {
                $null = $sb.AppendFormat( " @{0} = @{0},", $PSBoundParameter.Key )

                $parameters[$PSBoundParameter.Key] = $PSBoundParameter.Value
            }
        }

        if ( $parameters.Count -gt 1 )
        {
            try
            {
                $query = $sb.ToString().TrimEnd(",") # trim trailing comma

                Write-PSFMessage -Level Debug -Message "Executing: '$query'"

                Invoke-NonQuery -DatabaseConnectionInformation $DatabaseConnectionInformation -Query $query -Parameters $parameters
            }
            catch
            {
                Write-PSFMessage -Level Error -Message "Error executing update query '$($query)'" -Exception $_.Exception
            }
        }
        else 
        {
            Write-PSFMessage -Level Verbose -Message "No property updates required"
        }
    }
    end
    {
    }
}


