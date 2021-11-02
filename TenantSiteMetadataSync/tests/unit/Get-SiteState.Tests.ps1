Set-StrictMode -Off

Describe "Testing Get-SiteState cmdlet" -Tag "UnitTest" {

    BeforeAll {
        Remove-Module -Name "TenantSiteMetadataSync" -Force -ErrorAction Ignore
        Import-Module -Name "$PSScriptRoot\..\..\TenantSiteMetadataSync.psd1" -Force
    }
    
    InModuleScope -ModuleName "TenantSiteMetadataSync" {

        It "should return <State> for Id <Id>" -ForEach @(
            @{ Id = -1; State = "Unknown"   }
            @{ Id =  0; State = "Creating"  }
            @{ Id =  1; State = "Active"    }
            @{ Id =  2; State = "Updating"  }
            @{ Id =  3; State = "Renaming"  }
            @{ Id =  4; State = "Error"     }
            @{ Id =  5; State = "Deleted"   }
            @{ Id =  6; State = "Deleting"  }
            @{ Id =  7; State = "Recycling" }
            @{ Id =  8; State = "Recycled"  }
            @{ Id =  9; State = "Restoring" }
            @{ Id = 10; State = "Recreating"}
            @{ Id = 11; State = "New"       }
        ) {
            (Get-SiteState -StateId $Id).State | Should -BeExactly $State
        }

        It "should return <Id> for State <State>" -ForEach @(
            @{ Id = -1; State = "Unknown"   }
            @{ Id =  0; State = "Creating"  }
            @{ Id =  1; State = "Active"    }
            @{ Id =  2; State = "Updating"  }
            @{ Id =  3; State = "Renaming"  }
            @{ Id =  4; State = "Error"     }
            @{ Id =  5; State = "Deleted"   }
            @{ Id =  6; State = "Deleting"  }
            @{ Id =  7; State = "Recycling" }
            @{ Id =  8; State = "Recycled"  }
            @{ Id =  9; State = "Restoring" }
            @{ Id = 10; State = "Recreating"}
            @{ Id = 11; State = "New"       }
        ) {
            (Get-SiteState -StateName $State).Id | Should -BeExactly $Id
        }

        It "should throw for invalid StateId <StateId>" -ForEach @(
            @{ StateId = -100 }
            @{ StateId = 100 }
        ){
            { Get-SiteState -StateId $StateId } | Should -Throw
        }

        It "should return array of site states" {
            Get-SiteState | Should -BeOfType [System.Object[]]
        }
    }
}
