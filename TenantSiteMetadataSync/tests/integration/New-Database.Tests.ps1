Describe "Testing New-Database cmdlet" -Tag "IntegrationTest" {

    BeforeAll {

        Remove-Module -Name "TenantSiteMetadataSync" -Force -ErrorAction Ignore
        Import-Module -Name "$PSScriptRoot\..\..\TenantSiteMetadataSync.psd1" -Force

        # mock file path
        $mockSqlFile = Join-Path -Path $TestDrive -ChildPath "db_mockdatabase.sql"

        # unique database for testing
        $randomDatabaseName = (New-Guid).ToString()
        
        $sql = Get-Content -Path "$PSScriptRoot\..\..\private\sql\db_Database.sql"

        # create a fake temp sql file
        Set-Content -Path $mockSqlFile -Value ($sql -replace "TenantSiteMetadataSync", $randomDatabaseName)

        # mock function used to inject our fake sql file
        Mock `
            -CommandName "Get-ChildItem" `
            -ModuleName "TenantSiteMetadataSync" `
            -MockWith { [PSCustomObject] @{ FullName = $mockSqlFile } }
    }

    AfterAll {

        Invoke-Sqlcmd -ServerInstance "localhost\sqlexpress" -Database "master" -Query "DROP DATABASE [$randomDatabaseName]"
    }

    It "should create new sql database using a trusted connection" {

        $databaseConnectionInformation = New-TSMSSqlServerDatabaseConnectionInformation -DatabaseName "master" -DatabaseServer "localhost\sqlexpress"

        New-TSMSDatabase -DatabaseConnectionInformation $databaseConnectionInformation
    
        $result = Invoke-Sqlcmd -ServerInstance "localhost\sqlexpress" -Database "master" -Query "SELECT * FROM sys.databases WHERE name = '$randomDatabaseName'"

        $result.Name | Should -BeExactly $randomDatabaseName
    }
}