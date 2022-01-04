. $PSScriptRoot\New-MockValue.ps1

function New-MockTenantConnectionInformation
{
    $tenantName = New-MockValue -TypeName String

    return [PSCustomObject] @{
        ClientId   = New-MockValue -TypeName Guid
        Thumbprint = New-MockValue -TypeName String
        TenantName = $tenantName
        TenantFQDN = "$tenantName.onmicrosoft.com"
        TenantId   = New-MockValue -TypeName Guid
    }
}
