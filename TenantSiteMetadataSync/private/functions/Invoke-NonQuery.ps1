<#
 .Synopsis
    Executes the provided TSQL statement against the specified database and SQL instance.

 .EXAMPLE
    Invoke-NonQuery -DatabaseName "Users" -DatabaseServer "SQL01\INSTANCENAME" -Query "INSERT INTO Users (UserName, Email) VALUES ('johndoe', 'johndoe@contoso.com')"

 .EXAMPLE
    Invoke-NonQuery -DatabaseName "Users" -DatabaseServer "SQL01\INSTANCENAME" -Query "INSERT INTO Users (UserName, Email) VALUES (@UserName, @EmailAddress)" -Parameters @{ UserName = "johndoe"; EmailAddress = "johndoe@contoso.com" } 

 #>
 function Invoke-NonQuery
 {
    [CmdletBinding()]
    param
    (
        # Name of the SQL database
        [Parameter(Mandatory=$true)]
        [string]$DatabaseName,

        # Name of the SQL server or SQL and instance name
        [Parameter(Mandatory=$true)]
        [string]$DatabaseServer,

        # TSQL statement
        [Parameter(Mandatory=$true)]
        [string]$Query,

        # Hashtable of parameters to the SQL query.  Do not include the '@' character in the key name.
        [Parameter(Mandatory=$false)]
        [HashTable]$Parameters = @{},

        # SQL command timeout. Default is 30 seconds
        [Parameter(Mandatory=$false)]
        [int]$CommandTimeout = 30
    )

    begin
    {
        $connectionString = New-SqlConnectionString -DatabaseServer $DatabaseServer -DatabaseName $DatabaseName    
    }
    process
    {
        try
        {
            $connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)
            $connection.Open()

            $command = New-Object system.Data.SqlClient.SqlCommand($Query, $connection)     
            $command.CommandTimeout = $CommandTimeout

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

            $null = $command.ExecuteNonQuery()
        }
        catch
        {
            throw $_.Exception
        }
        finally
        {
            if($command)
            {
                $command.Dispose()
            }

            if($connection)
            {
                $connection.Close()
                $connection.Dispose()
            }
        }
    }
    end
    {
    }
}
 

