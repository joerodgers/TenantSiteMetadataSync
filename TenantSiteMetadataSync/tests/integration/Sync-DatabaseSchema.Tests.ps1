Describe "Testing Sync-DatabaseSchema cmdlet" -Tag "IntegrationTest" {

    BeforeAll {

        Remove-Module -Name "TenantSiteMetadataSync" -Force -ErrorAction Ignore
        Import-Module -Name "$PSScriptRoot\..\..\TenantSiteMetadataSync.psd1" -Force

        # mock file path
        $mockSqlFile = Join-Path -Path $TestDrive -ChildPath "db_mockdatabase.sql"

        # unique database for testing
        $randomDatabaseName = (New-Guid).ToString()
        
        # get contents of production file
        $sql = Get-Content -Path "$PSScriptRoot\..\..\private\sql\db_Database.sql"

        # create a fake temp sql file using a random name
        Set-Content -Path $mockSqlFile -Value ($sql -replace "TenantSiteMetadataSync", $randomDatabaseName)

        # mock function used to inject our fake sql file
        Mock `
            -CommandName "Get-ChildItem" `
            -ModuleName "TenantSiteMetadataSync" `
            -ParameterFilter { $Filter -eq "db_*.sql" } `
            -MockWith { [PSCustomObject] @{ FullName = $mockSqlFile } }

        # create a local connection to master
        $databaseConnectionInformation = New-TSMSSqlServerDatabaseConnectionInformation -DatabaseName "master" -DatabaseServer "localhost\sqlexpress"

        # provsion the empty database
        New-TSMSDatabase -DatabaseConnectionInformation $databaseConnectionInformation

        # create a local connection to the mock database
        $databaseConnectionInformation = New-TSMSSqlServerDatabaseConnectionInformation -DatabaseName $randomDatabaseName -DatabaseServer "localhost\sqlexpress"

        # provision schema
        Sync-TSMSDatabaseSchema -DatabaseConnectionInformation $databaseConnectionInformation

        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
        $tables = @(
            "ConditionalAccessPolicyType"
            "GroupMetadata"
            "GroupOwner"
            "SensitivityLabel"
            "SiteCreationSource"
            "SiteMetadata"
            "SiteState" 
            "SyncJob" 
            "SecondarySiteAdministrator"
        )

        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
        $views = @(
            "GroupConnectedSites"
            "GroupConnectedSitesAndOwner"
            "GroupsActive" 
            "GroupsAll"          
            "GroupsDeleted"
            "OneDriveForBusinessSites"
            "OneDriveForBusinessSitesDeleted"
            "SitesRedirectors"
            "SiteCountsByTemplate"
            "SitesActive"
            "SitesAll"
            "SitesDeleted"
            "SitesHubConnected"
            "SitesLocked"
            "SitesProjectOnlineEnabled" 
            "SyncJobExecutionTime"
            "TeamsActive"
            "TeamsActivePrivateChannels"
            "TeamsAll"
            "TeamsDeleted"
        )

        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
        $procs = @(
            "proc_AddGroupOwnerByGroupId"
            "proc_AddOrUpdateDataRefreshStatus"
            "proc_AddOrUpdateGroupMetadata"
            "proc_AddOrUpdateSensitivityLabel"
            "proc_AddOrUpdateSiteCreationSource"
            "proc_AddOrUpdateSiteMetadata"
            "proc_ColumnExistsInTable"
            "proc_RemoveGroupOwnersByGroupId"
            "proc_StartSyncJobExecution"
            "proc_StopSyncJobExecution"
        )

        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
        $functions = @(
            "TVF_GroupSites_Active"
            "TVF_GroupSites_All"
            "TVF_GroupSites_Deleted"
            "TVF_Sites_Active"
            "TVF_Sites_All"
            "TVF_Sites_Deleted"
        )
    }

    AfterAll {

        Invoke-Sqlcmd -ServerInstance "localhost\sqlexpress" -Database "master" -Query "
        
            EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N'$randomDatabaseName'
            GO
            
            USE [master]
            GO
            ALTER DATABASE [$randomDatabaseName] SET  SINGLE_USER WITH ROLLBACK IMMEDIATE
            GO
            
            USE [master]
            GO
            
            DROP DATABASE [$randomDatabaseName]
            GO"
    }

    It "should provision all required tables using trusted connection" {

        # ensure all expected tables exist
        foreach( $table in $tables )
        {
            (Invoke-Sqlcmd -ServerInstance "localhost\sqlexpress" -Database $randomDatabaseName -Query "SELECT * FROM sys.tables WHERE name = '$table'").Name | Should -BeExactly $table
        }

        # ensure no extra tables exist
        (Invoke-Sqlcmd -ServerInstance "localhost\sqlexpress" -Database $randomDatabaseName -Query "SELECT * FROM sys.tables").Rows.Count | Should -BeExactly $tables.Count
    }

    It "should provision all stored procedures views using trusted connection" {

        # ensure all expected procs exist
        foreach( $proc in $procs )
        {
            (Invoke-Sqlcmd -ServerInstance "localhost\sqlexpress" -Database $randomDatabaseName -Query "SELECT * FROM sys.procedures WHERE name = '$proc'").Name | Should -BeExactly $proc
        }

        # ensure no extra procs exist
        (Invoke-Sqlcmd -ServerInstance "localhost\sqlexpress" -Database $randomDatabaseName -Query "SELECT * FROM sys.procedures").Rows.Count | Should -BeExactly $procs.Count
    }

    It "should provision all required views using trusted connection" {

        # ensure all expected views exist
        foreach( $view in $views )
        {
            (Invoke-Sqlcmd -ServerInstance "localhost\sqlexpress" -Database $randomDatabaseName -Query "SELECT * FROM sys.views WHERE name = '$view'").Name | Should -BeExactly $view
        }

        # ensure no extra views exist
        (Invoke-Sqlcmd -ServerInstance "localhost\sqlexpress" -Database $randomDatabaseName -Query "SELECT * FROM sys.views").Rows.Count | Should -BeExactly $views.Count
    }

    It "should provision all required functions using trusted connection" {

        # ensure all expected functions exist
        foreach( $function in $functions )
        {
            (Invoke-Sqlcmd -ServerInstance "localhost\sqlexpress" -Database $randomDatabaseName -Query "SELECT ROUTINE_NAME FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'FUNCTION' AND ROUTINE_NAME = '$function'").ROUTINE_NAME | Should -BeExactly $function
        }

        # ensure no extra functions exist
        (Invoke-Sqlcmd -ServerInstance "localhost\sqlexpress" -Database $randomDatabaseName -Query "SELECT ROUTINE_NAME FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'FUNCTION'").Rows.Count | Should -BeExactly $functions.Count
    }

}