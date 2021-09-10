Import-Module Pester

$generalTests  = Get-ChildItem "$PSScriptRoot\general"   -Filter "*.Tests.ps1" -Recurse -ErrorAction Ignore
$functionTests = Get-ChildItem "$PSScriptRoot\functions" -Filter "*.Tests.ps1" -Recurse -ErrorAction Ignore

foreach( $file in $generalTests )
{
    Invoke-Pester -Path $file.FullName -Output Detailed
}

foreach( $file in $functionTests )
{
    Invoke-Pester -Path $file.FullName -Output Detailed
}

