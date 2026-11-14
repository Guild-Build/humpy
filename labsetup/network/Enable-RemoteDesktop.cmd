@echo off
setlocal DisableDelayedExpansion
if /i "%~1"=="--help" goto humpy_help
if /i "%~1"=="-Help" goto humpy_help
if /i "%~1"=="/?" goto humpy_help
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
echo RDP: NLA on, TCP 3389, all network profiles, local subnet only.
echo.
if not "%~1"=="" goto usage
reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v UserAuthentication /t REG_DWORD /d 1 /f
if errorlevel 1 goto failed
netsh.exe advfirewall firewall set rule name="Humpy-LabSetup-5-RDP-TCP" new enable=yes dir=in action=allow protocol=TCP localport=3389 profile=any remoteip=localsubnet service=TermService >nul 2>&1
if errorlevel 1 netsh.exe advfirewall firewall add rule name="Humpy-LabSetup-5-RDP-TCP" dir=in action=allow protocol=TCP localport=3389 profile=any remoteip=localsubnet service=TermService enable=yes
if errorlevel 1 goto failed
reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f
if errorlevel 1 goto failed
sc.exe config TermService start= auto
if errorlevel 1 goto failed
sc.exe start TermService
if "%errorlevel%"=="1056" goto done
if errorlevel 1 goto failed

:done
echo.
echo Remote Desktop settings enabled. Use an allowed account with a nonblank password.
pause
exit /b 0
:failed
echo.
echo Failed. Read the Windows error above. Earlier changes may remain.
pause
exit /b 1
:usage
echo No arguments needed. Double-click this CMD and approve Windows UAC if requested.
pause
exit /b 2
:humpy_help
echo RDP: NLA on, TCP 3389, all network profiles, local subnet only.
echo Run without arguments to apply. Windows UAC may be required.
exit /b 0
