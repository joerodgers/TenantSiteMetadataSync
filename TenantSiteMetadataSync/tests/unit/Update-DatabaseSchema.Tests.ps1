Describe "Testing Update-DatabaseSchema cmdlet" -Tag "UnitTest" {

    BeforeAll {

        Remove-Module -Name "TenantSiteMetadataSync" -Force -ErrorAction Ignore
        Import-Module -Name "$PSScriptRoot\..\..\TenantSiteMetadataSync.psd1" -Force

        . "$PSScriptRoot\..\mocks\New-MockDatabaseConnectionInformation.ps1"
        . "$PSScriptRoot\..\mocks\New-MockDatabaseSchemaFile.ps1"
        . "$PSScriptRoot\ConvertTo-ScriptBlock.ps1"

        function Invoke-Sqlcmd { param($InputFile, $ServerInstance, $Database) }
    }

    It "should execute <TableFileCount> table files, <TableValueFunctionCount> TFV files, <StoredProcCount> store proc files, <ViewCount> view files and <UpgradeFileCount> upgrade files over a trusted connection" -ForEach @(
        @{ TableFileCount = 0; TableValueFunctionCount = 0; StoredProcCount = 0; ViewCount = 0; UpgradeFileCount = 0 }
        @{ TableFileCount = 1; TableValueFunctionCount = 0; StoredProcCount = 0; ViewCount = 0; UpgradeFileCount = 0 }
        @{ TableFileCount = 0; TableValueFunctionCount = 1; StoredProcCount = 0; ViewCount = 0; UpgradeFileCount = 0 }
        @{ TableFileCount = 0; TableValueFunctionCount = 0; StoredProcCount = 1; ViewCount = 0; UpgradeFileCount = 0 }
        @{ TableFileCount = 0; TableValueFunctionCount = 0; StoredProcCount = 0; ViewCount = 1; UpgradeFileCount = 0 }
        @{ TableFileCount = 0; TableValueFunctionCount = 0; StoredProcCount = 0; ViewCount = 0; UpgradeFileCount = 1 }
        @{ TableFileCount = 1; TableValueFunctionCount = 1; StoredProcCount = 1; ViewCount = 1; UpgradeFileCount = 1 }
        @{ TableFileCount = 2; TableValueFunctionCount = 2; StoredProcCount = 2; ViewCount = 2; UpgradeFileCount = 2 }
    ) {

        $mockDatabaseConnectionInfo = New-MockDatabaseConnectionInformation -DatabaseConnectionType "TrustedConnection"

        $tableFiles   = New-MockDatabaseSchemaFile -Quantity $TableFileCount
        $tvfFiles     = New-MockDatabaseSchemaFile -Quantity $TableValueFunctionCount
        $procFiles    = New-MockDatabaseSchemaFile -Quantity $StoredProcCount
        $viewFiles    = New-MockDatabaseSchemaFile -Quantity $ViewCount
        $upgradeFiles = New-MockDatabaseSchemaFile -Quantity $UpgradeFileCount

        Mock -CommandName "Get-ChildItem" -ModuleName "TenantSiteMetadataSync" -ParameterFilter { $Filter -eq "tb_*.sql"     } -Verifiable -MockWith { $tableFiles   } 
        Mock -CommandName "Get-ChildItem" -ModuleName "TenantSiteMetadataSync" -ParameterFilter { $Filter -eq "tvf_*.sql"    } -Verifiable -MockWith { $tvfFiles     }  
        Mock -CommandName "Get-ChildItem" -ModuleName "TenantSiteMetadataSync" -ParameterFilter { $Filter -eq "proc_*.sql"   } -Verifiable -MockWith { $procFiles    } 
        Mock -CommandName "Get-ChildItem" -ModuleName "TenantSiteMetadataSync" -ParameterFilter { $Filter -eq "vw_*.sql"     } -Verifiable -MockWith { $viewFiles    } 
        Mock -CommandName "Get-ChildItem" -ModuleName "TenantSiteMetadataSync" -ParameterFilter { $Filter -eq "upgrade*.sql" } -Verifiable -MockWith { $upgradeFiles } 

        $files = $tableFiles + $tvfFiles + $procFiles + $viewFiles + $upgradeFiles

        foreach( $file in $files )
        {
            $parameterFilter = '$InputFile -eq "{0}"'             -f $file.FullName
            $parameterFilter += ' -and $Database -eq "{0}"'       -f $mockDatabaseConnectionInfo.DatabaseName
            $parameterFilter += ' -and $ServerInstance -eq "{0}"' -f $mockDatabaseConnectionInfo.DatabaseServer

            $parameterFilter = $parameterFilter | ConvertTo-ScriptBlock

            Mock `
                -CommandName "Invoke-Sqlcmd" `
                -ModuleName "TenantSiteMetadataSync" `
                -ParameterFilter $parameterFilter `
                -Verifiable        
        }

        Sync-DatabaseSchema -DatabaseConnectionInformation $mockDatabaseConnectionInfo

        Should -InvokeVerifiable
    }

    It "should execute <TableFileCount> table files, <TableValueFunctionCount> TFV files, <StoredProcCount> store proc files, <ViewCount> view files and <UpgradeFileCount> upgrade files over a SQL Auth connection" -ForEach @(
        @{ TableFileCount = 0; TableValueFunctionCount = 0; StoredProcCount = 0; ViewCount = 0; UpgradeFileCount = 0 }
        @{ TableFileCount = 1; TableValueFunctionCount = 0; StoredProcCount = 0; ViewCount = 0; UpgradeFileCount = 0 }
        @{ TableFileCount = 0; TableValueFunctionCount = 1; StoredProcCount = 0; ViewCount = 0; UpgradeFileCount = 0 }
        @{ TableFileCount = 0; TableValueFunctionCount = 0; StoredProcCount = 1; ViewCount = 0; UpgradeFileCount = 0 }
        @{ TableFileCount = 0; TableValueFunctionCount = 0; StoredProcCount = 0; ViewCount = 1; UpgradeFileCount = 0 }
        @{ TableFileCount = 0; TableValueFunctionCount = 0; StoredProcCount = 0; ViewCount = 0; UpgradeFileCount = 1 }
        @{ TableFileCount = 1; TableValueFunctionCount = 1; StoredProcCount = 1; ViewCount = 1; UpgradeFileCount = 1 }
        @{ TableFileCount = 2; TableValueFunctionCount = 2; StoredProcCount = 2; ViewCount = 2; UpgradeFileCount = 2 }
    ) {

        $mockDatabaseConnectionInfo = New-MockDatabaseConnectionInformation -DatabaseConnectionType "SqlAuthentication"

        $tableFiles   = New-MockDatabaseSchemaFile -Quantity $TableFileCount
        $tvfFiles     = New-MockDatabaseSchemaFile -Quantity $TableValueFunctionCount
        $procFiles    = New-MockDatabaseSchemaFile -Quantity $StoredProcCount
        $viewFiles    = New-MockDatabaseSchemaFile -Quantity $ViewCount
        $upgradeFiles = New-MockDatabaseSchemaFile -Quantity $UpgradeFileCount

        Mock -CommandName "Get-ChildItem" -ModuleName "TenantSiteMetadataSync" -ParameterFilter { $Filter -eq "tb_*.sql"     } -Verifiable -MockWith { $tableFiles   } 
        Mock -CommandName "Get-ChildItem" -ModuleName "TenantSiteMetadataSync" -ParameterFilter { $Filter -eq "tvf_*.sql"    } -Verifiable -MockWith { $tvfFiles     }  
        Mock -CommandName "Get-ChildItem" -ModuleName "TenantSiteMetadataSync" -ParameterFilter { $Filter -eq "proc_*.sql"   } -Verifiable -MockWith { $procFiles    } 
        Mock -CommandName "Get-ChildItem" -ModuleName "TenantSiteMetadataSync" -ParameterFilter { $Filter -eq "vw_*.sql"     } -Verifiable -MockWith { $viewFiles    } 
        Mock -CommandName "Get-ChildItem" -ModuleName "TenantSiteMetadataSync" -ParameterFilter { $Filter -eq "upgrade*.sql" } -Verifiable -MockWith { $upgradeFiles } 

        $files = $tableFiles + $tvfFiles + $procFiles + $viewFiles + $upgradeFiles

        foreach( $file in $files )
        {
            $parameterFilter = '$InputFile -eq "{0}"'             -f $file.FullName
            $parameterFilter += ' -and $Database -eq "{0}"'       -f $mockDatabaseConnectionInfo.DatabaseName
            $parameterFilter += ' -and $ServerInstance -eq "{0}"' -f $mockDatabaseConnectionInfo.DatabaseServer
            $parameterFilter += ' -and $Username -eq "{0}"'       -f $mockDatabaseConnectionInfo.SqlCredential.UserId
            $parameterFilter += ' -and $Password -eq "{0}"'       -f ($mockDatabaseConnectionInfo.SqlCredential.Password | ConvertFrom-SecureString -AsPlainText)
        
            $parameterFilter = $parameterFilter | ConvertTo-ScriptBlock

            Mock `
                -CommandName "Invoke-Sqlcmd" `
                -ModuleName "TenantSiteMetadataSync" `
                -ParameterFilter $parameterFilter `
                -Verifiable        
        }

        Sync-DatabaseSchema -DatabaseConnectionInformation  $mockDatabaseConnectionInfo

        Should -InvokeVerifiable
    }

    It "should execute <TableFileCount> table files, <TableValueFunctionCount> TFV files, <StoredProcCount> store proc files, <ViewCount> view files and <UpgradeFileCount> upgrade files over a Service Principal connection" -ForEach @(
        @{ TableFileCount = 0; TableValueFunctionCount = 0; StoredProcCount = 0; ViewCount = 0; UpgradeFileCount = 0 }
        @{ TableFileCount = 1; TableValueFunctionCount = 0; StoredProcCount = 0; ViewCount = 0; UpgradeFileCount = 0 }
        @{ TableFileCount = 0; TableValueFunctionCount = 1; StoredProcCount = 0; ViewCount = 0; UpgradeFileCount = 0 }
        @{ TableFileCount = 0; TableValueFunctionCount = 0; StoredProcCount = 1; ViewCount = 0; UpgradeFileCount = 0 }
        @{ TableFileCount = 0; TableValueFunctionCount = 0; StoredProcCount = 0; ViewCount = 1; UpgradeFileCount = 0 }
        @{ TableFileCount = 0; TableValueFunctionCount = 0; StoredProcCount = 0; ViewCount = 0; UpgradeFileCount = 1 }
        @{ TableFileCount = 1; TableValueFunctionCount = 1; StoredProcCount = 1; ViewCount = 1; UpgradeFileCount = 1 }
        @{ TableFileCount = 2; TableValueFunctionCount = 2; StoredProcCount = 2; ViewCount = 2; UpgradeFileCount = 2 }
    ) {
        $mockDatabaseConnectionInfo = New-MockDatabaseConnectionInformation -DatabaseConnectionType "ServicePrincipal"

        $parameterFilter = '$ClientId -eq "{0}"'       -f $mockDatabaseConnectionInfo.ClientId.ToString()
        $parameterFilter += ' -and $TenantId -eq "{0}"' -f $mockDatabaseConnectionInfo.TenantId.ToString()
        $parameterFilter += ' -and ($ClientSecret | ConvertFrom-SecureString -AsPlainText) -eq "{0}"' -f ($mockDatabaseConnectionInfo.ClientSecret | ConvertFrom-SecureString -AsPlainText)

        $parameterFilter = $parameterFilter | ConvertTo-ScriptBlock

        Mock `
            -CommandName "New-AzureSqlAccessToken" `
            -ModuleName "TenantSiteMetadataSync" `
            -ParameterFilter $parameterFilter `
            -MockWith { return "mock_access_token" } `
            -Verifiable

        $tableFiles   = New-MockDatabaseSchemaFile -Quantity $TableFileCount
        $tvfFiles     = New-MockDatabaseSchemaFile -Quantity $TableValueFunctionCount
        $procFiles    = New-MockDatabaseSchemaFile -Quantity $StoredProcCount
        $viewFiles    = New-MockDatabaseSchemaFile -Quantity $ViewCount
        $upgradeFiles = New-MockDatabaseSchemaFile -Quantity $UpgradeFileCount

        Mock -CommandName "Get-ChildItem" -ModuleName "TenantSiteMetadataSync" -ParameterFilter { $Filter -eq "tb_*.sql"     } -Verifiable -MockWith { $tableFiles   } 
        Mock -CommandName "Get-ChildItem" -ModuleName "TenantSiteMetadataSync" -ParameterFilter { $Filter -eq "tvf_*.sql"    } -Verifiable -MockWith { $tvfFiles     }  
        Mock -CommandName "Get-ChildItem" -ModuleName "TenantSiteMetadataSync" -ParameterFilter { $Filter -eq "proc_*.sql"   } -Verifiable -MockWith { $procFiles    } 
        Mock -CommandName "Get-ChildItem" -ModuleName "TenantSiteMetadataSync" -ParameterFilter { $Filter -eq "vw_*.sql"     } -Verifiable -MockWith { $viewFiles    } 
        Mock -CommandName "Get-ChildItem" -ModuleName "TenantSiteMetadataSync" -ParameterFilter { $Filter -eq "upgrade*.sql" } -Verifiable -MockWith { $upgradeFiles } 

        $files = $tableFiles + $tvfFiles + $procFiles + $viewFiles + $upgradeFiles

        foreach( $file in $files )
        {
    
            $filter = ''
            $filter = '$InputFile -eq "{0}"'             -f $file.FullName
            $filter += ' -and $Database -eq "{0}"'       -f $mockDatabaseConnectionInfo.DatabaseName
            $filter += ' -and $ServerInstance -eq "{0}"' -f $mockDatabaseConnectionInfo.DatabaseServer
            $filter += ' -and $AccessToken -eq "{0}"'    -f "mock_access_token"
    
            Mock `
                -CommandName "Invoke-Sqlcmd" `
                -ModuleName "TenantSiteMetadataSync" `
                -ParameterFilter ([ScriptBlock]::Create( $filter )) `
                -Verifiable        
        }

        Sync-DatabaseSchema -DatabaseConnectionInformation  $mockDatabaseConnectionInfo

        Should -InvokeVerifiable
    }
}