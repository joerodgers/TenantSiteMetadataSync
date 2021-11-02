# Force TLS 1.2 to communicate with Microsoft Graph API and SharePoint Online Tenant
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

foreach ($function in (Get-ChildItem "$PSScriptRoot\classes" -Filter "*.ps1" -Recurse -ErrorAction Ignore))
{
    Write-Verbose "Importing class file: '$($function.FullName)'"
    . $function.FullName
}

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


