function Get-UserName
{
    [CmdletBinding()]
    param ()

    return $env:USERNAME
}