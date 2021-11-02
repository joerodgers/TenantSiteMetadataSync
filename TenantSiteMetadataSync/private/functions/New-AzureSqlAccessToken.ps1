function New-AzureSqlAccessToken
{
    [cmdletbinding()]
    param
    (
        # Azure AD App Principal Application/Client Id
        [Parameter(Mandatory=$true)]
        [string]
        $ClientId,

        # Azure AD App Principal Application/Client Secret
        [Parameter(Mandatory=$true)]
        [SecureString]
        $ClientSecret,

        # Azure AD TenantId
        [Parameter(Mandatory=$true)]
        [string]
        $TenantId
    )

    begin
    {
        $body = @{ 
            grant_type    = "client_credentials" 
            client_id     = $ClientId
            client_secret = $ClientSecret | ConvertFrom-SecureString -AsPlainText
            resource      = "https://database.windows.net/"
         }
    }
    process
    {
        Invoke-RestMethod -Uri "https://login.microsoftonline.com/$TenantId/oauth2/token" -Method Post -Body $body | Select-Object -ExpandProperty access_token
    }
    end
    {
    }
}
