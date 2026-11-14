@echo off
setlocal DisableDelayedExpansion
set "LAB21_SELF=%~f0"
set "LAB21_VALUE="
set "LAB21_PREVIEW=0"
set "LAB21_NOPAUSE=0"
set "LAB21_HELP=0"
:parse
if "%~1"=="" goto run
if /i "%~1"=="-Value" goto value
if /i "%~1"=="-Preview" goto preview
if /i "%~1"=="-NoPause" goto nopause
if /i "%~1"=="-Help" goto help
if /i "%~1"=="on" goto on
if /i "%~1"=="true" goto on
if /i "%~1"=="off" goto off
if /i "%~1"=="false" goto off
goto invalid
:value
shift
if /i "%~1"=="on" goto on
if /i "%~1"=="true" goto on
if /i "%~1"=="off" goto off
if /i "%~1"=="false" goto off
goto invalid
:on
if defined LAB21_VALUE goto invalid
set "LAB21_VALUE=on"
shift
goto parse
:off
if defined LAB21_VALUE goto invalid
set "LAB21_VALUE=off"
shift
goto parse
:preview
set "LAB21_PREVIEW=1"
shift
goto parse
:nopause
set "LAB21_NOPAUSE=1"
shift
goto parse
:help
set "LAB21_HELP=1"
shift
goto parse
:invalid
echo ERROR: Use [-Value on^|off^|true^|false] [-Preview] [-NoPause] [-Help]. Nothing changed.
exit /b 2
:run
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoLogo -NoProfile -Command "$t=[IO.File]::ReadAllText($env:LAB21_SELF); $m='# LAB21_EMBEDDED_PS'; $i=$t.LastIndexOf($m); if($i -lt 0){throw 'Embedded command missing'}; & ([scriptblock]::Create($t.Substring($i+$m.Length))) -Value $env:LAB21_VALUE -Preview:($env:LAB21_PREVIEW -eq '1') -NoPause:($env:LAB21_NOPAUSE -eq '1') -Help:($env:LAB21_HELP -eq '1')"
exit /b %ERRORLEVEL%
# LAB21_EMBEDDED_PS
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
