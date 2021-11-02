Set-StrictMode -Off

Describe "Testing Import-DeletedSiteMetadataFromTenantAPI cmdlet" -Tag "UnitTest" {

    BeforeAll {
        Remove-Module -Name "TenantSiteMetadataSync" -Force -ErrorAction Ignore
        Import-Module -Name "$PSScriptRoot\..\..\TenantSiteMetadataSync.psd1" -Force

        . "$PSScriptRoot\..\mocks\New-MockDatabaseConnectionInformation.ps1"
        . "$PSScriptRoot\..\mocks\New-MockDeletedSiteCollection.ps1"
        . "$PSScriptRoot\..\mocks\New-MockTenantConnectionInformation.ps1"
        . "$PSScriptRoot\ConvertTo-ScriptBlock.ps1"
        
        function Connect-PnPOnline { param( $Url, $ClientId, $Thumbprint, $Tenant, $ReturnConnection )  }
        function Disconnect-PnPOnline { param( $Connection ) }
        function Get-PnPTenantDeletedSite { param( $Connection, $IncludePersonalSite, $Limit )  }
        function Write-PSFMessage { param( $Level, $Message, $Exception )  }

        # PnP.PowerShell Mocks
        Mock -CommandName "Connect-PnPOnline"    -Verifiable -ModuleName "TenantSiteMetadataSync" -MockWith { return 1 }
        Mock -CommandName "Disconnect-PnPOnline" -Verifiable -ModuleName "TenantSiteMetadataSync" -RemoveParameterType "Connection"

        # TenantSiteMetadataSync Mocks
        Mock -CommandName "Start-SyncJobExecution" -Verifiable -ModuleName "TenantSiteMetadataSync" 
        Mock -CommandName "Stop-SyncJobExecution"  -Verifiable -ModuleName "TenantSiteMetadataSync"

        # PSFramework Mocks
        Mock -CommandName "Write-PSFMessage" -ModuleName "TenantSiteMetadataSync" -MockWith { if( $Exception ) { Write-Error "Pester Exception: Message: $Message. Exception: $Exception" } }

        [Diagnostics.CodeAnalysis.SuppressMessageAttribute("UseDeclaredVarsMoreThanAssignments", "")]
        $mockTenantConnection = New-MockTenantConnectionInformation

        [Diagnostics.CodeAnalysis.SuppressMessageAttribute("UseDeclaredVarsMoreThanAssignments", "")]
        $mockDatabaseConnectionInfo = New-MockDatabaseConnectionInformation -DatabaseConnectionType "TrustedConnection"

    }
        
    It "should update <Quantity> deleted sites" -Foreach @( 
        @{ Quantity = 0 }, 
        @{ Quantity = 1 }, 
        @{ Quantity = 2 } 
    ) {
        # build a mock deleted site collection
        $mockSites = New-MockDeletedSiteCollection -Quantity $Quantity

        # dynamically build a ParameterFilter and a corresponding mock function for the Update-SiteMetadata cmdlet
        foreach( $mockSite in $mockSites )
        {
            $parameterFilter = '$SiteId -eq [Guid]::Parse("{0}") -and $SiteUrl -eq "{1}" -and $TimeDeleted.Ticks -eq {2}' -f $mockSite.SiteId, $mockSite.Url, $mockSite.DeletionTime.Ticks | ConvertTo-ScriptBlock

            # create a mock with the unique filter
            Mock `
                -CommandName "Update-SiteMetadata" `
                -ModuleName "TenantSiteMetadataSync" `
                -ParameterFilter $parameterFilter `
                -Verifiable    
        }

        # build a mock command that returns the set of mock deleted sites
        Mock `
            -CommandName "Get-PnPTenantDeletedSite" `
            -ModuleName "TenantSiteMetadataSync" `
            -RemoveParameterType "Connection" `
            -MockWith { $mockSites } `
            -Verifiable

        # execute the function we are testing
        Import-DeletedSiteMetadataFromTenantAPI `
                -ClientId   $mockTenantConnection.ClientId `
                -Thumbprint $mockTenantConnection.Thumbprint `
                -Tenant     $mockTenantConnection.TenantName `
                -DatabaseConnectionInformation $mockDatabaseConnectionInfo

        # ensure all our verifiable mocks have been called 
        Should -InvokeVerifiable
    }
}
