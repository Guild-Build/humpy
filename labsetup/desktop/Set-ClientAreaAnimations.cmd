@echo off
setlocal DisableDelayedExpansion
set "LAB18_SELF=%~f0"
set "LAB18_VALUE="
set "LAB18_PREVIEW="
set "LAB18_HELP="
set "LAB18_NOPAUSE="
:parse
if "%~1"=="" goto run
if /I "%~1"=="-Value" goto value
if /I "%~1"=="-Preview" (set "LAB18_PREVIEW=1"& shift& goto parse)
if /I "%~1"=="-NoPause" (set "LAB18_NOPAUSE=1"& shift& goto parse)
if /I "%~1"=="-Help" (set "LAB18_HELP=1"& shift& goto parse)
echo ERROR: Unknown argument. Use -Value on/off/true/false, -Preview, -NoPause or -Help.
exit /b 2
:value
if /I "%~2"=="on" (set "LAB18_VALUE=on"& goto valued)
if /I "%~2"=="off" (set "LAB18_VALUE=off"& goto valued)
if /I "%~2"=="true" (set "LAB18_VALUE=true"& goto valued)
if /I "%~2"=="false" (set "LAB18_VALUE=false"& goto valued)
echo ERROR: -Value requires on/off or true/false. Nothing changed.
exit /b 2
:valued
shift
shift
goto parse
:run
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoLogo -NoProfile -Command "try { $text=[IO.File]::ReadAllText($env:LAB18_SELF); $body=($text -split '(?m)^:LAB18_POWERSHELL\r?$',2)[1]; if (-not $body) { throw 'Embedded script missing.' }; & ([scriptblock]::Create($body)) -Value $env:LAB18_VALUE -Preview:($env:LAB18_PREVIEW -eq '1') -Help:($env:LAB18_HELP -eq '1') -NoPause:($env:LAB18_NOPAUSE -eq '1') } catch { Write-Host ('FAILED: '+$_.Exception.Message); exit 2 }"
exit /b %ERRORLEVEL%
:LAB18_POWERSHELL
#Requires -Version 5.1
[CmdletBinding()]
param([string]$Value, [switch]$Preview, [switch]$NoPause, [switch]$Help)
$ErrorActionPreference='Stop'
$code=0
try {
    if ($Help) {
        Write-Host 'Set-ClientAreaAnimations.cmd [-Value on|off|true|false] [-Preview] [-NoPause] [-Help]'
        Write-Host 'Sets only current-user client-area animations. Blank input cancels.'
    } else {
        Write-Host 'WARNING: Changes current-user client-area animations only; no guaranteed speedup.'
        Write-Host 'Menu animations are not changed. No Explorer restart, sign-out or elevation.'
        if ([string]::IsNullOrWhiteSpace($Value)) { $Value=Read-Host 'Animations: on/off or true/false (blank cancels)' }
        if ([string]::IsNullOrWhiteSpace($Value)) { Write-Host 'Cancelled.' }
        else {
            switch ($Value.Trim().ToLowerInvariant()) {
                { $_ -in @('on','true') } { $next=1 }
                { $_ -in @('off','false') } { $next=0 }
                default { throw 'Use on/off or true/false. No change attempted.' }
            }
            Add-Type @'
using System;
using System.Runtime.InteropServices;
public static class Lab18Animation {
    [DllImport("user32.dll", EntryPoint="SystemParametersInfoW", SetLastError=true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool Get(uint action, uint param, ref int value, uint flags);
    [DllImport("user32.dll", EntryPoint="SystemParametersInfoW", SetLastError=true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool Set(uint action, uint param, IntPtr value, uint flags);
}
'@
            $before=0
            if (-not [Lab18Animation]::Get(0x1042,0,[ref]$before,0)) {
                throw ('Cannot read client-area animations. Win32 error: '+[Runtime.InteropServices.Marshal]::GetLastWin32Error())
            }
            Write-Host ('Client-area animations: '+[bool]$before+' -> '+[bool]$next)
            Write-Host ('To restore: run this command with -Value '+(@('off','on')[[int][bool]$before]))
            if ($Preview) { Write-Host 'Preview only. Nothing changed.' }
            elseif ($before -eq $next) { Write-Host 'Already set. Nothing changed.' }
            else {
                if (-not [Lab18Animation]::Set(0x1043,0,[IntPtr]$next,3)) {
                    throw ('Windows rejected the change. Win32 error: '+[Runtime.InteropServices.Marshal]::GetLastWin32Error())
                }
                $after=0
                if (-not [Lab18Animation]::Get(0x1042,0,[ref]$after,0)) { throw 'Change attempted, but read-back failed; inspect the current user session.' }
                if ($after -ne $next) { throw 'Change did not verify. Policy or session restrictions may apply; no bypass attempted.' }
                Write-Host 'Verified: client-area animation preference saved and change notification broadcast.'
                Write-Host 'Apps or remote-session settings may ignore this preference; policy may override it later.'
            }
        }
    }
} catch { Write-Host ('FAILED: '+$_.Exception.Message); $code=2 }
if (-not $NoPause -and -not [Console]::IsInputRedirected -and -not [Console]::IsOutputRedirected) {
    [void](Read-Host 'Press Enter to close')
}
exit $code
