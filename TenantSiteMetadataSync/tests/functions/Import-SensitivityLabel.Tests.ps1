Describe "TenantSiteMetadataSync functional tests" {

    BeforeDiscovery {
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
                function Get-PnPGraphAccessToken
                {
                    param($Connection) 
                }

                Mock `
                    -CommandName "Start-SyncJobExecution" `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                Mock `
                    -CommandName "Stop-SyncJobExecution" `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                Mock `
                    -CommandName "Connect-PnPOnline" `
                    -MockWith { return 1 } `
                    -Verifiable

                Mock `
                    -CommandName "Disconnect-PnPOnline" `
                    -Verifiable

                Mock `
                    -CommandName "Get-PnPGraphAccessToken" `
                    -MockWith { return "mock_access_token" } `
                    -Verifiable
            }


            It "should update the group metadata" {
            
                $mockLabel1 = [PSCustomObject] @{ Id = [Guid]::NewGuid().ToString();  DisplayName = "Proprietary" }
                $mockLabel2 = [PSCustomObject] @{ Id = [Guid]::NewGuid().ToString();  DisplayName = "Confidential" }
                $mockLabel3 = [PSCustomObject] @{ Id = [Guid]::NewGuid().ToString();  DisplayName = "Restricated" }

                $mockGraphResponse = [PSCustomObject] @{ "value" = @($mockLabel1, $mockLabel2, $mockLabel3 ) }

                Mock `
                    -CommandName "Invoke-RestMethod" `
                    -ParameterFilter { $Uri -eq "https://graph.microsoft.com/beta/informationProtection/policy/labels" -and $Headers.Authorization -eq "Bearer mock_access_token" } `
                    -MockWith { $mockGraphResponse } `
                    -Verifiable    

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ParameterFilter { $query -eq "EXEC proc_AddOrUpdateSiteCreationSource @Id = @Id, @Source = @Source" -and $Parameters.Id -eq $mockLabel3.Id -and $Parameters.Label -eq $mockLabel3.Name } `
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