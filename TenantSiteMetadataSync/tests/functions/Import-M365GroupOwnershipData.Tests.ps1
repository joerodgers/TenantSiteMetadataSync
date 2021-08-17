Describe "TenantSiteMetadataSync functional tests" {

    BeforeDiscovery {
        Import-Module -Name "$PSScriptRoot\..\..\TenantSiteMetadataSync.psd1" -Force
    }

    Context "Import-M365GroupOwnershipData function" {

        InModuleScope -ModuleName "TenantSiteMetadataSync" {

            BeforeAll {

                function Connect-MgGraph 
                { 
                    param($ClientId, $CertificateThumbprint, $TenantId) 
                }
                function Disconnect-MgGraph 
                { 
                    param() 
                }

                function Get-MgGroupOwner
                {
                    param($GroupId, $Top) 
                }


                Mock -CommandName "Start-SyncJobExecution" -Verifiable
                Mock -CommandName "Stop-SyncJobExecution"  -Verifiable
                Mock -CommandName "Disconnect-MgGraph"     -Verifiable
            }


            It "should update the group owner" {

                $mockGroup1 = @{ GroupId = "8dca3683-8d6c-4735-878f-49001418f7c4"; AdditionalProperties = @{ userPrincipalName = "john.doe@contoso.com" }}
                $mockGroup2 = @{ GroupId = "388e3db3-fc77-4aac-ae1e-cf4ae19cf512"; AdditionalProperties = @{ userPrincipalName = "jane.doe@contoso.com" }}

                $mockDatabaseName   = "TenantSiteMetadataSync"
                $mockDatabaseServer = "localhost/mssql"
                $mockClientId       = "00000000-0000-0000-0000-000000000000"
                $mockThumbprint     = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
                $mockTenant         = "contoso"


                Mock `
                    -CommandName "Get-DataTable" `
                    -ParameterFilter { $Query -eq "SELECT GroupId FROM GroupConnectedSites" } `
                    -MockWith { @($mockGroup1,$mockGroup2) } `
                    -Verifiable

                Mock `
                    -CommandName "Connect-MgGraph" `
                    -ParameterFilter { $ClientId -eq $mockClientId -and $Thumbprint -eq $mockThumbprint -and $TenantId -eq "$mockTenant.onmicrosoft.com" } `
                    -Verifiable

                Mock `
                    -CommandName "Get-MgGroupOwner" `
                    -ParameterFilter { $GroupId -eq $mockGroup1.GroupId -and $Top -eq 500 } `
                    -MockWith { ,$mockGroup1 } `
                    -Verifiable

                Mock `
                    -CommandName "Get-MgGroupOwner" `
                    -ParameterFilter { $GroupId -eq $mockGroup2.GroupId -and $Top -eq 500 } `
                    -MockWith { ,$mockGroup2 } `
                    -Verifiable

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ParameterFilter { $Query -eq "EXEC proc_RemoveGroupOwnersByGroupId @GroupId = @GroupId" -and $Parameters.GroupId -eq $mockGroup1.GroupId } `
                    -Verifiable

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ParameterFilter { $Query -eq "EXEC proc_RemoveGroupOwnersByGroupId @GroupId = @GroupId" -and $Parameters.GroupId -eq  $mockGroup2.GroupId } `
                    -Verifiable

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ParameterFilter { $Query -eq "EXEC proc_AddGroupOwnerByGroupId @GroupId = @GroupId, @UserPrincipalName = @UserPrincipalName" -and $Parameters.GroupId -eq  $mockGroup1.GroupId } `
                    -Verifiable

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ParameterFilter { $Query -eq "EXEC proc_AddGroupOwnerByGroupId @GroupId = @GroupId, @UserPrincipalName = @UserPrincipalName" -and $Parameters.GroupId -eq  $mockGroup2.GroupId } `
                    -Verifiable

                Import-M365GroupOwnershipData -Tenant $mockTenant -ClientId $mockClientId -Thumbprint $mockThumbprint -DatabaseName $mockDatabaseName -DatabaseServer $mockDatabaseServer

                Should -InvokeVerifiable
            }
        }
    }
}