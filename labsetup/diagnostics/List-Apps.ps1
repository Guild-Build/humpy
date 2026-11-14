#Requires -Version 5.1
[CmdletBinding()]
param(
    [string]$Value, [string]$ValueFile,
    [ValidateSet('Preview','Apply','Verify')][string]$Action='Preview',
    [string]$Name, [string]$Config, [string]$Receipt, [string]$StateDirectory,
    [switch]$Apply, [switch]$Yes, [switch]$NoPause, [switch]$Help
)
$ErrorActionPreference='Stop'
$code=0
try {
    if ($Help) {
        Get-Content -LiteralPath (Join-Path $PSScriptRoot 'List-Apps.md') | Out-Host
    } else {
        foreach ($key in $PSBoundParameters.Keys) {
            if ($key -notin @('Help','NoPause')) { throw "Unsupported read-only parameter: $key" }
        }
        Get-AppxPackage | Select-Object Name,PackageFullName,NonRemovable,IsFramework | Format-Table -AutoSize | Out-Host
    }
} catch { Write-Host ('BLOCKED: ' + $_.Exception.Message); $code=2 }
if (-not $NoPause -and -not [Console]::IsInputRedirected -and -not [Console]::IsOutputRedirected) {
    [void](Read-Host 'Press Enter to close')
}
exit $code
