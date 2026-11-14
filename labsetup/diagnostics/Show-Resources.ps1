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
        Get-Content -LiteralPath (Join-Path $PSScriptRoot 'Show-Resources.md') | Out-Host
    } else {
        foreach ($key in $PSBoundParameters.Keys) {
            if ($key -notin @('Help','NoPause')) { throw "Unsupported read-only parameter: $key" }
        }
        Get-CimInstance Win32_OperatingSystem | Select-Object TotalVisibleMemorySize,FreePhysicalMemory,NumberOfProcesses,LastBootUpTime | Format-List | Out-Host
        Get-CimInstance Win32_Processor | Select-Object Name,LoadPercentage,NumberOfLogicalProcessors | Format-Table | Out-Host
    }
} catch { Write-Host ('BLOCKED: ' + $_.Exception.Message); $code=2 }
if (-not $NoPause -and -not [Console]::IsInputRedirected -and -not [Console]::IsOutputRedirected) {
    [void](Read-Host 'Press Enter to close')
}
exit $code
