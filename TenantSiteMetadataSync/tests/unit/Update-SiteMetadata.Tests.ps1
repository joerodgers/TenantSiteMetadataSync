Describe "Testing Update-SiteMetadata cmdlet" -Tag "UnitTest" {

    BeforeDiscovery {

        Remove-Module -Name "TenantSiteMetadataSync" -Force -ErrorAction Ignore
        Import-Module -Name "$PSScriptRoot\..\..\TenantSiteMetadataSync.psd1" -Force
    }

    InModuleScope -ModuleName "TenantSiteMetadataSync" {

        BeforeAll {

            . "$PSScriptRoot\..\mocks\New-MockDatabaseConnectionInformation.ps1"

            function Write-PSFMessage { param( $Level, $Message, $Exception )  }

            Mock -CommandName "Write-PSFMessage" -ModuleName "TenantSiteMetadataSync" -MockWith { if( $Exception ) { Write-Error "Pester Exception: Message: $Message. Exception: $Exception" } }
        }

        BeforeDiscovery {

            . "$PSScriptRoot\..\mocks\New-MockDatabaseConnectionInformation.ps1"
            . "$PSScriptRoot\..\mocks\New-MockSiteMetadata.ps1"
            . "$PSScriptRoot\ConvertTo-ScriptBlock.ps1"

            [Diagnostics.CodeAnalysis.SuppressMessageAttribute("UseDeclaredVarsMoreThanAssignments", "")]
            $testCases = New-MockSiteMetadata -Quantity 100
        }

        It "should update the site <_.SiteUrl> based on the test case values" -ForEach $testCases {

            $testCase = $_

            $parameters = @{}
            $parameters.SiteUrl = $testcase.SiteUrl.Value
            $parameters.DatabaseConnectionInformation = New-MockDatabaseConnectionInformation -DatabaseConnectionType "TrustedConnection"

            $parameterFilter = '$SiteUrl -eq "{0}"' -f $testcase.SiteUrl.Value

            foreach( $parameter in $testCase.GetEnumerator() )
            {
                if( $parameter.Name -eq "SiteUrl" )
                {
                     continue 
                }

                if( $null -eq $parameter.Value.Value -and $null -eq [System.Nullable]::GetUnderlyingType( $parameter.Value.Type) )
                {
                    continue
                }

                $parameters[$parameter.Name] = $parameter.Value.Value

                switch -Exact ( $parameter.Value.Type.ToString() )
                {
                    'System.Nullable`1[System.DateTime]'
                    {
                        if( $null -eq $parameter.Value.Value )
                        {
                            $parameterFilter += ' -and ${0} -eq $null' -f $parameter.Name
                        }
                        else
                        {
                            $parameterFilter += ' -and ${0}.Ticks -eq {1}' -f $parameter.Name, $parameter.Value.Value.Ticks
                        }
                        break
                    }
                    'System.Boolean'
                    {
                        $parameterFilter += ' -and ${0} -eq [bool]::Parse("{1}")' -f $parameter.Name, $parameter.Value.Value
                        break
                    }
                    'System.String'
                    {
                        $parameterFilter += ' -and ${0} -eq "{1}"' -f $parameter.Name, $parameter.Value.Value
                        break
                    }
                    'System.Guid'
                    {
                        $parameterFilter += ' -and ${0}.ToString() -eq "{1}"' -f $parameter.Name, $parameter.Value.Value
                        break
                    }
                    'System.DateTime'
                    {
                        $parameterFilter += ' -and ${0}.Ticks -eq {1}' -f $parameter.Name, $parameter.Value.Value.Ticks
                        break
                    }
                    'System.Int32'
                    {
                        $parameterFilter += ' -and ${0} -eq {1}' -f $parameter.Name, $parameter.Value.Value
                        break
                    }
                    'System.Int64'
                    {
                        $parameterFilter += ' -and ${0} -eq {1}' -f $parameter.Name, $parameter.Value.Value
                        break
                    }
                    default
                    {
                        throw "Missing test case parameter type check.  Missing type check for parameter type '$($parameter.Value.Type.ToString())'"
                    }
                }
            }
        
            $parameterFilter = [ScriptBlock]::Create( $parameterFilter )

            Mock `
                -CommandName "Invoke-NonQuery" `
                -ParameterFilter $parameterFilter `
                -Verifiable
        
            Update-SiteMetadata @parameters

            Should -InvokeVerifiable
       }
    }
}