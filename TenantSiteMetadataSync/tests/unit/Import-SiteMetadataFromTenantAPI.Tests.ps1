Set-StrictMode -Off

Describe "Testing Import-SiteMetadataFromTenantAPI cmdlet" -Tag "UnitTest" {

    BeforeAll {

        Remove-Module -Name "TenantSiteMetadataSync" -Force -ErrorAction Ignore
        Import-Module -Name "$PSScriptRoot\..\..\TenantSiteMetadataSync.psd1" -Force

        . "$PSScriptRoot\..\mocks\New-MockDatabaseConnectionInformation.ps1"
        . "$PSScriptRoot\..\mocks\New-MockTenantConnectionInformation.ps1"
        . "$PSScriptRoot\..\mocks\New-MockTenantSiteData.ps1"
        . "$PSScriptRoot\ConvertTo-ScriptBlock.ps1"

        function Connect-PnPOnline { param( $Url, $ClientId, $Thumbprint, $Tenant, $ReturnConnection )  }
        function Disconnect-PnPOnline { param( $Connection ) }
        function Get-PnPTenantSite { param($Connection) }
        function Get-PnPContext { }
        function Write-PSFMessage { param( $Level, $Message, $Exception )  }

        # PnP.PowerShell Mocks
        Mock -CommandName "Connect-PnPOnline"    -Verifiable -ModuleName "TenantSiteMetadataSync" -MockWith { return 1 }
        Mock -CommandName "Disconnect-PnPOnline" -Verifiable -ModuleName "TenantSiteMetadataSync" -RemoveParameterType "Connection"
        Mock -CommandName "Get-PnPContext"       -Verifiable -ModuleName "TenantSiteMetadataSync"

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


    It "should read the basic SPO site info from the API for <Quantity> sites with <_.Templates.Count> templates with DetailedImport being <DetailedImport>" -Foreach @(
        @{ Quantity = 0; IncludeOneDriveSites = $false; Templates = @() }
        @{ Quantity = 1; IncludeOneDriveSites = $false; Templates = @() }
        @{ Quantity = 2; IncludeOneDriveSites = $false; Templates = @() }

        @{ Quantity = 0; IncludeOneDriveSites = $false; Templates = @('APPCATALOG#0', 'BICenterSite#0', 'EDISC#0', 'EHS#1', 'PWA#0', 'SPSMSITEHOST#0', 'SRCHCEN#0', 'BLANKINTERNET#0', 'STS#-1', 'TEAMCHANNEL#0', 'RedirectSite#0', 'SITEPAGEPUBLISHING#0', 'STS#3', 'GROUP#0', 'STS#0') }
        @{ Quantity = 1; IncludeOneDriveSites = $false; Templates = @('APPCATALOG#0', 'BICenterSite#0', 'EDISC#0', 'EHS#1', 'PWA#0', 'SPSMSITEHOST#0', 'SRCHCEN#0', 'BLANKINTERNET#0', 'STS#-1', 'TEAMCHANNEL#0', 'RedirectSite#0', 'SITEPAGEPUBLISHING#0', 'STS#3', 'GROUP#0', 'STS#0') }
        @{ Quantity = 2; IncludeOneDriveSites = $false; Templates = @('APPCATALOG#0', 'BICenterSite#0', 'EDISC#0', 'EHS#1', 'PWA#0', 'SPSMSITEHOST#0', 'SRCHCEN#0', 'BLANKINTERNET#0', 'STS#-1', 'TEAMCHANNEL#0', 'RedirectSite#0', 'SITEPAGEPUBLISHING#0', 'STS#3', 'GROUP#0', 'STS#0') }

        @{ Quantity = 0; IncludeOneDriveSites = $true; Templates = @() }
        @{ Quantity = 1; IncludeOneDriveSites = $true; Templates = @() }
        @{ Quantity = 2; IncludeOneDriveSites = $true; Templates = @() }

        @{ Quantity = 0; IncludeOneDriveSites = $true; Templates = @('APPCATALOG#0', 'BICenterSite#0', 'EDISC#0', 'EHS#1', 'PWA#0', 'SPSMSITEHOST#0', 'SRCHCEN#0', 'BLANKINTERNET#0', 'STS#-1', 'TEAMCHANNEL#0', 'RedirectSite#0', 'SITEPAGEPUBLISHING#0', 'STS#3', 'GROUP#0', 'STS#0') }
        @{ Quantity = 1; IncludeOneDriveSites = $true; Templates = @('APPCATALOG#0', 'BICenterSite#0', 'EDISC#0', 'EHS#1', 'PWA#0', 'SPSMSITEHOST#0', 'SRCHCEN#0', 'BLANKINTERNET#0', 'STS#-1', 'TEAMCHANNEL#0', 'RedirectSite#0', 'SITEPAGEPUBLISHING#0', 'STS#3', 'GROUP#0', 'STS#0') }
        @{ Quantity = 2; IncludeOneDriveSites = $true; Templates = @('APPCATALOG#0', 'BICenterSite#0', 'EDISC#0', 'EHS#1', 'PWA#0', 'SPSMSITEHOST#0', 'SRCHCEN#0', 'BLANKINTERNET#0', 'STS#-1', 'TEAMCHANNEL#0', 'RedirectSite#0', 'SITEPAGEPUBLISHING#0', 'STS#3', 'GROUP#0', 'STS#0') }
        ) {

        $mockSites = New-MockTenantSiteData -Quantity $Quantity
    
        # build mock for Get-PnPTenantSite when no templates provided
        if( $Templates.Count -eq 0)
        {
            if( $IncludeOneDriveSites )
            {
                Mock `
                    -CommandName "Get-PnPTenantSite" `
                    -ModuleName "TenantSiteMetadataSync" `
                    -RemoveParameterType "Connection" `
                    -ParameterFilter { $IncludeOneDriveSites -eq $true } `
                    -MockWith { $mockSites } `
                    -Verifiable
            }
            else
            {
                Mock `
                    -CommandName "Get-PnPTenantSite" `
                    -ModuleName "TenantSiteMetadataSync" `
                    -RemoveParameterType "Connection" `
                    -ParameterFilter { $IncludeOneDriveSites -eq $false } `
                    -MockWith { $mockSites } `
                    -Verifiable
            }
        }
        else # build mock for Get-PnPTenantSite for each template provided 
        {
            foreach( $t in $Templates )
            {
                $filter = '$Template -eq "{0}"' -f $t

                Mock `
                    -CommandName "Get-PnPTenantSite" `
                    -ModuleName "TenantSiteMetadataSync" `
                    -RemoveParameterType "Connection" `
                    -ParameterFilter ([ScriptBlock]::Create( $filter )) `
                    -MockWith { $mockSites } `
                    -Verifiable
            }
        }

        # build a mock for Update-SiteMetadata for each mock site
        foreach( $mockSite in $mockSites )
        {
            $parameterFilter  = ''
            $parameterFilter += '$DenyAddAndCustomizePages -eq "{0}"'         -f $mockSite.DenyAddAndCustomizePages
            $parameterFilter += ' -and $GroupId.ToString() -eq "{0}"'         -f $mockSite.GroupId
            $parameterFilter += ' -and $HubSiteId.ToString() -eq "{0}"'       -f $mockSite.HubSiteId
            $parameterFilter += ' -and $LastItemModifiedDate.Ticks -eq {0}'   -f $mockSite.LastContentModifiedDate.Ticks
            $parameterFilter += ' -and $LockState -eq "{0}"'                  -f $mockSite.LockState
            $parameterFilter += ' -and $PWAEnabled -eq [bool]::Parse("{0}")'  -f ($null -ne $mockSite.PWAEnabled -and $mockSite.PWAEnabled -eq "Enabled") 
            $parameterFilter += ' -and $SiteUrl -eq "{0}"'                    -f $mockSite.Url
            $parameterFilter += ' -and $State -eq {0}'                        -f $mockSite.State
            $parameterFilter += ' -and $StorageQuota -eq {0}'                 -f ($mockSite.StorageQuota * 1MB)
            $parameterFilter += ' -and $StorageUsed -eq {0}'                  -f ($mockSite.StorageUsageCurrent * 1MB)
            $parameterFilter += ' -and $TemplateName -eq "{0}"'               -f $mockSite.Template
            $parameterFilter += ' -and $Title -eq "{0}"'                      -f $mockSite.Title
            $parameterFilter += ' -and $SharingCapability -eq "{0}"'          -f $mockSite.SharingCapability
            
            $parameterFilter = $parameterFilter | ConvertTo-ScriptBlock

            Mock `
                -CommandName "Update-SiteMetadata" `
                -ModuleName "TenantSiteMetadataSync" `
                -ParameterFilter $parameterFilter `
                -Verifiable
        }

        if( $Templates.Count -eq 0 )
        {
            Import-SiteMetadataFromTenantAPI `
                -IncludeOneDriveSites:$IncludeOneDriveSites `
                -DetailedImport:$DetailedImport `
                -ClientId   $mockTenantConnection.ClientId `
                -Thumbprint $mockTenantConnection.Thumbprint `
                -Tenant     $mockTenantConnection.TenantName `
                -DatabaseConnectionInformation $mockDatabaseConnectionInfo
        }
        else
        {
            foreach( $temp in $Templates )
            {
                Import-SiteMetadataFromTenantAPI `
                    -IncludeOneDriveSites:$IncludeOneDriveSites `
                    -DetailedImport:$DetailedImport `
                    -ClientId   $mockTenantConnection.ClientId `
                    -Thumbprint $mockTenantConnection.Thumbprint `
                    -Tenant     $mockTenantConnection.TenantName `
                    -Template   $temp `
                    -DatabaseConnectionInformation $mockDatabaseConnectionInfo `
            }
        }

        Should -InvokeVerifiable
    }

    <#

    It "should import <Quantity> detailed site data" -ForEach @(
        @{ Quantity = 0 }
        @{ Quantity = 1 }
        @{ Quantity = 2 }

    ) {

        function Get-PnPSite { param($Includes) }
        function Get-PnPWeb { param($Includes) }
        function Get-PnPContext { }
        function Get-PnPTenantSite { param($Identity, $Connection) }
        function Set-PnPContext { param($Context) }

        $mockSites = New-MockTenantSiteData -Quantity $Quantity -IncludeDetail

        Mock 
            -CommandName "Connect-PnPOnline" `
            -ModuleName "TenantSiteMetadataSync" `
            -MockWith { return [Guid]::NewGuid().ToString() } `
            -Verifiable 

        Mock `
            -CommandName "Get-PnPContext" `
            -ModuleName "TenantSiteMetadataSync" `
            -MockWith { return 1 } `
            -Verifiable

        Mock 
            -CommandName "Set-PnPContext" `
            -ModuleName "TenantSiteMetadataSync" `
            -RemoveParameterType "Context" `
            -Verifiable

        Mock `
            -CommandName "Get-PnPTenantSite" `
            -ModuleName "TenantSiteMetadataSync" `
            -RemoveParameterType "Connection" `
            -MockWith { $mockSites } `
            -Verifiable

        Mock 
            -CommandName "Copy-Context" `
            -ModuleName "TenantSiteMetadataSync" `
            -Verifiable

        # build a mock for Update-SiteMetadata for each mock site
        foreach( $mockSite in $mockSites )
        {
            $filter  = ''
            $filter += '$DenyAddAndCustomizePages -eq "{0}"'         -f $mockSite.DenyAddAndCustomizePages
            $filter += ' -and $GroupId.ToString() -eq "{0}"'         -f $mockSite.GroupId
            $filter += ' -and $HubSiteId.ToString() -eq "{0}"'       -f $mockSite.HubSiteId
            $filter += ' -and $LastItemModifiedDate.Ticks -eq {0}'   -f $mockSite.LastContentModifiedDate.Ticks
            $filter += ' -and $LockState -eq "{0}"'                  -f $mockSite.LockState
            $filter += ' -and $PWAEnabled -eq [bool]::Parse("{0}")'  -f ($null -ne $mockSite.PWAEnabled -and $mockSite.PWAEnabled -eq "Enabled") 
            $filter += ' -and $SiteUrl -eq "{0}"'                    -f $mockSite.Url
            $filter += ' -and $State -eq {0}'                        -f $mockSite.State
            $filter += ' -and $StorageQuota -eq {0}'                 -f ($mockSite.StorageQuota * 1MB)
            $filter += ' -and $StorageUsed -eq {0}'                  -f ($mockSite.StorageUsageCurrent * 1MB)
            $filter += ' -and $TemplateName -eq "{0}"'               -f $mockSite.Template
            $filter += ' -and $Title -eq "{0}"'                      -f $mockSite.Title
            $filter += ' -and $SharingCapability -eq "{0}"'          -f $mockSite.SharingCapability

            if( $mockSite.LockState -eq "NoAccess")
            {
                Mock `
                    -CommandName "Write-PSFMessage" `
                    -ModuleName "TenantSiteMetadataSync" `
                    -ParameterFilter { $Message -match "Skipping detailed request for site" } `
                    -Verifiable
            }
            else 
            {
                Mock 
                    -CommandName "Get-PnPSite" `
                    -ModuleName "TenantSiteMetadataSync" `
                    -MockWith { $mockSite } `
                    -Verifiable

                Mock 
                    -CommandName "Get-PnPWeb" `
                    -ModuleName "TenantSiteMetadataSync" `
                    -MockWith { $mockSite } `
                    -Verifiable

                $filter += ' -and $ConditionalAccessPolicy -eq {0}' -f $mockSite.ConditionalAccessPolicy
                $filter += ' -and $SiteId.ToString() -eq "{0}"'     -f $mockSite.Id.ToString()
                $filter += ' -and $SiteOwnerEmail -eq "{0}"'        -f $mockSite.OwnerEmail
                $filter += ' -and $SiteOwnerName -eq "{0}"'         -f $mockSite.OwnerName
                $filter += ' -and $TimeCreated.Ticks -eq {0}'       -f $mockSite.Created.Ticks

                if( $mockSite.SensitivityLabel)
                {
                    $filter += ' -and $SensitivityLabel.ToString() -eq "{0}"' -f $mockSite.SensitivityLabel.ToString()
                }

                if( $mockSite.RelatedGroupId)
                {
                    $filter += ' -and $RelatedGroupId.ToString() -eq "{0}"' -f $mockSite.RelatedGroupId.ToString()
                }
            }
        }

        Import-SiteMetadataFromTenantAPI `
            -DetailedImport `
            -ClientId   $mockTenantConnection.ClientId `
            -Thumbprint $mockTenantConnection.Thumbprint `
            -Tenant     $mockTenantConnection.TenantName `
            -DatabaseConnectionInformation $mockDatabaseConnectionInfo
    }

    #>
}