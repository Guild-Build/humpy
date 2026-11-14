@echo off
setlocal DisableDelayedExpansion
rem Adapted startup-only operation from ChrisTitusTech/winutil, pinned commit 8ec33e211f0724974088806b8623b0aa8afe5fc4.
rem Exact MIT notice is embedded below and supplied in LICENSE. No WinUtil code is downloaded or run.
set "TITUS_SELF=%~f0"
set "TITUS_PREVIEW="
set "TITUS_NOPAUSE="
set "TITUS_ELEVATED="
:parse
if "%~1"=="" goto run
if /i "%~1"=="-Help" goto help
if /i "%~1"=="--help" goto help
if /i "%~1"=="-Preview" (set "TITUS_PREVIEW=1"& shift& goto parse)
if /i "%~1"=="-NoPause" (set "TITUS_NOPAUSE=1"& shift& goto parse)
if /i "%~1"=="-Elevated" (set "TITUS_ELEVATED=1"& shift& goto parse)
echo ERROR: Use no arguments, -Preview, -NoPause or -Help. No service change attempted.
exit /b 2
:help
echo lfsvc: set only its startup type to Disabled.
echo WARNING: Location-dependent applications and location features can stop working.
echo Double-click for UAC if needed, prior state and apply unless -Preview.
echo -Preview reads only. -NoPause skips closing prompt. True missing service is a no-op.
echo No stop/start, dependent change, reboot, shared helper or other setting change.
echo Actual Server/VM behavior has not been tested.
exit /b 0
:run
set "TITUS_PS=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"
if exist "%SystemRoot%\Sysnative\WindowsPowerShell\v1.0\powershell.exe" set "TITUS_PS=%SystemRoot%\Sysnative\WindowsPowerShell\v1.0\powershell.exe"
"%TITUS_PS%" -NoLogo -NoProfile -Command "try { $body=([IO.File]::ReadAllText($env:TITUS_SELF) -split '(?m)^# TITUS_SERVICE_BODY\r?$',2)[1]; if(-not $body){throw 'Embedded body missing'}; & ([scriptblock]::Create($body)) } catch { Write-Host ('FAILED: '+$_.Exception.Message); exit 1 }"
exit /b %ERRORLEVEL%
# TITUS_SERVICE_BODY
<#
MIT License

Copyright (c) 2022 CT Tech Group LLC

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
#>
$ServiceName='lfsvc'
$DesiredStartup='Disabled'
$RiskWarning='Location-dependent applications and location features can stop working.'
function Get-TargetService {
    try { $found=@(Get-Service -Name $ServiceName -ErrorAction Stop) }
    catch {
        if ($_.FullyQualifiedErrorId -like 'NoServiceFoundForGivenName,*') {
            return $null
        }
        throw
    }
    if ($found.Count -ne 1 -or $found[0].Name -ine $ServiceName) { throw 'Service provider did not return the one exact target.' }
    if (-not $found[0].PSObject.Properties['StartType'] -or -not $found[0].PSObject.Properties['Status']) {
        throw 'Startup/running-state inspection is unavailable on this provider; no change attempted.'
    }
    if ([string]$found[0].StartType -notin @('Automatic','AutomaticDelayedStart','Manual','Disabled')) { throw 'Unrecognized startup type; no change attempted.' }
    if ([string]$found[0].Status -notin @('Stopped','StartPending','StopPending','Running','ContinuePending','PausePending','Paused')) { throw 'Unrecognized running state; no change attempted.' }
    return $found[0]
}
function Show-State($Label,$Service) {
    Write-Host ("{0}: {1}; startup={2}; running state={3}" -f $Label,$ServiceName,$Service.StartType,$Service.Status)
}
function Is-Administrator {
    $id=[Security.Principal.WindowsIdentity]::GetCurrent()
    return (New-Object Security.Principal.WindowsPrincipal($id)).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}
function Invoke-StartupChange([bool]$Preview) {
    $before=Get-TargetService
    if ($null -eq $before) { Write-Host "NOT INSTALLED: $ServiceName. No-op; nothing configured."; return 0 }
    Show-State 'BEFORE' $before
    Write-Host "Requested startup only: $DesiredStartup. A running service need not stop; process count need not fall."
    if ($Preview) { Write-Host 'PREVIEW: no change.'; return 0 }
    if ([string]$before.StartType -eq $DesiredStartup) {
        $after=Get-TargetService
        if ($null -eq $after -or [string]$after.StartType -ne $DesiredStartup) { throw 'Startup changed during read-back; rerun to inspect. No configuration attempted.' }
        Show-State 'READ-BACK (already set)' $after
        return 0
    }
    if (-not (Is-Administrator)) { throw 'Administrator authorization is required. No change attempted.' }
    $current=Get-TargetService
    if ($null -eq $current -or [string]$current.StartType -ne [string]$before.StartType) { throw 'Service/startup changed before the write. Nothing configured.' }
    $script:ChangeAttempted=$true
    Set-Service -Name $ServiceName -StartupType $DesiredStartup -ErrorAction Stop
    $after=Get-TargetService
    if ($null -eq $after) { throw 'Service disappeared after the request; configuration result cannot be verified.' }
    Show-State 'READ-BACK' $after
    if ([string]$after.StartType -ne $DesiredStartup) { throw 'Requested startup did not verify. Inspect policy/service permissions; no bypass or automatic rollback.' }
    Write-Host 'VERIFIED: requested startup type only. No service/dependent was stopped or started; no reboot requested.'
    return 0
}
$ErrorActionPreference='Stop'
$script:ChangeAttempted=$false
$code=0
try {
    Write-Host "WARNING: $ServiceName startup -> $DesiredStartup for this machine."
    Write-Host $RiskWarning
    Write-Host 'Only this startup type changes. No forced stop, restart, other setting or policy bypass.'
    if ($env:TITUS_PREVIEW -ne '1' -and -not (Is-Administrator)) {
        if ($env:TITUS_ELEVATED -eq '1') { throw 'Administrator authorization is still unavailable after UAC; no relaunch loop.' }
        Write-Host 'Windows will ask for administrator permission; the elevated window will show prior state and apply.'
        $arguments=@('-Elevated')
        if ($env:TITUS_NOPAUSE -eq '1') { $arguments+='-NoPause' }
        $child=Start-Process -FilePath $env:TITUS_SELF -ArgumentList $arguments -Verb RunAs -WindowStyle Normal -Wait -PassThru -ErrorAction Stop
        if ($null -eq $child.ExitCode) { throw 'Elevated outcome unavailable; inspect its window. Success is not established.' }
        exit $child.ExitCode
    }
    $code=Invoke-StartupChange ($env:TITUS_PREVIEW -eq '1')
} catch {
    Write-Host ('FAILED: '+$_.FullyQualifiedErrorId+' | '+$_.Exception.Message)
    if ($script:ChangeAttempted) { Write-Host 'A configuration request was attempted; an earlier change may remain. No automatic rollback.' }
    $code=1
}
if ($env:TITUS_NOPAUSE -ne '1' -and -not [Console]::IsInputRedirected -and -not [Console]::IsOutputRedirected) { [void](Read-Host 'Press Enter to close') }
exit $code
