Set-StrictMode -Off

Describe "Testing Import-SensitivityLabel cmdlet" -Tag "UnitTest" {

    BeforeAll {

        Remove-Module -Name "TenantSiteMetadataSync" -Force -ErrorAction Ignore
        Import-Module -Name "$PSScriptRoot\..\..\TenantSiteMetadataSync.psd1" -Force

        . "$PSScriptRoot\..\mocks\New-MockDatabaseConnectionInformation.ps1"
        . "$PSScriptRoot\..\mocks\New-MockTenantConnectionInformation.ps1"
        . "$PSScriptRoot\ConvertTo-ScriptBlock.ps1"

        function Connect-PnPOnline { param( $Url, $ClientId, $Thumbprint, $Tenant, $ReturnConnection )  }
        function Disconnect-PnPOnline { param( $Connection ) }
        function Get-PnPTenantDeletedSite { param( $Connection, $IncludePersonalSite, $Limit )  }
        function Get-PnPGraphAccessToken { param($Connection) }
        function Write-PSFMessage { param( $Level, $Message, $Exception )  }

        # PnP.PowerShell Mocks
        Mock -CommandName "Connect-PnPOnline"       -Verifiable -ModuleName "TenantSiteMetadataSync" -MockWith { return 1 }
        Mock -CommandName "Get-PnPGraphAccessToken" -Verifiable -ModuleName "TenantSiteMetadataSync" -RemoveParameterType "Connection" -MockWith { return "mock_access_token" }
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

    BeforeDiscovery {

        [Diagnostics.CodeAnalysis.SuppressMessageAttribute("UseDeclaredVarsMoreThanAssignments", "")]
        $testCases = @(
            @{ Labels = @() }
            @{ Labels = [PSCustomObject] @{ Id = [Guid]::NewGuid().ToString(); Name = "Proprietary"  } }
            @{ Labels = [PSCustomObject] @{ Id = [Guid]::NewGuid().ToString(); Name = "Proprietary"  },
                        [PSCustomObject] @{ Id = [Guid]::NewGuid().ToString(); Name = "Confidential" },
                        [PSCustomObject] @{ Id = [Guid]::NewGuid().ToString(); Name = "Restricted"   } })    
    }

    It "should import <_.Labels.Count> labels from O365" -ForEach $testCases {

        $parameterFilter = '$Method -eq "Get" -and $Uri -eq "https://graph.microsoft.com/beta/informationProtection/policy/labels" -and $Headers.Authorization -eq "Bearer mock_access_token"' | ConvertTo-ScriptBlock

        Mock `
            -CommandName "Invoke-RestMethod" `
            -ModuleName "TenantSiteMetadataSync" `
            -ParameterFilter $parameterFilter `
            -MockWith { [PSCustomObject] @{ "value" = $Labels } } `
            -Verifiable

        foreach( $label in $Labels )
        {
            $parameterFilter = '$query -eq "EXEC proc_AddOrUpdateSensitivityLabel @Id = @Id, @Label = @Label" -and $Parameters.Id -eq "{0}" -and $Parameters.Label -eq "{1}"' -f $label.Id, $label.Name | ConvertTo-ScriptBlock
        
            Mock `
                -CommandName "Invoke-NonQuery" `
                -ModuleName "TenantSiteMetadataSync" `
                -ParameterFilter $parameterFilter `
                -Verifiable
        }

        Import-SensitivityLabel `
            -ClientId       $mockTenantConnection.ClientId `
            -Thumbprint     $mockTenantConnection.Thumbprint `
            -Tenant         $mockTenantConnection.TenantName `
            -DatabaseConnectionInformation $mockDatabaseConnectionInfo

        Should -InvokeVerifiable
    }
}


