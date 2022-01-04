Set-StrictMode -Off

Describe "Testing Import-M365GroupOwnershipData cmdlet" -Tag "UnitTest" {

    BeforeAll {

        Remove-Module -Name "TenantSiteMetadataSync" -Force -ErrorAction Ignore
        Import-Module -Name "$PSScriptRoot\..\..\TenantSiteMetadataSync.psd1" -Force

        . "$PSScriptRoot\..\mocks\New-MockDatabaseConnectionInformation.ps1"
        . "$PSScriptRoot\..\mocks\New-MockO365GroupCollection.ps1"
        . "$PSScriptRoot\..\mocks\New-MockO365GroupOwnerCollection.ps1"
        . "$PSScriptRoot\..\mocks\New-MockTenantConnectionInformation.ps1"
        . "$PSScriptRoot\..\mocks\New-MockUsageAccountReportData.ps1"
        . "$PSScriptRoot\..\mocks\New-MockValue.ps1"
        . "$PSScriptRoot\ConvertTo-ScriptBlock.ps1"

        function Connect-PnPOnline { param( $Url, $ClientId, $Thumbprint, $Tenant, $ReturnConnection )  }
        function Disconnect-PnPOnline { param( $Connection ) }
        function Get-PnPTenantDeletedSite { param( $Connection, $IncludePersonalSite, $Limit )  }
        function Get-PnPGraphAccessToken { param($Connection) }
        function Write-PSFMessage { param( $Level, $Message, $Exception )  }
        function Connect-MgGraph { param($ClientId, $CertificateThumbprint, $TenantId) }
        function Disconnect-MgGraph { param() }
        
        # PnP.PowerShell Mocks
        Mock -CommandName "Connect-PnPOnline"       -Verifiable -ModuleName "TenantSiteMetadataSync" -MockWith { return 1 }
        Mock -CommandName "Disconnect-PnPOnline"    -Verifiable -ModuleName "TenantSiteMetadataSync" -RemoveParameterType "Connection"
        Mock -CommandName "Get-PnPGraphAccessToken" -Verifiable -ModuleName "TenantSiteMetadataSync" -RemoveParameterType "Connection" -MockWith { return "mock_access_token" }

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

    BeforeDiscovery {

        [Diagnostics.CodeAnalysis.SuppressMessageAttribute("UseDeclaredVarsMoreThanAssignments", "")]
        $testCases = @(
            @{ Quantity = 0; ReportType = "M365Group"; ApiVersion = "v1.0"; Period = 7   }
            @{ Quantity = 1; ReportType = "M365Group"; ApiVersion = "v1.0"; Period = 7   }
            @{ Quantity = 2; ReportType = "M365Group"; ApiVersion = "v1.0"; Period = 7   }
            @{ Quantity = 0; ReportType = "M365Group"; ApiVersion = "v1.0"; Period = 30  }
            @{ Quantity = 1; ReportType = "M365Group"; ApiVersion = "v1.0"; Period = 30  }
            @{ Quantity = 2; ReportType = "M365Group"; ApiVersion = "v1.0"; Period = 30  }
            @{ Quantity = 0; ReportType = "M365Group"; ApiVersion = "v1.0"; Period = 90  }
            @{ Quantity = 1; ReportType = "M365Group"; ApiVersion = "v1.0"; Period = 90  }
            @{ Quantity = 2; ReportType = "M365Group"; ApiVersion = "v1.0"; Period = 90  }
            @{ Quantity = 0; ReportType = "M365Group"; ApiVersion = "v1.0"; Period = 180 }
            @{ Quantity = 1; ReportType = "M365Group"; ApiVersion = "v1.0"; Period = 180 }
            @{ Quantity = 2; ReportType = "M365Group"; ApiVersion = "v1.0"; Period = 180 }
            @{ Quantity = 0; ReportType = "M365Group"; ApiVersion = "beta"; Period = 7   }
            @{ Quantity = 1; ReportType = "M365Group"; ApiVersion = "beta"; Period = 7   }
            @{ Quantity = 2; ReportType = "M365Group"; ApiVersion = "beta"; Period = 7   }
            @{ Quantity = 0; ReportType = "M365Group"; ApiVersion = "beta"; Period = 30  }
            @{ Quantity = 1; ReportType = "M365Group"; ApiVersion = "beta"; Period = 30  }
            @{ Quantity = 2; ReportType = "M365Group"; ApiVersion = "beta"; Period = 30  }
            @{ Quantity = 0; ReportType = "M365Group"; ApiVersion = "beta"; Period = 90  }
            @{ Quantity = 1; ReportType = "M365Group"; ApiVersion = "beta"; Period = 90  }
            @{ Quantity = 2; ReportType = "M365Group"; ApiVersion = "beta"; Period = 90  }
            @{ Quantity = 0; ReportType = "M365Group"; ApiVersion = "beta"; Period = 180 }
            @{ Quantity = 1; ReportType = "M365Group"; ApiVersion = "beta"; Period = 180 }
            @{ Quantity = 2; ReportType = "M365Group"; ApiVersion = "beta"; Period = 180 }
            @{ Quantity = 0; ReportType = "M365Group"; ApiVersion = "Default"; Period = "Default" }
            @{ Quantity = 1; ReportType = "M365Group"; ApiVersion = "Default"; Period = "Default" }
            @{ Quantity = 2; ReportType = "M365Group"; ApiVersion = "Default"; Period = "Default" }
    
            @{ Quantity = 0; ReportType = "SharePoint"; ApiVersion = "v1.0"; Period = 7   }
            @{ Quantity = 1; ReportType = "SharePoint"; ApiVersion = "v1.0"; Period = 7   }
            @{ Quantity = 2; ReportType = "SharePoint"; ApiVersion = "v1.0"; Period = 7   }
            @{ Quantity = 0; ReportType = "SharePoint"; ApiVersion = "v1.0"; Period = 30  }
            @{ Quantity = 1; ReportType = "SharePoint"; ApiVersion = "v1.0"; Period = 30  }
            @{ Quantity = 2; ReportType = "SharePoint"; ApiVersion = "v1.0"; Period = 30  }
            @{ Quantity = 0; ReportType = "SharePoint"; ApiVersion = "v1.0"; Period = 90  }
            @{ Quantity = 1; ReportType = "SharePoint"; ApiVersion = "v1.0"; Period = 90  }
            @{ Quantity = 2; ReportType = "SharePoint"; ApiVersion = "v1.0"; Period = 90  }
            @{ Quantity = 0; ReportType = "SharePoint"; ApiVersion = "v1.0"; Period = 180 }
            @{ Quantity = 1; ReportType = "SharePoint"; ApiVersion = "v1.0"; Period = 180 }
            @{ Quantity = 2; ReportType = "SharePoint"; ApiVersion = "v1.0"; Period = 180 }
            @{ Quantity = 0; ReportType = "SharePoint"; ApiVersion = "beta"; Period = 7   }
            @{ Quantity = 1; ReportType = "SharePoint"; ApiVersion = "beta"; Period = 7   }
            @{ Quantity = 2; ReportType = "SharePoint"; ApiVersion = "beta"; Period = 7   }
            @{ Quantity = 0; ReportType = "SharePoint"; ApiVersion = "beta"; Period = 30  }
            @{ Quantity = 1; ReportType = "SharePoint"; ApiVersion = "beta"; Period = 30  }
            @{ Quantity = 2; ReportType = "SharePoint"; ApiVersion = "beta"; Period = 30  }
            @{ Quantity = 0; ReportType = "SharePoint"; ApiVersion = "beta"; Period = 90  }
            @{ Quantity = 1; ReportType = "SharePoint"; ApiVersion = "beta"; Period = 90  }
            @{ Quantity = 2; ReportType = "SharePoint"; ApiVersion = "beta"; Period = 90  }
            @{ Quantity = 0; ReportType = "SharePoint"; ApiVersion = "beta"; Period = 180 }
            @{ Quantity = 1; ReportType = "SharePoint"; ApiVersion = "beta"; Period = 180 }
            @{ Quantity = 2; ReportType = "SharePoint"; ApiVersion = "beta"; Period = 180 }
            @{ Quantity = 0; ReportType = "SharePoint"; ApiVersion = "Default"; Period = "Default" }
            @{ Quantity = 1; ReportType = "SharePoint"; ApiVersion = "Default"; Period = "Default" }
            @{ Quantity = 2; ReportType = "SharePoint"; ApiVersion = "Default"; Period = "Default" }
    
            @{ Quantity = 0; ReportType = "OneDrive"; ApiVersion = "v1.0"; Period = 7   }
            @{ Quantity = 1; ReportType = "OneDrive"; ApiVersion = "v1.0"; Period = 7   }
            @{ Quantity = 2; ReportType = "OneDrive"; ApiVersion = "v1.0"; Period = 7   }
            @{ Quantity = 0; ReportType = "OneDrive"; ApiVersion = "v1.0"; Period = 30  }
            @{ Quantity = 1; ReportType = "OneDrive"; ApiVersion = "v1.0"; Period = 30  }
            @{ Quantity = 2; ReportType = "OneDrive"; ApiVersion = "v1.0"; Period = 30  }
            @{ Quantity = 0; ReportType = "OneDrive"; ApiVersion = "v1.0"; Period = 90  }
            @{ Quantity = 1; ReportType = "OneDrive"; ApiVersion = "v1.0"; Period = 90  }
            @{ Quantity = 2; ReportType = "OneDrive"; ApiVersion = "v1.0"; Period = 90  }
            @{ Quantity = 0; ReportType = "OneDrive"; ApiVersion = "v1.0"; Period = 180 }
            @{ Quantity = 1; ReportType = "OneDrive"; ApiVersion = "v1.0"; Period = 180 }
            @{ Quantity = 2; ReportType = "OneDrive"; ApiVersion = "v1.0"; Period = 180 }
            @{ Quantity = 0; ReportType = "OneDrive"; ApiVersion = "beta"; Period = 7   }
            @{ Quantity = 1; ReportType = "OneDrive"; ApiVersion = "beta"; Period = 7   }
            @{ Quantity = 2; ReportType = "OneDrive"; ApiVersion = "beta"; Period = 7   }
            @{ Quantity = 0; ReportType = "OneDrive"; ApiVersion = "beta"; Period = 30  }
            @{ Quantity = 1; ReportType = "OneDrive"; ApiVersion = "beta"; Period = 30  }
            @{ Quantity = 2; ReportType = "OneDrive"; ApiVersion = "beta"; Period = 30  }
            @{ Quantity = 0; ReportType = "OneDrive"; ApiVersion = "beta"; Period = 90  }
            @{ Quantity = 1; ReportType = "OneDrive"; ApiVersion = "beta"; Period = 90  }
            @{ Quantity = 2; ReportType = "OneDrive"; ApiVersion = "beta"; Period = 90  }
            @{ Quantity = 0; ReportType = "OneDrive"; ApiVersion = "beta"; Period = 180 }
            @{ Quantity = 1; ReportType = "OneDrive"; ApiVersion = "beta"; Period = 180 }
            @{ Quantity = 2; ReportType = "OneDrive"; ApiVersion = "beta"; Period = 180 }
            @{ Quantity = 0; ReportType = "OneDrive"; ApiVersion = "Default"; Period = "Default" }
            @{ Quantity = 1; ReportType = "OneDrive"; ApiVersion = "Default"; Period = "Default" }
            @{ Quantity = 2; ReportType = "OneDrive"; ApiVersion = "Default"; Period = "Default" }
        )
    }


    It "should update <Quantity> rows for report type <ReportType> with API version <ApiVersion> for <Period> days" -ForEach $testCases {

        if( $ApiVersion -eq "Default" )
        {
            $mockApiVersion = "v1.0"
        }
        else
        {
            $mockApiVersion = $ApiVersion
        }

        if( $Period -eq "Default" )
        {
            $mockPeriod = "30"
        }
        else
        {
            $mockPeriod = $Period
        }

        $mockActivityReportData =  New-MockUsageAccountReportData -Quantity $Quantity -ReportType $ReportType -ApiVersion $mockApiVersion

        if( $ReportType -eq "M365Group" )
        {
            $parameterfilter = '$Method -eq "Get" -and $Uri -eq "https://graph.microsoft.com/{0}/reports/getOffice365GroupsActivityDetail(period=''D{1}'')" -and $Headers.Authorization -eq "Bearer mock_access_token" -and $MaximumRedirection -eq 10' -f $mockApiVersion, $mockPeriod | ConvertTo-ScriptBlock
        }
        elseif( $ReportType -eq "SharePoint" )
        {
            $parameterfilter = '$Method -eq "Get" -and $Uri -eq "https://graph.microsoft.com/{0}/reports/getSharePointSiteUsageDetail(period=''D{1}'')" -and $Headers.Authorization -eq "Bearer mock_access_token" -and $MaximumRedirection -eq 10' -f $mockApiVersion, $mockPeriod | ConvertTo-ScriptBlock
        }
        elseif( $ReportType -eq "OneDrive" )
        {
            $parameterfilter = '$Method -eq "Get" -and $Uri -eq "https://graph.microsoft.com/{0}/reports/getOneDriveUsageAccountDetail(period=''D{1}'')" -and $Headers.Authorization -eq "Bearer mock_access_token" -and $MaximumRedirection -eq 10' -f $mockApiVersion, $mockPeriod | ConvertTo-ScriptBlock
        }

        Mock `
            -CommandName "Invoke-RestMethod" `
            -ParameterFilter $parameterfilter `
            -ModuleName "TenantSiteMetadataSync" `
            -MockWith { $mockActivityReportData | ConvertTo-Csv -UseQuotes AsNeeded | Out-String } `
            -Verifiable

        # build dynamic mocks
        foreach( $row in $mockActivityReportData )
        {
            if( $ReportType -eq "M365Group" )
            {
                $parameterfilter   = '$GroupId -eq "{0}"'                           -f $row.'Group Id'
                $parameterfilter  += ' -and $DisplayName -eq "{0}"'                 -f $row.'Group Display Name'
                $parameterfilter  += ' -and $IsDeleted -eq [bool]::Parse("{0}")'    -f ($row.'Is Deleted' -eq "TRUE")
                $parameterfilter  += ' -and $IsPublic -eq [bool]::Parse("{0}")'     -f ($row.'Group Type' -eq "Public" )
                $parameterfilter  += ' -and $MemberCount -eq {0}'                   -f $row.'Member Count'
                $parameterfilter  += ' -and $ExternalMemberCount -eq {0}'           -f $row.'External Member Count'
                $parameterfilter  += ' -and $ExchangeReceivedEmailCount -eq {0}'    -f $row.'Exchange Received Email Count'
                $parameterfilter  += ' -and $ExchangeReceivedEmailCount -eq {0}'    -f $row.'Exchange Received Email Count'
                $parameterfilter  += ' -and $SharePointActiveFileCount -eq {0}'     -f $row.'SharePoint Active File Count'
                $parameterfilter  += ' -and $SharePointTotalFileCount -eq {0}'      -f $row.'SharePoint Total File Count' 
                $parameterfilter  += ' -and $YammerPostedMessageCount -eq {0}'      -f $row.'Yammer Posted Message Count'
                $parameterfilter  += ' -and $YammerReadMessageCount -eq {0}'        -f $row.'Yammer Read Message Count'
                $parameterfilter  += ' -and $YammerLikedMessageCount -eq {0}'       -f $row.'Yammer Liked Message Count'
                $parameterfilter  += ' -and $ExchangeMailboxTotalItemCount -eq {0}' -f $row.'Exchange Mailbox Total Item Count'
                $parameterfilter  += ' -and $ExchangeMailboxStorageUsed -eq {0}'    -f $row.'Exchange Mailbox Storage Used (Byte)'

                if( [string]::IsNullOrWhiteSpace($row.'Last Activity Date'))
                {
                    $parameterfilter += ' -and $LastActivityDate -eq $NULL'
                }
                else
                {
                    $parameterfilter += ' -and $LastActivityDate -eq "{0}"' -f $row.'Last Activity Date'
                }

                $parameterfilter = $parameterfilter | ConvertTo-ScriptBlock

                # create a mock with the unique filter
                Mock `
                    -CommandName "Update-GroupMetadata" `
                    -ModuleName "TenantSiteMetadataSync" `
                    -ParameterFilter $parameterfilter `
                    -Verifiable
            }
            else # SharePoint or OneDrive
            {
                # common columns
                $parameterfilter  = ''
                $parameterfilter +=  '$SiteUrl -eq "{0}"'            -f $row.'Site Url'
                $parameterfilter += ' -and $NumOfFiles -eq {0}'      -f $row.'File Count'
                $parameterfilter += ' -and $StorageQuota -eq {0}'    -f $row.'Storage Allocated (Byte)'
                $parameterfilter += ' -and $SiteOwnerName -eq "{0}"' -f $row.'Owner Display Name'
                
                if ( $ReportType -eq "SharePoint")
                {
                    $parameterfilter += ' -and $SiteId -eq "{0}"'     -f $row.'Site Id'
                    $parameterfilter += ' -and $PagesVisited -eq {0}' -f $row.'Visited Page Count'
                    $parameterfilter += ' -and $PageViews -eq {0}'    -f $row.'Page View Count'

                    if ( [string]::IsNullOrWhiteSpace($row.'Last Activity Date'))
                    {
                        $parameterfilter  += ' -and $LastActivityOn -eq $NULL'
                    }
                    else
                    {
                        $parameterfilter  += ' -and $LastActivityOn -eq [DateTime]::Parse("{0}")' -f $row.'Last Activity Date'
                    }

                    if ( $ApiVersion -eq "beta" )
                    {
                        $parameterfilter += ' -and $CompanyLinkCount -eq {0}'   -f $row.'Company Link Count'
                        $parameterfilter += ' -and $AnonymousLinkCount -eq {0}' -f $row.'Anonymous Link Count'
                        $parameterfilter += ' -and $GuestLinkCount -eq {0}'     -f $row.'Secure Link For Guest Count'
                        $parameterfilter += ' -and $MemberLinkCount -eq {0}'    -f $row.'Secure Link For Member Count'

                        if ( [string]::IsNullOrWhiteSpace($row.'Site Sensitivity Label Id') )
                        {
                            $parameterfilter += ' -and $SensitivityLabel -eq $NULL'
                        }
                        else
                        {
                            $parameterfilter += ' -and $SensitivityLabel -eq "{0}"' -f $row.'Site Sensitivity Label Id'
                        }
                    }   
                }

                $parameterfilter = $parameterfilter | ConvertTo-ScriptBlock

                # create a mock with the unique filter
                Mock `
                    -CommandName "Update-SiteMetadata" `
                    -ModuleName "TenantSiteMetadataSync" `
                    -ParameterFilter $parameterfilter `
                    -Verifiable
            }
        }

        $parameters = @{}
        $parameters.ReportType = $ReportType
        $parameters.ClientId   = $mockTenantConnection.ClientId
        $parameters.Thumbprint = $mockTenantConnection.Thumbprint
        $parameters.Tenant     = $mockTenantConnection.TenantName
        $parameters.DatabaseConnectionInformation = $mockDatabaseConnectionInfo

        if( $ApiVersion -ne "Default" )
        {
            $parameters.ApiVersion = $ApiVersion            
        }

        if( $Period -ne "Default" )
        {
            $parameters.Period = $Period            
        }

        Import-TSMSMicrosoftGraphUsageAccountReportData @parameters

        Should -InvokeVerifiable
    }
}
