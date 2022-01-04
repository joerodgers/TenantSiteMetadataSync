Set-StrictMode -Off

Describe "Testing Import-M365GroupOwnershipData cmdlet" -Tag "UnitTest" {

    BeforeAll {
        Remove-Module -Name "TenantSiteMetadataSync" -Force -ErrorAction Ignore
        Import-Module -Name "$PSScriptRoot\..\..\TenantSiteMetadataSync.psd1" -Force

        . "$PSScriptRoot\..\mocks\New-MockDatabaseConnectionInformation.ps1"
        . "$PSScriptRoot\..\mocks\New-MockO365GroupCollection.ps1"
        . "$PSScriptRoot\..\mocks\New-MockO365GroupOwnerCollection.ps1"
        . "$PSScriptRoot\..\mocks\New-MockTenantConnectionInformation.ps1"
        . "$PSScriptRoot\ConvertTo-ScriptBlock.ps1"

        function Connect-MgGraph { param($ClientId, $CertificateThumbprint, $TenantId) }
        function Disconnect-MgGraph { param() }
        function Get-MgGroupOwner { param($GroupId, $Top)  }
        function Write-PSFMessage { param( $Level, $Message, $Exception )  }

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

    It "should update <GroupQuantity> group(s) with <OwnerQuantity> owners" -ForEach @( 
        @{ GroupQuantity = 0; OwnerQuantity = 0 }, 
        @{ GroupQuantity = 1; OwnerQuantity = 0 }, 
        @{ GroupQuantity = 2; OwnerQuantity = 1 },
        @{ GroupQuantity = 3; OwnerQuantity = 0 },
        @{ GroupQuantity = 5; OwnerQuantity = 5 }
    ) {


        # get mock group dataset
        $mockO365Groups = New-MockO365GroupCollection -Quantity $GroupQuantity

        # get mock group owner dataset
        $mockO365GroupOwners = New-MockO365GroupOwnerCollection -Quantity $OwnerQuantity

        # Microsoft.Graph Mocks
        $parameterFilter = '$ClientId -eq "{0}" -and $CertificateThumbprint -eq "{1}" -and $TenantId -eq "{2}"' -f $mockTenantConnection.ClientId, $mockTenantConnection.Thumbprint, $mockTenantConnection.TenantFQDN | ConvertTo-ScriptBlock

        Mock -CommandName "Disconnect-MgGraph" -Verifiable:$($GroupQuantity -gt 0) -ModuleName "TenantSiteMetadataSync"
        Mock -CommandName "Connect-MgGraph"    -Verifiable:$($GroupQuantity -gt 0) -ModuleName "TenantSiteMetadataSync" -ParameterFilter $parameterFilter

        Mock `
            -CommandName "Get-DataTable" `
            -ModuleName "TenantSiteMetadataSync" `
            -ParameterFilter { $Query -eq "SELECT GroupId FROM GroupConnectedSites" } `
            -MockWith { $mockO365Groups } `
            -Verifiable

        # build dynamic mocks
        foreach( $mockO365Group in $mockO365Groups )
        {
            $parameterFilter = '$GroupId.ToString() -eq "{0}" -and $Top -eq 500' -f $mockO365Group.GroupId.ToString() | ConvertTo-ScriptBlock

            # create a mock with the unique filter
            Mock `
                -CommandName "Get-MgGroupOwner" `
                -ModuleName "TenantSiteMetadataSync" `
                -ParameterFilter $parameterFilter `
                -MockWith { $mockO365GroupOwners } `
                -Verifiable

            $parameterFilter = '$Query -eq "EXEC proc_RemoveGroupOwnersByGroupId @GroupId = @GroupId" -and $Parameters.GroupId.ToString() -eq "{0}"' -f $mockO365Group.GroupId | ConvertTo-ScriptBlock

            # create a mock with the unique filter
            Mock `
                -CommandName "Invoke-NonQuery" `
                -ModuleName "TenantSiteMetadataSync" `
                -ParameterFilter $parameterFilter `
                -Verifiable:$($OwnerQuantity -gt 0)

            foreach( $mockO365GroupOwner in $mockO365GroupOwners )
            {
                $parameterFilter = '$Query -eq "EXEC proc_AddGroupOwnerByGroupId @GroupId = @GroupId, @UserPrincipalName = @UserPrincipalName" -and $Parameters.GroupId.ToString() -eq "{0}" -and $Parameters.UserPrincipalName -eq "{1}"' -f 
                    $mockO365Group.GroupId.ToString(), $mockO365GroupOwner.AdditionalProperties.userPrincipalName | ConvertTo-ScriptBlock
    
                # create a mock with the unique filter
                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ModuleName "TenantSiteMetadataSync" `
                    -ParameterFilter $parameterFilter `
                    -Verifiable
            }
        }

        Import-TSMSM365GroupOwnershipData `
            -ClientId   $mockTenantConnection.ClientId `
            -Tenant     $mockTenantConnection.TenantName `
            -Thumbprint $mockTenantConnection.Thumbprint `
            -DatabaseConnectionInformation $mockDatabaseConnectionInfo

        Should -InvokeVerifiable
    }
}