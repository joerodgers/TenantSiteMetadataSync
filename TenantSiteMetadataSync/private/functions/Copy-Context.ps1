function Copy-Context
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [object]
        $Context,

        [Parameter(Mandatory=$true)]
        [string]
        $Url
    )
    
    begin
    {
    }
    process
    {
        return [Microsoft.SharePoint.Client.ClientContextExtensions]::Clone( $Context, $Url, $null )
    }
    end
    {
    }
}
