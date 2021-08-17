# Guide for available variables and working with secrets:
# https://docs.microsoft.com/en-us/vsts/build-release/concepts/definitions/build/variables?tabs=powershell

# Needs to ensure things are Done Right and only legal commits to master get built

# define the module root
$moduleRoot = Resolve-Path -Path "$PSScriptRoot\.." | Select-Object -ExpandProperty Path

# Run internal pester tests
& "$moduleRoot\Tests\pester.ps1"
