function Assert-AccessTokenHasRole
{
<#
	.SYNOPSIS
		Throws terminating error if the current context does not contain the specified roles
	
	.DESCRIPTION
		Returns true if the current context contains the specified roles, otherwise false.
	
	.PARAMETER Cmdlet
		Calling PowerShell cmdlet

    .PARAMETER RequiredRole
		Array of role names to check against the current PnP context.
	
	.EXAMPLE
		PS C:\> Assert-AccessTokenHasRole -Cmdlet $PSCmdlet -RequiredRole "Sites.FullControl.All"
	
	.EXAMPLE
		PS C:\> Assert-AccessTokenHasRole -Cmdlet $PSCmdlet -RequiredRole "Sites.FullControl.All", "User.ReadWrite.All"
#>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [System.Management.Automation.Cmdlet]
        $Cmdlet,

        [Parameter(Mandatory=$true)]
        [string[]]
        $RequiredRole
    )

    begin
    {
        $token = $null
        
        $missingRoles = @()
    }
    process
    {
        Write-PSFMessage -Level Verbose -Message "Checking access token for roles '$($RequiredRole -join, ', ')'"

        try
        {
            $token = Request-PnPAccessToken -Decoded:$true -co
        }
        catch
        {
            $exception   = [System.Exception]::new($_.Exception.Message)
            $errorId     = "Access Token Validation Error"
            $category    = [System.Management.Automation.ErrorCategory]::ObjectNotFound
            $errorRecord = [System.Management.Automation.ErrorRecord]::new( $exception, $errorId, $category, $null)
        
            $Cmdlet.ThrowTerminatingError($errorRecord)
        }

        if( $token )
        {
            $tokenRoles = $token.Claims | Where-Object -Property "Type" -eq "roles" | Select-Object -ExpandProperty Value

            foreach( $rr in $RequiredRole )
            {
                if( $tokenRoles -notcontains $rr )
                {
                    $missingRoles += $rr
                }
            }
        }

        if( $missingRoles.Count -gt 0 )
        {
            $exception   = New-Object System.Exception("Access token missing roles '$($missingRoles -join ',')'")
            $errorId     = "Missing Roles"
            $category    = [System.Management.Automation.ErrorCategory]::InvalidArgument
            $errorRecord = [System.Management.Automation.ErrorRecord]::new($exception, $errorId, $category, $null)
        
            $Cmdlet.ThrowTerminatingError($errorRecord)
        }
    }
    end
    {
    }
}
