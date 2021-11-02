function New-MockParametersFromCmdletParameterList
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [object[]]$Parameters,
    
        [Parameter(Mandatory=$true)]
        [int]$Quantity
    )

    $mocks = @()

    for( $x = 0; $x -lt $Quantity; $x++ )
    {
        $mock = @{}

        foreach( $parameter in $parameters )
        {
            switch( $parameter.ParameterType.ToString() )
            {
                "DatabaseConnectionInformation"
                {
                    # do nothing
                }
                "System.Int32"
                {
                    $parameterValue = Get-Random -Minimum 0 -Maximum ([int32]::MaxValue) # random number between 0 and 2147483647
                    break
                }
                "System.Int64"
                {
                    $parameterValue = Get-Random -Minimum 0 -Maximum ([int64]::MaxValue) # random number between 0 and 9223372036854775807
                    break
                }
                "System.String"
                {
                    $parameterValue = -join (1..50 | Foreach-Object { [char](Get-Random -Minimum 32 -Maximum 128) }) # 50 char random string
                    break
                }
                "System.Guid"
                {
                    $parameterValue = [Guid]::NewGuid() # random guid
                    break
                }
                "System.Boolean"
                {
                    $parameterValue = $true, $false | Get-Random # random true/false
                    break
                }
                "System.DateTime"
                {
                    $parameterValue = Get-Date # today's day
                    break
                }
                "System.Nullable`1[System.DateTime]"
                {
                    $parameterValue = $null, (Get-Date) | Get-Random # $null or today's date
                    break
                }
                "System.Management.Automation.SwitchParameter"
                {
                    $parameterValue = $true, $false | Get-Random # random true/false
                    break
                }
                default
                {
                    throw "Unhandled parameter type '$($parameter.ParameterType.ToString())' found during parameter processing."
                }
            }

            if( $parameter.IsMandatory )
            {
                $mock[$parameter.Name] = $parameterValue
                continue
            }
            elseif( ($true, $false | Get-Random) ) 
            {
                $mock[$parameter.Name] = $parameterValue
                continue                
            }
        }

        $mocks += $mock
    }

    ,$mocks
}