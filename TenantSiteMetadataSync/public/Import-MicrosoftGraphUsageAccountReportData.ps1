function Import-MicrosoftGraphUsageAccountReportData
{
<#
	.SYNOPSIS
		Imports details about Microsoft 365 groups, SharePoint Sites or OneDrive sites into the SQL database.

        Azure Active Directory Application Principal requires Graph > Application > Reports.Read.All permissions.
	
	.DESCRIPTION
		Imports details about Microsoft 365 groups, SharePoint Sites or OneDrive sites into the SQL database.

        Azure Active Directory Application Principal requires Graph > Application > Reports.Read.All permissions.
	
            - SharePoint report details: https://docs.microsoft.com/en-us/graph/api/reportroot-getsharepointsiteusagedetail?view=graph-rest-1.0

            - OneDrive report details: https://docs.microsoft.com/en-us/graph/api/reportroot-getonedriveusageaccountdetail?view=graph-rest-1.0

            - M365Group report details: https://docs.microsoft.com/en-us/graph/api/reportroot-getoffice365groupsactivitydetail?view=graph-rest-1.0

	.PARAMETER ReportType
		The type of report (SharePoint, OneDrive or M365Group) to download and import.  

	.PARAMETER Period
		The data aggregration period for the report. Valid options are 7, 30, 90, or 180 days.  Default value is 30 days.

    .PARAMETER ClientId
		Azure Active Directory Application Principal Client/Application Id
	
	.PARAMETER Thumbprint
		Thumbprint of certificate associated with the Azure Active Directory Application Principal
	
	.PARAMETER Tenant
		Name of the O365 Tenant
	
	.PARAMETER DatabaseName
		The SQL Server database name
	
	.PARAMETER DatabaseServer
		Name of the SQL Server database server, including the instance name (if applicable).
	
	.EXAMPLE
		PS C:\> Import-MicrosoftGraphUsageAccountReportData -ReportType SharePoint -Period 30 -ClientId <clientId> -Thumbprint <thumbprint> -Tenant <tenant> -DatabaseName <database name> -DatabaseServer <database server>

	.EXAMPLE
		PS C:\> Import-MicrosoftGraphUsageAccountReportData -ReportType OneDrive -Period 90 -ClientId <clientId> -Thumbprint <thumbprint> -Tenant <tenant> -DatabaseName <database name> -DatabaseServer <database server>

    .EXAMPLE
		PS C:\> Import-MicrosoftGraphUsageAccountReportData -ReportType M365Group -Period 180 -ClientId <clientId> -Thumbprint <thumbprint> -Tenant <tenant> -DatabaseName <database name> -DatabaseServer <database server>
#>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateSet('SharePoint', 'OneDrive', 'M365Group')]
        [string]$ReportType,

        [Parameter(Mandatory=$false)]
        [ValidateSet(7, 30, 90, 180)]
        [int]$Period = 30,

        [Parameter(Mandatory=$false)]
        [ValidateSet("v1.0", "beta")]
        [string]$ApiVersion = "v1.0",

        [Parameter(Mandatory=$true)]
        [string]$ClientId,

        [Parameter(Mandatory=$true)]
        [string]$Thumbprint,

        [Parameter(Mandatory=$true)]
        [string]$Tenant,

        [Parameter(Mandatory=$true)]
        [string]$DatabaseName,
        
        [Parameter(Mandatory=$true)]
        [string]$DatabaseServer
    )

    begin
    {
        $Error.Clear()

        Start-SyncJobExecution -Name $PSCmdlet.MyInvocation.InvocationName -DatabaseName $DatabaseName -DatabaseServer $DatabaseServer

        if( $ReportType -eq 'SharePoint' )
        {
            $uri = "https://graph.microsoft.com/$ApiVersion/reports/getSharePointSiteUsageDetail(period='D$Period')"
        }
        elseif( $ReportType -eq 'OneDrive' )
        {
            $uri = "https://graph.microsoft.com/$ApiVersion/reports/getOneDriveUsageAccountDetail(period='D$Period')"
        }
        else
        {
            $uri = "https://graph.microsoft.com/$ApiVersion/reports/getOffice365GroupsActivityDetail(period='D$Period')"
        }
    }
    process
    {
        if( $connection = Connect-PnPOnline -Url "https://$Tenant-admin.sharepoint.com" -ClientId $ClientId -Thumbprint $Thumbprint -Tenant "$Tenant.onmicrosoft.com" -ReturnConnection $true )
        {
            if( $accessToken = Get-PnPGraphAccessToken -Connection $connection )
            {
                $response = Invoke-RestMethod -Method Get -Uri $uri -Headers @{ Authorization = "Bearer $accessToken" } -MaximumRedirection 10 

                # strip off OM if present
                $response = $response -replace "^\xEF\xBB\xBF", ""
        
                if( $response )
                {
                    $rows = ConvertFrom-Csv -InputObject $response -Delimiter ","

                    foreach( $row in $rows )
                    {
                        try
                        {
                            $parameters = @{}
                            $parameters.DatabaseName   = $DatabaseName
                            $parameters.DatabaseServer = $DatabaseServer

                            if( $ReportType -eq 'M365Group' ) 
                            {
                                <#  Columns in v1.0 and beta report:

                                    Report Refresh Date
                                    Group Display Name
                                    Is Deleted
                                    Owner Principal Name
                                    Last Activity Date
                                    Group Type
                                    Member Count
                                    External Member Count
                                    Exchange Received Email Count
                                    SharePoint Active File Count
                                    Yammer Posted Message Count
                                    Yammer Read Message Count
                                    Yammer Liked Message Count
                                    Exchange Mailbox Total Item Count
                                    Exchange Mailbox Storage Used (Byte)
                                    SharePoint Total File Count
                                    SharePoint Site Storage Used (Byte)
                                    Group Id
                                    Report Period
                                #>

                                # these fields are present in reports and report versions
                                $parameters.GroupId                       = $row.'Group Id'
                                $parameters.DisplayName                   = $row.'Group Display Name'
                                $parameters.IsDeleted                     = $row.'Is Deleted' -eq "TRUE"
                                $parameters.IsPublic                      = $row.'Group Type' -eq "Public"
                                $parameters.MemberCount                   = $row.'Member Count'
                                $parameters.ExternalMemberCount           = $row.'External Member Count'
                                $parameters.ExchangeReceivedEmailCount    = $row.'Exchange Received Email Count'
                                $parameters.SharePointActiveFileCount     = $row.'SharePoint Active File Count'
                                $parameters.SharePointTotalFileCount      = $row.'SharePoint Total File Count'
                                # $parameters.SharePointSiteStorageUsed     = $row.'SharePoint Site Storage Used (Byte)'
                                $parameters.YammerPostedMessageCount      = $row.'Yammer Posted Message Count'
                                $parameters.YammerReadMessageCount        = $row.'Yammer Read Message Count'
                                $parameters.YammerLikedMessageCount       = $row.'Yammer Liked Message Count'
                                $parameters.ExchangeMailboxTotalItemCount = $row.'Exchange Mailbox Total Item Count'
                                $parameters.ExchangeMailboxStorageUsed    = $row.'Exchange Mailbox Storage Used (Byte)'

                                if( -not [string]::IsNullOrWhiteSpace($row.'Last Activity Date') )
                                {
                                    $parameters.LastActivityDate = $row.'Last Activity Date'
                                }

                                Update-GroupMetadata @parameters
                            }
                            else
                            {

                                # these fields are present in reports and report versions
                                $parameters.SiteUrl        = $row.'Site URL'
                                $parameters.NumOfFiles     = $row.'File Count'
                                $parameters.StorageQuota   = $row.'Storage Allocated (Byte)'
                                $parameters.StorageUsed    = $row.'Storage Used (Byte)'
                                $parameters.SiteOwnerName  = $row.'Owner Display Name'

                                if( -not [string]::IsNullOrWhiteSpace($row.'Last Activity Date') )
                                {
                                    $parameters.LastActivityOn = $row.'Last Activity Date'
                                }

                                if( $ReportType -eq 'SharePoint' )
                                {
                                    <#  Columns in v1.0 report:

                                            - Report Refresh Date
                                            - Site Id
                                            - Site URL
                                            - Owner Display Name
                                            - Is Deleted
                                            - Last Activity Date
                                            - File Count
                                            - Active File Count
                                            - Page View Count
                                            - Visited Page Count
                                            - Storage Used (Byte)
                                            - Storage Allocated (Byte)
                                            - Root Web Template
                                            - Owner Principal Name
                                            - Report Period

                                    #>

                                    $parameters.SiteId       = $row.'Site Id'
                                    $parameters.PagesVisited = $row.'Visited Page Count'
                                    $parameters.PageViews    = $row.'Page View Count'

                                    if( $ApiVersion -eq 'beta' )
                                    {
                                        <# Additional columns in beta report: 

                                            - Site Sensitivity Label Id
                                            - External Sharing
                                            - Unmanaged Device Policy
                                            - Geo Location,
                                            - Anonymous Link Count
                                            - Company Link Count
                                            - Secure Link For Guest Count
                                            - Secure Link For Member Count, 
                                        #>

                                        if( -not [string]::IsNullOrWhiteSpace($row.'Site Sensitivity Label Id') )
                                        {
                                            $parameters.SensitivityLabel = $row.'Site Sensitivity Label Id'
                                        }

                                        $parameters.CompanyLinkCount   = $row.'Company Link Count'
                                        $parameters.AnonymousLinkCount = $row.'Anonymous Link Count'
                                        $parameters.GuestLinkCount     = $row.'Secure Link For Guest Count'
                                        $parameters.MemberLinkCount    = $row.'Secure Link For Member Count'
                                    }
                                }
                                else # onedrive
                                {
                                    <#  Columns in v1.0 report:
                                    
                                            - Report Refresh Date
                                            - Site URL
                                            - Owner Display Name
                                            - Is Deleted
                                            - Last Activity Date
                                            - File Count
                                            - Active File Count
                                            - Storage Used (Byte)
                                            - Storage Allocated (Byte)
                                            - Owner Principal Name
                                            - Report Period
                                    #>

                                    if( $ApiVersion -eq 'beta' )
                                    {
                                        # no differences in columns between v1.0 and beta (yet)
                                    }
                                }

                                Update-SiteMetadata @parameters
                            }
                        }
                        catch
                        {
                            Write-Error "$($PSCmdlet.MyInvocation.MyCommand) - Error updating account usage detail.  Error: $_"
                        }            
                    }
                }
            }
            
            Disconnect-PnPOnline -Connection $connection
        }
    }
    end
    {
        Stop-SyncJobExecution -Name $PSCmdlet.MyInvocation.InvocationName -ErrorCount $Error.Count -DatabaseName $DatabaseName -DatabaseServer $DatabaseServer
    }
}

