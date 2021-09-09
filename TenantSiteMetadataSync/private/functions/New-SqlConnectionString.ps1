function New-SqlConnectionString
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

        # Connection timeout, default is 15
        [Parameter(Mandatory=$false)]
        [int]$ConnectTimeout = 15,

        # Application name, default is calling command.
        [Parameter(Mandatory=$false)]
        [string]$ApplicationName,

        # Application name, default is calling command.
        [Parameter(Mandatory=$false)]
        [switch]$Encrypt
    )

    begin
    {
        # attempt to define an application name if non provided
        if( -not $PSBoundParameters.Keys -contains "ApplicationName" )
        {
            $callingCommand = Get-PSCallStack | Select-Object -ExpandProperty Command -Last 1 
            
            if( $callingCommand -ne "<ScriptBlock>" )
            {
                $ApplicationName = $callingCommand
            }
        }
    }
    process
    {
        $sqlConnectionStringBuilder = New-Object System.Data.SqlClient.SqlConnectionStringBuilder
        $sqlConnectionStringBuilder.PSBase.InitialCatalog     = $DatabaseName
        $sqlConnectionStringBuilder.PSBase.DataSource         = $DatabaseServer
        $sqlConnectionStringBuilder.PSBase.IntegratedSecurity = $true
        $sqlConnectionStringBuilder.PSBase.ConnectTimeout     = $ConnectTimeout
        $sqlConnectionStringBuilder.PSBase.Encrypt            = $Encrypt.IsPresent

        if( $ApplicationName )
        {
            $sqlConnectionStringBuilder.PSBase.ApplicationName = $ApplicationName
        }
       
        return $sqlConnectionStringBuilder.PSBase.ConnectionString
    }
    end
    {
    }
}

