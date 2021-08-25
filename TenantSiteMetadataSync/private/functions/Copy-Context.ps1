function Copy-Context
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [string]$Context,

        [Parameter(Mandatory=$true)]
        [string]$Url
    )
    
    begin
    {
    }
    process
    {
        if( (Get-Command -Name "Get-PnPContext").Source -eq "PnP.PowerShell" )
        {
            return [Microsoft.SharePoint.Client.ClientContextExtensions]::Clone($Context, $Url, $null)
        }
  
        return [Microsoft.SharePoint.Client.ClientContextExtensions]::Clone($Context, $Url)
    }
    end
    {
    }
}

