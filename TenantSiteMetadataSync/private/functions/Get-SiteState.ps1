function Get-SiteState
{
    [CmdletBinding(DefaultParameterSetName="None")]
    param
    (
        [Parameter(Mandatory=$false,ParameterSetName="StateId")]
        [ValidateRange(-1,11)]
        [int]
        $StateId,

        [Parameter(Mandatory=$false,ParameterSetName="StateName")]
        [string]
        $StateName
    )
    
    begin
    {
        # keep in sync with New-MockTenantSiteData.ps1
        $states = @(
            [PSCustomObject] @{ Id = -1; State = "Unknown"   }
            [PSCustomObject] @{ Id =  0; State = "Creating"  }
            [PSCustomObject] @{ Id =  1; State = "Active"    }
            [PSCustomObject] @{ Id =  2; State = "Updating"  }
            [PSCustomObject] @{ Id =  3; State = "Renaming"  }
            [PSCustomObject] @{ Id =  4; State = "Error"     }
            [PSCustomObject] @{ Id =  5; State = "Deleted"   }
            [PSCustomObject] @{ Id =  6; State = "Deleting"  }
            [PSCustomObject] @{ Id =  7; State = "Recycling" }
            [PSCustomObject] @{ Id =  8; State = "Recycled"  }
            [PSCustomObject] @{ Id =  9; State = "Restoring" }
            [PSCustomObject] @{ Id = 10; State = "Recreating"}
            [PSCustomObject] @{ Id = 11; State = "New"       }
        )
    }
    process
    {
        if( $PSCmdlet.ParameterSetName -eq "StateId" )
        {
            return $states | Where-Object -Property Id -eq $StateId
        }
        elseif( $PSCmdlet.ParameterSetName -eq "StateName" )
        {
            return $states | Where-Object -Property State -eq $StateName
        }

        return ,$states
    }
    end
    {
    }
}


Get-SiteState -StateId 1

Get-SiteState -StateName "Active"
