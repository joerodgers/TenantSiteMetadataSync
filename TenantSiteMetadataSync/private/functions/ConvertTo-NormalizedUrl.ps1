function ConvertTo-NormalizedUrl
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [string]
        $Url
    )
    
    begin
    {
    }
    process
    {
        $uri = New-Object System.Uri($Url)

        return [System.Web.HttpUtility]::UrlDecode( $uri.AbsoluteUri.ToString().TrimEnd('/') )
    }
    end
    {
    }
}

