<#
    .SYNOPSIS
        Get the username of the current user.
#>
function Get-UserName
{
    [CmdletBinding()]
    param ()

    return $env:USERNAME
}