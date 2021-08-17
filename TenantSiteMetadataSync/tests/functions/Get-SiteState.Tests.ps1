Describe "TenantSiteMetadataSync functional tests" {

    BeforeAll {
        Import-Module -Name "$PSScriptRoot\..\..\TenantSiteMetadataSync.psd1" -Force
    }

    Context "Get-SiteState function" {

        InModuleScope -ModuleName "TenantSiteMetadataSync" {

            It "should return array of site states" {
                Get-SiteState | Should -BeOfType [System.Object[]]
            }

            It "should return Unknown" {
                (Get-SiteState -StateId -1).State | Should -BeExactly "Unknown"
            }

            It "should return Creating" {
                (Get-SiteState -StateId 0).State | Should -BeExactly "Creating"
            }

            It "should throw" {
                { Get-SiteState -StateId 100 } | Should -Throw
            }

            It "should throw" {
                { Get-SiteState -StateId -100 } | Should -Throw
            }
        }
    }
}