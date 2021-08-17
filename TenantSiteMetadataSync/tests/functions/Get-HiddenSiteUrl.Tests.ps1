Describe "TenantSiteMetadataSync functional tests" {

    BeforeAll {
        Import-Module -Name "$PSScriptRoot\..\..\TenantSiteMetadataSync.psd1" -Force
    }

    Context "Get-HiddenSiteUrl function" {

        InModuleScope -ModuleName "TenantSiteMetadataSync" {

            It "should return array of tenant urls" {
                Get-HiddenSiteUrl -Tenant "contoso" | Should -Be @( "https://contoso.sharepoint.com/sites/contentTypeHub", "https://contoso.sharepoint.com/sites/CompliancePolicyCenter", "https://contoso-admin.sharepoint.com" )
            }
        }
    }
}