@echo off
setlocal DisableDelayedExpansion
if /i "%~1"=="--help" goto humpy_help
if /i "%~1"=="-Help" goto humpy_help
if /i "%~1"=="/?" goto humpy_help
if not "%~2"=="" exit /b 2
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
set "LOCALNAME=%~1"
set "CLICK_RUN="
if not defined LOCALNAME set "CLICK_RUN=1"
echo Follow the prompts below.
if not defined LOCALNAME set /p "LOCALNAME=Existing local user name: "
if not defined LOCALNAME goto cancelled
setlocal EnableDelayedExpansion
"%SystemRoot%\System32\net.exe" localgroup Administrators "!COMPUTERNAME!\!LOCALNAME!" /add
set "ExitCode=!ERRORLEVEL!"
goto done
:cancelled
set "ExitCode=0"
:done
if defined CLICK_RUN pause
exit /b %ExitCode%
exit /b %ERRORLEVEL%
:humpy_help
echo Add-LocalAdmin.cmd
echo Add one existing local user to Administrators. Supply the name or enter it when prompted.
exit /b 0
