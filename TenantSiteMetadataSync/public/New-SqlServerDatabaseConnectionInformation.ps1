
function New-SqlServerDatabaseConnectionInformation
{
    [cmdletbinding(DefaultParameterSetName="TrustedConnection")]
    param
    (
        # Name of the SQL database
        [Parameter(Mandatory=$true,ParameterSetName="TrustedConnection")]
        [Parameter(Mandatory=$true,ParameterSetName="SqlAuthentication")]
        [Parameter(Mandatory=$true,ParameterSetName="ServicePrincipal")]
        [string]$DatabaseName,

        # Name of the SQL server or SQL and instance name
        [Parameter(Mandatory=$true,ParameterSetName="TrustedConnection")]
        [Parameter(Mandatory=$true,ParameterSetName="SqlAuthentication")]
        [Parameter(Mandatory=$true,ParameterSetName="ServicePrincipal")]
        [string]$DatabaseServer,

        # Connection timeout, default is 15
        [Parameter(Mandatory=$false)]
        [int]$ConnectTimeout = 15,

        # Application name, default is calling command.
        [Parameter(Mandatory=$false)]
        [switch]$Encrypt,

        # Application name, default is calling command.
        [Parameter(Mandatory=$false,ParameterSetName="SqlAuthentication")]
        [string]$UserName,

        # Application name, default is calling command.
        [Parameter(Mandatory=$false,ParameterSetName="SqlAuthentication")]
        [SecureString]$Password,

        # Application name, default is calling command.
        [Parameter(Mandatory=$false,ParameterSetName="ServicePrincipal")]
        [string]$ClientId,

        # Application name, default is calling command.
        [Parameter(Mandatory=$false,ParameterSetName="ServicePrincipal")]
        [SecureString]$ClientSecret,

        # Application name, default is calling command.
        [Parameter(Mandatory=$false,ParameterSetName="ServicePrincipal")]
        [string]$TenantId
    )

    begin
    {
    }
    process
    {
        if( $PSCmdlet.ParameterSetName -eq "TrustedConnection" )
        {
            return New-Object TrustedConnectionDatabaseConnectionInformation -Property @{
                DatabaseName    = $DatabaseName
                DatabaseServer  = $DatabaseServer
                ConnectTimeout  = $ConnectTimeout
                Encrypt         = $Encrypt.IsPresent
            }
        }
        
        if( $PSCmdlet.ParameterSetName -eq "SqlAuthentication" )
        {
            $readOnlyPassword = $Password.Copy()
            $readOnlyPassword.MakeReadOnly()

            return New-Object SqlAuthenticationDatabaseConnectionInformation -Property @{
                DatabaseName    = $DatabaseName
                DatabaseServer  = $DatabaseServer
                ConnectTimeout  = $ConnectTimeout
                Encrypt         = $true
                SqlCredential   = New-Object System.Data.SqlClient.SqlCredential( $UserName, $readOnlyPassword )
            }
        }
        
        if( $PSCmdlet.ParameterSetName -eq "ServicePrincipal" )
        {
            return New-Object ServicePrincipalDatabaseConnectionInformation -Property @{
                DatabaseName    = $DatabaseName
                DatabaseServer  = $DatabaseServer
                ConnectTimeout  = $ConnectTimeout
                Encrypt         = $true
                ClientId        = $ClientId
                ClientSecret    = $ClientSecret
                TenantId        = $TenantId
            }
        }
    }
    end
    {
    }
}

