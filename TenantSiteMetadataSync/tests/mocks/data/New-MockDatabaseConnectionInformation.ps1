function New-MockDatabaseConnectionInformation
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateSet("TrustedConnection","SqlAuthentication", "ServicePrincipal")]
        [string]$DatabaseConnectionType
    )

    switch( $DatabaseConnectionType )
    {
        "SqlAuthentication" 
        {
            $mockusername = "mock_sa"
            $mockpassword = "mock_password" | ConvertTo-SecureString -AsPlainText -Force
 
            return New-SqlServerDatabaseConnectionInformation `
                    -DatabaseName   "mock_databasename" `
                    -DatabaseServer "mock_sqlserver" `
                    -ConnectTimeout 15 `
                    -UserName       $mockusername `
                    -Password       $mockpassword
        }
        "ServicePrincipal"
        {
            $mockclientId     = [Guid]::Parse( "00000000-0000-0000-0000-000000000001" )
            $mockclientSecret = "mock_client_secret" | ConvertTo-SecureString -AsPlainText -Force
            $mocktenantId     = [Guid]::Parse( "00000000-0000-0000-0000-000000000002" )

            return New-SqlServerDatabaseConnectionInformation `
                    -DatabaseName   "mock_databasename" `
                    -DatabaseServer "mock_sqlserver" `
                    -ConnectTimeout 15 `
                    -ClientId       $mockclientId `
                    -ClientSecret   $mockclientSecret `
                    -TenantId       $mocktenantId
        }
        default
        {
            return New-SqlServerDatabaseConnectionInformation `
                    -DatabaseName "mock_databasename" `
                    -DatabaseServer "mock_sqlserver" `
                    -ConnectTimeout 15 `
                    -Encrypt
        }
    }
}

