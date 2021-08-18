Describe "TenantSiteMetadataSync functional tests" {

    BeforeDiscovery {
        Import-Module -Name "$PSScriptRoot\..\..\TenantSiteMetadataSync.psd1" -Force
    }

    Context "Update-DatabaseSchema function" {

        InModuleScope -ModuleName "TenantSiteMetadataSync" {

            BeforeAll {

                function Invoke-Sqlcmd
                {
                    param($InputFile, $ServerInstance, $Database) 
                }
            }


            It "should update tables" {
            
                $mockFile1 = [PSCustomObject] @{ FullName = "C:\temp\mock1.sql" }
                $mockFile2 = [PSCustomObject] @{ FullName = "C:\temp\mock2.sql" }

                $mockSqlFiles = $mockFile1, $mockFile2

                Mock -CommandName "Get-ChildItem" -ParameterFilter { $Filter -eq "tb_*.sql"    } -Verifiable -MockWith { $mockSqlFiles } 
                Mock -CommandName "Get-ChildItem" -ParameterFilter { $Filter -eq "tvf_*.sql"   } -Verifiable
                Mock -CommandName "Get-ChildItem" -ParameterFilter { $Filter -eq "procs_*.sql" } -Verifiable
                Mock -CommandName "Get-ChildItem" -ParameterFilter { $Filter -eq "vw_*.sql"    } -Verifiable

                Mock -CommandName "Invoke-Sqlcmd" -ParameterFilter { $InputFile -eq $mockFile1.FullName } -Verifiable
                Mock -CommandName "Invoke-Sqlcmd" -ParameterFilter { $InputFile -eq $mockFile2.FullName } -Verifiable

                Update-DatabaseSchema `
                    -DatabaseName   "TenantSiteMetadataSync" `
                    -DatabaseServer "localhost/mssql" `

                Should -InvokeVerifiable
            }

            It "should update functions" {
            
                $mockFile1 = [PSCustomObject] @{ FullName = "C:\temp\mock1.sql" }
                $mockFile2 = [PSCustomObject] @{ FullName = "C:\temp\mock2.sql" }

                $mockSqlFiles = $mockFile1, $mockFile2

                Mock -CommandName "Get-ChildItem" -ParameterFilter { $Filter -eq "tb_*.sql"    } -Verifiable
                Mock -CommandName "Get-ChildItem" -ParameterFilter { $Filter -eq "tvf_*.sql"   } -Verifiable -MockWith { $mockSqlFiles } 
                Mock -CommandName "Get-ChildItem" -ParameterFilter { $Filter -eq "procs_*.sql" } -Verifiable
                Mock -CommandName "Get-ChildItem" -ParameterFilter { $Filter -eq "vw_*.sql"    } -Verifiable

                Mock -CommandName "Invoke-Sqlcmd" -ParameterFilter { $InputFile -eq $mockFile1.FullName } -Verifiable
                Mock -CommandName "Invoke-Sqlcmd" -ParameterFilter { $InputFile -eq $mockFile2.FullName } -Verifiable

                Update-DatabaseSchema `
                    -DatabaseName   "TenantSiteMetadataSync" `
                    -DatabaseServer "localhost/mssql" `

                Should -InvokeVerifiable
            }

            It "should update procs" {
            
                $mockFile1 = [PSCustomObject] @{ FullName = "C:\temp\mock1.sql" }
                $mockFile2 = [PSCustomObject] @{ FullName = "C:\temp\mock2.sql" }

                $mockSqlFiles = $mockFile1, $mockFile2

                Mock -CommandName "Get-ChildItem" -ParameterFilter { $Filter -eq "tb_*.sql"    } -Verifiable
                Mock -CommandName "Get-ChildItem" -ParameterFilter { $Filter -eq "tvf_*.sql"   } -Verifiable
                Mock -CommandName "Get-ChildItem" -ParameterFilter { $Filter -eq "procs_*.sql" } -Verifiable -MockWith { $mockSqlFiles } 
                Mock -CommandName "Get-ChildItem" -ParameterFilter { $Filter -eq "vw_*.sql"    } -Verifiable

                Mock -CommandName "Invoke-Sqlcmd" -ParameterFilter { $InputFile -eq $mockFile1.FullName } -Verifiable
                Mock -CommandName "Invoke-Sqlcmd" -ParameterFilter { $InputFile -eq $mockFile2.FullName } -Verifiable

                Update-DatabaseSchema `
                    -DatabaseName   "TenantSiteMetadataSync" `
                    -DatabaseServer "localhost/mssql" `

                Should -InvokeVerifiable
            }

            It "should update views" {
            
                $mockFile1 = [PSCustomObject] @{ FullName = "C:\temp\mock1.sql" }
                $mockFile2 = [PSCustomObject] @{ FullName = "C:\temp\mock2.sql" }

                $mockSqlFiles = $mockFile1, $mockFile2

                Mock -CommandName "Get-ChildItem" -ParameterFilter { $Filter -eq "tb_*.sql"    } -Verifiable
                Mock -CommandName "Get-ChildItem" -ParameterFilter { $Filter -eq "tvf_*.sql"   } -Verifiable
                Mock -CommandName "Get-ChildItem" -ParameterFilter { $Filter -eq "procs_*.sql" } -Verifiable
                Mock -CommandName "Get-ChildItem" -ParameterFilter { $Filter -eq "vw_*.sql"    } -Verifiable -MockWith { $mockSqlFiles } 

                Mock -CommandName "Invoke-Sqlcmd" -ParameterFilter { $InputFile -eq $mockFile1.FullName } -Verifiable
                Mock -CommandName "Invoke-Sqlcmd" -ParameterFilter { $InputFile -eq $mockFile2.FullName } -Verifiable

                Update-DatabaseSchema `
                    -DatabaseName   "TenantSiteMetadataSync" `
                    -DatabaseServer "localhost/mssql" `

                Should -InvokeVerifiable
            }

            It "should update tables, functions, procs and views" {
            
                $mockFile1 = [PSCustomObject] @{ FullName = "C:\temp\mock1.sql" }
                $mockFile2 = [PSCustomObject] @{ FullName = "C:\temp\mock2.sql" }

                $mockSqlFiles = $mockFile1, $mockFile2

                Mock -CommandName "Get-ChildItem" -ParameterFilter { $Filter -eq "tb_*.sql"    } -Verifiable -MockWith { $mockSqlFiles } 
                Mock -CommandName "Get-ChildItem" -ParameterFilter { $Filter -eq "tvf_*.sql"   } -Verifiable -MockWith { $mockSqlFiles } 
                Mock -CommandName "Get-ChildItem" -ParameterFilter { $Filter -eq "procs_*.sql" } -Verifiable -MockWith { $mockSqlFiles } 
                Mock -CommandName "Get-ChildItem" -ParameterFilter { $Filter -eq "vw_*.sql"    } -Verifiable -MockWith { $mockSqlFiles } 

                Mock -CommandName "Invoke-Sqlcmd" -ParameterFilter { $InputFile -eq $mockFile1.FullName } -Verifiable
                Mock -CommandName "Invoke-Sqlcmd" -ParameterFilter { $InputFile -eq $mockFile2.FullName } -Verifiable

                Update-DatabaseSchema `
                    -DatabaseName   "TenantSiteMetadataSync" `
                    -DatabaseServer "localhost/mssql" `

                Should -InvokeVerifiable
                Should -Invoke -CommandName "Invoke-Sqlcmd" -Exactly -Times 4 -ParameterFilter { $InputFile -eq $mockFile1.FullName }
                Should -Invoke -CommandName "Invoke-Sqlcmd" -Exactly -Times 4 -ParameterFilter { $InputFile -eq $mockFile2.FullName }
            }
       }
    }
}