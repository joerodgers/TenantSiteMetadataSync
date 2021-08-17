Describe "TenantSiteMetadataSync functional tests" {

    BeforeDiscovery {
        Import-Module -Name "$PSScriptRoot\..\..\TenantSiteMetadataSync.psd1" -Force
    }

    Context "Import-SiteCreationSources function" {

        InModuleScope -ModuleName "TenantSiteMetadataSync" {

            It "should update the group metadata" {
            
                $mockSource1 = [PSCustomObject] @{ Id = [Guid]::NewGuid().ToString();  DisplayName = "A" }
                $mockSource2 = [PSCustomObject] @{ Id = [Guid]::NewGuid().ToString();  DisplayName = "B" }
                $mockSource3 = [PSCustomObject] @{ Id = [Guid]::NewGuid().ToString();  DisplayName = "C" }

                $mockSiteCreationSources = [PSCustomObject] @{ "value" = @($mockSource1, $mockSource2, $mockSource3 ) }

                function Connect-PnPOnline {}
                function Disconnect-PnPOnline {}
                function Invoke-PnPSPRestMethod {}


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
                    -RemoveParameterType "Connection" `
                    -Verifiable

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