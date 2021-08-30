Describe "TenantSiteMetadataSync functional tests" {

    BeforeDiscovery {
        Remove-Module -Name "TenantSiteMetadataSync" -Force -ErrorAction Ignore
        Import-Module -Name "$PSScriptRoot\..\..\TenantSiteMetadataSync.psd1" -Force
    }

    Context "Import-SiteCreationSources function" {

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

                Mock -CommandName "Start-SyncJobExecution"  -Verifiable
                Mock -CommandName "Stop-SyncJobExecution"   -Verifiable
                Mock -CommandName "Connect-PnPOnline"       -Verifiable -MockWith { return 1 }
                Mock -CommandName "Disconnect-PnPOnline"    -Verifiable
                Mock -CommandName "Write-PSFMessage"

                function Invoke-PnPSPRestMethod 
                {
                    param($Method, $Url, $Connection) 
                }
            }

            It "should update the group metadata" {
            
                $mockSource1 = [PSCustomObject] @{ Id = [Guid]::NewGuid().ToString();  DisplayName = "A" }
                $mockSource2 = [PSCustomObject] @{ Id = [Guid]::NewGuid().ToString();  DisplayName = "B" }
                $mockSource3 = [PSCustomObject] @{ Id = [Guid]::NewGuid().ToString();  DisplayName = "C" }

                $mockSiteCreationSources = [PSCustomObject] @{ "value" = @($mockSource1, $mockSource2, $mockSource3 ) }

                Mock `
                    -CommandName "Invoke-PnPSPRestMethod" `
                    -RemoveParameterType "Connection", "Method" `
                    -ParameterFilter { $Url -eq "https://contoso-admin.sharepoint.com/_api/SPO.Tenant/GetSPOSiteCreationSources" } `
                    -MockWith { $mockSiteCreationSources } `
                    -Verifiable    

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ParameterFilter { $query -eq "EXEC proc_AddOrUpdateSiteCreationSource @Id = @Id, @Source = @Source" -and $Parameters.Id -eq $mockSource1.Id -and $Parameters.Source -eq $mockSource1.DisplayName } `
                    -Verifiable    

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ParameterFilter { $query -eq "EXEC proc_AddOrUpdateSiteCreationSource @Id = @Id, @Source = @Source" -and $Parameters.Id -eq $mockSource2.Id -and $Parameters.Source -eq $mockSource2.DisplayName } `
                    -Verifiable    

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ParameterFilter { $query -eq "EXEC proc_AddOrUpdateSiteCreationSource @Id = @Id, @Source = @Source" -and $Parameters.Id -eq $mockSource3.Id -and $Parameters.Source -eq $mockSource3.DisplayName } `
                    -Verifiable    

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ParameterFilter { $query -eq "EXEC proc_AddOrUpdateSiteCreationSource @Id = @Id, @Source = @Source" -and $Parameters.Id -eq "14D82EEC-204B-4C2F-B7E8-296A70DAB67E" -and $Parameters.Source -eq "Microsoft Graph"  } `
                    -Verifiable    

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ParameterFilter { $query -eq "EXEC proc_AddOrUpdateSiteCreationSource @Id = @Id, @Source = @Source" -and $Parameters.Id -eq "5D9FFF84-5B34-4204-BC91-3AAF5F298C5D" -and $Parameters.Source -eq "PnP Lookbook" } `
                    -Verifiable    

                Import-SiteCreationSources `
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