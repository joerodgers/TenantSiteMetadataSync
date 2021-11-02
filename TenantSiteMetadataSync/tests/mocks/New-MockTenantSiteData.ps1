. $PSScriptRoot\New-MockValue.ps1

function New-MockTenantSiteData
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [int]$Quantity
    )

    # keep in sync with Get-SiteState.ps1
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
    
    $mocks = @()

    for($x=0; $x -lt $Quantity; $x++)
    {
        $state = $states | Get-Random

        $mock = [PSCustomObject] @{
            DenyAddAndCustomizePages = "Enabled", "Disabled" | Get-Random
            GroupId                  = New-MockValue -TypeName Guid
            HubSiteId                = New-MockValue -TypeName Guid
            LastContentModifiedDate  = New-MockValue -TypeName DateTime
            LockState                = "Unlock", "NoAccess" | Get-Random
            PWAEnabled               = $null, "Enabled" | Get-Random 
            Url                      = New-MockValue -TypeName String
            Status                   = $state.Name
            State                    = $state.Id
            StorageQuota             = [int64]((New-MockValue -TypeName Int64) / 1MB)
            StorageUsageCurrent      = [int64]((New-MockValue -TypeName Int64) / 1MB)
            Template                 = New-MockValue -TypeName String
            Title                    = New-MockValue -TypeName String
            SharingCapability        = New-MockValue -TypeName String
            Id                       = New-MockValue -TypeName Guid
            RelatedGroupId           = New-MockValue -TypeName Guid -IncludeNulls
            Created                  = New-MockValue -TypeName DateTime
            ConditionalAccessPolicy  =  0, 1, 2, 3 | Get-Random
            OwnerEmail               = New-MockValue -TypeName String
            OwnerName                = New-MockValue -TypeName String
            SensitivityLabel         = New-MockValue -TypeName Guid -IncludeNulls
        }

        $mocks += $mock
    }

    ,$mocks
}

