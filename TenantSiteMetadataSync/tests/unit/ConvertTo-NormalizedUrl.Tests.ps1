Set-StrictMode -Off

Describe "Testing ConvertTo-NormalizedUrl cmdlet" -Tag "UnitTest" {

    BeforeAll {
        Remove-Module -Name "TenantSiteMetadataSync" -Force -ErrorAction Ignore
        Import-Module -Name "$PSScriptRoot\..\..\TenantSiteMetadataSync.psd1" -Force
    }
    
    InModuleScope -ModuleName "TenantSiteMetadataSync" {

        It "should normalize URL <InputUrl> when passed as a parameter" -ForEach @(
            @{ InputUrl = "https://contoso.sharepoint.com/sites/teamsite";     OutputUrl = "https://contoso.sharepoint.com/sites/teamsite"  },
            @{ InputUrl = "https://contoso.sharepoint.com/sites/teamsite/";    OutputUrl = "https://contoso.sharepoint.com/sites/teamsite"  },
            @{ InputUrl = "https://contoso.sharepoint.com/sites/team%20site/"; OutputUrl = "https://contoso.sharepoint.com/sites/team site" }
        ){
            ConvertTo-NormalizedUrl -Url $InputUrl | Should -BeExactly $OutputUrl
        }

        It "should normalize URL <InputUrl> when passed in the pipeline" -ForEach @(
            @{ InputUrl = "https://contoso.sharepoint.com/sites/teamsite";     OutputUrl = "https://contoso.sharepoint.com/sites/teamsite"  },
            @{ InputUrl = "https://contoso.sharepoint.com/sites/teamsite/";    OutputUrl = "https://contoso.sharepoint.com/sites/teamsite"  },
            @{ InputUrl = "https://contoso.sharepoint.com/sites/team%20site/"; OutputUrl = "https://contoso.sharepoint.com/sites/team site" }
        ){
            $InputUrl | ConvertTo-NormalizedUrl | Should -BeExactly $OutputUrl
        }
    }
}