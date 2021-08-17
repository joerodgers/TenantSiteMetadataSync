$modules = @( "Pester", "PSScriptAnalyzer" )

# define the module root
$moduleRoot = Resolve-Path -Path "$PSScriptRoot\.." | Select-Object -ExpandProperty Path

# local the first .psd1 file in the module root
$moduleManifestPath = Get-ChildItem -Path $moduleRoot -Filter "*.psd1" | Select-Object -ExpandProperty FullName -First 1 

# Automatically add missing dependencies
$data = Import-PowerShellDataFile -Path $moduleManifestPath

foreach ($dependency in $data.RequiredModules) 
{
    if ($dependency -is [string])
    {
        if ($modules -contains $dependency) { continue }
        $modules += $dependency
    }
    else
    {
        if ($modules -contains $dependency.ModuleName) { continue }
        $modules += $dependency.ModuleName
    }
}

foreach ($module in $modules)
{
    Install-Module $module -Force -SkipPublisherCheck -Repository 'PSGallery'
    Import-Module $module -Force -PassThru
}