Describe "verifying module integrity" -Tag "General" {

    BeforeAll {

        # get the module root directory
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
        $moduleRoot = Resolve-Path -Path "$PSScriptRoot\..\.." | Select-Object -ExpandProperty Path

        # local the first .psd1 file in the module root
        $moduleManifestPath = Get-ChildItem -Path $moduleRoot -Filter "*.psd1" | Select-Object -ExpandProperty FullName -First 1 

        # load the manifest path
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
        $manifest = Import-PowerShellDataFile -Path $moduleManifestPath

        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
        $public  = Get-ChildItem "$moduleRoot\Public" -Recurse -Filter *.ps1

        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
        $private = Get-ChildItem "$moduleRoot\Private" -Recurse -Filter *.ps1
    }

    Context "public and private function visibility is valid" {

        It "should export more than one or more functions" {
            @($manifest.FunctionsToExport).Count | Should -BeGreaterThan 0
        }
    
        It "should export all functions defined in the public folder"  {
            $functions = (Compare-Object -ReferenceObject $public.BaseName -DifferenceObject $manifest.FunctionsToExport | Where-Object SideIndicator -Like '<=').InputObject
            $functions | Should -BeNullOrEmpty
        }
    
        It "should not export any functions not defined in the public folder" {
            $functions = (Compare-Object -ReferenceObject $public.BaseName -DifferenceObject $manifest.FunctionsToExport | Where-Object SideIndicator -Like '=>').InputObject
            $functions | Should -BeNullOrEmpty
        }
        
        It "should not export any functions defined in the private folder" {
            $private | Where-Object -Property BaseName -In $manifest.FunctionsToExport | Should -BeNullOrEmpty
        }

    }

    Context "module properties are valid" {

        It "The module ID should not be blank" {
            $manifest.GUID | Should -Not -BeNullOrEmpty
        }

        It "The root module should not be blank" {
            $manifest.RootModule | Should -Not -BeNullOrEmpty
        }

        It "The module description should not be blank" {
            $manifest.Description | Should -Not -BeNullOrEmpty
        }

        It "The module version should not be blank" {
            $manifest.PowerShellVersion | Should -Not -BeNullOrEmpty
        }

        It "The module version should not be blank" {
            $manifest.PowerShellVersion | Should -Not -BeNullOrEmpty
        }

        foreach ( $assembly in $manifest.RequiredAssemblies )
        {
            if ( $assembly -match 'dll$' ) 
            {
                It "The file $assembly should exist" -TestCases @{ moduleRoot = $moduleRoot; assembly = $assembly } {
                    Test-Path "$moduleRoot\$assembly" | Should -Be $true
                }
            }
            else
            {
                It "The file $assembly should load from the GAC" -TestCases @{ moduleRoot = $moduleRoot; assembly = $assembly } {
                    { Add-Type -AssemblyName $assembly } | Should -Not -Throw
                }
            }
        }
    }
}
