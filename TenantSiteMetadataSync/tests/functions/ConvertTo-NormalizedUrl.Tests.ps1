Describe "TenantSiteMetadataSync functional tests" {

    BeforeDiscovery {
        Remove-Module -Name "TenantSiteMetadataSync" -Force -ErrorAction Ignore
        Import-Module -Name "$PSScriptRoot\..\..\TenantSiteMetadataSync.psd1" -Force
    }

    Context "ConvertTo-NormalizedUrl function" {

        InModuleScope -ModuleName "TenantSiteMetadataSync" {

            It "should return a normalized url from an already normalized url using parameter" {
                ConvertTo-NormalizedUrl -Url "https://contoso.sharepoint.com/sites/teamsite" | Should -BeExactly "https://contoso.sharepoint.com/sites/teamsite"
            }

            It "should remove any trailing slashes from the provided URL using parameter" {
                ConvertTo-NormalizedUrl -Url "https://contoso.sharepoint.com/sites/teamsite/" | Should -BeExactly "https://contoso.sharepoint.com/sites/teamsite"
            }

            It "should normalize the provided the encoded URL using parameter" {
                ConvertTo-NormalizedUrl -Url "https://contoso.sharepoint.com/sites/team%20site/" | Should -BeExactly "https://contoso.sharepoint.com/sites/team site"
            }

            It "should return a normalized url from an already normalized url using pipeline" {
                "https://contoso.sharepoint.com/sites/teamsite" | ConvertTo-NormalizedUrl | Should -BeExactly "https://contoso.sharepoint.com/sites/teamsite"
            }

            It "should remove any trailing slashes from the provided URL using pipeline" {
                "https://contoso.sharepoint.com/sites/teamsite/" | ConvertTo-NormalizedUrl | Should -BeExactly "https://contoso.sharepoint.com/sites/teamsite"
            }

            It "should normalize the provided the encoded URL using pipeline" {
                "https://contoso.sharepoint.com/sites/team%20site/" | ConvertTo-NormalizedUrl | Should -BeExactly "https://contoso.sharepoint.com/sites/team site"
            }
        }
    }
}
