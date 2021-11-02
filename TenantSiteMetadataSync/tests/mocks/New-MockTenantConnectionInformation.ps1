. $PSScriptRoot\New-MockValue.ps1

function New-MockTenantConnectionInformation
{
    return [PSCustomObject] @{
        ClientId   = New-MockValue -TypeName Guid
        Thumbprint = New-MockValue -TypeName String
        TenantName = New-MockValue -TypeName String
        TenantFQDN = New-MockValue -TypeName String
        TenantId   = New-MockValue -TypeName Guid
    }
}
