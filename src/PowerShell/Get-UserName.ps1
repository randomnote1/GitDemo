<#
    .SYNOPSIS
        Get the username of the current user.
#>
function Get-UserName
{
    [CmdletBinding()]
    param ()

    Write-Verbose -Message $env:USERNAME
}