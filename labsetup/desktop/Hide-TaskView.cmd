@echo off
setlocal DisableDelayedExpansion
if /i "%~1"=="/?" goto help
if /i "%~1"=="-Help" goto help
if not "%~1"=="" goto bad_args
echo WARNING: Hides only the current user's Task View taskbar button.
echo Run normally as the intended user, not as another administrator account.
echo Search, other taskbar controls and virtual desktops are unchanged. Win+Tab remains available.
echo No Explorer restart or sign-out is forced.
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoLogo -NoProfile -Command "$ErrorActionPreference='Stop'; try { $path='HKCU:/Software/Microsoft/Windows/CurrentVersion/Explorer/Advanced'; if(-not (Test-Path -LiteralPath $path)){New-Item -Path $path -Force | Out-Null}; New-ItemProperty -LiteralPath $path -Name ShowTaskViewButton -PropertyType DWord -Value 0 -Force | Out-Null; $actual=Get-ItemPropertyValue -LiteralPath $path -Name ShowTaskViewButton; if($actual -ne 0){throw 'ShowTaskViewButton readback did not match.'}; Write-Host 'Saved and read back: ShowTaskViewButton=0. Visible appearance is NOT verified.'; Write-Host 'If still visible, open Taskbar settings and switch Task view off; alternatively sign out and back in when convenient.'; Write-Host 'Managed policy or a different shell may ignore this preference. No policy bypass was attempted.'; exit 0 } catch { [Console]::Error.WriteLine('FAILED: '+$_.Exception.Message); [Console]::Error.WriteLine('An attempted preference write may remain.'); exit 2 }"
set "ExitCode=%ERRORLEVEL%"
pause
exit /b %ExitCode%
:bad_args
echo ERROR: No arguments are needed. Use /? for help.
exit /b 2
:help
echo Usage: Hide-TaskView.cmd
echo Intended for Windows Server 2025 Desktop Experience, signed-in user only.
echo Writes only ShowTaskViewButton=0; does not change Search or disable virtual desktops.
echo No elevation, helper, forced Explorer restart or sign-out. Appearance requires your check.
exit /b 0
