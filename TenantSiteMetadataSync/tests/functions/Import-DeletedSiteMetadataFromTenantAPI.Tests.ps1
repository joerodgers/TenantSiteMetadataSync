Describe "TenantSiteMetadataSync functional tests" {

    BeforeDiscovery {
        Remove-Module -Name "TenantSiteMetadataSync" -Force -ErrorAction Ignore
        Import-Module -Name "$PSScriptRoot\..\..\TenantSiteMetadataSync.psd1" -Force
    }

    Context "Import-DeletedSiteMetadataFromTenantAPI function" {

        InModuleScope -ModuleName "TenantSiteMetadataSync" {

            BeforeAll {

                function Connect-PnPOnline
                {
                    param($Url, $ClientId, $Thumbprint, $Tenant, $ReturnConnection) 
                }
                function Disconnect-PnPOnline 
                {
                    param($Connection) 
                }
                function Write-PSFMessage
                {
                    param($Level, $Message, $Exception) 
                }

                Mock -CommandName "Start-SyncJobExecution" -Verifiable
                Mock -CommandName "Stop-SyncJobExecution"  -Verifiable
                Mock -CommandName "Connect-PnPOnline"      -Verifiable -MockWith { return 1 }
                Mock -CommandName "Disconnect-PnPOnline"   -Verifiable
                Mock -CommandName "Write-PSFMessage"       

                function Get-PnPTenantDeletedSite
                {
                    param($Connection, $IncludePersonalSite, $Limit ) 
                }
            }


            It "should update the group's DisplayName value" {


                $mockDeletedSites = [PSCustomObject] @{ Url = "https://contoso.sharepoint.com/sites/foo"; SiteId = [Guid]::NewGuid() },
                                    [PSCustomObject] @{ Url = "https://contoso.sharepoint.com/sites/bar"; SiteId = [Guid]::NewGuid() } 

                Mock `
                    -CommandName "Get-PnPTenantDeletedSite" `
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
                Should -Invoke -CommandName "Update-SiteMetadata" -Exactly -Times 2
            }
        }
    }
}