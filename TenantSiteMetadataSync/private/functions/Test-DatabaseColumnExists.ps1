 function Test-DatabaseColumnExists
 {
     [cmdletbinding()]
     param
     (
         # Name of the SQL database
         [Parameter(Mandatory=$true)]
         [string]$DatabaseName,
 
         # Name of the SQL server or SQL and instance name
         [Parameter(Mandatory=$true)]
         [string]$DatabaseServer,
 
         # Full connection string.  Necessary if using SQL authentication
         [Parameter(Mandatory=$true)]
         [string]$TableName,
 
         # Column Name
         [Parameter(Mandatory=$true)]
         [string]$ColumnName

    )
    begin
    {
        $connectionString = "Data Source=$DatabaseServer;Initial Catalog=$DatabaseName;Integrated Security=True;Enlist=False;Connect Timeout=5"
    }
    process
    {
        try
        {
            $returnValueParameter = New-Object System.Data.SqlClient.SqlParameter -Property @{
                SqlDbType     = [System.Data.SqlDbType]::Int
                Direction     = [System.Data.ParameterDirection]::ReturnValue
                ParameterName = "@ReturnValue"
            }

            $tableNameParameter = New-Object System.Data.SqlClient.SqlParameter -Property @{
                SqlDbType     = [System.Data.SqlDbType]::NVarChar
                Direction     = [System.Data.ParameterDirection]::Input
                ParameterName = "@TableName"
                Value         = $TableName
            }

            $columnNameParameter = New-Object System.Data.SqlClient.SqlParameter -Property @{
                SqlDbType     = [System.Data.SqlDbType]::NVarChar
                Direction     = [System.Data.ParameterDirection]::Input
                ParameterName = "@ColumnName"
                Value         = $ColumnName
            }

            $connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)
            $connection.Open()

            $command = New-Object System.Data.SqlClient.SqlCommand( "proc_ColumnExistsInTable", $connection )
            $command.CommandType = [System.Data.CommandType]::StoredProcedure

            $null = $command.Parameters.Add( $returnValueParameter )
            $null = $command.Parameters.Add( $tableNameParameter   )
            $null = $command.Parameters.Add( $columnNameParameter  )
            $null = $command.ExecuteNonQuery()

            return [bool]$command.Parameters["@ReturnValue"].Value
        }
        catch
        {
            throw $_.Exception
        }
        finally
        {
            if($connection)
            {
                [System.Data.SqlClient.SqlConnection]::ClearAllPools()
                $connection.Close()
                $connection.Dispose()
            }
        }
    }
    end
    {
    }
}

