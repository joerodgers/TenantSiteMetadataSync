Describe "Validating file encoding" {

    BeforeAll {
        . $PSScriptRoot\Get-FileEncoding.ps1
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

    It "<FileName> should have 'Unicode (UTF-8)' encoding" -TestCases $testCases {
        Get-FileEncoding -Path $FilePath | Should -Be ([System.Text.Encoding]::UTF8.EncodingName)
    }
}

