Describe "TenantSiteMetadataSync functional tests" {

    BeforeDiscovery {
        Import-Module -Name "$PSScriptRoot\..\..\TenantSiteMetadataSync.psd1" -Force
    }

    Context "Import-MicrosoftGraphUsageAccountReportData function" {

        InModuleScope -ModuleName "TenantSiteMetadataSync" {
        
            It "should update the group metadata" {
            
                $mockM365Group1 = [PSCustomObject] @{
                    'Group Id'                             = "a048c82c-fea8-4a8d-9b4b-e8e85237f742"
                    'Group Display Name'                   = "Mock Group 1"
                    'Is Deleted'                           = "FALSE"
                    'Group Type'                           = "Public"
                    'Member Count'                         = 100
                    'External Member Count'                = 101
                    'Exchange Received Email Count'        = 102
                    'SharePoint Active File Count'         = 103
                    'SharePoint Total File Count'          = 104
                    'SharePoint Site Storage Used (Byte)'  = 2GB
                    'Yammer Posted Message Count'          = 106
                    'Yammer Read Message Count'            = 107
                    'Yammer Liked Message Count'           = 108
                    'Exchange Mailbox Total Item Count'    = 109
                    'Exchange Mailbox Storage Used (Byte)' = 1GB
                    'Last Activity Date'                   = $null
                }

                $mockM365Group2 = [PSCustomObject] @{
                    'Group Id'                             = "d4bf6fd9-ebfa-4abe-a032-b6396e772a90"
                    'Group Display Name'                   = "Mock Group 2"
                    'Is Deleted'                           = "FALSE"
                    'Group Type'                           = "Private"
                    'Member Count'                         = 100
                    'External Member Count'                = 101
                    'Exchange Received Email Count'        = 102
                    'SharePoint Active File Count'         = 103
                    'SharePoint Total File Count'          = 104
                    'SharePoint Site Storage Used (Byte)'  = 2GB
                    'Yammer Posted Message Count'          = 106
                    'Yammer Read Message Count'            = 107
                    'Yammer Liked Message Count'           = 108
                    'Exchange Mailbox Total Item Count'    = 109
                    'Exchange Mailbox Storage Used (Byte)' = 1GB
                    'Last Activity Date'                   = [DateTime]::Today.ToString()
                }

                function Connect-PnPOnline {}
                function Disconnect-PnPOnline {}
                function Get-PnPGraphAccessToken {}

                Mock `
                    -CommandName "Start-SyncJobExecution" `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                Mock `
                    -CommandName "Stop-SyncJobExecution" `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                Mock `
                    -CommandName "Connect-PnPOnline" `
                    -MockWith { return 1 } `
                    -Verifiable

                Mock `
                    -CommandName "Disconnect-PnPOnline" `
                    -RemoveParameterType "Connection" `
                    -Verifiable

                Mock `
                    -CommandName "Get-PnPGraphAccessToken" `
                    -RemoveParameterType "Connection" `
                    -MockWith { return "mock_access_token" } `
                    -Verifiable

                Mock `
                    -CommandName "Invoke-RestMethod" `
                    -ParameterFilter { $Uri -eq "https://graph.microsoft.com/v1.0/reports/getOffice365GroupsActivityDetail(period='D30')" -and $Headers.Authorization -eq "Bearer mock_access_token" } `
                    -MockWith {  @($mockM365Group1, $mockM365Group2) | ConvertTo-Csv -UseQuotes AsNeeded | Out-String } `
                    -Verifiable    

                Mock `
                    -CommandName "Update-GroupMetadata" `
                    -ParameterFilter { $Parameters.GroupId                       -eq $mockM365Group1.'Group Id' -and 
                                       $Parameters.DisplayName                   -eq $mockM365Group1.'Group Display Name' -and 
                                       $Parameters.IsDeleted                     -eq ($mockM365Group1.'Is Deleted' -eq "TRUE") -and
                                       $Parameters.IsPublic                      -eq ($mockM365Group1.'Group Type' -eq "Public") -and
                                       $Parameters.MemberCount                   -eq $mockM365Group1.'Member Count' -and 
                                       $Parameters.ExternalMemberCount           -eq $mockM365Group1.'External Member Count' -and
                                       $Parameters.ExchangeReceivedEmailCount    -eq $mockM365Group1.'Exchange Received Email Count' -and
                                       $Parameters.SharePointActiveFileCount     -eq $mockM365Group1.'SharePoint Active File Count' -and
                                       $Parameters.SharePointTotalFileCount      -eq $mockM365Group1.'SharePoint Total File Count' -and
                                       $Parameters.YammerPostedMessageCount      -eq $mockM365Group1.'Yammer Posted Message Count' -and
                                       $Parameters.YammerReadMessageCount        -eq $mockM365Group1.'Yammer Read Message Count' -and
                                       $Parameters.YammerLikedMessageCount       -eq $mockM365Group1.'Yammer Liked Message Count' -and
                                       $Parameters.ExchangeMailboxTotalItemCount -eq $mockM365Group1.'Exchange Mailbox Total Item Count' -and
                                       $Parameters.ExchangeMailboxStorageUsed    -eq $mockM365Group1.'Exchange Mailbox Storage Used (Byte)' -and 
                                       -not $Parameters.ContainsKey("LastActivityDate") } `
                    -Verifiable    

                Mock `
                    -CommandName "Update-GroupMetadata" `
                    -ParameterFilter { $Parameters.GroupId                       -eq $mockM365Group2.'Group Id' -and 
                                       $Parameters.DisplayName                   -eq $mockM365Group2.'Group Display Name' -and 
                                       $Parameters.IsDeleted                     -eq ($mockM365Group2.'Is Deleted' -eq "TRUE") -and
                                       $Parameters.IsPublic                      -eq ($mockM365Group2.'Group Type' -eq "Public") -and
                                       $Parameters.MemberCount                   -eq $mockM365Group2.'Member Count' -and 
                                       $Parameters.ExternalMemberCount           -eq $mockM365Group2.'External Member Count' -and
                                       $Parameters.ExchangeReceivedEmailCount    -eq $mockM365Group2.'Exchange Received Email Count' -and
                                       $Parameters.SharePointActiveFileCount     -eq $mockM365Group2.'SharePoint Active File Count' -and
                                       $Parameters.SharePointTotalFileCount      -eq $mockM365Group2.'SharePoint Total File Count' -and
                                       $Parameters.YammerPostedMessageCount      -eq $mockM365Group2.'Yammer Posted Message Count' -and
                                       $Parameters.YammerReadMessageCount        -eq $mockM365Group2.'Yammer Read Message Count' -and
                                       $Parameters.YammerLikedMessageCount       -eq $mockM365Group2.'Yammer Liked Message Count' -and
                                       $Parameters.ExchangeMailboxTotalItemCount -eq $mockM365Group2.'Exchange Mailbox Total Item Count' -and
                                       $Parameters.ExchangeMailboxStorageUsed    -eq $mockM365Group2.'Exchange Mailbox Storage Used (Byte)' -and
                                       $Parameters.LastActivityDate              -eq $mockM365Group2.'Last Activity Date' } `
                    -Verifiable


                Import-MicrosoftGraphUsageAccountReportData `
                    -ReportType     "M365Group" `
                    -DatabaseName   "TenantSiteMetadataSync" `
                    -DatabaseServer "localhost/mssql" `
                    -ClientId       "00000000-0000-0000-0000-000000000000" `
                    -Thumbprint     "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" `
                    -Tenant         "contoso"

            }

            It "should update the site metadata using v1.0 report API" {
            
                $mockSite1 = [PSCustomObject] @{
                    'Site Url'                 = "https://contoso.sharepoint.com/sites/site1"
                    'File Count'               = "100"
                    'Storage Allocated (Byte)' = 2GB
                    'Storage Used (Byte)'      = 1GB
                    'Owner Display Name'       = "John Doe"
                    'Last Activity Date'       = [DateTime]::Today.ToString()
                    'Site Id'                  = [Guid]::NewGuid().ToString()
                    'Visited Page Count'       = 100
                    'Page View Count'          = 101
                }

                $mockSite2 = [PSCustomObject] @{
                    'Site Url'                 = "https://contoso.sharepoint.com/sites/site2"
                    'File Count'               = "101"
                    'Storage Allocated (Byte)' = 3GB
                    'Storage Used (Byte)'      = 2GB
                    'Owner Display Name'       = "Jane Doe"
                    'Last Activity Date'       = ""
                    'Site Id'                  = [Guid]::NewGuid().ToString()
                    'Visited Page Count'       = 101
                    'Page View Count'          = 102
                }

                function Connect-PnPOnline {}
                function Disconnect-PnPOnline {}
                function Get-PnPGraphAccessToken {}

                Mock `
                    -CommandName "Start-SyncJobExecution" `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                Mock `
                    -CommandName "Stop-SyncJobExecution" `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                Mock `
                    -CommandName "Connect-PnPOnline" `
                    -MockWith { return 1 } `
                    -Verifiable

                Mock `
                    -CommandName "Disconnect-PnPOnline" `
                    -RemoveParameterType "Connection" `
                    -Verifiable

                Mock `
                    -CommandName "Get-PnPGraphAccessToken" `
                    -RemoveParameterType "Connection" `
                    -MockWith { return "mock_access_token" } `
                    -Verifiable

                Mock `
                    -CommandName "Invoke-RestMethod" `
                    -ParameterFilter { $Uri -eq "https://graph.microsoft.com/v1.0/reports/getSharePointSiteUsageDetail(period='D30')" -and $Headers.Authorization -eq "Bearer mock_access_token" } `
                    -MockWith {  @($mockSite1, $mockSite2) | ConvertTo-Csv -UseQuotes AsNeeded | Out-String } `
                    -Verifiable    

                Mock `
                    -CommandName "Update-SiteMetadata" `
                    -ParameterFilter { $Parameters.SiteUrl        -eq $mockSite1.'Site Url' -and
                                       $Parameters.NumOfFiles     -eq $mockSite1.'File Count' -and   
                                       $Parameters.StorageQuota   -eq $mockSite1.'Storage Allocated (Byte)' -and   
                                       $Parameters.StorageUsed    -eq $mockSite1.'Storage Used (Byte)' -and   
                                       $Parameters.SiteOwnerName  -eq $mockSite1.'Owner Display Name' -and   
                                       $Parameters.LastActivityOn -eq $mockSite1.'Last Activity Date' -and   
                                       $Parameters.SiteId         -eq $mockSite1.'Site Id' -and   
                                       $Parameters.PagesVisited   -eq $mockSite1.'Visited Page Count' -and   
                                       $Parameters.PageViews      -eq $mockSite1.'Page View Count' } `
                    -Verifiable    

                Mock `
                    -CommandName "Update-SiteMetadata" `
                    -ParameterFilter { $Parameters.SiteUrl        -eq $mockSite2.'Site Url' -and
                                       $Parameters.NumOfFiles     -eq $mockSite2.'File Count' -and   
                                       $Parameters.StorageQuota   -eq $mockSite2.'Storage Allocated (Byte)' -and   
                                       $Parameters.StorageUsed    -eq $mockSite2.'Storage Used (Byte)' -and   
                                       $Parameters.SiteOwnerName  -eq $mockSite2.'Owner Display Name' -and   
                                       $Parameters.SiteId         -eq $mockSite2.'Site Id' -and   
                                       $Parameters.PagesVisited   -eq $mockSite2.'Visited Page Count' -and   
                                       $Parameters.PageViews      -eq $mockSite2.'Page View Count' -and 
                                       -not $Parameters.ContainsKey("LastActivityOn") } `
                    -Verifiable    


                Import-MicrosoftGraphUsageAccountReportData `
                    -ReportType     "SharePoint" `
                    -DatabaseName   "TenantSiteMetadataSync" `
                    -DatabaseServer "localhost/mssql" `
                    -ClientId       "00000000-0000-0000-0000-000000000000" `
                    -Thumbprint     "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" `
                    -Tenant         "contoso"

                Should -InvokeVerifiable
            }

            It "should update the onedrive metadata using v1.0 report API" {
            
                $mockSite1 = [PSCustomObject] @{
                    'Site Url'                 = "https://contoso-my.sharepoint.com/personal/johndoe_contoso_com"
                    'File Count'               = "100"
                    'Storage Allocated (Byte)' = 2GB
                    'Storage Used (Byte)'      = 1GB
                    'Owner Display Name'       = "John Doe"
                    'Last Activity Date'       = [DateTime]::Today.ToString()
                    'Site Id'                  = [Guid]::NewGuid().ToString()
                    'Visited Page Count'       = 100
                    'Page View Count'          = 101
                }

                $mockSite2 = [PSCustomObject] @{
                    'Site Url'                 = "https://contoso-my.sharepoint.com/personal/janedoe_contoso_com"
                    'File Count'               = "101"
                    'Storage Allocated (Byte)' = 3GB
                    'Storage Used (Byte)'      = 2GB
                    'Owner Display Name'       = "Jane Doe"
                    'Last Activity Date'       = ""
                    'Site Id'                  = [Guid]::NewGuid().ToString()
                    'Visited Page Count'       = 101
                    'Page View Count'          = 102
                }

                function Connect-PnPOnline {}
                function Disconnect-PnPOnline {}
                function Get-PnPGraphAccessToken {}

                Mock `
                    -CommandName "Start-SyncJobExecution" `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                Mock `
                    -CommandName "Stop-SyncJobExecution" `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                Mock `
                    -CommandName "Connect-PnPOnline" `
                    -MockWith { return 1 } `
                    -Verifiable

                Mock `
                    -CommandName "Disconnect-PnPOnline" `
                    -RemoveParameterType "Connection" `
                    -Verifiable

                Mock `
                    -CommandName "Get-PnPGraphAccessToken" `
                    -RemoveParameterType "Connection" `
                    -MockWith { return "mock_access_token" } `
                    -Verifiable

                Mock `
                    -CommandName "Invoke-RestMethod" `
                    -ParameterFilter { $Uri -eq "https://graph.microsoft.com/v1.0/reports/getOneDriveUsageAccountDetail(period='D30')" -and $Headers.Authorization -eq "Bearer mock_access_token" } `
                    -MockWith {  @($mockSite1, $mockSite2) | ConvertTo-Csv -UseQuotes AsNeeded | Out-String } `
                    -Verifiable    

                Mock `
                    -CommandName "Update-SiteMetadata" `
                    -ParameterFilter { $Parameters.SiteUrl        -eq $mockSite1.'Site Url' -and
                                       $Parameters.NumOfFiles     -eq $mockSite1.'File Count' -and   
                                       $Parameters.StorageQuota   -eq $mockSite1.'Storage Allocated (Byte)' -and   
                                       $Parameters.StorageUsed    -eq $mockSite1.'Storage Used (Byte)' -and   
                                       $Parameters.SiteOwnerName  -eq $mockSite1.'Owner Display Name' } `
                    -Verifiable    

                Mock `
                    -CommandName "Update-SiteMetadata" `
                    -ParameterFilter { $Parameters.SiteUrl        -eq $mockSite2.'Site Url' -and
                                       $Parameters.NumOfFiles     -eq $mockSite2.'File Count' -and   
                                       $Parameters.StorageQuota   -eq $mockSite2.'Storage Allocated (Byte)' -and   
                                       $Parameters.StorageUsed    -eq $mockSite2.'Storage Used (Byte)' -and   
                                       $Parameters.SiteOwnerName  -eq $mockSite2.'Owner Display Name' } `
                    -Verifiable    


                Import-MicrosoftGraphUsageAccountReportData `
                    -ReportType     "OneDrive" `
                    -DatabaseName   "TenantSiteMetadataSync" `
                    -DatabaseServer "localhost/mssql" `
                    -ClientId       "00000000-0000-0000-0000-000000000000" `
                    -Thumbprint     "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" `
                    -Tenant         "contoso"

                Should -InvokeVerifiable
            }

            It "should update the site metadata using beta report API" {
            
                $mockSite1 = [PSCustomObject] @{
                    'Site Url'                     = "https://contoso.sharepoint.com/sites/site1"
                    'File Count'                   = "100"
                    'Storage Allocated (Byte)'     = 2GB
                    'Storage Used (Byte)'          = 1GB
                    'Owner Display Name'           = "John Doe"
                    'Last Activity Date'           = [DateTime]::Today.ToString()
                    'Site Id'                      = [Guid]::NewGuid().ToString()
                    'Visited Page Count'           = 100
                    'Page View Count'              = 101
                    'Site Sensitivity Label Id'    = ""
                    'Company Link Count'           = 102
                    'Anonymous Link Count'         = 103
                    'Secure Link For Guest Count'  = 104
                    'Secure Link For Member Count' = 105
                }

                $mockSite2 = [PSCustomObject] @{
                    'Site Url'                     = "https://contoso.sharepoint.com/sites/site2"
                    'File Count'                   = "100"
                    'Storage Allocated (Byte)'     = 2GB
                    'Storage Used (Byte)'          = 1GB
                    'Owner Display Name'           = "John Doe"
                    'Last Activity Date'           = [DateTime]::Today.ToString()
                    'Site Id'                      = [Guid]::NewGuid().ToString()
                    'Visited Page Count'           = 100
                    'Page View Count'              = 101
                    'Site Sensitivity Label Id'    = [Guid]::NewGuid().ToString()
                    'Company Link Count'           = 102
                    'Anonymous Link Count'         = 103
                    'Secure Link For Guest Count'  = 104
                    'Secure Link For Member Count' = 105
                }

                function Connect-PnPOnline {}
                function Disconnect-PnPOnline {}
                function Get-PnPGraphAccessToken {}
                
                Mock `
                    -CommandName "Start-SyncJobExecution" `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                Mock `
                    -CommandName "Stop-SyncJobExecution" `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                Mock `
                    -CommandName "Connect-PnPOnline" `
                    -MockWith { return 1 } `
                    -Verifiable

                Mock `
                    -CommandName "Disconnect-PnPOnline" `
                    -RemoveParameterType "Connection" `
                    -Verifiable

                Mock `
                    -CommandName "Get-PnPGraphAccessToken" `
                    -RemoveParameterType "Connection" `
                    -MockWith { return "mock_access_token" } `
                    -Verifiable

                Mock `
                    -CommandName "Invoke-RestMethod" `
                    -ParameterFilter { $Uri -eq "https://graph.microsoft.com/beta/reports/getSharePointSiteUsageDetail(period='D30')" -and $Headers.Authorization -eq "Bearer mock_access_token" } `
                    -MockWith {  @($mockSite1, $mockSite2) | ConvertTo-Csv -UseQuotes AsNeeded | Out-String } `
                    -Verifiable    

                Mock `
                    -CommandName "Update-SiteMetadata" `
                    -ParameterFilter { $Parameters.SiteUrl            -eq $mockSite1.'Site Url' -and
                                       $Parameters.NumOfFiles         -eq $mockSite1.'File Count' -and   
                                       $Parameters.StorageQuota       -eq $mockSite1.'Storage Allocated (Byte)' -and   
                                       $Parameters.StorageUsed        -eq $mockSite1.'Storage Used (Byte)' -and   
                                       $Parameters.SiteOwnerName      -eq $mockSite1.'Owner Display Name' -and   
                                       $Parameters.LastActivityOn     -eq $mockSite1.'Last Activity Date' -and   
                                       $Parameters.SiteId             -eq $mockSite1.'Site Id' -and   
                                       $Parameters.PagesVisited       -eq $mockSite1.'Visited Page Count' -and   
                                       $Parameters.PageViews          -eq $mockSite1.'Page View Count' -and
                                       $Parameters.CompanyLinkCount   -eq $mockSite1.'Company Link Count' -and
                                       $Parameters.AnonymousLinkCount -eq $mockSite1.'Anonymous Link Count' -and
                                       $Parameters.GuestLinkCount     -eq $mockSite1.'Secure Link For Guest Count' -and
                                       $Parameters.MemberLinkCount    -eq $mockSite1.'Secure Link For Member Count' } `
                    -Verifiable    

                Mock `
                    -CommandName "Update-SiteMetadata" `
                    -ParameterFilter { $Parameters.SiteUrl            -eq $mockSite2.'Site Url' -and
                                       $Parameters.NumOfFiles         -eq $mockSite2.'File Count' -and   
                                       $Parameters.StorageQuota       -eq $mockSite2.'Storage Allocated (Byte)' -and   
                                       $Parameters.StorageUsed        -eq $mockSite2.'Storage Used (Byte)' -and   
                                       $Parameters.SiteOwnerName      -eq $mockSite2.'Owner Display Name' -and   
                                       $Parameters.LastActivityOn     -eq $mockSite2.'Last Activity Date' -and   
                                       $Parameters.SiteId             -eq $mockSite2.'Site Id' -and   
                                       $Parameters.PagesVisited       -eq $mockSite2.'Visited Page Count' -and   
                                       $Parameters.PageViews          -eq $mockSite2.'Page View Count' -and
                                       $Parameters.CompanyLinkCount   -eq $mockSite2.'Company Link Count' -and
                                       $Parameters.AnonymousLinkCount -eq $mockSite2.'Anonymous Link Count' -and
                                       $Parameters.GuestLinkCount     -eq $mockSite2.'Secure Link For Guest Count' -and
                                       $Parameters.MemberLinkCount    -eq $mockSite2.'Secure Link For Member Count' -and
                                       $Parameters.SensitivityLabel   -eq $mockSite2.'Site Sensitivity Label Id' } `
                    -Verifiable    


                Import-MicrosoftGraphUsageAccountReportData `
                    -ReportType     "SharePoint" `
                    -ApiVersion     "beta" `
                    -DatabaseName   "TenantSiteMetadataSync" `
                    -DatabaseServer "localhost/mssql" `
                    -ClientId       "00000000-0000-0000-0000-000000000000" `
                    -Thumbprint     "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" `
                    -Tenant         "contoso"

                Should -InvokeVerifiable
            }

            $periodTests =  @{ Period = 7   },
                            @{ Period = 30  },
                            @{ Period = 90  },
                            @{ Period = 180 }

            It "should request report for <period> days" -TestCases $periodTests {

                $mockSite1 = [PSCustomObject] @{
                    'Site Url'                 = "https://contoso-my.sharepoint.com/personal/johndoe_contoso_com"
                    'File Count'               = "100"
                    'Storage Allocated (Byte)' = 2GB
                    'Storage Used (Byte)'      = 1GB
                    'Owner Display Name'       = "John Doe"
                    'Last Activity Date'       = [DateTime]::Today.ToString()
                    'Site Id'                  = [Guid]::NewGuid().ToString()
                    'Visited Page Count'       = 100
                    'Page View Count'          = 101
                }

                $mockSite2 = [PSCustomObject] @{
                    'Site Url'                 = "https://contoso-my.sharepoint.com/personal/janedoe_contoso_com"
                    'File Count'               = "101"
                    'Storage Allocated (Byte)' = 3GB
                    'Storage Used (Byte)'      = 2GB
                    'Owner Display Name'       = "Jane Doe"
                    'Last Activity Date'       = ""
                    'Site Id'                  = [Guid]::NewGuid().ToString()
                    'Visited Page Count'       = 101
                    'Page View Count'          = 102
                }

                function Connect-PnPOnline {}
                function Disconnect-PnPOnline {}
                function Get-PnPGraphAccessToken {}

                
                Mock `
                    -CommandName "Start-SyncJobExecution" `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                Mock `
                    -CommandName "Stop-SyncJobExecution" `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                Mock `
                    -CommandName "Connect-PnPOnline" `
                    -MockWith { return 1 } `
                    -Verifiable

                Mock `
                    -CommandName "Disconnect-PnPOnline" `
                    -RemoveParameterType "Connection" `
                    -Verifiable

                Mock `
                    -CommandName "Get-PnPGraphAccessToken" `
                    -RemoveParameterType "Connection" `
                    -MockWith { return "mock_access_token" } `
                    -Verifiable

                Mock `
                    -CommandName "Invoke-RestMethod" `
                    -ParameterFilter { $Uri -eq "https://graph.microsoft.com/v1.0/reports/getSharePointSiteUsageDetail(period='D$Period')" -and $Headers.Authorization -eq "Bearer mock_access_token" } `
                    -MockWith {  @($mockSite1, $mockSite2) | ConvertTo-Csv -UseQuotes AsNeeded | Out-String } `
                    -Verifiable    

                Mock `
                    -CommandName "Update-SiteMetadata" `
                    -Verifiable    


                Import-MicrosoftGraphUsageAccountReportData `
                    -ReportType     "SharePoint" `
                    -Period         $Period `
                    -ApiVersion     "v1.0" `
                    -DatabaseName   "TenantSiteMetadataSync" `
                    -DatabaseServer "localhost/mssql" `
                    -ClientId       "00000000-0000-0000-0000-000000000000" `
                    -Thumbprint     "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" `
                    -Tenant         "contoso"

                Should -InvokeVerifiable
            }

            $apiTests =  @{ApiVersion = "v1.0"},
                         @{ApiVersion = "beta"}

            It "should request report from <ApiVersion> endpoint" -TestCases $apiTests {
            
                $mockSite1 = [PSCustomObject] @{
                    'Site Url'                 = "https://contoso-my.sharepoint.com/personal/johndoe_contoso_com"
                    'File Count'               = "100"
                    'Storage Allocated (Byte)' = 2GB
                    'Storage Used (Byte)'      = 1GB
                    'Owner Display Name'       = "John Doe"
                    'Last Activity Date'       = [DateTime]::Today.ToString()
                    'Site Id'                  = [Guid]::NewGuid().ToString()
                    'Visited Page Count'       = 100
                    'Page View Count'          = 101
                }

                $mockSite2 = [PSCustomObject] @{
                    'Site Url'                 = "https://contoso-my.sharepoint.com/personal/janedoe_contoso_com"
                    'File Count'               = "101"
                    'Storage Allocated (Byte)' = 3GB
                    'Storage Used (Byte)'      = 2GB
                    'Owner Display Name'       = "Jane Doe"
                    'Last Activity Date'       = ""
                    'Site Id'                  = [Guid]::NewGuid().ToString()
                    'Visited Page Count'       = 101
                    'Page View Count'          = 102
                }

                function Connect-PnPOnline {}
                function Disconnect-PnPOnline {}
                function Get-PnPGraphAccessToken {}


                Mock `
                    -CommandName "Start-SyncJobExecution" `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                Mock `
                    -CommandName "Stop-SyncJobExecution" `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                Mock `
                    -CommandName "Connect-PnPOnline" `
                    -MockWith { return 1 } `
                    -Verifiable

                Mock `
                    -CommandName "Disconnect-PnPOnline" `
                    -RemoveParameterType "Connection" `
                    -Verifiable

                Mock `
                    -CommandName "Get-PnPGraphAccessToken" `
                    -RemoveParameterType "Connection" `
                    -MockWith { return "mock_access_token" } `
                    -Verifiable

                Mock `
                    -CommandName "Invoke-RestMethod" `
                    -ParameterFilter { $Uri -eq "https://graph.microsoft.com/$ApiVersion/reports/getSharePointSiteUsageDetail(period='D30')" -and $Headers.Authorization -eq "Bearer mock_access_token" } `
                    -MockWith {  @($mockSite1, $mockSite2) | ConvertTo-Csv -UseQuotes AsNeeded | Out-String } `
                    -Verifiable    

                Mock `
                    -CommandName "Update-SiteMetadata" `
                    -Verifiable    


                Import-MicrosoftGraphUsageAccountReportData `
                    -ReportType     "SharePoint" `
                    -ApiVersion     $ApiVersion `
                    -DatabaseName   "TenantSiteMetadataSync" `
                    -DatabaseServer "localhost/mssql" `
                    -ClientId       "00000000-0000-0000-0000-000000000000" `
                    -Thumbprint     "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" `
                    -Tenant         "contoso"

                Should -InvokeVerifiable
            }

            It "should remove BOM from report data"{
            
                $mockSite1 = [PSCustomObject] @{
                    'Site Url'                 = "https://contoso.sharepoint.com/sites/site1"
                    'File Count'               = "100"
                    'Storage Allocated (Byte)' = 2GB
                    'Storage Used (Byte)'      = 1GB
                    'Owner Display Name'       = "John Doe"
                    'Last Activity Date'       = [DateTime]::Today.ToString()
                    'Site Id'                  = [Guid]::NewGuid().ToString()
                    'Visited Page Count'       = 100
                    'Page View Count'          = 101
                }

                $mockSite2 = [PSCustomObject] @{
                    'Site Url'                 = "https://contoso.sharepoint.com/sites/site2"
                    'File Count'               = "101"
                    'Storage Allocated (Byte)' = 3GB
                    'Storage Used (Byte)'      = 2GB
                    'Owner Display Name'       = "Jane Doe"
                    'Last Activity Date'       = ""
                    'Site Id'                  = [Guid]::NewGuid().ToString()
                    'Visited Page Count'       = 101
                    'Page View Count'          = 102
                }

                $csvWithoutBOM = @($mockSite1, $mockSite2) | ConvertTo-Csv -UseQuotes AsNeeded | Out-String

                $csvWithBOM = [char]0xEF + [char]0xBB + [char]0xBF + $csvWithoutBOM

                $csvWithBOM.Length | Should -BeExactly ($csvWithoutBOM.Length + 3)

                function Connect-PnPOnline {}
                function Disconnect-PnPOnline {}
                function Get-PnPGraphAccessToken {}

                Mock `
                    -CommandName "Start-SyncJobExecution" `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                Mock `
                    -CommandName "Stop-SyncJobExecution" `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                Mock `
                    -CommandName "Connect-PnPOnline" `
                    -MockWith { return 1 } `
                    -Verifiable

                Mock `
                    -CommandName "Disconnect-PnPOnline" `
                    -RemoveParameterType "Connection" `
                    -Verifiable

                Mock `
                    -CommandName "Get-PnPGraphAccessToken" `
                    -RemoveParameterType "Connection" `
                    -MockWith { return "mock_access_token" } `
                    -Verifiable

                Mock `
                    -CommandName "Invoke-RestMethod" `
                    -ParameterFilter { $Uri -eq "https://graph.microsoft.com/v1.0/reports/getSharePointSiteUsageDetail(period='D30')" -and $Headers.Authorization -eq "Bearer mock_access_token" } `
                    -MockWith {  $csvWithBOM } `
                    -Verifiable    

                Mock `
                    -CommandName "Update-SiteMetadata" `
                    -Verifiable

                Import-MicrosoftGraphUsageAccountReportData `
                    -ReportType     "SharePoint" `
                    -DatabaseName   "TenantSiteMetadataSync" `
                    -DatabaseServer "localhost/mssql" `
                    -ClientId       "00000000-0000-0000-0000-000000000000" `
                    -Thumbprint     "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" `
                    -Tenant         "contoso"

                Should -InvokeVerifiable
            }
        }
    }
}