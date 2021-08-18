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

            It "should create database" {
            
                $mockFile1 = [PSCustomObject] @{ FullName = "C:\temp\mock1.sql" }
                $mockFile2 = [PSCustomObject] @{ FullName = "C:\temp\mock2.sql" }

                $mockSqlFiles = $mockFile1, $mockFile2

                Mock -CommandName "Get-ChildItem" -ParameterFilter { $Filter -eq "db_*.sql" } -Verifiable -MockWith { $mockSqlFiles } 

                Mock -CommandName "Invoke-Sqlcmd" -ParameterFilter { $InputFile -eq $mockFile1.FullName } -Verifiable
                Mock -CommandName "Invoke-Sqlcmd" -ParameterFilter { $InputFile -eq $mockFile2.FullName } -Verifiable

                New-Database -DatabaseServer "localhost/mssql" `

                Should -InvokeVerifiable
            }
       }
    }
}