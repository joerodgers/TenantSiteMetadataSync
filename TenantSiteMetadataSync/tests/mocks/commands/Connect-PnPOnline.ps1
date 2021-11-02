function Connect-PnPOnline
{
    param($Url, $ClientId, $Thumbprint, $Tenant, $ReturnConnection) 
}

Mock -CommandName "Connect-PnPOnline" -Verifiable -MockWith { return 1 }