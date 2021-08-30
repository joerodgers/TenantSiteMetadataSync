function Get-DataTable
{
    [cmdletbinding()]
    param
    (
        # Name of the SQL database
        [Parameter(Mandatory=$true,ParameterSetName="Individual")]
        [string]$DatabaseName,

        # Name of the SQL server or SQL and instance name
        [Parameter(Mandatory=$true,ParameterSetName="Individual")]
        [string]$DatabaseServer,

        # Full connection string.  Necessary if using SQL authentication
        [Parameter(Mandatory=$true,ParameterSetName="ConnectionString")]
        [string]$ConnectionString,

        # TSQL statement
        [Parameter(Mandatory=$true,ParameterSetName="Individual")]
        [Parameter(Mandatory=$true,ParameterSetName="ConnectionString")]
        [string]$Query,

        # Hashtable of parameters to the SQL query.  Do not include the '@' character in the key name.
        [Parameter(Mandatory=$false,ParameterSetName="Individual")]
        [Parameter(Mandatory=$false,ParameterSetName="ConnectionString")]
        [HashTable]$Parameters = @{}
    )

    begin
    {
        if( $PSCmdlet.ParameterSetName -eq "Individual" )
        {
            $ConnectionString = "Data Source=$DatabaseServer;Initial Catalog=$DatabaseName;Integrated Security=True;Enlist=False;Connect Timeout=5"
        }
    }
    process
    {
        try
        {
            $dataSet     = New-Object System.Data.DataSet     
            $dataAdapter = New-Object System.Data.SqlClient.SqlDataAdapter( $Query, $ConnectionString )

            foreach( $Parameter in $Parameters.GetEnumerator() )
            {
                Write-PSFMessage -Level Debug -Message "Query parameter data: '@$($Parameter.Key)', Parameter Value: '$($Parameter.Value)'"
                $null = $dataAdapter.SelectCommand.Parameters.AddWithValue( "@$($Parameter.Key)", $Parameter.Value )
            }

            $dataAdapter.Fill($dataSet) | Out-Null
            return $dataSet.Tables[0]
        }
        catch
        {
            Write-PSFMessage -Level Critical -Message "Error executing query: '$query'" -Exception $_
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

