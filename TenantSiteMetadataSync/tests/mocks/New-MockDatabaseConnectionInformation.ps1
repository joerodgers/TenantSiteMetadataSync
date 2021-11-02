. $PSScriptRoot\New-MockValue.ps1

function New-MockDatabaseConnectionInformation
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$false)]
        [ValidateSet("TrustedConnection","SqlAuthentication", "ServicePrincipal")]
        [string]$DatabaseConnectionType = "TrustedConnection"
    )

    $parameters = @{}
    $parameters.DatabaseName   = New-MockValue -TypeName String
    $parameters.DatabaseServer = New-MockValue -TypeName String

    switch( $DatabaseConnectionType )
    {
        "SqlAuthentication" 
        {
            $parameters.UserName = New-MockValue -TypeName String
            $parameters.Password = New-MockValue -TypeName String | ConvertTo-SecureString -Force -AsPlainText
            break
        }
        "ServicePrincipal"
        {
            $parameters.ClientId     = New-MockValue -TypeName Guid
            $parameters.ClientSecret = New-MockValue -TypeName String | ConvertTo-SecureString -Force -AsPlainText
            $parameters.TenantId     = New-MockValue -TypeName Guid
            break
        }
    }

    return New-SqlServerDatabaseConnectionInformation @parameters
}

