# Force TLS 1.2 to communicate with Microsoft Graph API and SharePoint Online Tenant
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

$importIndividualFiles = $true

if( $importIndividualFiles )
{
	. "$PSScriptRoot\private\scripts\Invoke-PreImport.ps1"

    foreach ($function in (Get-ChildItem "$PSScriptRoot\private\functions" -Filter "*.ps1" -Recurse -ErrorAction Ignore))
    {
        Write-Verbose "Importing private file: '$($function.FullName)'"
        . $function.FullName
    }

    foreach ($function in (Get-ChildItem "$PSScriptRoot\public" -Filter "*.ps1" -Recurse -ErrorAction Ignore))
    {
        Write-Verbose "Importing public file: '$($function.FullName)'"
        . $function.FullName
    }

	. "$PSScriptRoot\private\scripts\Invoke-PostImport.ps1"

    return
}


