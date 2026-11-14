@echo off
setlocal DisableDelayedExpansion
set "LAB25_SELF=%~f0"
set "LAB25_VALUE="
set "LAB25_PREVIEW=0"
set "LAB25_NOPAUSE=0"
set "LAB25_HELP=0"
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
if /i "%~1"=="reset" goto reset
goto invalid
:value
shift
if /i "%~1"=="on" goto on
if /i "%~1"=="true" goto on
if /i "%~1"=="off" goto off
if /i "%~1"=="false" goto off
if /i "%~1"=="reset" goto reset
goto invalid
:on
if defined LAB25_VALUE goto invalid
set "LAB25_VALUE=on"
shift
goto parse
:off
if defined LAB25_VALUE goto invalid
set "LAB25_VALUE=off"
shift
goto parse
:reset
if defined LAB25_VALUE goto invalid
set "LAB25_VALUE=reset"
shift
goto parse
:preview
set "LAB25_PREVIEW=1"
shift
goto parse
:nopause
set "LAB25_NOPAUSE=1"
shift
goto parse
:help
set "LAB25_HELP=1"
shift
goto parse
:invalid
echo ERROR: Use [-Value true^|false^|reset] [-Preview] [-NoPause] [-Help]. Nothing changed.
exit /b 2
:run
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoLogo -NoProfile -Command "$t=[IO.File]::ReadAllText($env:LAB25_SELF); $m='# LAB25_EMBEDDED_PS'; $i=$t.LastIndexOf($m); if($i -lt 0){throw 'Embedded command missing'}; & ([scriptblock]::Create($t.Substring($i+$m.Length))) -Value $env:LAB25_VALUE -Preview:($env:LAB25_PREVIEW -eq '1') -NoPause:($env:LAB25_NOPAUSE -eq '1') -Help:($env:LAB25_HELP -eq '1')"
exit /b %ERRORLEVEL%
# LAB25_EMBEDDED_PS
#Requires -Version 5.1
[CmdletBinding()]
param([string]$Value, [switch]$Preview, [switch]$NoPause, [switch]$Help)
$ErrorActionPreference='Stop'; $code=0
$path='HKLM:/SOFTWARE/Policies/Microsoft/Windows/WindowsUpdate/AU'
function Read-UpdatePolicy {
    if (-not (Test-Path -LiteralPath $path)) { return 'absent' }
    $key=Get-Item -LiteralPath $path
    if ('NoAutoUpdate' -notin $key.GetValueNames()) { return 'absent' }
    if ($key.GetValueKind('NoAutoUpdate') -ne 'DWord') { throw 'Existing NoAutoUpdate is not a DWORD; refusing to overwrite it.' }
    $current=$key.GetValue('NoAutoUpdate')
    if ($current -notin @(0,1)) { throw 'Unexpected NoAutoUpdate value; refusing to overwrite it.' }
    return [string]$current
}
try {
    if ($Help) {
        Write-Host 'Usage: Set-AutomaticUpdates.cmd [-Value true|false|reset] [-Preview] [-NoPause] [-Help]'
        Write-Host 'true/on disables automatic updates; false/off sets NoAutoUpdate=0; reset removes only this value.'
        Write-Host 'Writes require administrator rights. Blank input cancels.'
    } else {
        Write-Host 'HIGH RISK: Disabling automatic updates can leave known security vulnerabilities unpatched.'
        Write-Host 'Arrange manual patching. This does not guarantee that every update or restart is blocked.'
        Write-Host 'No services, Defender protection, network access or managed-policy enforcement are disabled.'
        Write-Host 'Home is unsupported. Domain/MDM policy may override this; Defender intelligence behavior is not guaranteed.'
        if ([string]::IsNullOrWhiteSpace($Value)) { $Value=Read-Host 'Disable automatic updates: true/false/reset (blank cancels)' }
        if ([string]::IsNullOrWhiteSpace($Value)) { Write-Host 'Cancelled; nothing changed.' }
        else {
            switch ($Value.Trim().ToLowerInvariant()) {
                {$_ -in @('true','on')} { $next='1' }
                {$_ -in @('false','off')} { $next='0' }
                'reset' { $next='absent' }
                default { throw 'Use true/on, false/off or reset. Nothing changed.' }
            }
            $edition=(Get-ItemProperty -LiteralPath 'HKLM:/SOFTWARE/Microsoft/Windows NT/CurrentVersion' -Name EditionID).EditionID
            if ($edition -notmatch '^(Professional|Enterprise|Education|Server|IoTEnterprise)') {
                throw ('Unsupported or unrecognized Windows edition: '+$edition+'. No policy written.')
            }
            $before=Read-UpdatePolicy
            Write-Host ('Before NoAutoUpdate: '+$before+'; requested: '+$next)
            Write-Host 'Keep the original value: restore 1 with true, 0 with false, or absent with reset.'
            if ($Preview) { Write-Host 'Preview only; nothing changed.' }
            elseif ($before -eq $next) { Write-Host 'Already set; nothing changed.' }
            else {
                $id=[Security.Principal.WindowsIdentity]::GetCurrent()
                $principal=New-Object Security.Principal.WindowsPrincipal($id)
                if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
                    throw 'Run from an administrator terminal or right-click Run as administrator.'
                }
                if ((Read-UpdatePolicy) -ne $before) { throw 'Policy changed before the write; rerun rather than overwrite.' }
                if ($next -eq 'absent') { Remove-ItemProperty -LiteralPath $path -Name NoAutoUpdate -ErrorAction Stop }
                else {
                    if (-not (Test-Path -LiteralPath $path)) { New-Item -Path $path -Force -ErrorAction Stop | Out-Null }
                    New-ItemProperty -LiteralPath $path -Name NoAutoUpdate -PropertyType DWord -Value ([int]$next) -Force -ErrorAction Stop | Out-Null
                }
                if ((Read-UpdatePolicy) -ne $next) { throw 'Policy readback mismatch. Inspect Windows Update and management policy.' }
                Write-Host ('Local policy readback matched: NoAutoUpdate='+$next)
                Write-Host 'Not proof of effective update behavior. Check Windows Update; policy refresh or restart may be needed.'
                Write-Host 'No refresh, restart, rollback or update installation was triggered.'
            }
        }
    }
} catch {
    Write-Host ('FAILED: '+$_.Exception.Message)
    Write-Host 'No policy bypass or automatic rollback. If a write occurred, it may remain.'
    $code=2
}
if (-not $NoPause -and -not [Console]::IsInputRedirected -and -not [Console]::IsOutputRedirected) { [void](Read-Host 'Press Enter to close') }
exit $code
