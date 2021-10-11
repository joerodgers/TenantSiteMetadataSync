Describe "TenantSiteMetadataSync functional tests" {

    BeforeDiscovery {
        Remove-Module -Name "TenantSiteMetadataSync" -Force -ErrorAction Ignore
        Import-Module -Name "$PSScriptRoot\..\..\TenantSiteMetadataSync.psd1" -Force
    }

    Context "Update-SiteMetadata function" {

        InModuleScope -ModuleName "TenantSiteMetadataSync" {

            BeforeAll {
                function Write-PSFMessage
                {
                    param($Level, $Message, $Exception) 
                }

                Mock -CommandName "Write-PSFMessage"
            }

            It "should update the site's AnonymousLinkCount value" {

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ParameterFilter { $DatabaseName -eq "TenantSiteMetadataSync" -and $DatabaseServer -eq "localhost/mssql" -and $SiteUrl -eq "https://contoso.sharepoint.com" -and $parameters.AnonymousLinkCount -eq 100 } `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                Update-SiteMetadata -DatabaseName "TenantSiteMetadataSync" -DatabaseServer "localhost/mssql" -SiteUrl "https://contoso.sharepoint.com" -AnonymousLinkCount 100
        
                Should -InvokeVerifiable
            }

            It "should throw trying to update the group's AnonymousLinkCount value to a negative number" {

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ParameterFilter { $DatabaseName -eq "TenantSiteMetadataSync" -and $DatabaseServer -eq "localhost/mssql" -and $parameters.AnonymousLinkCount -eq -1 } `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                { Update-SiteMetadata -DatabaseName "TenantSiteMetadataSync" -DatabaseServer "localhost/mssql" -SiteUrl "https://contoso.sharepoint.com" -AnonymousLinkCount -1 } | Should -Throw -ExpectedMessage "Cannot validate argument on parameter 'AnonymousLinkCount'. The argument `"-1`" cannot be validated because its value is not greater than or equal to zero."
            }    

            It "should update the site's CompanyLinkCount value" {

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ParameterFilter { $DatabaseName -eq "TenantSiteMetadataSync" -and $DatabaseServer -eq "localhost/mssql" -and $SiteUrl -eq "https://contoso.sharepoint.com" -and $parameters.CompanyLinkCount -eq 100 } `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                Update-SiteMetadata -DatabaseName "TenantSiteMetadataSync" -DatabaseServer "localhost/mssql" -SiteUrl "https://contoso.sharepoint.com" -CompanyLinkCount 100
        
                Should -InvokeVerifiable
            }

            It "should throw trying to update the group's CompanyLinkCount value to a negative number" {

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ParameterFilter { $DatabaseName -eq "TenantSiteMetadataSync" -and $DatabaseServer -eq "localhost/mssql" -and $parameters.CompanyLinkCount -eq -1 } `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                { Update-SiteMetadata -DatabaseName "TenantSiteMetadataSync" -DatabaseServer "localhost/mssql" -SiteUrl "https://contoso.sharepoint.com" -CompanyLinkCount -1 } | Should -Throw -ExpectedMessage "Cannot validate argument on parameter 'CompanyLinkCount'. The argument `"-1`" cannot be validated because its value is not greater than or equal to zero."
            }    

            It "should update the site's ConditionalAccessPolicy value" {

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ParameterFilter { $DatabaseName -eq "TenantSiteMetadataSync" -and $DatabaseServer -eq "localhost/mssql" -and $SiteUrl -eq "https://contoso.sharepoint.com" -and $parameters.ConditionalAccessPolicy -eq 1 } `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                Update-SiteMetadata -DatabaseName "TenantSiteMetadataSync" -DatabaseServer "localhost/mssql" -SiteUrl "https://contoso.sharepoint.com" -ConditionalAccessPolicy 1
        
                Should -InvokeVerifiable
            }

            It "should throw because of an invalid ConditionalAccessPolicy value" {

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ParameterFilter { $DatabaseName -eq "TenantSiteMetadataSync" -and $DatabaseServer -eq "localhost/mssql" -and $SiteUrl -eq "https://contoso.sharepoint.com" -and $parameters.ConditionalAccessPolicy -eq 100 } `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                { Update-SiteMetadata -DatabaseName "TenantSiteMetadataSync" -DatabaseServer "localhost/mssql" -SiteUrl "https://contoso.sharepoint.com" -ConditionalAccessPolicy 100 } | Should -Throw -ExpectedMessage "Cannot validate argument on parameter 'ConditionalAccessPolicy'. The 100 argument is greater than the maximum allowed range of 3. Supply an argument that is less than or equal to 3 and then try the command again."
            }

            It "should update the site's CreatedBy value" {

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ParameterFilter { $DatabaseName -eq "TenantSiteMetadataSync" -and $DatabaseServer -eq "localhost/mssql" -and $SiteUrl -eq "https://contoso.sharepoint.com" -and $parameters.CreatedBy -eq 'contoso\johndoe' } `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                Update-SiteMetadata -DatabaseName "TenantSiteMetadataSync" -DatabaseServer "localhost/mssql" -SiteUrl "https://contoso.sharepoint.com" -CreatedBy 'contoso\johndoe'
        
                Should -InvokeVerifiable
            }

            It "should update the site's DeletedBy value" {

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ParameterFilter { $DatabaseName -eq "TenantSiteMetadataSync" -and $DatabaseServer -eq "localhost/mssql" -and $SiteUrl -eq "https://contoso.sharepoint.com" -and $parameters.DeletedBy -eq 'contoso\johndoe' } `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                Update-SiteMetadata -DatabaseName "TenantSiteMetadataSync" -DatabaseServer "localhost/mssql" -SiteUrl "https://contoso.sharepoint.com" -DeletedBy 'contoso\johndoe'
        
                Should -InvokeVerifiable
            }

            It "should update the site's DenyAddAndCustomizePages value" {

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ParameterFilter { $DatabaseName -eq "TenantSiteMetadataSync" -and $DatabaseServer -eq "localhost/mssql" -and $SiteUrl -eq "https://contoso.sharepoint.com" -and $parameters.DenyAddAndCustomizePages -eq 'Enabled' } `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                Update-SiteMetadata -DatabaseName "TenantSiteMetadataSync" -DatabaseServer "localhost/mssql" -SiteUrl "https://contoso.sharepoint.com" -DenyAddAndCustomizePages 'Enabled'
        
                Should -InvokeVerifiable
            }

            It "should update the site's FileViewedOrEdited value" {

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ParameterFilter { $DatabaseName -eq "TenantSiteMetadataSync" -and $DatabaseServer -eq "localhost/mssql" -and $SiteUrl -eq "https://contoso.sharepoint.com" -and $parameters.FileViewedOrEdited -eq 100 } `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                Update-SiteMetadata -DatabaseName "TenantSiteMetadataSync" -DatabaseServer "localhost/mssql" -SiteUrl "https://contoso.sharepoint.com" -FileViewedOrEdited 100
        
                Should -InvokeVerifiable
            }

            It "should throw trying to update the group's FileViewedOrEdited value to a negative number" {

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ParameterFilter { $DatabaseName -eq "TenantSiteMetadataSync" -and $DatabaseServer -eq "localhost/mssql" -and $parameters.FileViewedOrEdited -eq -1 } `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                {  Update-SiteMetadata -DatabaseName "TenantSiteMetadataSync" -DatabaseServer "localhost/mssql" -SiteUrl "https://contoso.sharepoint.com" -FileViewedOrEdited  -1 } | Should -Throw -ExpectedMessage "Cannot validate argument on parameter 'FileViewedOrEdited'. The argument `"-1`" cannot be validated because its value is not greater than or equal to zero."
            } 

            It "should update the site's GroupId value" {

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ParameterFilter { $DatabaseName -eq "TenantSiteMetadataSync" -and $DatabaseServer -eq "localhost/mssql" -and $SiteUrl -eq "https://contoso.sharepoint.com" -and $parameters.GroupId -eq '397b1a61-e130-4fca-b868-de8ae8d5185c' } `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                Update-SiteMetadata -DatabaseName "TenantSiteMetadataSync" -DatabaseServer "localhost/mssql" -SiteUrl "https://contoso.sharepoint.com" -GroupId '397b1a61-e130-4fca-b868-de8ae8d5185c'
        
                Should -InvokeVerifiable
            }

            It "should update the site's GuestLinkCount value" {

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ParameterFilter { $DatabaseName -eq "TenantSiteMetadataSync" -and $DatabaseServer -eq "localhost/mssql" -and $SiteUrl -eq "https://contoso.sharepoint.com" -and $parameters.GuestLinkCount -eq 100 } `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                Update-SiteMetadata -DatabaseName "TenantSiteMetadataSync" -DatabaseServer "localhost/mssql" -SiteUrl "https://contoso.sharepoint.com" -GuestLinkCount 100
        
                Should -InvokeVerifiable
            }

            It "should throw trying to update the group's GuestLinkCount value to a negative number" {

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ParameterFilter { $DatabaseName -eq "TenantSiteMetadataSync" -and $DatabaseServer -eq "localhost/mssql" -and $parameters.GuestLinkCount -eq -1 } `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                {  Update-SiteMetadata -DatabaseName "TenantSiteMetadataSync" -DatabaseServer "localhost/mssql" -SiteUrl "https://contoso.sharepoint.com" -GuestLinkCount  -1 } | Should -Throw -ExpectedMessage "Cannot validate argument on parameter 'GuestLinkCount'. The argument `"-1`" cannot be validated because its value is not greater than or equal to zero."
            } 

            It "should update the site's HubSiteId value" {

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ParameterFilter { $DatabaseName -eq "TenantSiteMetadataSync" -and $DatabaseServer -eq "localhost/mssql" -and $SiteUrl -eq "https://contoso.sharepoint.com" -and $parameters.HubSiteId -eq '3e866a2b-ae42-41a4-b90f-25e4213ba8a4' } `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                Update-SiteMetadata -DatabaseName "TenantSiteMetadataSync" -DatabaseServer "localhost/mssql" -SiteUrl "https://contoso.sharepoint.com" -HubSiteId '3e866a2b-ae42-41a4-b90f-25e4213ba8a4'
        
                Should -InvokeVerifiable
            }

            It "should update the site's Initiator value" {

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ParameterFilter { $DatabaseName -eq "TenantSiteMetadataSync" -and $DatabaseServer -eq "localhost/mssql" -and $SiteUrl -eq "https://contoso.sharepoint.com" -and $parameters.Initiator -eq 'john.doe@contoso.com' } `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                Update-SiteMetadata -DatabaseName "TenantSiteMetadataSync" -DatabaseServer "localhost/mssql" -SiteUrl "https://contoso.sharepoint.com" -Initiator 'john.doe@contoso.com'
        
                Should -InvokeVerifiable
            }

            It "should update the site's IsGroupConnected value" {

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ParameterFilter { $DatabaseName -eq "TenantSiteMetadataSync" -and $DatabaseServer -eq "localhost/mssql" -and $SiteUrl -eq "https://contoso.sharepoint.com" -and $parameters.IsGroupConnected -eq $true } `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                Update-SiteMetadata -DatabaseName "TenantSiteMetadataSync" -DatabaseServer "localhost/mssql" -SiteUrl "https://contoso.sharepoint.com" -IsGroupConnected $true
        
                Should -InvokeVerifiable
            }

            It "should update the site's IsTeamsConnected value" {

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ParameterFilter { $DatabaseName -eq "TenantSiteMetadataSync" -and $DatabaseServer -eq "localhost/mssql" -and $SiteUrl -eq "https://contoso.sharepoint.com" -and $parameters.IsTeamsConnected -eq $true } `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                Update-SiteMetadata -DatabaseName "TenantSiteMetadataSync" -DatabaseServer "localhost/mssql" -SiteUrl "https://contoso.sharepoint.com" -IsTeamsConnected $true
        
                Should -InvokeVerifiable
            }

            It "should update the site's LastActivityOn value" {

                $timestamp = Get-Date

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ParameterFilter { $DatabaseName -eq "TenantSiteMetadataSync" -and $DatabaseServer -eq "localhost/mssql" -and $SiteUrl -eq "https://contoso.sharepoint.com" -and $parameters.LastActivityOn -eq $timestamp } `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                Update-SiteMetadata -DatabaseName "TenantSiteMetadataSync" -DatabaseServer "localhost/mssql" -SiteUrl "https://contoso.sharepoint.com" -LastActivityOn $timestamp
        
                Should -InvokeVerifiable
            }

            It "should update the site's LastItemModifiedDate value" {

                $timestamp = Get-Date

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ParameterFilter { $DatabaseName -eq "TenantSiteMetadataSync" -and $DatabaseServer -eq "localhost/mssql" -and $SiteUrl -eq "https://contoso.sharepoint.com" -and $parameters.LastItemModifiedDate -eq $timestamp } `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                Update-SiteMetadata -DatabaseName "TenantSiteMetadataSync" -DatabaseServer "localhost/mssql" -SiteUrl "https://contoso.sharepoint.com" -LastItemModifiedDate $timestamp
        
                Should -InvokeVerifiable
            }

            It "should update the site's LockState value" {

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ParameterFilter { $DatabaseName -eq "TenantSiteMetadataSync" -and $DatabaseServer -eq "localhost/mssql" -and $SiteUrl -eq "https://contoso.sharepoint.com" -and $parameters.LockState -eq "NoAccess" } `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                Update-SiteMetadata -DatabaseName "TenantSiteMetadataSync" -DatabaseServer "localhost/mssql" -SiteUrl "https://contoso.sharepoint.com" -LockState "NoAccess"
        
                Should -InvokeVerifiable
            }

            It "should update the site's MemberLinkCount value" {

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ParameterFilter { $DatabaseName -eq "TenantSiteMetadataSync" -and $DatabaseServer -eq "localhost/mssql" -and $SiteUrl -eq "https://contoso.sharepoint.com" -and $parameters.MemberLinkCount -eq 100 } `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                Update-SiteMetadata -DatabaseName "TenantSiteMetadataSync" -DatabaseServer "localhost/mssql" -SiteUrl "https://contoso.sharepoint.com" -MemberLinkCount 100
        
                Should -InvokeVerifiable
            }

            It "should throw trying to update the group's MemberLinkCount value to a negative number" {

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ParameterFilter { $DatabaseName -eq "TenantSiteMetadataSync" -and $DatabaseServer -eq "localhost/mssql" -and $parameters.MemberLinkCount -eq -1 } `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                {  Update-SiteMetadata -DatabaseName "TenantSiteMetadataSync" -DatabaseServer "localhost/mssql" -SiteUrl "https://contoso.sharepoint.com" -MemberLinkCount  -1 } | Should -Throw -ExpectedMessage "Cannot validate argument on parameter 'MemberLinkCount'. The argument `"-1`" cannot be validated because its value is not greater than or equal to zero."
            } 

            It "should update the site's NumOfFiles value" {

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ParameterFilter { $DatabaseName -eq "TenantSiteMetadataSync" -and $DatabaseServer -eq "localhost/mssql" -and $SiteUrl -eq "https://contoso.sharepoint.com" -and $parameters.NumOfFiles -eq 100 } `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                Update-SiteMetadata -DatabaseName "TenantSiteMetadataSync" -DatabaseServer "localhost/mssql" -SiteUrl "https://contoso.sharepoint.com" -NumOfFiles 100
        
                Should -InvokeVerifiable
            }

            It "should throw trying to update the group's NumOfFiles value to a negative number" {

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ParameterFilter { $DatabaseName -eq "TenantSiteMetadataSync" -and $DatabaseServer -eq "localhost/mssql" -and $parameters.NumOfFiles -eq -1 } `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                {  Update-SiteMetadata -DatabaseName "TenantSiteMetadataSync" -DatabaseServer "localhost/mssql" -SiteUrl "https://contoso.sharepoint.com" -NumOfFiles  -1 } | Should -Throw -ExpectedMessage "Cannot validate argument on parameter 'NumOfFiles'. The argument `"-1`" cannot be validated because its value is not greater than or equal to zero."
            } 

            It "should update the site's PagesVisited value" {

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ParameterFilter { $DatabaseName -eq "TenantSiteMetadataSync" -and $DatabaseServer -eq "localhost/mssql" -and $SiteUrl -eq "https://contoso.sharepoint.com" -and $parameters.PagesVisited -eq 100 } `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                Update-SiteMetadata -DatabaseName "TenantSiteMetadataSync" -DatabaseServer "localhost/mssql" -SiteUrl "https://contoso.sharepoint.com" -PagesVisited 100
        
                Should -InvokeVerifiable
            }

            It "should throw trying to update the group's PagesVisited value to a negative number" {

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ParameterFilter { $DatabaseName -eq "TenantSiteMetadataSync" -and $DatabaseServer -eq "localhost/mssql" -and $parameters.PagesVisited -eq -1 } `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                {  Update-SiteMetadata -DatabaseName "TenantSiteMetadataSync" -DatabaseServer "localhost/mssql" -SiteUrl "https://contoso.sharepoint.com" -PagesVisited  -1 } | Should -Throw -ExpectedMessage "Cannot validate argument on parameter 'PagesVisited'. The argument `"-1`" cannot be validated because its value is not greater than or equal to zero."
            } 

            It "should update the site's PageViews value" {

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ParameterFilter { $DatabaseName -eq "TenantSiteMetadataSync" -and $DatabaseServer -eq "localhost/mssql" -and $SiteUrl -eq "https://contoso.sharepoint.com" -and $parameters.PageViews -eq 100 } `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                Update-SiteMetadata -DatabaseName "TenantSiteMetadataSync" -DatabaseServer "localhost/mssql" -SiteUrl "https://contoso.sharepoint.com" -PageViews 100
        
                Should -InvokeVerifiable
            }

            It "should throw trying to update the group's PageViews value to a negative number" {

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ParameterFilter { $DatabaseName -eq "TenantSiteMetadataSync" -and $DatabaseServer -eq "localhost/mssql" -and $parameters.PageViews -eq -1 } `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                {  Update-SiteMetadata -DatabaseName "TenantSiteMetadataSync" -DatabaseServer "localhost/mssql" -SiteUrl "https://contoso.sharepoint.com" -PageViews  -1 } | Should -Throw -ExpectedMessage "Cannot validate argument on parameter 'PageViews'. The argument `"-1`" cannot be validated because its value is not greater than or equal to zero."
            } 

            It "should update the site's PWAEnabled value" {

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ParameterFilter { $DatabaseName -eq "TenantSiteMetadataSync" -and $DatabaseServer -eq "localhost/mssql" -and $SiteUrl -eq "https://contoso.sharepoint.com" -and $parameters.PWAEnabled -eq $true } `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                Update-SiteMetadata -DatabaseName "TenantSiteMetadataSync" -DatabaseServer "localhost/mssql" -SiteUrl "https://contoso.sharepoint.com" -PWAEnabled $true
        
                Should -InvokeVerifiable
            }

            It "should update the site's RelatedGroupId value" {

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ParameterFilter { $DatabaseName -eq "TenantSiteMetadataSync" -and $DatabaseServer -eq "localhost/mssql" -and $SiteUrl -eq "https://contoso.sharepoint.com" -and $parameters.RelatedGroupId -eq 'a3bb53d4-cb0d-4a4a-8df2-2712525b42fe' } `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                Update-SiteMetadata -DatabaseName "TenantSiteMetadataSync" -DatabaseServer "localhost/mssql" -SiteUrl "https://contoso.sharepoint.com" -RelatedGroupId 'a3bb53d4-cb0d-4a4a-8df2-2712525b42fe'
        
                Should -InvokeVerifiable
            }

            It "should update the site's SensitivityLabel value" {

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ParameterFilter { $DatabaseName -eq "TenantSiteMetadataSync" -and $DatabaseServer -eq "localhost/mssql" -and $SiteUrl -eq "https://contoso.sharepoint.com" -and $parameters.SensitivityLabel -eq '5d427e73-435e-4017-b368-fef75d7eb448' } `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                Update-SiteMetadata -DatabaseName "TenantSiteMetadataSync" -DatabaseServer "localhost/mssql" -SiteUrl "https://contoso.sharepoint.com" -SensitivityLabel '5d427e73-435e-4017-b368-fef75d7eb448'
        
                Should -InvokeVerifiable
            }        

            It "should update the site's SharingCapability value" {

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ParameterFilter { $DatabaseName -eq "TenantSiteMetadataSync" -and $DatabaseServer -eq "localhost/mssql" -and $SiteUrl -eq "https://contoso.sharepoint.com" -and $parameters.SharingCapability -eq 'ExternalUserSharingOnly' } `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                Update-SiteMetadata -DatabaseName "TenantSiteMetadataSync" -DatabaseServer "localhost/mssql" -SiteUrl "https://contoso.sharepoint.com" -SharingCapability 'ExternalUserSharingOnly'
        
                Should -InvokeVerifiable
            }        

            It "should update the site's SiteCreationSource value" {

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ParameterFilter { $DatabaseName -eq "TenantSiteMetadataSync" -and $DatabaseServer -eq "localhost/mssql" -and $SiteUrl -eq "https://contoso.sharepoint.com" -and $parameters.SiteCreationSource -eq '3c25b599-7b5f-43b4-8e70-63f23981c4d8' } `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                Update-SiteMetadata -DatabaseName "TenantSiteMetadataSync" -DatabaseServer "localhost/mssql" -SiteUrl "https://contoso.sharepoint.com" -SiteCreationSource '3c25b599-7b5f-43b4-8e70-63f23981c4d8'
        
                Should -InvokeVerifiable
            }        

            It "should update the site's SiteId value" {

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ParameterFilter { $DatabaseName -eq "TenantSiteMetadataSync" -and $DatabaseServer -eq "localhost/mssql" -and $SiteUrl -eq "https://contoso.sharepoint.com" -and $parameters.SiteId -eq 'eba50c45-7080-432e-b105-0c5e9eae1b4a' } `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                Update-SiteMetadata -DatabaseName "TenantSiteMetadataSync" -DatabaseServer "localhost/mssql" -SiteUrl "https://contoso.sharepoint.com" -SiteId 'eba50c45-7080-432e-b105-0c5e9eae1b4a'
        
                Should -InvokeVerifiable
            }        

            It "should update the site's SiteOwnerEmail value" {

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ParameterFilter { $DatabaseName -eq "TenantSiteMetadataSync" -and $DatabaseServer -eq "localhost/mssql" -and $SiteUrl -eq "https://contoso.sharepoint.com" -and $parameters.SiteOwnerEmail -eq 'john.doe@contoso.com' } `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                Update-SiteMetadata -DatabaseName "TenantSiteMetadataSync" -DatabaseServer "localhost/mssql" -SiteUrl "https://contoso.sharepoint.com" -SiteOwnerEmail 'john.doe@contoso.com'
        
                Should -InvokeVerifiable
            }        

            It "should update the site's SiteOwnerName value" {

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ParameterFilter { $DatabaseName -eq "TenantSiteMetadataSync" -and $DatabaseServer -eq "localhost/mssql" -and $SiteUrl -eq "https://contoso.sharepoint.com" -and $parameters.SiteOwnerName -eq 'john.doe@contoso.com' } `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                Update-SiteMetadata -DatabaseName "TenantSiteMetadataSync" -DatabaseServer "localhost/mssql" -SiteUrl "https://contoso.sharepoint.com" -SiteOwnerName 'john.doe@contoso.com'
        
                Should -InvokeVerifiable
            }        

            It "should update the site's State value" {

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ParameterFilter { $DatabaseName -eq "TenantSiteMetadataSync" -and $DatabaseServer -eq "localhost/mssql" -and $SiteUrl -eq "https://contoso.sharepoint.com" -and $parameters.State -eq -1 } `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                Update-SiteMetadata -DatabaseName "TenantSiteMetadataSync" -DatabaseServer "localhost/mssql" -SiteUrl "https://contoso.sharepoint.com" -State -1
        
                Should -InvokeVerifiable
            }        

            It "should throw trying to update the sites's State value to a negative number" {

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ParameterFilter { $DatabaseName -eq "TenantSiteMetadataSync" -and $DatabaseServer -eq "localhost/mssql" -and $parameters.State -eq -100 } `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                {  Update-SiteMetadata -DatabaseName "TenantSiteMetadataSync" -DatabaseServer "localhost/mssql" -SiteUrl "https://contoso.sharepoint.com" -State -100 } | Should -Throw -ExpectedMessage "Cannot validate argument on parameter 'State'. The -100 argument is less than the minimum allowed range of -1. Supply an argument that is greater than or equal to -1 and then try the command again."
            } 

            It "should update the site's StorageQuota value" {

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ParameterFilter { $DatabaseName -eq "TenantSiteMetadataSync" -and $DatabaseServer -eq "localhost/mssql" -and $SiteUrl -eq "https://contoso.sharepoint.com" -and $parameters.StorageQuota -eq 1GB } `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                Update-SiteMetadata -DatabaseName "TenantSiteMetadataSync" -DatabaseServer "localhost/mssql" -SiteUrl "https://contoso.sharepoint.com" -StorageQuota 1GB
        
                Should -InvokeVerifiable
            }        

            It "should update the site's StorageUsed value" {

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ParameterFilter { $DatabaseName -eq "TenantSiteMetadataSync" -and $DatabaseServer -eq "localhost/mssql" -and $SiteUrl -eq "https://contoso.sharepoint.com" -and $parameters.StorageUsed -eq 1GB } `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                Update-SiteMetadata -DatabaseName "TenantSiteMetadataSync" -DatabaseServer "localhost/mssql" -SiteUrl "https://contoso.sharepoint.com" -StorageUsed 1GB
        
                Should -InvokeVerifiable
            }        

            It "should update the site's TemplateName value" {

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ParameterFilter { $DatabaseName -eq "TenantSiteMetadataSync" -and $DatabaseServer -eq "localhost/mssql" -and $SiteUrl -eq "https://contoso.sharepoint.com" -and $parameters.TemplateName -eq 'GROUP#0' } `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                Update-SiteMetadata -DatabaseName "TenantSiteMetadataSync" -DatabaseServer "localhost/mssql" -SiteUrl "https://contoso.sharepoint.com" -TemplateName 'GROUP#0'
        
                Should -InvokeVerifiable
            }        

            It "should update the site's TimeCreated value" {

                $timestamp = Get-Date

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ParameterFilter { $DatabaseName -eq "TenantSiteMetadataSync" -and $DatabaseServer -eq "localhost/mssql" -and $SiteUrl -eq "https://contoso.sharepoint.com" -and $parameters.TimeCreated -eq $timestamp } `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                Update-SiteMetadata -DatabaseName "TenantSiteMetadataSync" -DatabaseServer "localhost/mssql" -SiteUrl "https://contoso.sharepoint.com" -TimeCreated $timestamp
        
                Should -InvokeVerifiable
            }        

            It "should update the site's TimeDeleted value" {

                $timestamp = Get-Date

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ParameterFilter { $DatabaseName -eq "TenantSiteMetadataSync" -and $DatabaseServer -eq "localhost/mssql" -and $SiteUrl -eq "https://contoso.sharepoint.com" -and $parameters.TimeDeleted -eq $timestamp } `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                Update-SiteMetadata -DatabaseName "TenantSiteMetadataSync" -DatabaseServer "localhost/mssql" -SiteUrl "https://contoso.sharepoint.com" -TimeDeleted $timestamp
        
                Should -InvokeVerifiable
            }        

            It "should update the site's Title value" {

                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ParameterFilter { $DatabaseName -eq "TenantSiteMetadataSync" -and $DatabaseServer -eq "localhost/mssql" -and $SiteUrl -eq "https://contoso.sharepoint.com" -and $parameters.Title -eq 'Team Site' } `
                    -ModuleName "TenantSiteMetadataSync" `
                    -Verifiable

                Update-SiteMetadata -DatabaseName "TenantSiteMetadataSync" -DatabaseServer "localhost/mssql" -SiteUrl "https://contoso.sharepoint.com" -Title 'Team Site'
        
                Should -InvokeVerifiable
            }        
        }
    }
}