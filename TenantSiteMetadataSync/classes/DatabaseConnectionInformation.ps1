using namespace System.Data.SqlClient;

class DatabaseConnectionInformation 
{
    [string]
    $DatabaseName

    [string]
    $DatabaseServer

    [int]
    $ConnectTimeout = 15

    [bool]
    $Encrypt
}

class TrustedConnectionDatabaseConnectionInformation : DatabaseConnectionInformation
{
}

class SqlAuthenticationDatabaseConnectionInformation : DatabaseConnectionInformation
{
    [SqlCredential]
    $SqlCredential
}

class ServicePrincipalDatabaseConnectionInformation : DatabaseConnectionInformation
{
    [Guid]
    $ClientId

    [SecureString]
    $ClientSecret
    
    [Guid]
    $TenantId
}