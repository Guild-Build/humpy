@echo off
setlocal DisableDelayedExpansion
if /i "%~1"=="--help" goto humpy_help
if /i "%~1"=="-Help" goto humpy_help
if /i "%~1"=="/?" goto humpy_help
if not "%~1"=="" goto humpy_bad_args
setlocal DisableDelayedExpansion
echo WARNING: Disables local idle locking. An unattended signed-in session is exposed.
echo Screen-saver and Dynamic Lock changes apply to the account running this command.
echo The machine inactivity timeout change applies to ALL users on this machine.
echo Run as administrator using the intended user's own account, not another admin.
echo No automatic sign-in, password removal, power changes, restart or sign-out.
echo Managed devices or enforced screen-saver policy are refused, not bypassed.
echo.
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoLogo -NoProfile -Command "$ErrorActionPreference='Stop'; try { $p=New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent()); if(-not $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)){throw 'Run this CMD as administrator with the intended user account.'}; if((Get-CimInstance Win32_ComputerSystem).PartOfDomain){throw 'Domain-joined device: local override refused.'}; $ds= & $env:SystemRoot\System32\dsregcmd.exe /status; if($LASTEXITCODE -ne 0){throw 'Cannot check device registration.'}; if($ds -match 'AzureAdJoined\s*:\s*YES'){throw 'Entra-joined device: local override refused.'}; if(Test-Path 'HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\Accounts'){if(@(Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\Accounts').Count){throw 'MDM account present: local override refused.'}}; if(Test-Path 'HKLM:\SOFTWARE\Microsoft\Enrollments'){foreach($k in Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\Enrollments'){$e=Get-ItemProperty $k.PSPath; if($e.ProviderID -or $e.UPN){throw 'Management enrollment detected: local override refused.'}}}; foreach($k in @('HKCU:\Software\Policies\Microsoft\Windows\Control Panel\Desktop','HKLM:\Software\Policies\Microsoft\Windows\Control Panel\Desktop')){if(Test-Path $k){$v=Get-ItemProperty $k; foreach($n in @('ScreenSaveActive','ScreenSaverIsSecure','ScreenSaveTimeOut','SCRNSAVE.EXE')){if($null -ne $v.$n){throw 'Screen-saver policy exists: local override refused.'}}}}; Write-Host ('Target user: '+[Security.Principal.WindowsIdentity]::GetCurrent().Name) } catch { Write-Host ('ERROR: '+$_.Exception.Message); exit 1 }"
if errorlevel 1 goto refused
"%SystemRoot%\System32\reg.exe" add "HKCU\Control Panel\Desktop" /v ScreenSaveActive /t REG_SZ /d 0 /f
if errorlevel 1 goto failed
"%SystemRoot%\System32\reg.exe" add "HKCU\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /v EnableGoodbye /t REG_DWORD /d 0 /f
if errorlevel 1 goto failed
"%SystemRoot%\System32\reg.exe" add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v InactivityTimeoutSecs /t REG_DWORD /d 0 /f
if errorlevel 1 goto failed
echo.
echo Saved: screen saver off, Dynamic Lock off, machine inactivity timeout disabled.
echo These saved settings may require your next manual sign-out/sign-in or restart.
echo Until then, do not assume the running session has changed.
echo Sleep/wake sign-in, presence sensing, RDP disconnects and external policies remain.
echo Management detection is conservative, not proof that every policy was detected.
echo If Windows still locks, check its effective policy; this command will not bypass it.
set "ExitCode=0"
goto done
:refused
echo Nothing changed. Resolve the rights or OS/policy limitation shown above.
set "ExitCode=1"
goto done
:failed
echo ERROR: Windows rejected a registry write. Earlier changes may remain.
set "ExitCode=1"
:done
pause
exit /b %ExitCode%
exit /b %ERRORLEVEL%
:humpy_bad_args
echo ERROR: Use --help or run without arguments. 1>&2
exit /b 2
:humpy_help
echo Disable-AutoLock.cmd
echo Administrator only. Disables idle locking; an unattended session can remain exposed.
exit /b 0
