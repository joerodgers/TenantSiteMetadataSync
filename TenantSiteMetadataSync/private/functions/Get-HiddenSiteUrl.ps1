function Get-HiddenSiteUrl
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [string]
        $Tenant
    )
    
    begin
    {
    }
    process
    {
        return "https://$Tenant.sharepoint.com/sites/contentTypeHub", 
               "https://$Tenant.sharepoint.com/sites/CompliancePolicyCenter", 
               "https://$Tenant-admin.sharepoint.com"
    }
    end
    {
    }
}


