function ConvertTo-PSCustomObject
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [System.Data.DataRow[]]$DataRow
    )

    begin
    {
        $excludedProperties = "ItemArray", "Table", "RowError", "RowState", "HasErrors"
    }
    process
    {
        foreach( $row in $DataRow )
        {
            $row | Select-Object * -ExcludeProperty $excludedProperties | ConvertTo-Json | ConvertFrom-Json
        }
    }
    end
    {
    }
}