function New-SqlServerDatabaseConnection
{
    [cmdletbinding()]
    param
    (
        # Database Connection Information
        [Parameter(Mandatory=$true)]
        [DatabaseConnectionInformation]
        $DatabaseConnectionInformation
    )

    begin
    {
        $connection = $null
    }
    process
    {
        try 
        {
            $sqlConnectionStringBuilder = New-Object System.Data.SqlClient.SqlConnectionStringBuilder
            $sqlConnectionStringBuilder.PSBase.InitialCatalog           = $DatabaseConnectionInformation.DatabaseName
            $sqlConnectionStringBuilder.PSBase.DataSource               = $DatabaseConnectionInformation.DatabaseServer
            $sqlConnectionStringBuilder.PSBase.IntegratedSecurity       = $true
            $sqlConnectionStringBuilder.PSBase.ConnectTimeout           = $DatabaseConnectionInformation.ConnectTimeout
            $sqlConnectionStringBuilder.PSBase.Encrypt                  = $DatabaseConnectionInformation.Encypt
            $sqlConnectionStringBuilder.PSBase.TrustServerCertificate   = $DatabaseConnectionInformation.Encypt
            $sqlConnectionStringBuilder.PSBase.MultipleActiveResultSets = $false
    
            if( $DatabaseConnectionInformation -is [TrustedConnectionDatabaseConnectionInformation] )
            {
                $connection = New-Object System.Data.SqlClient.SqlConnection($sqlConnectionStringBuilder.PSBase.ConnectionString)
            }
            elseif( $DatabaseConnectionInformation -is [SqlAuthenticationDatabaseConnectionInformation] )
            {
                $sqlConnectionStringBuilder.PSBase.IntegratedSecurity     = $false
                $sqlConnectionStringBuilder.PSBase.Encrypt                = $true
                $sqlConnectionStringBuilder.PSBase.TrustServerCertificate = $true
        
                $connection = New-Object System.Data.SqlClient.SqlConnection($sqlConnectionStringBuilder.PSBase.ConnectionString, $DatabaseConnectionInformation.SqlCredential)
            }
            elseif( $DatabaseConnectionInformation -is [ServicePrincipalDatabaseConnectionInformation] )
            {
                $sqlConnectionStringBuilder.PSBase.IntegratedSecurity     = $false
                $sqlConnectionStringBuilder.PSBase.Encrypt                = $true
                $sqlConnectionStringBuilder.PSBase.TrustServerCertificate = $true
                $sqlConnectionStringBuilder.PSBase.PersistSecurityInfo    = $true # allows the AccessToken property to the viewed after the connection is made
    
                $connection = New-Object System.Data.SqlClient.SqlConnection($sqlConnectionStringBuilder.PSBase.ConnectionString)
    
                # generate an access token from Azure AD
                $connection.AccessToken = New-AzureSqlAccessToken `
                                            -ClientId     $DatabaseConnectionInformation.ClientId `
                                            -ClientSecret $DatabaseConnectionInformation.ClientSecret `
                                            -TenantId     $DatabaseConnectionInformation.TenantId
            }
    
            Write-PSFMessage -Level Debug -Message "Opening database connection with connection string: $($sqlConnectionStringBuilder.PSBase.ConnectionString)"

            # open the connection
            $connection.Open()
    
            if( -not $connection -or $connection.State -ne "Open" )
            {
                Write-PSFMessage -Level Critical -Message "Failed to open a connection.  Connection string: $($sqlConnectionStringBuilder.PSBase.ConnectionString)"
                throw "Invalid Connection"
            }
    
            return $connection
        }
        catch
        {
            Stop-PSFFunction -Message "Failed to create new database connection." -EnableException $true -ErrorRecord $_
        }
    }
    end
    {
    }
}
