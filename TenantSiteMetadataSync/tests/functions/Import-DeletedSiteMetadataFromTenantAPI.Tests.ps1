Describe "TenantSiteMetadataSync functional tests" {

    BeforeDiscovery {
        Import-Module -Name "$PSScriptRoot\..\..\TenantSiteMetadataSync.psd1" -Force
    }

    Context "Import-DeletedSiteMetadataFromTenantAPI function" {

        InModuleScope -ModuleName "TenantSiteMetadataSync" {

            It "should update the group's DisplayName value" {

                $mockDeletedSites = [PSCustomObject] @{ Url = "https://contoso.sharepoint.com/sites/foo"; SiteId = [Guid]::NewGuid() },
                                    [PSCustomObject] @{ Url = "https://contoso.sharepoint.com/sites/bar"; SiteId = [Guid]::NewGuid() } 

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
                    -CommandName "Get-PnPTenantRecycleBinItem" `
                    -RemoveParameterType "Connection" `
                    -MockWith { $mockDeletedSites } `
                    -Verifiable

                Mock `
                    -CommandName "Update-SiteMetadata" `
                    -Verifiable    
                    

                Import-DeletedSiteMetadataFromTenantAPI `
                    -DatabaseName   "TenantSiteMetadataSync" `
                    -DatabaseServer "localhost/mssql" `
                    -ClientId       "00000000-0000-0000-0000-000000000000" `
                    -Thumbprint     "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" `
                    -Tenant         "contoso"
            
                Should -InvokeVerifiable
                Should -Invoke -CommandName "Update-SiteMetadata" -Exactly -Times 3
            }
        }
    }
}