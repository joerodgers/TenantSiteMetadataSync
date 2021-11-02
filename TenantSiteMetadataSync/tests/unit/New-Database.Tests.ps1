Describe "Testing New-Database cmdlet" -Tag "UnitTest" {

    BeforeAll {

        Remove-Module -Name "TenantSiteMetadataSync" -Force -ErrorAction Ignore
        Import-Module -Name "$PSScriptRoot\..\..\TenantSiteMetadataSync.psd1" -Force

        . "$PSScriptRoot\..\mocks\New-MockDatabaseConnectionInformation.ps1"
        . "$PSScriptRoot\..\mocks\New-MockDatabaseSchemaFile.ps1"
        . "$PSScriptRoot\ConvertTo-ScriptBlock.ps1"

        function Invoke-Sqlcmd { param($InputFile, $ServerInstance, $Database) }
    }

    It "should create a database from <TableFileCount> table files using a trusted connection" -Foreach @(
        @{ TableFileCount = 0 }
        @{ TableFileCount = 1 }
        @{ TableFileCount = 2 }
    ){
        $mockDatabaseConnectionInfo = New-MockDatabaseConnectionInformation -DatabaseConnectionType "TrustedConnection"

        $tableFiles = New-MockDatabaseSchemaFile -Quantity $TableFileCount

        Mock -CommandName "Get-ChildItem" -ModuleName "TenantSiteMetadataSync" -ParameterFilter { $Filter -eq "db_*.sql" } -Verifiable -MockWith { $tableFiles } 

        foreach( $file in $tableFiles )
        {
            $filter = ''
            $filter = '$InputFile -eq "{0}"'             -f $file.FullName
            $filter += ' -and $Database -eq "{0}"'       -f $mockDatabaseConnectionInfo.DatabaseName
            $filter += ' -and $ServerInstance -eq "{0}"' -f $mockDatabaseConnectionInfo.DatabaseServer

            Mock `
                -CommandName "Invoke-Sqlcmd" `
                -ModuleName "TenantSiteMetadataSync" `
                -ParameterFilter ([ScriptBlock]::Create( $filter )) `
                -Verifiable        
        }

        New-Database -DatabaseConnectionInformation $mockDatabaseConnectionInfo

        Should -InvokeVerifiable
    }

    It "should create a database from <TableFileCount> table files using a sql auth connection" -Foreach @(
        @{ TableFileCount = 0 }
        @{ TableFileCount = 1 }
        @{ TableFileCount = 2 }
    ){
        $mockDatabaseConnectionInfo = New-MockDatabaseConnectionInformation -DatabaseConnectionType "SqlAuthentication"

        $tableFiles = New-MockDatabaseSchemaFile -Quantity $TableFileCount

        Mock -CommandName "Get-ChildItem" -ModuleName "TenantSiteMetadataSync" -ParameterFilter { $Filter -eq "db_*.sql" } -Verifiable -MockWith { $tableFiles } 

        foreach( $file in $tableFiles )
        {
            $filter = ''
            $filter = '$InputFile -eq "{0}"'             -f $file.FullName
            $filter += ' -and $Database -eq "{0}"'       -f $mockDatabaseConnectionInfo.DatabaseName
            $filter += ' -and $ServerInstance -eq "{0}"' -f $mockDatabaseConnectionInfo.DatabaseServer
            $filter += ' -and $Username -eq "{0}"'       -f $mockDatabaseConnectionInfo.SqlCredential.UserId
            $filter += ' -and $Password -eq "{0}"'       -f ($mockDatabaseConnectionInfo.SqlCredential.Password | ConvertFrom-SecureString -AsPlainText)

            Mock `
                -CommandName "Invoke-Sqlcmd" `
                -ModuleName "TenantSiteMetadataSync" `
                -ParameterFilter ([ScriptBlock]::Create( $filter )) `
                -Verifiable        
        }


        New-Database -DatabaseConnectionInformation $mockDatabaseConnectionInfo

        Should -InvokeVerifiable
    }

    It "should create a database from <TableFileCount> table files using a service principal connection" -Foreach @(
        @{ TableFileCount = 0 }
        @{ TableFileCount = 1 }
        @{ TableFileCount = 2 }
            
    ){
        $mockDatabaseConnectionInfo = New-MockDatabaseConnectionInformation -DatabaseConnectionType "ServicePrincipal"

        $tableFiles = New-MockDatabaseSchemaFile -Quantity $TableFileCount

        Mock -CommandName "Get-ChildItem" -ModuleName "TenantSiteMetadataSync" -ParameterFilter { $Filter -eq "db_*.sql" } -Verifiable -MockWith { $tableFiles } 
    
        $parameterFilter  = '$ClientId -eq "{0}"'       -f $mockDatabaseConnectionInfo.ClientId.ToString()
        $parameterFilter += ' -and $TenantId -eq "{0}"' -f $mockDatabaseConnectionInfo.TenantId.ToString()
        $parameterFilter += ' -and ($ClientSecret | ConvertFrom-SecureString -AsPlainText) -eq "{0}"' -f ($mockDatabaseConnectionInfo.ClientSecret | ConvertFrom-SecureString -AsPlainText)

        $parameterFilter = $parameterFilter | ConvertTo-ScriptBlock

        Mock `
            -CommandName "New-AzureSqlAccessToken" `
            -ModuleName "TenantSiteMetadataSync" `
            -ParameterFilter $parameterFilter `
            -MockWith { return "mock_access_token" } `
            -Verifiable

        foreach( $file in $tableFiles )
        {
            $parameterFilter = '$InputFile -eq "{0}"'             -f $file.FullName
            $parameterFilter += ' -and $Database -eq "{0}"'       -f $mockDatabaseConnectionInfo.DatabaseName
            $parameterFilter += ' -and $ServerInstance -eq "{0}"' -f $mockDatabaseConnectionInfo.DatabaseServer
            $parameterFilter += ' -and $AccessToken -eq "{0}"'    -f "mock_access_token"

            $parameterFilter = $parameterFilter | ConvertTo-ScriptBlock

            Mock `
                -CommandName "Invoke-Sqlcmd" `
                -ModuleName "TenantSiteMetadataSync" `
                -ParameterFilter $parameterFilter `
                -Verifiable        
        }
    
        $UpdateSiteMetadataParameters = InModuleScope -ModuleName "TenantSiteMetadataSync" -ScriptBlock {

            $command = Get-Command -Name "Update-SiteMetadata"
            
            $command.ParameterSets[0].Parameters # | Where-Object -Property Position -ge 0 | Select-Object Name, ParameterType, IsMandatory 
        }

        Write-Host "parameters: $UpdateSiteMetadataParameters"
        
        New-Database -DatabaseConnectionInformation $mockDatabaseConnectionInfo

        Should -InvokeVerifiable
    }

}