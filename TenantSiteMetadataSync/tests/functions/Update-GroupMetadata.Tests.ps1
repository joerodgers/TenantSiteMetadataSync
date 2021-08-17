Describe "TenantSiteMetadataSync functional tests" {

    BeforeDiscovery {
        Import-Module -Name "$PSScriptRoot\..\..\TenantSiteMetadataSync.psd1" -Force
    }

    Context "Update-GroupMetadata function" {

        InModuleScope -ModuleName "TenantSiteMetadataSync" {

            It "should update the group's DisplayName value" {

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ParameterFilter { $DatabaseName -eq "TenantSiteMetadataSync" -and $DatabaseServer -eq "localhost/mssql" -and $parameters.DisplayName -eq "Contoso Sales" } `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                Update-GroupMetadata -DatabaseName "TenantSiteMetadataSync" -DatabaseServer "localhost/mssql" -GroupId "e5c6a4ad-d005-4665-be02-3073a16c8265" -DisplayName "Contoso Sales"
        
                Should -Invoke -CommandName "Invoke-NonQuery" -Exactly -Times 1 -ModuleName "TenantSiteMetadataSync"
            }

            It "should update the group's IsDeleted value" {

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ParameterFilter { $DatabaseName -eq "TenantSiteMetadataSync" -and $DatabaseServer -eq "localhost/mssql" -and $parameters.IsDeleted -eq $true } `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                Update-GroupMetadata -DatabaseName "TenantSiteMetadataSync" -DatabaseServer "localhost/mssql" -GroupId "e5c6a4ad-d005-4665-be02-3073a16c8265" -IsDeleted $true
        
                Should -InvokeVerifiable
            }

            It "should update the group's LastActivityDate value" {

                $timestamp = Get-Date

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ParameterFilter { $DatabaseName -eq "TenantSiteMetadataSync" -and $DatabaseServer -eq "localhost/mssql" -and $parameters.LastActivityDate -eq $timestamp } `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                Update-GroupMetadata -DatabaseName "TenantSiteMetadataSync" -DatabaseServer "localhost/mssql" -GroupId "e5c6a4ad-d005-4665-be02-3073a16c8265" -LastActivityDate $timestamp
        
                Should -InvokeVerifiable
            }

            It "should not update the group's LastActivityDate value if value is null" {

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ModuleName "TenantSiteMetadataSync"

                Update-GroupMetadata -DatabaseName "TenantSiteMetadataSync" -DatabaseServer "localhost/mssql" -GroupId "e5c6a4ad-d005-4665-be02-3073a16c8265" -LastActivityDate $null
        
                Should -Invoke -CommandName "Invoke-NonQuery" -Exactly -Times 0
            }

            It "should update the group's IsPublic value" {

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ParameterFilter { $DatabaseName -eq "TenantSiteMetadataSync" -and $DatabaseServer -eq "localhost/mssql" -and $parameters.IsPublic -eq $true } `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                Update-GroupMetadata -DatabaseName "TenantSiteMetadataSync" -DatabaseServer "localhost/mssql" -GroupId "e5c6a4ad-d005-4665-be02-3073a16c8265" -IsPublic $true
        
                Should -InvokeVerifiable
            }

            It "should update the group's MemberCount value" {

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ParameterFilter { $DatabaseName -eq "TenantSiteMetadataSync" -and $DatabaseServer -eq "localhost/mssql" -and $parameters.MemberCount -eq 100 } `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                Update-GroupMetadata -DatabaseName "TenantSiteMetadataSync" -DatabaseServer "localhost/mssql" -GroupId "e5c6a4ad-d005-4665-be02-3073a16c8265" -MemberCount 100
        
                Should -InvokeVerifiable
            }

            It "should throw trying to update the group's MemberCount value to a negative number" {

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ParameterFilter { $DatabaseName -eq "TenantSiteMetadataSync" -and $DatabaseServer -eq "localhost/mssql" -and $parameters.MemberCount -eq -1 } `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                {Update-GroupMetadata -DatabaseName "TenantSiteMetadataSync" -DatabaseServer "localhost/mssql" -GroupId "e5c6a4ad-d005-4665-be02-3073a16c8265" -MemberCount -1 } | Should -Throw -ExpectedMessage "Cannot validate argument on parameter 'MemberCount'. The argument `"-1`" cannot be validated because its value is not greater than or equal to zero."
            }

            It "should update the group's ExternalMemberCount value" {

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ParameterFilter { $DatabaseName -eq "TenantSiteMetadataSync" -and $DatabaseServer -eq "localhost/mssql" -and $parameters.ExternalMemberCount -eq 100 } `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                Update-GroupMetadata -DatabaseName "TenantSiteMetadataSync" -DatabaseServer "localhost/mssql" -GroupId "e5c6a4ad-d005-4665-be02-3073a16c8265" -ExternalMemberCount 100
        
                Should -InvokeVerifiable
            }

            It "should throw trying to update the group's ExternalMemberCount value to a negative number" {

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ParameterFilter { $DatabaseName -eq "TenantSiteMetadataSync" -and $DatabaseServer -eq "localhost/mssql" -and $parameters.ExternalMemberCount -eq -1 } `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                { Update-GroupMetadata -DatabaseName "TenantSiteMetadataSync" -DatabaseServer "localhost/mssql" -GroupId "e5c6a4ad-d005-4665-be02-3073a16c8265" -ExternalMemberCount -1 -Verbose } | Should -Throw -ExpectedMessage "Cannot validate argument on parameter 'ExternalMemberCount'. The argument `"-1`" cannot be validated because its value is not greater than or equal to zero."
        
            }

            It "should update the group's SharePointActiveFileCount value" {

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ParameterFilter { $DatabaseName -eq "TenantSiteMetadataSync" -and $DatabaseServer -eq "localhost/mssql" -and $parameters.SharePointActiveFileCount -eq 100 } `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                Update-GroupMetadata -DatabaseName "TenantSiteMetadataSync" -DatabaseServer "localhost/mssql" -GroupId "e5c6a4ad-d005-4665-be02-3073a16c8265" -SharePointActiveFileCount 100
        
                Should -InvokeVerifiable
            }        

            It "should throw trying to update the group's SharePointActiveFileCount value to a negative number" {

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ParameterFilter { $DatabaseName -eq "TenantSiteMetadataSync" -and $DatabaseServer -eq "localhost/mssql" -and $parameters.SharePointActiveFileCount -eq -1 } `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                { Update-GroupMetadata -DatabaseName "TenantSiteMetadataSync" -DatabaseServer "localhost/mssql" -GroupId "e5c6a4ad-d005-4665-be02-3073a16c8265" -SharePointActiveFileCount -1 } | Should -Throw -ExpectedMessage "Cannot validate argument on parameter 'SharePointActiveFileCount'. The argument `"-1`" cannot be validated because its value is not greater than or equal to zero."
            }        

            It "should update the group's SharePointTotalFileCount value" {

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ParameterFilter { $DatabaseName -eq "TenantSiteMetadataSync" -and $DatabaseServer -eq "localhost/mssql" -and $parameters.SharePointTotalFileCount -eq 100 } `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                Update-GroupMetadata -DatabaseName "TenantSiteMetadataSync" -DatabaseServer "localhost/mssql" -GroupId "e5c6a4ad-d005-4665-be02-3073a16c8265" -SharePointTotalFileCount 100
        
                Should -InvokeVerifiable
            }        

            It "should throw trying to update the group's SharePointTotalFileCount value to a negative number" {

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ParameterFilter { $DatabaseName -eq "TenantSiteMetadataSync" -and $DatabaseServer -eq "localhost/mssql" -and $parameters.SharePointTotalFileCount -eq -1 } `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                { Update-GroupMetadata -DatabaseName "TenantSiteMetadataSync" -DatabaseServer "localhost/mssql" -GroupId "e5c6a4ad-d005-4665-be02-3073a16c8265" -SharePointTotalFileCount -1 } | Should -Throw -ExpectedMessage "Cannot validate argument on parameter 'SharePointTotalFileCount'. The argument `"-1`" cannot be validated because its value is not greater than or equal to zero."
            }    

            It "should update the group's YammerPostedMessageCount value" {

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ParameterFilter { $DatabaseName -eq "TenantSiteMetadataSync" -and $DatabaseServer -eq "localhost/mssql" -and $parameters.YammerPostedMessageCount -eq 100 } `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                Update-GroupMetadata -DatabaseName "TenantSiteMetadataSync" -DatabaseServer "localhost/mssql" -GroupId "e5c6a4ad-d005-4665-be02-3073a16c8265" -YammerPostedMessageCount 100
        
                Should -InvokeVerifiable
            }      

            It "should throw trying to update the group's YammerPostedMessageCount value to a negative number" {

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ParameterFilter { $DatabaseName -eq "TenantSiteMetadataSync" -and $DatabaseServer -eq "localhost/mssql" -and $parameters.YammerPostedMessageCount -eq -1 } `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                { Update-GroupMetadata -DatabaseName "TenantSiteMetadataSync" -DatabaseServer "localhost/mssql" -GroupId "e5c6a4ad-d005-4665-be02-3073a16c8265" -YammerPostedMessageCount -1 } | Should -Throw -ExpectedMessage "Cannot validate argument on parameter 'YammerPostedMessageCount'. The argument `"-1`" cannot be validated because its value is not greater than or equal to zero."
            }    

            It "should update the group's YammerReadMessageCount value" {

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ParameterFilter { $DatabaseName -eq "TenantSiteMetadataSync" -and $DatabaseServer -eq "localhost/mssql" -and $parameters.YammerReadMessageCount -eq 100 } `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                Update-GroupMetadata -DatabaseName "TenantSiteMetadataSync" -DatabaseServer "localhost/mssql" -GroupId "e5c6a4ad-d005-4665-be02-3073a16c8265" -YammerReadMessageCount 100
        
                Should -InvokeVerifiable
            }      

            It "should throw trying to update the group's YammerReadMessageCount value to a negative number" {

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ParameterFilter { $DatabaseName -eq "TenantSiteMetadataSync" -and $DatabaseServer -eq "localhost/mssql" -and $parameters.YammerReadMessageCount -eq -1 } `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                { Update-GroupMetadata -DatabaseName "TenantSiteMetadataSync" -DatabaseServer "localhost/mssql" -GroupId "e5c6a4ad-d005-4665-be02-3073a16c8265" -YammerReadMessageCount -1 } | Should -Throw -ExpectedMessage "Cannot validate argument on parameter 'YammerReadMessageCount'. The argument `"-1`" cannot be validated because its value is not greater than or equal to zero."
            }    

            It "should update the group's YammerLikedMessageCount value" {

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ParameterFilter { $DatabaseName -eq "TenantSiteMetadataSync" -and $DatabaseServer -eq "localhost/mssql" -and $parameters.YammerLikedMessageCount -eq 100 } `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                Update-GroupMetadata -DatabaseName "TenantSiteMetadataSync" -DatabaseServer "localhost/mssql" -GroupId "e5c6a4ad-d005-4665-be02-3073a16c8265" -YammerLikedMessageCount 100
        
                Should -InvokeVerifiable
            }      

            It "should throw trying to update the group's YammerLikedMessageCount value to a negative number" {

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ParameterFilter { $DatabaseName -eq "TenantSiteMetadataSync" -and $DatabaseServer -eq "localhost/mssql" -and $parameters.YammerLikedMessageCount -eq -1 } `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                { Update-GroupMetadata -DatabaseName "TenantSiteMetadataSync" -DatabaseServer "localhost/mssql" -GroupId "e5c6a4ad-d005-4665-be02-3073a16c8265" -YammerLikedMessageCount -1 } | Should -Throw -ExpectedMessage "Cannot validate argument on parameter 'YammerLikedMessageCount'. The argument `"-1`" cannot be validated because its value is not greater than or equal to zero."
            }    

            It "should update the group's ExchangeMailboxTotalItemCount value" {

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ParameterFilter { $DatabaseName -eq "TenantSiteMetadataSync" -and $DatabaseServer -eq "localhost/mssql" -and $parameters.ExchangeMailboxTotalItemCount -eq 100 } `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                Update-GroupMetadata -DatabaseName "TenantSiteMetadataSync" -DatabaseServer "localhost/mssql" -GroupId "e5c6a4ad-d005-4665-be02-3073a16c8265" -ExchangeMailboxTotalItemCount 100
        
                Should -InvokeVerifiable
            }      

            It "should throw trying to update the group's ExchangeMailboxTotalItemCount value to a negative number" {

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ParameterFilter { $DatabaseName -eq "TenantSiteMetadataSync" -and $DatabaseServer -eq "localhost/mssql" -and $parameters.ExchangeMailboxTotalItemCount -eq -1 } `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                { Update-GroupMetadata -DatabaseName "TenantSiteMetadataSync" -DatabaseServer "localhost/mssql" -GroupId "e5c6a4ad-d005-4665-be02-3073a16c8265" -ExchangeMailboxTotalItemCount -1 } | Should -Throw -ExpectedMessage "Cannot validate argument on parameter 'ExchangeMailboxTotalItemCount'. The argument `"-1`" cannot be validated because its value is not greater than or equal to zero."
            }    

            It "should update the group's ExchangeMailboxStorageUsed value" {

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ParameterFilter { $DatabaseName -eq "TenantSiteMetadataSync" -and $DatabaseServer -eq "localhost/mssql" -and $parameters.ExchangeMailboxStorageUsed -eq 100 } `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                Update-GroupMetadata -DatabaseName "TenantSiteMetadataSync" -DatabaseServer "localhost/mssql" -GroupId "e5c6a4ad-d005-4665-be02-3073a16c8265" -ExchangeMailboxStorageUsed 100
        
                Should -InvokeVerifiable
            }      

            It "should throw trying to update the group's ExchangeMailboxStorageUsed value to a negative number" {

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ParameterFilter { $DatabaseName -eq "TenantSiteMetadataSync" -and $DatabaseServer -eq "localhost/mssql" -and $parameters.ExchangeMailboxStorageUsed -eq -1 } `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                { Update-GroupMetadata -DatabaseName "TenantSiteMetadataSync" -DatabaseServer "localhost/mssql" -GroupId "e5c6a4ad-d005-4665-be02-3073a16c8265" -ExchangeMailboxStorageUsed -1 } | Should -Throw -ExpectedMessage "Cannot validate argument on parameter 'ExchangeMailboxStorageUsed'. The argument `"-1`" cannot be validated because its value is not greater than or equal to zero."
            }    

            It "should update multiple group property values" {

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ParameterFilter { $DatabaseName -eq "TenantSiteMetadataSync" -and $DatabaseServer -eq "localhost/mssql" -and $parameters.ExchangeMailboxStorageUsed -eq 100 -and $parameters.ExchangeMailboxTotalItemCount -eq 101 -and $parameters.YammerLikedMessageCount -eq 102 } `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                Update-GroupMetadata -DatabaseName "TenantSiteMetadataSync" -DatabaseServer "localhost/mssql" -GroupId "e5c6a4ad-d005-4665-be02-3073a16c8265" -ExchangeMailboxStorageUsed 100 -ExchangeMailboxTotalItemCount 101 -YammerLikedMessageCount 102
        
                Should -InvokeVerifiable
            }      

            It "should update no group property values" {

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                Update-GroupMetadata -DatabaseName "TenantSiteMetadataSync" -DatabaseServer "localhost/mssql" -GroupId "e5c6a4ad-d005-4665-be02-3073a16c8265"
        
                Should -Invoke -CommandName "Invoke-NonQuery" -Exactly -Times 0 -ModuleName "TenantSiteMetadataSync"
            }      

        }
    }
}