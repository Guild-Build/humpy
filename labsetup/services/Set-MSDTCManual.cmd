@echo off
setlocal
if /i "%~1"=="/?" goto help
if not "%~1"=="" exit /b 2
echo Stops Distributed Transaction Coordinator and sets it to Manual.
echo Use only if this VM is not using distributed transactions.
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -Command "$ErrorActionPreference='Stop'; try { $p=[Security.Principal.WindowsPrincipal]::new([Security.Principal.WindowsIdentity]::GetCurrent()); if(-not $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)){throw 'Run this CMD as administrator.'}; $s=Get-Service -Name MSDTC; Write-Host ('Before: '+$s.Status+', '+$s.StartType); if($s.Status -ne 'Stopped'){Stop-Service -Name MSDTC; $s.WaitForStatus('Stopped',[TimeSpan]::FromSeconds(15))}; if($s.StartType -ne 'Manual'){Set-Service -Name MSDTC -StartupType Manual}; $s=Get-Service -Name MSDTC; if($s.Status -ne 'Stopped' -or $s.StartType -ne 'Manual'){throw 'Read-back did not match; check Services.'}; Write-Host 'Verified: MSDTC is stopped and set to Manual.'; exit 0 } catch { [Console]::Error.WriteLine($_.Exception.Message); exit 1 }"
set "RC=%ERRORLEVEL%"
pause
exit /b %RC%
:help
echo Run as administrator on the intended VM if distributed transactions are unused.
echo Stops MSDTC without forcing dependent services and sets it to Manual, not Disabled.
exit /b 0
