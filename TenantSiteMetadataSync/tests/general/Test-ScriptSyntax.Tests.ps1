Describe 'Validating File Syntax' -Tag "General" {

    BeforeAll {

        # define the module root
        $moduleRoot = Resolve-Path -Path "$PSScriptRoot\..\.." | Select-Object -ExpandProperty Path
    
        # local the first .psd1 file in the module root
        $moduleManifestPath = Get-ChildItem -Path $moduleRoot -Filter "*.psd1" | Select-Object -ExpandProperty FullName -First 1 
    
        # local the first .psm1 file in the module root
        $modulePath = Get-ChildItem -Path $moduleRoot -Filter "*.psm1" | Select-Object -ExpandProperty FullName -First 1 
    
        # import the module and the manifest
        Import-Module -Name $moduleManifestPath -Force
        Import-Module -Name $modulePath -Force
    }

    $files = @()
    $files += Get-ChildItem -Path "$PSScriptRoot\..\..\Classes" -Recurse -ErrorAction Ignore -Filter *.ps1
    $files += Get-ChildItem -Path "$PSScriptRoot\..\..\Tests"   -Recurse -ErrorAction Ignore -Filter *.ps1
    $files += Get-ChildItem -Path "$PSScriptRoot\..\..\Private" -Recurse -ErrorAction Ignore -Filter *.ps1
    $files += Get-ChildItem -Path "$PSScriptRoot\..\..\Public"  -Recurse -ErrorAction Ignore -Filter *.ps1
    $files += Get-ChildItem -Path "$PSScriptRoot\..\..\"                 -ErrorAction Ignore -Filter *.psm1
    $files += Get-ChildItem -Path "$PSScriptRoot\..\..\"                 -ErrorAction Ignore -Filter *.psd1
    
    $testCases = $files | ForEach-Object { 
        @{ 
            FileName = $_.Name
            FilePath = $_.FullName 
        }
    }

    It "<FileName> should have no syntax errors" -TestCases $testCases {

        $tokens = $errors = $null

        $null = [System.Management.Automation.Language.Parser]::ParseFile( $FilePath, [ref] $tokens, [ref] $errors )

        $errors | Should -BeNullOrEmpty
	}
}
