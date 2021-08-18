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
        return [Microsoft.SharePoint.Client.ClientContextExtensions]::Clone($Context, $Url)
    }
    end
    {
    }
}

