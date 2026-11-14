#Requires -Version 5.1
[CmdletBinding()]
param([string]$Value, [switch]$Preview, [switch]$NoPause, [switch]$Help)
$ErrorActionPreference = 'Stop'
$code = 0
try {
    if ($Help) {
        Write-Host 'Usage: Set-DefenderIdleScanThrottle.cmd [-Value on|off|true|false] [-Preview] [-NoPause] [-Help]'
        Write-Host 'On enables idle-scan CPU throttling; off disables that throttle, not scanning.'
        Write-Host 'Run as administrator to apply. No automatic elevation or restart.'
    } else {
        Write-Host 'WARNING: Idle-scan CPU throttling may lengthen scans; disabling it may increase idle CPU use.'
        Write-Host 'Only DisableCpuThrottleOnIdleScans changes. Defender and scanning remain enabled.'
        Write-Host 'Policy, tamper protection and platform support may prevent or override this preference.'
        if ([string]::IsNullOrWhiteSpace($Value)) { $Value = Read-Host 'Throttle idle scans too: on/off (blank cancels)' }
        if ([string]::IsNullOrWhiteSpace($Value)) { Write-Host 'Cancelled; nothing changed.' }
        else {
            switch ($Value.Trim().ToLowerInvariant()) {
                { $_ -in @('on','true') } { $disableThrottle = $false }
                { $_ -in @('off','false') } { $disableThrottle = $true }
                default { throw 'Use on/off or true/false. Nothing changed.' }
            }
            $null = Get-Command Get-MpPreference -ErrorAction Stop
            $setter = Get-Command Set-MpPreference -ErrorAction Stop
            if (-not $setter.Parameters.ContainsKey('DisableCpuThrottleOnIdleScans')) {
                throw 'This Defender platform does not support DisableCpuThrottleOnIdleScans.'
            }
            $before = (Get-MpPreference -ErrorAction Stop).PSObject.Properties['DisableCpuThrottleOnIdleScans']
            if ($null -eq $before -or $null -eq $before.Value) { throw 'Defender did not expose the idle-scan throttle preference.' }
            Write-Host ('Before: DisableCpuThrottleOnIdleScans = ' + $before.Value)
            Write-Host ('Requested: DisableCpuThrottleOnIdleScans = ' + $disableThrottle)
            if ($Preview) { Write-Host 'Preview only; nothing changed.' }
            elseif ([bool]$before.Value -eq $disableThrottle) { Write-Host 'Already set; nothing changed.' }
            else {
                $id = [Security.Principal.WindowsIdentity]::GetCurrent()
                $principal = New-Object Security.Principal.WindowsPrincipal($id)
                if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
                    throw 'Run this CMD from an administrator terminal, or right-click Run as administrator.'
                }
                Set-MpPreference -DisableCpuThrottleOnIdleScans $disableThrottle -ErrorAction Stop
                $after = (Get-MpPreference -ErrorAction Stop).PSObject.Properties['DisableCpuThrottleOnIdleScans']
                if ($null -eq $after -or $null -eq $after.Value -or [bool]$after.Value -ne $disableThrottle) {
                    throw 'Readback did not match. Policy or tamper protection may have blocked the change; inspect Defender settings.'
                }
                Write-Host ('Preference readback matched: DisableCpuThrottleOnIdleScans = ' + $after.Value)
                Write-Host 'This verifies the preference only, not actual CPU use during a scan.'
            }
        }
    }
} catch {
    Write-Host ('FAILED: ' + $_.Exception.Message)
    Write-Host 'No policy bypass or automatic rollback. If a write occurred, its effect may remain.'
    $code = 2
}
if (-not $NoPause -and -not [Console]::IsInputRedirected -and -not [Console]::IsOutputRedirected) {
    [void](Read-Host 'Press Enter to close')
}
exit $code
