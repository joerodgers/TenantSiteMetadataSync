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

        # SQL command timeout. Default is 30 seconds
        [Parameter(Mandatory=$false)]
        [int]
        $CommandTimeout = 30
    )

    begin
    {
    }
    process
    {
        try
        {
            $connection = New-SqlServerDatabaseConnection -DatabaseConnectionInformation $DatabaseConnectionInformation

            if( $connection )
            {
                $command = New-Object System.Data.SqlClient.SqlCommand($Query, $connection)     
                $command.CommandTimeout = $CommandTimeout

                foreach( $parameter in $Parameters.GetEnumerator() )
                {
                    if( $null -eq $parameter.Value )
                    {
                        Write-PSFMessage -Level Debug -Message "Parameter: $($parameter.Key), Value=DBNULL"
                        $null = $command.Parameters.AddWithValue( "@$($parameter.Key)", [System.DBNull]::Value )
                    }
                    else 
                    {
                        Write-PSFMessage -Level Debug -Message "Parameter: $($parameter.Key), Value='$parameter.Value'"
                        $null = $command.Parameters.AddWithValue( "@$($parameter.Key)", $parameter.Value )
                    }
                }

                Write-PSFMessage -Level Debug -Message "Executing Query: $Query"

                $null = $command.ExecuteNonQuery()
            }
        }
        catch
        {
            Stop-PSFFunction -Message "Failed to execute non-query." -EnableException $false -ErrorRecord $_
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
 

