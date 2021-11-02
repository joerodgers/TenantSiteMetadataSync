function Update-GroupMetadata
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [DatabaseConnectionInformation]
        $DatabaseConnectionInformation,

        [Parameter(Mandatory=$true)]
        [Guid]$GroupId,

        [Parameter(Mandatory=$false)]
        [string]$DisplayName,

        [Parameter(Mandatory=$false)]
        [bool]$IsDeleted,

        [Parameter(Mandatory=$false)]
        [Nullable[DateTime]]$LastActivityDate,

        [Parameter(Mandatory=$false)]
        [bool]$IsPublic,

        [Parameter(Mandatory=$false)]
        [ValidateRange("NonNegative")]
        [int]$MemberCount,

        [Parameter(Mandatory=$false)]
        [ValidateRange("NonNegative")]
        [int]$ExternalMemberCount,

        [Parameter(Mandatory=$false)]
        [ValidateRange("NonNegative")]
        [int]$ExchangeReceivedEmailCount,

        [Parameter(Mandatory=$false)]
        [ValidateRange("NonNegative")]
        [int]$SharePointActiveFileCount,

        [Parameter(Mandatory=$false)]
        [ValidateRange("NonNegative")]
        [int]$SharePointTotalFileCount,

        [Parameter(Mandatory=$false)]
        [ValidateRange("NonNegative")]
        [int]$YammerPostedMessageCount,

        [Parameter(Mandatory=$false)]
        [ValidateRange("NonNegative")]
        [int]$YammerReadMessageCount,

        [Parameter(Mandatory=$false)]
        [ValidateRange("NonNegative")]
        [int]$YammerLikedMessageCount,

        [Parameter(Mandatory=$false)]
        [ValidateRange("NonNegative")]
        [int]$ExchangeMailboxTotalItemCount,

        [Parameter(Mandatory=$false)]
        [ValidateRange("NonNegative")]
        [long]$ExchangeMailboxStorageUsed
    )

    begin
    {
        $sb = New-Object System.Text.StringBuilder("EXEC proc_AddOrUpdateGroupMetadata ")

        $parameters = @{}
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

        if( $parameters.Count -gt 1 )
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

