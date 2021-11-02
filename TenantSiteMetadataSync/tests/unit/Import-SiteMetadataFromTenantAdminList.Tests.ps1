Set-StrictMode -Off

Describe "Testing Import-SiteMetadataFromTenantAdminLists cmdlet" -Tag "UnitTest" {

    BeforeAll {

        Remove-Module -Name "TenantSiteMetadataSync" -Force -ErrorAction Ignore
        Import-Module -Name "$PSScriptRoot\..\..\TenantSiteMetadataSync.psd1" -Force

        . "$PSScriptRoot\..\mocks\New-MockDatabaseConnectionInformation.ps1"
        . "$PSScriptRoot\..\mocks\New-MockTenantConnectionInformation.ps1"
        . "$PSScriptRoot\..\mocks\New-MockSiteCreationSource.ps1"
        . "$PSScriptRoot\..\mocks\New-MockAggregatedSiteCollectionListData.ps1"
        . "$PSScriptRoot\ConvertTo-ScriptBlock.ps1"

        function Connect-PnPOnline { param( $Url, $ClientId, $Thumbprint, $Tenant, $ReturnConnection )  }
        function Disconnect-PnPOnline { param( $Connection ) }
        function Get-PnPListitem { param( $List, $PageSize, $Fields, $Connection ) }
        function Invoke-PnPSPRestMethod { param($Method, $Url, $Connection) }
        function Write-PSFMessage { param( $Level, $Message, $Exception )  }

        # PnP.PowerShell Mocks
        Mock -CommandName "Connect-PnPOnline"    -Verifiable -ModuleName "TenantSiteMetadataSync" -MockWith { return 1 }
        Mock -CommandName "Disconnect-PnPOnline" -Verifiable -ModuleName "TenantSiteMetadataSync" -RemoveParameterType "Connection"

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

    It "should read the <AdminList> list and save <ListItemCount> entries to database" -ForEach @(
        @{ AdminList = "AggregatedSiteCollections"; ListItemCount = 0 }
        @{ AdminList = "AggregatedSiteCollections"; ListItemCount = 1 }
        @{ AdminList = "AggregatedSiteCollections"; ListItemCount = 2 }

        @{ AdminList = "AllSitesAggregatedSiteCollections"; ListItemCount = 0 }
        @{ AdminList = "AllSitesAggregatedSiteCollections"; ListItemCount = 1 }
        @{ AdminList = "AllSitesAggregatedSiteCollections"; ListItemCount = 2 }
    ){

        # build a mock collection of mock list items
        $mockListItems = New-MockAggregatedSiteCollectionListData -ListItemCount $ListItemCount -AdminList $AdminList

        Mock `
            -CommandName "Get-PnPListItem" `
            -ModuleName "TenantSiteMetadataSync" `
            -RemoveParameterType "Connection" `
            -MockWith { $mockListItems } `
            -Verifiable

        foreach ( $mockListItem in $mockListItems )
        {
            $parameterFilter = ''

            if( $AdminList -eq "AggregatedSiteCollections" )
            {
                $parameterFilter += '$FileViewedOrEdited -eq {0}'                      -f $mockListItem.FieldValues.FileViewedOrEdited
                $parameterFilter += ' -and $Initiator -eq "{0}"'                       -f $mockListItem.FieldValues.Initiator
                $parameterFilter += ' -and $IsGroupConnected -eq [bool]::Parse("{0}")' -f $mockListItem.FieldValues.IsGroupConnected
                $parameterFilter += ' -and $LastActivityOn.Ticks -eq {0}'              -f $mockListItem.FieldValues.LastActivityOn.Ticks
                $parameterFilter += ' -and $LastItemModifiedDate.Ticks -eq {0}'        -f $mockListItem.FieldValues.LastItemModifiedDate.Ticks
                $parameterFilter += ' -and $NumOfFiles -eq {0}'                        -f $mockListItem.FieldValues.NumOfFiles
                $parameterFilter += ' -and $PagesVisited -eq {0}'                      -f $mockListItem.FieldValues.PagesVisited
                $parameterFilter += ' -and $PageViews -eq {0}'                         -f $mockListItem.FieldValues.PageViews
                $parameterFilter += ' -and $SiteCreationSource -eq "{0}"'              -f $mockListItem.FieldValues.SiteCreationSource
                $parameterFilter += ' -and $SiteId -eq "{0}"'                          -f $mockListItem.FieldValues.SiteId
                $parameterFilter += ' -and $SiteUrl -eq "{0}"'                         -f $mockListItem.FieldValues.SiteUrl
                $parameterFilter += ' -and $StorageUsed -eq {0}'                       -f $mockListItem.FieldValues.StorageUsed
                $parameterFilter += ' -and $IsTeamsConnected -eq [bool]::Parse("{0}")' -f ($mockListItem.FieldValues.SiteFlags -eq 1)

                if( -not [string]::IsNullOrWhiteSpace($mockListItem.FieldValues.State) )
                {
                    $parameterFilter += ' -and $State -eq {0}' -f $mockListItem.FieldValues.State
                }
                else
                {
                    $parameterFilter += ' -and $State -eq -1'
                }

                if( -not [string]::IsNullOrWhiteSpace($mockListItem.FieldValues.SensitivityLabel) )
                {
                    $parameterFilter += ' -and $SensitivityLabel -eq [Guid]::Parse("{0}")' -f $mockListItem.FieldValues.SensitivityLabel
                }
                else
                {
                    $parameterFilter += ' -and $SensitivityLabel -eq $null'
                }

                if( -not [string]::IsNullOrWhiteSpace($mockListItem.FieldValues.GroupId) )
                {
                    $parameterFilter += ' -and $GroupId -eq [Guid]::Parse("{0}")' -f $mockListItem.FieldValues.GroupId
                }
                else
                {
                    $parameterFilter += ' -and $GroupId -eq $null'
                }

                if( -not [string]::IsNullOrWhiteSpace($mockListItem.FieldValues.HubSiteId) )
                {
                    $parameterFilter += ' -and $HubSiteId -eq [Guid]::Parse("{0}")' -f $mockListItem.FieldValues.HubSiteId
                }
                else
                {
                    $parameterFilter += ' -and $HubSiteId -eq $null'
                }
            }
            elseif( $AdminList -eq "AllSitesAggregatedSiteCollections" )
            {
                $parameterFilter += '$ConditionalAccessPolicy -eq {0}' -f $mockListItem.FieldValues.ConditionalAccessPolicy
                $parameterFilter += ' -and $CreatedBy -eq "{0}"'       -f $mockListItem.FieldValues.CreatedBy
                $parameterFilter += ' -and $DeletedBy -eq "{0}"'       -f $mockListItem.FieldValues.DeletedBy
                $parameterFilter += ' -and $SiteOwnerEmail -eq "{0}"'  -f $mockListItem.FieldValues.SiteOwnerEmail
                $parameterFilter += ' -and $SiteOwnerName -eq "{0}"'   -f $mockListItem.FieldValues.SiteOwnerName
                $parameterFilter += ' -and $StorageQuota -eq {0}'      -f $mockListItem.FieldValues.StorageQuota
                $parameterFilter += ' -and $SiteId -eq "{0}"'          -f $mockListItem.FieldValues.SiteId
                $parameterFilter += ' -and $SiteUrl -eq "{0}"'         -f $mockListItem.FieldValues.SiteUrl
                $parameterFilter += ' -and $TemplateName -eq "{0}"'    -f $mockListItem.FieldValues.TemplateName
                $parameterFilter += ' -and $TimeCreated.Ticks -eq {0}' -f $mockListItem.FieldValues.TimeCreated.Ticks
                $parameterFilter += ' -and $Title -eq "{0}"'           -f $mockListItem.FieldValues.Title
            }

            $parameterFilter = $parameterFilter | ConvertTo-ScriptBlock

            Mock `
                -CommandName "Update-SiteMetadata" `
                -ModuleName "TenantSiteMetadataSync" `
                -ParameterFilter $parameterFilter `
                -Verifiable
        }
        
        Import-SiteMetadataFromTenantAdminList `
            -AdminList  $AdminList `
            -ClientId   $mockTenantConnection.ClientId `
            -Thumbprint $mockTenantConnection.Thumbprint `
            -Tenant     $mockTenantConnection.TenantName `
            -DatabaseConnectionInformation $mockDatabaseConnectionInfo

        Should -InvokeVerifiable
    }
}