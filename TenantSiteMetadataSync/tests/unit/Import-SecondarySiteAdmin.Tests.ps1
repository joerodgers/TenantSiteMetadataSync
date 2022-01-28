Set-StrictMode -Off

Describe "Testing Import-SecondarySiteAdmin cmdlet" -Tag "UnitTest" {

    BeforeAll {
        Remove-Module -Name "TenantSiteMetadataSync" -Force -ErrorAction Ignore
        Import-Module -Name "$PSScriptRoot\..\..\TenantSiteMetadataSync.psd1" -Force

        . "$PSScriptRoot\..\mocks\New-MockDatabaseConnectionInformation.ps1"
        . "$PSScriptRoot\..\mocks\New-MockDeletedSiteCollection.ps1"
        . "$PSScriptRoot\..\mocks\New-MockTenantConnectionInformation.ps1"
        . "$PSScriptRoot\..\mocks\data\New-MockSiteCollection.ps1"
        . "$PSScriptRoot\..\mocks\data\New-MockSiteOwnerCollection.ps1"
        . "$PSScriptRoot\ConvertTo-ScriptBlock.ps1"
        
        function Connect-PnPOnline { param( $Url, $ClientId, $Thumbprint, $Tenant, $ReturnConnection )  }
        function Disconnect-PnPOnline { param( $Connection ) }
        function Write-PSFMessage { param( $Level, $Message, $Exception )  }

        # PnP.PowerShell Mocks
        Mock -CommandName "Connect-PnPOnline"    -Verifiable -ModuleName "TenantSiteMetadataSync" -MockWith { return 1 }
        Mock -CommandName "Disconnect-PnPOnline" -Verifiable -ModuleName "TenantSiteMetadataSync" -RemoveParameterType "Connection"

        # TenantSiteMetadataSync Mocks
        Mock -CommandName "Start-SyncJobExecution" -Verifiable -ModuleName "TenantSiteMetadataSync" 
        Mock -CommandName "Stop-SyncJobExecution"  -Verifiable -ModuleName "TenantSiteMetadataSync"

        # PSFramework Mocks
        Mock -CommandName "Write-PSFMessage" -ModuleName "TenantSiteMetadataSync" -MockWith { if( $Exception ) { Write-Error "Pester Exception: Message: $Message. Exception: $Exception" } }
        Mock -CommandName "Stop-PSFFunction" -ModuleName "TenantSiteMetadataSync" -MockWith { Write-Error -Message $Message -ErrorRecord $Exception }

        [Diagnostics.CodeAnalysis.SuppressMessageAttribute("UseDeclaredVarsMoreThanAssignments", "")]
        $mockTenantConnection = New-MockTenantConnectionInformation

        [Diagnostics.CodeAnalysis.SuppressMessageAttribute("UseDeclaredVarsMoreThanAssignments", "")]
        $mockDatabaseConnectionInfo = New-MockDatabaseConnectionInformation -DatabaseConnectionType "TrustedConnection"
    }

    It "should update <SiteQuantity> group(s) with <SecondaryAdminQuantity> owners" -ForEach @( 
        @{ SiteQuantity = 0; SecondaryAdminQuantity = 0 },
        @{ SiteQuantity = 1; SecondaryAdminQuantity = 0 },
        @{ SiteQuantity = 1; SecondaryAdminQuantity = 1 }, 
        @{ SiteQuantity = 2; SecondaryAdminQuantity = 0 },
        @{ SiteQuantity = 2; SecondaryAdminQuantity = 1 },
        @{ SiteQuantity = 2; SecondaryAdminQuantity = 2 }
    ) {
        # get mock site dataset
        $mockSites = New-MockSiteCollection -Quantity $SiteQuantity

        # get mock site owner dataset
        $mockSiteOwners = New-MockSiteOwnerCollection -Quantity $SecondaryAdminQuantity

        Mock `
            -CommandName "Get-DataTable" `
            -ModuleName "TenantSiteMetadataSync" `
            -ParameterFilter { $Query -eq "SELECT SiteUrl, SiteId FROM dbo.SitesActive (nolock) WHERE LockState = 'Unlock'" } `
            -MockWith { $mockSites } `
            -Verifiable

        # build dynamic mocks
        foreach( $mockSite in $mockSites )
        {
            $content         = '{{ "secondaryAdministratorsFieldsData":  {{"siteId":  "{0}" }}}}' -f $mockSite.SiteId.ToString()
            $parameterFilter = '$Url -eq "https://{0}-admin.sharepoint.com/_api/SPO.Tenant/GetSiteSecondaryAdministrators" -and $Content -eq ''{1}''' -f $mockTenantConnection.TenantName, $content | ConvertTo-ScriptBlock

            # mock the REST call to pull secondary site admins
            Mock `
                -CommandName "Invoke-PnPSPRestMethod" `
                -ModuleName "TenantSiteMetadataSync" `
                -ParameterFilter $parameterFilter `
                -MockWith { $mockSiteOwners } `
                -Verifiable

            if( $mockSiteOwners.Count -gt 0 )
            {
                $parameterFilter = '$Query -eq "EXEC proc_RemoveSecondarySiteAdminsBySiteId @SiteId = @SiteId" -and $Parameters.SiteId.ToString() -eq "{0}"' -f $mockSite.SiteId.ToString() | ConvertTo-ScriptBlock

                # mock the call to remove all existing site admins 
                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ModuleName "TenantSiteMetadataSync" `
                    -ParameterFilter $parameterFilter `
                    -Verifiable
            }

            foreach( $mockSiteOwner in $mockSiteOwners.value )
            {
                $parameterFilter = '$Query -eq "EXEC proc_AddSecondarySiteAdminBySiteId @SiteId = @SiteId, @LoginName = @LoginName, @IsUserPrincipal = @IsUserPrincipal, @PrincipalDisplayName = @PrincipalDisplayName" -and $Parameters.SiteId.ToString() -eq "{0}" -and $Parameters.LoginName -eq "{1}"' -f $mockSite.SiteId.ToString(), $mockSiteOwner.UserPrincipalName | ConvertTo-ScriptBlock
                
                # mock the call to add each new site admin
                Mock `
                    -CommandName "Invoke-NonQuery" `
                    -ModuleName "TenantSiteMetadataSync" `
                    -ParameterFilter $parameterFilter `
                    -Verifiable
           }

        }

        Import-TSMSSecondarySiteAdmin `
            -ClientId   $mockTenantConnection.ClientId `
            -Tenant     $mockTenantConnection.TenantName `
            -Thumbprint $mockTenantConnection.Thumbprint `
            -DatabaseConnectionInformation $mockDatabaseConnectionInfo -Verbose

        Should -InvokeVerifiable
    }
}