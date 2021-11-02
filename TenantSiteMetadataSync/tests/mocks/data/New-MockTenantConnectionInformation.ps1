function New-MockTenantConnectionInformation
{
    return [PSCustomObject] @{
        ClientId   = [Guid]::NewGuid()
        Thumbprint = "mock_certificate_thumbprint"
        TenantName = "mock_tenant"
        TenantFQDN = "mock_tenant.onmicrosoft.com"
        TenantId   = [Guid]::NewGuid()
    }
}
