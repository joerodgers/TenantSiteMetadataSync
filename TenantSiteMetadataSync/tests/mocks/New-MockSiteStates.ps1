
function New-MockSiteState
{
    # keep in sync with New-MockTenantSiteData.ps1
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
}
