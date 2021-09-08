function Update-GroupMetadata
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [string]$DatabaseName,
        
        [Parameter(Mandatory=$true)]
        [string]$DatabaseServer,

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
        [int]$ExchangeMailboxStorageUsed
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
            if( $PSBoundParameter.Key -eq "DatabaseName" -or $PSBoundParameter.Key -eq "DatabaseServer" )
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

                Invoke-NonQuery -DatabaseName $DatabaseName -DatabaseServer $DatabaseServer -Query $query -Parameters $parameters
            }
            catch
            {
                Write-PSFMessage -Level Error -Message "Error executing update query '$($query)'" -Exception $_
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

