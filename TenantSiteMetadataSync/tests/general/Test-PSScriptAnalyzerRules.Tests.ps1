Describe "Validating code quality" {

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
    
    $files = @()
    $files += Get-ChildItem -Path "$PSScriptRoot\..\..\Classes" -Recurse -ErrorAction Ignore -Filter *.ps1
    $files += Get-ChildItem -Path "$PSScriptRoot\..\..\Private" -Recurse -ErrorAction Ignore -Filter *.ps1
    $files += Get-ChildItem -Path "$PSScriptRoot\..\..\Public"  -Recurse -ErrorAction Ignore -Filter *.ps1
    $files += Get-ChildItem -Path "$PSScriptRoot\..\..\"                 -ErrorAction Ignore -Filter *.psm1
    $files += Get-ChildItem -Path "$PSScriptRoot\..\..\"                 -ErrorAction Ignore -Filter *.psd1
    
    $rules = Get-ScriptAnalyzerRule

    foreach($rule in $rules)
    {
        Context "PSScriptAnalyzer rule $($rule.RuleName)" {

            $testCases = $files | ForEach-Object { 
                @{ 
                    FileName = $_.Name
                    FilePath = $_.FullName
                    RuleName = $rule.RuleName
                }
            }

            It "<FileName> should not violate rule: <RuleName>" -TestCases $testCases {
                $record = Invoke-ScriptAnalyzer -Path $FilePath -IncludeRule $RuleName -ExcludeRule "PSAvoidUsingConvertToSecureStringWithPlainText", "PSAvoidUsingEmptyCatchBlock", "PSAvoidTrailingWhitespace", "PSUseShouldProcessForStateChangingFunctions", "PSUseOutputTypeCorrectly" 

                if( $record )
                {
                    Write-Host $record.SuggestedCorrections
                }

                $record | Should -BeNullOrEmpty
            }
        }
    }
}

