function Get-DataTable
{
    [CmdletBinding()]
    param
    (
        # Database Connection Information
        [Parameter(Mandatory=$true)]
        [DatabaseConnectionInformation]
        $DatabaseConnectionInformation,

        # TSQL statement
        [Parameter(Mandatory=$true)]
        [string]
        $Query,

        # Hashtable of parameters to the SQL query.  Do not include the '@' character in the key name.
        [Parameter(Mandatory=$false)]
        [HashTable]
        $Parameters = @{},

        # Specifies output type. Valid options for this parameter are 'DataSet', 'DataTable', 'DataRow', 'PSObject', and 'SingleValue'
        [Parameter(Mandatory=$false)]
        [ValidateSet("DataSet", "DataTable", "DataRow", "PSObject", "SingleValue")]
        [string]
        $As = "DataRow"
    )
    begin
    {
    }
    process
    {
        try
        {
            $connection = New-SqlServerDatabaseConnection -DatabaseConnectionInformation $DatabaseConnectionInformation

            $command = New-Object system.Data.SqlClient.SqlCommand($Query, $connection)     
            $command.CommandTimeout = $CommandTimeout

            $dataSet     = New-Object System.Data.DataSet     
            $dataAdapter = New-Object System.Data.SqlClient.SqlDataAdapter( $command )

            foreach( $parameter in $Parameters.GetEnumerator() )
            {
                if( $null -eq $parameter.Value )
                {
                    $null = $command.Parameters.AddWithValue( "@$($parameter.Key)", [System.DBNull]::Value )
                }
                else 
                {
                    $null = $command.Parameters.AddWithValue( "@$($parameter.Key)", $parameter.Value )
                }
            }

            $null = $dataAdapter.Fill($dataSet)

            switch( $As )
            {
                "DataSet"
                {
                    $dataSet
                }
                "DataTable"
                {
                    $dataSet.Tables
                }
                "DataRow"
                {
                    if ($dataSet.Tables.Count -gt 0)
                    {
                        $dataSet.Tables[0]
                    }                
                }
                "PSObject"
                {
                    if ($dataSet.Tables.Count -ne 0) 
                    {
                        $dataSet.Tables[0].Rows | ConvertTo-PSCustomObject
                    }
                }
                "SingleValue"
                {
                    if ($ds.Tables.Count -ne 0)
                    {
                        $dataSet.Tables[0] | Select-Object -ExpandProperty $dataSet.Tables[0].Columns[0].ColumnName
                    }         
                }
            }
        }
        catch
        {
            throw $_.Exception
        }
        finally
        {
            if($dataSet)
            {
                $dataSet.Dispose()
            }

            if($dataAdapter)
            {
                $dataAdapter.Dispose()
            }
        }
    }
    end
    {
    }
}

