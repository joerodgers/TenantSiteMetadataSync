Describe "TenantSiteMetadataSync functional tests" {

    BeforeDiscovery {
        Remove-Module -Name "TenantSiteMetadataSync" -Force -ErrorAction Ignore
        Import-Module -Name "$PSScriptRoot\..\..\TenantSiteMetadataSync.psd1" -Force
    }

    Context "Import-SensitivityLabel function" {

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
                function Get-PnPGraphAccessToken
                {
                    param($Connection) 
                }

                Mock -CommandName "Start-SyncJobExecution"  -Verifiable
                Mock -CommandName "Stop-SyncJobExecution"   -Verifiable
                Mock -CommandName "Connect-PnPOnline"       -Verifiable -MockWith { return 1 }
                Mock -CommandName "Disconnect-PnPOnline"    -Verifiable
                Mock -CommandName "Get-PnPGraphAccessToken" -Verifiable -MockWith { return "mock_access_token" }
                Mock -CommandName "Write-PSFMessage"
            }


            It "should update the group metadata" {
            
                $mockLabel1 = [PSCustomObject] @{ Id = [Guid]::NewGuid().ToString();  Name = "Proprietary" }
                $mockLabel2 = [PSCustomObject] @{ Id = [Guid]::NewGuid().ToString();  Name = "Confidential" }
                $mockLabel3 = [PSCustomObject] @{ Id = [Guid]::NewGuid().ToString();  Name = "Restricted" }

                $mockGraphResponse = [PSCustomObject] @{ "value" = @($mockLabel1, $mockLabel2, $mockLabel3) }

                Mock `
                    -CommandName "Invoke-RestMethod" `
                    -ParameterFilter { $Uri -eq "https://graph.microsoft.com/beta/informationProtection/policy/labels" -and $Headers.Authorization -eq "Bearer mock_access_token" } `
                    -MockWith { $mockGraphResponse } `
                    -Verifiable    

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ParameterFilter { $query -eq "EXEC proc_AddOrUpdateSensitivityLabel @Id = @Id, @Label = @Label" -and $Parameters.Id -eq $mockLabel1.Id -and $Parameters.Label -eq $mockLabel1.Name } `
                    -Verifiable    

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ParameterFilter { $query -eq "EXEC proc_AddOrUpdateSensitivityLabel @Id = @Id, @Label = @Label" -and $Parameters.Id -eq $mockLabel2.Id -and $Parameters.Label -eq $mockLabel2.Name } `
                    -Verifiable    

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ParameterFilter { $query -eq "EXEC proc_AddOrUpdateSensitivityLabel @Id = @Id, @Label = @Label" -and $Parameters.Id -eq $mockLabel3.Id -and $Parameters.Label -eq $mockLabel3.Name } `
                    -Verifiable    

                Import-SensitivityLabel `
                    -DatabaseName   "TenantSiteMetadataSync" `
                    -DatabaseServer "localhost/mssql" `
                    -ClientId       "00000000-0000-0000-0000-000000000000" `
                    -Thumbprint     "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" `
                    -Tenant         "contoso"

                Should -InvokeVerifiable
            }


       }
    }
}