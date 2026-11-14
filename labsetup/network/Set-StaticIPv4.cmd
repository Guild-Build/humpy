@echo off
setlocal DisableDelayedExpansion
if /i "%~1"=="--help" goto humpy_help
if /i "%~1"=="-Help" goto humpy_help
if /i "%~1"=="/?" goto humpy_help
if not "%~1"=="" goto humpy_bad_args
if not "%~1"=="" goto lab_click_ready
"%SystemRoot%\System32\fltmc.exe" >nul 2>&1
if not errorlevel 1 goto lab_click_ready
setlocal DisableDelayedExpansion
set "LAB_CLICK_FILE=%~f0"
set "LAB_CLICK_DIR=%~dp0"
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoLogo -NoProfile -Command "$ErrorActionPreference='Stop';try{if([Console]::IsInputRedirected -or [Console]::IsOutputRedirected){throw 'Open the CMD from Explorer for UAC; redirected invocations must use an appropriate existing token.'};$id=[Security.Principal.WindowsIdentity]::GetCurrent();$who=New-Object Security.Principal.WindowsPrincipal($id);if($who.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)){throw 'The native administrator check failed; no relaunch attempted.'};[Console]::WriteLine('Windows will ask for administrator permission.');$p=Start-Process -FilePath $env:LAB_CLICK_FILE -WorkingDirectory $env:LAB_CLICK_DIR -Verb RunAs -WindowStyle Normal -Wait -PassThru;exit $p.ExitCode}catch{[Console]::Error.WriteLine('Administrator launch cancelled or failed: '+$_.Exception.Message);exit 1223}"
set "ClickExitCode=%ERRORLEVEL%"
if "%ClickExitCode%"=="1223" goto lab_click_failed
if "%ClickExitCode%"=="9009" goto lab_click_failed
exit /b %ClickExitCode%
:lab_click_failed
echo Administrator launch or command returned code %ClickExitCode%.
pause
exit /b %ClickExitCode%
:lab_click_ready
setlocal DisableDelayedExpansion
setlocal EnableDelayedExpansion
echo Follow the prompts below.
echo.
netsh interface show interface
set "IFACE="
set "IP="
set "MASK="
set "GW="
set "DNS="
set "DNS2="
set /p "IFACE=Interface name from the list above: "
set /p "IP=Static IPv4 address: "
set /p "MASK=Subnet mask (for example 255.255.255.0): "
set /p "GW=Default gateway (or none): "
set /p "DNS=Primary DNS address: "
set /p "DNS2=Secondary DNS address (Enter to skip): "
for %%V in (IFACE IP MASK GW DNS) do if not defined %%V goto missing
echo Changing this adapter can disconnect RDP. Use the local or VM console.
netsh interface ipv4 set address name="!IFACE!" source=static address="!IP!" mask="!MASK!" gateway="!GW!" store=persistent
if errorlevel 1 goto failed
netsh interface ipv4 set dnsservers name="!IFACE!" source=static address="!DNS!" validate=no
if errorlevel 1 goto failed
if not defined DNS2 goto done
netsh interface ipv4 add dnsservers name="!IFACE!" address="!DNS2!" index=2 validate=no
if errorlevel 1 goto failed
goto done
:missing
echo Required value missing. No network settings changed.
goto failed

:done
echo.
pause
exit /b 0
:failed
echo.
echo Command failed. Read the Windows error above. Earlier changes may remain.
pause
exit /b 1
exit /b %ERRORLEVEL%
:humpy_bad_args
echo ERROR: Use --help or run without arguments. 1>&2
exit /b 2
:humpy_help
echo Set-StaticIPv4.cmd
echo Administrator only. Prompts for adapter, IPv4, mask, gateway and DNS. Use a local console.
exit /b 0
