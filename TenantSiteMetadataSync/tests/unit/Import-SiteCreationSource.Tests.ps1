Set-StrictMode -Off

Describe "Testing Import-SiteCreationSource cmdlet" -Tag "UnitTest" {

    BeforeAll {

        Remove-Module -Name "TenantSiteMetadataSync" -Force -ErrorAction Ignore
        Import-Module -Name "$PSScriptRoot\..\..\TenantSiteMetadataSync.psd1" -Force

        . "$PSScriptRoot\..\mocks\New-MockDatabaseConnectionInformation.ps1"
        . "$PSScriptRoot\..\mocks\New-MockTenantConnectionInformation.ps1"
        . "$PSScriptRoot\..\mocks\New-MockSiteCreationSource.ps1"

        function Connect-PnPOnline { param( $Url, $ClientId, $Thumbprint, $Tenant, $ReturnConnection )  }
        function Disconnect-PnPOnline { param( $Connection ) }
        function Invoke-PnPSPRestMethod { param($Method, $Url, $Connection) }
        function Write-PSFMessage { param( $Level, $Message, $Exception )  }

        # PnP.PowerShell Mocks
        Mock -CommandName "Connect-PnPOnline"       -Verifiable -ModuleName "TenantSiteMetadataSync" -MockWith { return 1 }
        Mock -CommandName "Disconnect-PnPOnline"    -Verifiable -ModuleName "TenantSiteMetadataSync" -RemoveParameterType "Connection"

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

    It "should add <Quantity> site creation sources to the database" -Foreach @(
        @{ Quantity = 0 },
        @{ Quantity = 1 },
        @{ Quantity = 2 },
        @{ Quantity = 3 }
    ) {
        # build mock dataset
        $mockSiteCreationSources = New-MockSiteCreationSource -Quantity $Quantity

        Mock `
            -CommandName "Invoke-PnPSPRestMethod" `
            -RemoveParameterType "Connection" `
            -ModuleName "TenantSiteMetadataSync" `
            -ParameterFilter { $Url -eq "https://$($mockTenantConnection.TenantName)-admin.sharepoint.com/_api/SPO.Tenant/GetSPOSiteCreationSources" } `
            -MockWith { $mockSiteCreationSources } `
            -Verifiable    

        foreach( $mockSiteCreationSource in $mockSiteCreationSources.value )
        {
            $filter = '$Query -eq "EXEC proc_AddOrUpdateSiteCreationSource @Id = @Id, @Source = @Source" -and $Parameters.Id -eq "{0}" -and $Parameters.Source -eq "{1}"' -f $mockSiteCreationSource.Id, $mockSiteCreationSource.DisplayName

            Mock `
                -CommandName "Invoke-NonQuery" `
                -ModuleName "TenantSiteMetadataSync" `
                -ParameterFilter ([ScriptBlock]::Create( $filter )) `
                -Verifiable    
        }

        Import-SiteCreationSource `
            -ClientId       $mockTenantConnection.ClientId `
            -Thumbprint     $mockTenantConnection.Thumbprint `
            -Tenant         $mockTenantConnection.TenantName `
            -DatabaseConnectionInformation $mockDatabaseConnectionInfo

        Should -InvokeVerifiable
    }
}