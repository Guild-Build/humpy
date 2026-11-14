#Requires -Version 5.1
[CmdletBinding()]
param([string]$Receipt, [switch]$Preview, [switch]$NoPause, [switch]$Help)
$ErrorActionPreference='Stop'; $code=0
try {
    if ($Help) { Get-Content -LiteralPath (Join-Path $PSScriptRoot 'Restore-OptionalFeature.md') | Out-Host }
    else {
        . (Join-Path $PSScriptRoot 'Simple.ps1')
        Write-Host 'Restore one component using an existing compatible receipt. Not an app reinstall.'
        if (-not $Receipt) { $Receipt=Read-LabInput 'Exact .undo.json path (blank cancels)' }
        if ([string]::IsNullOrWhiteSpace($Receipt)) { Write-Host 'Cancelled.' }
        else { $code=Restore-LabRecord -Path $Receipt.Trim().Trim('"') -Trim -Preview:$Preview }
    }
} catch { Write-Host ('FAILED: ' + $_.Exception.Message); $code=2 }
if (-not $NoPause -and -not [Console]::IsInputRedirected -and -not [Console]::IsOutputRedirected) {
    [void](Read-Host 'Press Enter to close')
}
exit $code
