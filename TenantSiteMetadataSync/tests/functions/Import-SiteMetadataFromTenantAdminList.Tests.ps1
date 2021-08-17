Describe "TenantSiteMetadataSync functional tests" {

    BeforeDiscovery {
        Import-Module -Name "$PSScriptRoot\..\..\TenantSiteMetadataSync.psd1" -Force
    }

    Context "Import-SiteMetadataFromTenantAdminList function" {

        InModuleScope -ModuleName "TenantSiteMetadataSync" {

            It "should read the AggregatedSiteCollections list and save entries to database" {
            
                $mockListItem1 = [PSCustomObject] @{ 
                    Id = 1
                    FieldValues = @{ 
                            FileViewedOrEdited   = 0
                            Initiator            = "John Doe"
                            IsGroupConnected     = 1
                            LastActivityOn       = [DateTime]::Today
                            LastItemModifiedDate = [DateTime]::Today
                            NumOfFiles           = 100
                            PagesVisited         = 101
                            PageViews            = 102
                            SiteCreationSource   = [Guid]::NewGuid()
                            SiteId               = [Guid]::NewGuid()
                            SiteUrl              = "https://contoso.sharepoint.com/sites/site1"
                            StorageUsed          = 1GB
                            TimeDeleted          = $null
                            SiteFlags            = 1
                            State                = "1"
                            SensitivityLabel     = [Guid]::NewGuid()
                            GroupId              = [Guid]::NewGuid()
                            HubSiteId            = [Guid]::NewGuid()
                        }
                    }

                $mockListItem2 = [PSCustomObject] @{ 
                    Id = 2
                    FieldValues = @{ 
                        FileViewedOrEdited   = 1
                        Initiator            = "Jane Doe"
                        IsGroupConnected     = 1
                        LastActivityOn       = [DateTime]::Today
                        LastItemModifiedDate = [DateTime]::Today
                        NumOfFiles           = 100
                        PagesVisited         = 101
                        PageViews            = 102
                        SiteCreationSource   = [Guid]::NewGuid()
                        SiteId               = [Guid]::NewGuid()
                        SiteUrl              = "https://contoso.sharepoint.com/sites/site2  "
                        StorageUsed          = 1GB
                        TimeDeleted          = $null
                        SiteFlags            = 0
                        State                = "0"
                        SensitivityLabel     = $null
                        GroupId              = $null
                        HubSiteId            = $null
                    }
                }

                $mockListItems = @( $mockListItem1, $mockListItem2 )

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
                    -CommandName "Get-PnPListItem" `
                    -RemoveParameterType "Connection", "List" `
                    -ParameterFilter { $List -eq "DO_NOT_DELETE_SPLIST_TENANTADMIN_AGGREGATED_SITECOLLECTIONS" } `
                    -MockWith { $mockListItems } `
                    -Verifiable

                Mock `
                    -CommandName "Update-SiteMetadata" `
                    -ParameterFilter { $DatabaseName         -eq "TenantSiteMetadataSync" -and 
                                       $DatabaseServer       -eq "localhost/mssql" -and 
                                       $FileViewedOrEdited   -eq $mockListItem1.FieldValues.FileViewedOrEdited -and 
                                       $Initiator            -eq $mockListItem1.FieldValues.Initiator -and 
                                       $IsGroupConnected     -eq $mockListItem1.FieldValues.IsGroupConnected -and 
                                       $LastActivityOn       -eq $mockListItem1.FieldValues.LastActivityOn -and 
                                       $LastItemModifiedDate -eq $mockListItem1.FieldValues.LastItemModifiedDate -and 
                                       $NumOfFiles           -eq $mockListItem1.FieldValues.NumOfFiles -and 
                                       $PagesVisited         -eq $mockListItem1.FieldValues.PagesVisited -and 
                                       $PageViews            -eq $mockListItem1.FieldValues.PageViews -and 
                                       $SiteCreationSource   -eq $mockListItem1.FieldValues.SiteCreationSource -and 
                                       $SiteId               -eq $mockListItem1.FieldValues.SiteId -and 
                                       $SiteUrl              -eq $mockListItem1.FieldValues.SiteUrl -and 
                                       $StorageUsed          -eq $mockListItem1.FieldValues.StorageUsed -and 
                                       $IsTeamsConnected     -eq ($mockListItem1.FieldValues.SiteFlags -eq 1) -and
                                       $State                -eq $mockListItem1.FieldValues.State
                                    } `
                    -Verifiable

                Mock `
                    -CommandName "Update-SiteMetadata" `
                    -ParameterFilter { $DatabaseName         -eq "TenantSiteMetadataSync" -and 
                                       $DatabaseServer       -eq "localhost/mssql" -and 
                                       $FileViewedOrEdited   -eq $mockListItem2.FieldValues.FileViewedOrEdited -and 
                                       $Initiator            -eq $mockListItem2.FieldValues.Initiator -and 
                                       $IsGroupConnected     -eq $mockListItem2.FieldValues.IsGroupConnected -and 
                                       $LastActivityOn       -eq $mockListItem2.FieldValues.LastActivityOn -and 
                                       $LastItemModifiedDate -eq $mockListItem2.FieldValues.LastItemModifiedDate -and
                                       $NumOfFiles           -eq $mockListItem2.FieldValues.NumOfFiles -and 
                                       $PagesVisited         -eq $mockListItem2.FieldValues.PagesVisited -and 
                                       $PageViews            -eq $mockListItem2.FieldValues.PageViews -and 
                                       $SiteCreationSource   -eq $mockListItem2.FieldValues.SiteCreationSource -and 
                                       $SiteId               -eq $mockListItem2.FieldValues.SiteId -and 
                                       $SiteUrl              -eq $mockListItem2.FieldValues.SiteUrl -and
                                       $StorageUsed          -eq $mockListItem2.FieldValues.StorageUsed -and 
                                       $IsTeamsConnected     -eq ($mockListItem2.FieldValues.SiteFlags -eq 1) -and
                                       $State                -eq $mockListItem2.FieldValues.State
                                    } `
                    -Verifiable

                Import-SiteMetadataFromTenantAdminList `
                    -AdminList      "AggregatedSiteCollections" `
                    -DatabaseName   "TenantSiteMetadataSync" `
                    -DatabaseServer "localhost/mssql" `
                    -ClientId       "00000000-0000-0000-0000-000000000000" `
                    -Thumbprint     "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" `
                    -Tenant         "contoso"

                Should -InvokeVerifiable
            }

            It "should read the AggregatedSiteCollections list and save entries to database" {
            
                $mockListItem1 = [PSCustomObject] @{ 
                    Id = 1
                    FieldValues = @{ 
                        ConditionalAccessPolicy = 0
                        CreatedBy               = "John Doe"
                        DeletedBy               = "John Rambo"
                        SiteOwnerEmail          = "john.doe@contoso.com"
                        SiteOwnerName           = "John Doe"
                        StorageQuota            = 1GB
                        SiteId                  = [Guid]::NewGuid()
                        SiteUrl                 = "https://contoso.sharepoint.com/sites/site1"
                        TemplateName            = "STS#3"
                        TimeCreated             = [DateTime]::Today
                        Title                   = "Classic Teams Site"
                    }
                }

                $mockListItem2 = [PSCustomObject] @{ 
                    Id = 2
                    FieldValues = @{ 
                        ConditionalAccessPolicy = 0
                        CreatedBy               = "Jane Doe"
                        DeletedBy               = "Jane Rambo"
                        SiteOwnerEmail          = "jane.doe@contoso.com"
                        SiteOwnerName           = "Jane Doe"
                        StorageQuota            = 1GB
                        SiteId                  = [Guid]::NewGuid()
                        SiteUrl                 = "https://contoso.sharepoint.com/sites/site2"
                        TemplateName            = "GROUP#0"
                        TimeCreated             = [DateTime]::Today
                        Title                   = "Modern Teams Site"
                    }
                }

                $mockListItems = @( $mockListItem1, $mockListItem2 )

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
                    -CommandName "Get-PnPListItem" `
                    -RemoveParameterType "Connection", "List" `
                    -ParameterFilter { $List -eq "DO_NOT_DELETE_SPLIST_TENANTADMIN_ALL_SITES_AGGREGATED_SITECOLLECTIONS" } `
                    -MockWith { $mockListItems } `
                    -Verifiable

                Mock `
                    -CommandName "Update-SiteMetadata" `
                    -ParameterFilter { $DatabaseName            -eq "TenantSiteMetadataSync" -and 
                                       $DatabaseServer          -eq "localhost/mssql" -and 
                                       $ConditionalAccessPolicy -eq $mockListItem1.FieldValues.ConditionalAccessPolicy -and 
                                       $CreatedBy               -eq $mockListItem1.FieldValues.CreatedBy -and 
                                       $DeletedBy               -eq $mockListItem1.FieldValues.DeletedBy -and 
                                       $SiteOwnerEmail          -eq $mockListItem1.FieldValues.SiteOwnerEmail -and 
                                       $SiteOwnerName           -eq $mockListItem1.FieldValues.SiteOwnerName -and 
                                       $StorageQuota            -eq $mockListItem1.FieldValues.StorageQuota -and 
                                       $SiteId                  -eq $mockListItem1.FieldValues.SiteId -and 
                                       $SiteUrl                 -eq $mockListItem1.FieldValues.SiteUrl -and 
                                       $TemplateName            -eq $mockListItem1.FieldValues.TemplateName -and 
                                       $TimeCreated             -eq $mockListItem1.FieldValues.TimeCreated -and 
                                       $Title                   -eq $mockListItem1.FieldValues.Title
                                    } `
                    -Verifiable

                Mock `
                    -CommandName "Update-SiteMetadata" `
                    -ParameterFilter { $DatabaseName            -eq "TenantSiteMetadataSync" -and 
                                       $DatabaseServer          -eq "localhost/mssql" -and 
                                       $ConditionalAccessPolicy -eq $mockListItem2.FieldValues.ConditionalAccessPolicy -and 
                                       $CreatedBy               -eq $mockListItem2.FieldValues.CreatedBy -and 
                                       $DeletedBy               -eq $mockListItem2.FieldValues.DeletedBy -and 
                                       $SiteOwnerEmail          -eq $mockListItem2.FieldValues.SiteOwnerEmail -and 
                                       $SiteOwnerName           -eq $mockListItem2.FieldValues.SiteOwnerName -and 
                                       $StorageQuota            -eq $mockListItem2.FieldValues.StorageQuota -and 
                                       $SiteId                  -eq $mockListItem2.FieldValues.SiteId -and 
                                       $SiteUrl                 -eq $mockListItem2.FieldValues.SiteUrl -and 
                                       $TemplateName            -eq $mockListItem2.FieldValues.TemplateName -and 
                                       $TimeCreated             -eq $mockListItem2.FieldValues.TimeCreated -and 
                                       $Title                   -eq $mockListItem2.FieldValues.Title
                                    } `
                    -Verifiable

                Import-SiteMetadataFromTenantAdminList `
                    -AdminList      "AllSitesAggregatedSiteCollections" `
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