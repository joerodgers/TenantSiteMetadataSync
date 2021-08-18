<#
	.SYNOPSIS
		Installs the TenantSiteMetadataSync Module from github
		
	.DESCRIPTION
		This script installs the PSModuleDevelopment Module from github.
		
		It does so by ...
		- downloading the specified branch as zip to $env:TEMP
		- Unpacking that zip file to a folder in $env:TEMP
		- Moving that content to a module folder in either program files (default) or the user profile
	
	.PARAMETER Branch
		The branch to install. Installs master by default.
		Unknown branches will terminate the script in error.
	
	.PARAMETER Scope
		By default, the downloaded module will be moved to program files.
		Setting this to 'CurrentUser' installs to the userprofile of the current user.

	.PARAMETER Force
		The install script will overwrite an existing module.
#>
[CmdletBinding()]
Param 
(
	[Parameter(Mandatory=$false)]
	[string]$Branch = "main",
	
	[Parameter(Mandatory=$false)]
	[ValidateSet('AllUsers', 'CurrentUser')]
	[string]$Scope = "AllUsers",
	
	[Parameter(Mandatory=$false)]
	[switch]$Force
)

begin
{
	# force TLS 1.2 to communicate with Github
	[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

	# Name of the module that is being cloned
	$moduleName = "TenantSiteMetadataSync"
	
	# Name of the organization that is being cloned
	$organizationName = "joerodgers"

	# Base path to the github repository
	$baseUrl = "https://github.com/$organizationName/$moduleName"

	$fileName              = "$Branch.zip"
	$downloadDirectoryPath = Join-Path -Path $env:TEMP              -ChildPath $moduleName
	$downloadFilePath      = Join-Path -Path $downloadDirectoryPath -ChildPath "$moduleName-$fileName"

	$moduleInstallationRelativePath = "WindowsPowerShell\Modules\$moduleName"

	Remove-Module -Name $moduleName -Force -ErrorAction Ignore
}
process
{
	try 
	{
		# remove any previous downloads
		Remove-Item -Path $downloadFilePath      -Force -Recurse -ErrorAction Ignore
		Remove-Item -Path $downloadDirectoryPath -Force -Recurse -ErrorAction Ignore
		
		# create download directory
		$null = New-Item -Path $downloadDirectoryPath -ItemType Directory -Force -ErrorAction Stop

		# download files
		Write-Verbose "$(Get-Date) - Downloading $fileName to '$downloadFilePath'"
		Invoke-WebRequest -Uri "$($BaseUrl)/archive/$fileName" -MaximumRedirection 100 -UseBasicParsing -OutFile $downloadFilePath -ErrorAction Stop

		# extract zip
		Write-Verbose "$(Get-Date) - Extracting '$downloadFilePath' to '$downloadDirectory'"
		Expand-Archive -Path $downloadFilePath -DestinationPath $downloadDirectoryPath -ErrorAction Stop

		# locate the module manifest psd1 file
		Write-Verbose "$(Get-Date) - Searching for PowerShell manifest in $downloadDirectoryPath"
		$moduleManifestPath = Get-ChildItem -Path $downloadDirectoryPath -Recurse -Filter "*.psd1" | Select-Object -First 1 -ExpandProperty FullName

		# parse module manifest
		Write-Verbose "$(Get-Date) - Parsing PowerShell manifest at $moduleManifestPath"
		$moduleManifest = Import-PowerShellDataFile -Path $moduleManifestPath
		$moduleRootFolder = Split-Path -Path $moduleManifestPath

		# determine target installation root path
		switch($Scope)
		{
			"AllUsers"
			{
				$installationRootPath = $env:ProgramFiles 
			}
			"CurrentUser"
			{
				$installationRootPath = Split-Path -Path $profile.CurrentUserAllHosts
			}
		}

		# build the full path to the module installation directory
		$installationPath = Join-Path -Path $installationRootPath -ChildPath $moduleInstallationRelativePath

		# append the downloaded module version to the installation Path
		$installationPath = Join-Path -Path $installationPath -ChildPath $moduleManifest.ModuleVersion

		# stop if the this version is already installed for this scope, unless -Force was supplied
		if ( Test-Path -Path $installationPath -PathType Container )
		{
            if( -not $Force.IsPresent )
            {
			    Write-Error -Message "A module with the name '$moduleName' and version $($moduleManifest.ModuleVersion) already exists.  Use the -Force option to overwrite."
			    return
    	    }
            else
            {
		        Write-Warning "$(Get-Date) - Removing folder '$installationPath'"
                Remove-Item -Path $installationPath -Force -Recurse
            }
        }

		# create installation folder
		Write-Verbose "$(Get-Date) - Creating installation folder at '$installationPath'"
		$null = New-Item -Path $installationPath -ItemType Directory -Force -ErrorAction Stop
		
		# copy module files to folder 
		foreach ($file in (Get-ChildItem -Path $moduleRootFolder))
		{
			Write-Verbose "$(Get-Date) - Copying '$($file.FullName)'' to '$installationPath'"
			Copy-Item -Path $file.FullName -Destination $installationPath -Force -Recurse -ErrorAction Stop
		}
	}
	finally
	{
		# remove the downloaded folder
		Remove-Item -Path $downloadDirectoryPath -Recurse -Force -ErrorAction Ignore
	}
}
end
{
}


