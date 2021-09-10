Import-Module Pester

$failedTestCount = $totalTestCount = 0

$testFailureResults = @()

$generalTests  = Get-ChildItem "$PSScriptRoot\general"   -Filter "*.Tests.ps1" -Recurse -ErrorAction Ignore
$functionTests = Get-ChildItem "$PSScriptRoot\functions" -Filter "*.Tests.ps1" -Recurse -ErrorAction Ignore

$configuration = New-PesterConfiguration
$configuration.TestResult.Enabled = $true
$configuration.Run.PassThru       = $true
$configuration.Output.Verbosity   = "Detailed"

foreach( $file in $generalTests )
{
    $configuration.TestResult.OutputPath = Join-Path -Path "$PSScriptRoot\..\..\TestResults" -ChildPath "$($file.BaseName).xml"
    $configuration.Run.Path              = $file.FullName

    $results = Invoke-Pester -Configuration $configuration

    foreach( $result in $results )
    {
        $totalTestCount  += $result.TotalCount
        $failedTestCount += $result.FailedCount

        $result.Tests | Where-Object Result -ne 'Passed' | ForEach-Object {

            $testFailureResults += [PSCustomObject] @{
                Block    = $_.Block
                Name	 = "It $($_.Name)"
                Result   = $_.Result
                Message  = $_.ErrorRecord.DisplayErrorMessage
            }
        }
    }
}


foreach( $file in $functionTests )
{
    $configuration.TestResult.OutputPath = Join-Path -Path "$PSScriptRoot\..\..\TestResults" -ChildPath "$($file.BaseName).xml"
    $configuration.Run.Path              = $file.FullName

    $results = Invoke-Pester -Configuration $configuration

    foreach( $result in $results )
    {
        $totalTestCount  += $result.TotalCount
        $failedTestCount += $result.FailedCount

        $result.Tests | Where-Object Result -ne 'Passed' | ForEach-Object {

            $testFailureResults += [PSCustomObject] @{
                Block    = $_.Block
                Name	 = "It $($_.Name)"
                Result   = $_.Result
                Message  = $_.ErrorRecord.DisplayErrorMessage
            }
        }
    }

}

[PSCustomObject] @{
    "Total Tests Executed" = $totalTestCount
    "Total Tests Passed"   = $totalTestCount - $failedTestCount
    "Total Tests Failed"   = $failedTestCount
}

$testFailureResults | Sort-Object Describe, Context, Name, Result, Message | Format-List

