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
