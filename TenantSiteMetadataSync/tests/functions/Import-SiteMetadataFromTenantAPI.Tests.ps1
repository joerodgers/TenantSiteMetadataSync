Describe "TenantSiteMetadataSync functional tests" {

    BeforeDiscovery {
        Import-Module -Name "$PSScriptRoot\..\..\TenantSiteMetadataSync.psd1" -Force
    }

    Context "Import-SiteMetadataFromTenantAPI function" {

        InModuleScope -ModuleName "TenantSiteMetadataSync" {

            It "should read the basic SPO site info from the API" {
            
                $mockSite1 = [PSCustomObject] @{ 
                    DenyAddAndCustomizePages = "Disabled"
                    GroupId                  = [Guid]::Empty.ToString()
                    HubSiteId                = [Guid]::Empty.ToString()
                    LastContentModifiedDate  = [DateTime]::Today.ToString()
                    LockState                = "Unlock"
                    PWAEnabled               = $null
                    Url                      = "https://contoso.sharepoint.com/sites/site1"
                    Status                   = 1
                    StorageQuota             = 2TB
                    StorageUsageCurrent      = 1TB
                    Template                 = 'STS#3'
                    Title                    = "Classic Team Site"
                    SharingCapability        = "ExternalUserSharingOnly"
                }

                $mockSite2 = [PSCustomObject] @{ 
                    DenyAddAndCustomizePages = "Enabled"
                    GroupId                  = [Guid]::NewGuid().ToString()
                    HubSiteId                = [Guid]::NewGuid().ToString()
                    LastContentModifiedDate  = [DateTime]::Today.ToString()
                    LockState                = "Unlock"
                    PWAEnabled               = "Enabled"
                    Url                      = "https://contoso.sharepoint.com/sites/site2"
                    Status                   = 1
                    StorageQuota             = 2TB
                    StorageUsageCurrent      = 1TB
                    Template                 = 'GROUP#0'
                    Title                    = "Modern Team Site"
                    SharingCapability        = "ExternalUserSharingOnly"
                }

                $mockSites = @( $mockSite1, $mockSite2 )

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
                    -CommandName "Get-PnPTenantSite" `
                    -RemoveParameterType "Connection" `
                    -MockWith { $mockSites } `
                    -Verifiable

                Mock `
                    -CommandName "Update-SiteMetadata" `
                    -ParameterFilter { $DatabaseName             -eq "TenantSiteMetadataSync" -and 
                                       $DatabaseServer           -eq "localhost/mssql" -and 
                                       $DenyAddAndCustomizePages -eq $mockSite1.DenyAddAndCustomizePages -and 
                                       $GroupId                  -eq $mockSite1.GroupId -and 
                                       $HubSiteId                -eq $mockSite1.HubSiteId -and 
                                       $LastItemModifiedDate     -eq $mockSite1.LastContentModifiedDate -and 
                                       $LockState                -eq $mockSite1.LockState -and 
                                       $PWAEnabled               -eq ($null -ne $mockSite1.PWAEnabled -and $mockSite1.PWAEnabled.ToString() -eq "Enabled") -and 
                                       $SiteUrl                  -eq $mockSite1.Url -and 
                                       $State                    -eq 0 -and 
                                       $StorageQuota             -eq $mockSite1.StorageQuota * 1MB -and 
                                       $StorageUsed              -eq $mockSite1.StorageUsageCurrent * 1MB -and  
                                       $TemplateName             -eq $mockSite1.Template -and 
                                       $Title                    -eq $mockSite1.Title -and 
                                       $SharingCapability        -eq $mockSite1.SharingCapability
                                    } `
                    -Verifiable

                Mock `
                    -CommandName "Update-SiteMetadata" `
                    -ParameterFilter { $DatabaseName             -eq "TenantSiteMetadataSync" -and 
                                       $DatabaseServer           -eq "localhost/mssql" -and 
                                       $DenyAddAndCustomizePages -eq $mockSite2.DenyAddAndCustomizePages -and 
                                       $GroupId                  -eq $mockSite2.GroupId -and 
                                       $HubSiteId                -eq $mockSite2.HubSiteId -and 
                                       $LastItemModifiedDate     -eq $mockSite2.LastContentModifiedDate -and 
                                       $LockState                -eq $mockSite2.LockState -and 
                                       $PWAEnabled               -eq ($null -ne $mockSite2.PWAEnabled -and $mockSite2.PWAEnabled.ToString() -eq "Enabled") -and 
                                       $SiteUrl                  -eq $mockSite2.Url -and 
                                       $State                    -eq 0 -and 
                                       $StorageQuota             -eq $mockSite2.StorageQuota * 1MB -and 
                                       $StorageUsed              -eq $mockSite2.StorageUsageCurrent * 1MB -and 
                                       $TemplateName             -eq $mockSite2.Template -and 
                                       $Title                    -eq $mockSite2.Title -and 
                                       $SharingCapability        -eq $mockSite2.SharingCapability
                                    } `
                    -Verifiable

                    Import-SiteMetadataFromTenantAPI `
                    -DatabaseName   "TenantSiteMetadataSync" `
                    -DatabaseServer "localhost/mssql" `
                    -ClientId       "00000000-0000-0000-0000-000000000000" `
                    -Thumbprint     "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" `
                    -Tenant         "contoso"

                Should -InvokeVerifiable
            }

            It "should read the basic SPO and OD4B site info from the API" {
            
                $mockSite1 = [PSCustomObject] @{ 
                    DenyAddAndCustomizePages = "Disabled"
                    GroupId                  = [Guid]::Empty.ToString()
                    HubSiteId                = [Guid]::Empty.ToString()
                    LastContentModifiedDate  = [DateTime]::Today.ToString()
                    LockState                = "Unlock"
                    PWAEnabled               = $null
                    Url                      = "https://contoso.sharepoint.com/sites/site1"
                    Status                   = 1
                    StorageQuota             = 2TB
                    StorageUsageCurrent      = 1TB
                    Template                 = 'STS#3'
                    Title                    = "Classic Team Site"
                    SharingCapability        = "ExternalUserSharingOnly"
                }

                $mockSite2 = [PSCustomObject] @{ 
                    DenyAddAndCustomizePages = "Enabled"
                    GroupId                  = [Guid]::NewGuid().ToString()
                    HubSiteId                = [Guid]::NewGuid().ToString()
                    LastContentModifiedDate  = [DateTime]::Today.ToString()
                    LockState                = "Unlock"
                    PWAEnabled               = "Enabled"
                    Url                      = "https://contoso.sharepoint.com/sites/site2"
                    Status                   = 1
                    StorageQuota             = 2TB
                    StorageUsageCurrent      = 1TB
                    Template                 = 'GROUP#0'
                    Title                    = "Modern Team Site"
                    SharingCapability        = "ExternalUserSharingOnly"
                }

                $mockSites = @( $mockSite1, $mockSite2 )

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
                    -CommandName "Get-PnPTenantSite" `
                    -RemoveParameterType "Connection" `
                    -ParameterFilter { $IncludeOneDriveSites -eq $true } `
                    -MockWith { $mockSites } `
                    -Verifiable

                Mock `
                    -CommandName "Update-SiteMetadata" `
                    -Verifiable

                Import-SiteMetadataFromTenantAPI `
                    -IncludeOneDriveSites `
                    -DatabaseName         "TenantSiteMetadataSync" `
                    -DatabaseServer       "localhost/mssql" `
                    -ClientId             "00000000-0000-0000-0000-000000000000" `
                    -Thumbprint           "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" `
                    -Tenant               "contoso"

                Should -InvokeVerifiable
            }

            It "should read the basic SPO and OD4B site info from the API" {
            
                $mockSite1 = [PSCustomObject] @{ 
                    DenyAddAndCustomizePages = "Disabled"
                    GroupId                  = [Guid]::Empty.ToString()
                    HubSiteId                = [Guid]::Empty.ToString()
                    LastContentModifiedDate  = [DateTime]::Today.ToString()
                    LockState                = "Unlock"
                    PWAEnabled               = $null
                    Url                      = "https://contoso.sharepoint.com/sites/site1"
                    Status                   = 1
                    StorageQuota             = 2TB
                    StorageUsageCurrent      = 1TB
                    Template                 = 'STS#3'
                    Title                    = "Classic Team Site"
                    SharingCapability        = "ExternalUserSharingOnly"
                }

                $mockSite2 = [PSCustomObject] @{ 
                    DenyAddAndCustomizePages = "Enabled"
                    GroupId                  = [Guid]::NewGuid().ToString()
                    HubSiteId                = [Guid]::NewGuid().ToString()
                    LastContentModifiedDate  = [DateTime]::Today.ToString()
                    LockState                = "Unlock"
                    PWAEnabled               = "Enabled"
                    Url                      = "https://contoso.sharepoint.com/sites/site2"
                    Status                   = 1
                    StorageQuota             = 2TB
                    StorageUsageCurrent      = 1TB
                    Template                 = 'GROUP#0'
                    Title                    = "Modern Team Site"
                    SharingCapability        = "ExternalUserSharingOnly"
                }

                $mockSites = @( $mockSite1, $mockSite2 )

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
                    -CommandName "Get-PnPTenantSite" `
                    -RemoveParameterType "Connection" `
                    -ParameterFilter { $Template -eq "APPCATALOG#0" } `
                    -MockWith { $mockSites } `
                    -Verifiable

                Mock `
                    -CommandName "Update-SiteMetadata" `
                    -Verifiable

                Import-SiteMetadataFromTenantAPI `
                    -Template       "APPCATALOG#0" `
                    -DatabaseName   "TenantSiteMetadataSync" `
                    -DatabaseServer "localhost/mssql" `
                    -ClientId       "00000000-0000-0000-0000-000000000000" `
                    -Thumbprint     "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" `
                    -Tenant         "contoso"

                Should -InvokeVerifiable
            }

            It "should read the detailed SPO site info from the API" {
            
                function Get-PnPSite {}
                function Get-PnPWeb {}

                $mockSites = [PSCustomObject] @{ 
                    DenyAddAndCustomizePages = "Disabled"
                    GroupId                  = [Guid]::Empty.ToString()
                    HubSiteId                = [Guid]::Empty.ToString()
                    LastContentModifiedDate  = [DateTime]::Today.ToString()
                    LockState                = "Unlock"
                    PWAEnabled               = $null
                    Url                      = "https://contoso.sharepoint.com/sites/site1"
                    Status                   = 1
                    StorageQuota             = 2TB
                    StorageUsageCurrent      = 1TB
                    Template                 = 'STS#3'
                    Title                    = "Classic Team Site"
                    SharingCapability        = "ExternalUserSharingOnly"
                }

                $mockSiteDetail = [PSCustomObject] @{
                    ConditionalAccessPolicy = 0 
                    SensitivityLabel        = [Guid]::NewGuid()
                    Id                      = [Guid]::NewGuid()
                    Owner                   = [PSCustomObject]@{ Email = "john.doe@contoso.com"; Title = "John Doe" }
                    RelatedGroupId          = [Guid]::NewGuid()
                }

                $mockWebDetail = [PSCustomObject] @{
                    Created = [DateTime]::Today                
                }

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
                    -ParameterFilter { $Url -eq "https://contoso-admin.sharepoint.com" } `
                    -MockWith { return 1 } `
                    -Verifiable

                Mock `
                    -CommandName "Connect-PnPOnline" `
                    -ParameterFilter { $Url -eq "https://contoso.sharepoint.com/sites/site1" } `
                    -MockWith { return 1 } `
                    -Verifiable

                Mock `
                    -CommandName "Get-PnPSite" `
                    -MockWith { $mockSiteDetail } `
                    -Verifiable
                
                Mock `
                    -CommandName "Get-PnPWeb" `
                    -MockWith { $mockWebDetail } `
                    -Verifiable

                Mock `
                    -CommandName "Disconnect-PnPOnline" `
                    -RemoveParameterType "Connection" `
                    -Verifiable

                Mock `
                    -CommandName "Get-PnPTenantSite" `
                    -RemoveParameterType "Connection" `
                    -MockWith { $mockSites } `
                    -Verifiable

                Mock `
                    -CommandName "Update-SiteMetadata" `
                    -ParameterFilter { $SensitivityLabel -eq $mockSiteDetail.SensitivityLabel -and 
                                       $SiteId           -eq $mockSiteDetail.Id -and 
                                       $SiteOwnerEmail   -eq $mockSiteDetail.Owner.Email -and 
                                       $SiteOwnerName    -eq $mockSiteDetail.Owner.Title -and 
                                       $RelatedGroupId   -eq $mockSiteDetail.RelatedGroupId } `
                    -Verifiable

                Import-SiteMetadataFromTenantAPI `
                    -DetailedImport `
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