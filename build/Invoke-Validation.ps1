# define the module root
$moduleRoot = Resolve-Path -Path "$PSScriptRoot" | Select-Object -ExpandProperty Path

# Run internal pester tests
& "$moduleRoot\Tests\pester.ps1"
