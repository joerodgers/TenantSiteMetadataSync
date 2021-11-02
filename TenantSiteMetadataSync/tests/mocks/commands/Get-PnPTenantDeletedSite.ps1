function Get-PnPTenantDeletedSite
{
    param($Connection, $IncludePersonalSite, $Limit ) 
}

Mock -CommandName "Get-PnPTenantDeletedSite" -Verifiable -MockWith { New-MockDeletedSiteCollection }
