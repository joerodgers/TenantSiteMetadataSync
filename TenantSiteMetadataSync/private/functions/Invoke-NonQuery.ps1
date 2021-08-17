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
 
         # Command Timeout
         [Parameter(Mandatory=$false,ParameterSetName="Individual")]
         [Parameter(Mandatory=$false,ParameterSetName="ConnectionString")]
         [int]$CommandTimeout=30, # The default is 30 seconds
 
         # Hashtable of parameters to the SQL query.  Do not include the '@' character in the key name.
         [Parameter(Mandatory=$false,ParameterSetName="Individual")]
         [Parameter(Mandatory=$false,ParameterSetName="ConnectionString")]
         [HashTable]$Parameters = @{}    )
 
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
             $connection = New-Object System.Data.SqlClient.SqlConnection($ConnectionString)
             $connection.Open()
 
             $command = New-Object system.Data.SqlClient.SqlCommand($Query, $connection)     
             $command.CommandTimeout = $CommandTimeout
 
             foreach( $Parameter in $Parameters.GetEnumerator() )
             {
                 $null = $command.Parameters.Add( "@$($Parameter.Key)", $Parameter.Value )
             }
 
             $command.ExecuteNonQuery() | Out-Null
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
 

