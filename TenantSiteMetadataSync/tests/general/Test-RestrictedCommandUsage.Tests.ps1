Describe "Validating not references to restricted commands" {

    BeforeAll {

        # define the module root
        $moduleRoot = Resolve-Path -Path "$PSScriptRoot\..\.." | Select-Object -ExpandProperty Path
    
        # local the first .psd1 file in the module root
        $moduleManifestPath = Get-ChildItem -Path $moduleRoot -Filter "*.psd1" | Select-Object -ExpandProperty FullName -First 1 
    
        # local the first .psm1 file in the module root
        $modulePath = Get-ChildItem -Path $moduleRoot -Filter "*.psm1" | Select-Object -ExpandProperty FullName -First 1 
    
        # force import all required modules
        $manifest = Import-PowerShellDataFile -Path $moduleManifestPath
        $manifest.RequiredModules | Foreach-Object { Import-Module -Name $_.ModuleName -RequiredVersion $_.RequiredVersion -Force }

        # import the module and the manifest
        Import-Module -Name $moduleManifestPath -Force
        Import-Module -Name $modulePath -Force
    }
    
    $restrictedCommands = @(

        'Write-Host', 'Write-Information'

        'Add-PSSnapIn'
    
        # Use CIM instead where possible
        'Get-WmiObject', 'Invoke-WmiMethod', 'Register-WmiEvent', 'Remove-WmiObject', 'Set-WmiInstance'

        # Use Get-WinEvent instead
        'Get-EventLog'
    )


    $files = @()
    $files += Get-ChildItem -Path "$PSScriptRoot\..\..\Private" -Recurse -ErrorAction Ignore -Filter *.ps1
    $files += Get-ChildItem -Path "$PSScriptRoot\..\..\Public"  -Recurse -ErrorAction Ignore -Filter *.ps1
    $files += Get-ChildItem -Path "$PSScriptRoot\..\..\"                 -ErrorAction Ignore -Filter *.psm1

    foreach(  $file in $files )
    {
        $tokens = $null
        $parseErrors = $null

        $null = [System.Management.Automation.Language.Parser]::ParseFile( $file.FullName, [ref]$tokens, [ref]$parseErrors)

        $testCases = $restrictedCommands | ForEach-Object { 
            @{ 
                FileName          = $file.Name
                FilePath          = $file.FullName
                RestrictedCommand = $_
                Tokens            = $tokens
            }
        }

        It "<FileName> should not contain command: '<RestrictedCommand>'" -TestCases $testCases {

            $tokens | Where-Object -Property Text -eq $RestrictedCommand | Should -BeNullOrEmpty

        }
    }
}

