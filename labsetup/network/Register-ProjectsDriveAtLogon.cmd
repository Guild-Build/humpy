@echo off
setlocal
if /i "%~1"=="/?" goto help
if not "%~1"=="" exit /b 2
echo Run once on the target VM as the user who needs P:. Do not elevate.
echo Registers one limited task at that user's sign-in. It does not map P: now.
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoLogo -NoProfile -Command "try { $ErrorActionPreference='Stop'; if(-not (Test-Path -LiteralPath 'C:\Projects' -PathType Container)){throw 'C:\Projects does not exist.'}; $u=[Security.Principal.WindowsIdentity]::GetCurrent().Name; $n='Map-Projects-P-AtLogon'; $a=New-ScheduledTaskAction -Execute (Join-Path $env:SystemRoot 'System32\subst.exe') -Argument 'P: C:\Projects'; $t=New-ScheduledTaskTrigger -AtLogOn -User $u; $p=New-ScheduledTaskPrincipal -UserId $u -LogonType Interactive -RunLevel Limited; Register-ScheduledTask -TaskName $n -Action $a -Trigger $t -Principal $p -Description 'Map C:\Projects to P: for the signed-in user.' | Out-Null; Write-Host ('Registered '+$n+' for '+$u+'. Sign out and back in to verify P:.'); exit 0 } catch { [Console]::Error.WriteLine($_.Exception.Message); exit 1 }"
set "RC=%ERRORLEVEL%"
pause
exit /b %RC%
:help
echo Register-ProjectsDriveAtLogon.cmd
echo On the VM, run normally as the intended user. C:\Projects must exist and P: must be free at sign-in.
echo Use instead of a Startup-folder copy. This registers a task but does not run it now.
exit /b 0
