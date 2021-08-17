function Stop-LogFile
{
    [CmdletBinding()]
    param
    (
    )

    begin
    {
    }
    process
    {
        try
        { 
            Stop-Transcript 
        }
        catch
        {
        }
    }
    end
    {
    }
}
