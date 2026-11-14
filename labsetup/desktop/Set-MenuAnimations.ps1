#Requires -Version 5.1
[CmdletBinding()]
param([string]$Value, [switch]$Preview, [switch]$NoPause, [switch]$Help)
$ErrorActionPreference='Stop'; $code=0
try {
    if ($Help) { Get-Content -LiteralPath (Join-Path $PSScriptRoot 'Set-MenuAnimations.md') | Out-Host }
    else {
        . (Join-Path $PSScriptRoot '../recovery/Simple.ps1')
        Write-Host 'Changes current-user menu animations, not a guaranteed speedup.'
        if (-not $Value) { $Value=Read-LabInput 'Menu animations: on/off (blank cancels)' }
        if ([string]::IsNullOrWhiteSpace($Value)) { Write-Host 'Cancelled.' }
        else {
            switch ($Value.Trim().ToLowerInvariant()) {
                {$_ -in @('on','true')} { $next=$true }
                {$_ -in @('off','false')} { $next=$false }
                default { throw 'Use on/off or true/false.' }
            }
            Assert-LabMachine 'menus'
            $before=Get-LabAnimation 'menus'
            Write-Host "Menu animation: $before -> $next. To restore, run with -Value $before."
            if ($before -eq $next) { Write-Host 'Already set.' }
            elseif ($Preview) { Write-Host 'Preview only.' }
            else {
                Get-LabAnimation 'menus' $next -Write
                if ((Get-LabAnimation 'menus') -ne $next) { throw 'Preference did not verify.' }
                Write-Host 'Verified.'
            }
        }
    }
} catch { Write-Host ('FAILED: ' + $_.Exception.Message); $code=2 }
if (-not $NoPause -and -not [Console]::IsInputRedirected -and -not [Console]::IsOutputRedirected) {
    [void](Read-Host 'Press Enter to close')
}
exit $code
