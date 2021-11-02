Set-StrictMode -Off

Describe "Testing Get-HiddenSiteUrl cmdlet" -Tag "UnitTest" {

    BeforeAll {
        Remove-Module -Name "TenantSiteMetadataSync" -Force -ErrorAction Ignore
        Import-Module -Name "$PSScriptRoot\..\..\TenantSiteMetadataSync.psd1" -Force
    }
    
    InModuleScope -ModuleName "TenantSiteMetadataSync" {

        It "should return <_.Results.Count> Urls for the tenant '<Tenant>'" -ForEach @(
            @{ Tenant = "contoso";  Results = @("https://contoso.sharepoint.com/sites/contentTypeHub",  "https://contoso.sharepoint.com/sites/CompliancePolicyCenter",  "https://contoso-admin.sharepoint.com")  },
            @{ Tenant = "tailspin"; Results = @("https://tailspin.sharepoint.com/sites/contentTypeHub", "https://tailspin.sharepoint.com/sites/CompliancePolicyCenter", "https://tailspin-admin.sharepoint.com") }
        ){
            Get-HiddenSiteUrl -Tenant $Tenant | Should -Be $Results
        }
    }
}
