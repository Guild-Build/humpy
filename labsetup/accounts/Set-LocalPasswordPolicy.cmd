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
if not "%~1"=="" exit /b 2
echo WARNING: Local passwords will not expire and complexity checking is disabled.
echo Standalone lab machines only. Other policy settings are not included.
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -NonInteractive -Command "$ErrorActionPreference='Stop'; try { if ((Get-CimInstance Win32_ComputerSystem).DomainRole -notin 0,2) { throw 'Standalone lab machines only.' }; exit 0 } catch { [Console]::Error.WriteLine($_.Exception.Message); exit 1 }"
if errorlevel 1 goto failed
if not exist "%~dp0LocalPasswordPolicy.inf" goto failed
if not defined TEMP goto failed
if not exist "%TEMP%\." goto failed
set "WORK=%TEMP%\HumpyPolicy-%RANDOM%-%RANDOM%"
mkdir "%WORK%" || goto failed
"%SystemRoot%\System32\secedit.exe" /configure /db "%WORK%\apply.sdb" /cfg "%~dp0LocalPasswordPolicy.inf" /overwrite /areas SECURITYPOLICY
set "ExitCode=%ERRORLEVEL%"
del /q "%WORK%\apply.sdb" "%WORK%\apply.jfm" >nul 2>&1
rd "%WORK%" 2>nul
if exist "%WORK%\." echo Windows left temporary database files in "%WORK%".
if not "%ExitCode%"=="0" goto failed
echo Policy command completed. Verify maximum password age and complexity in Local Security Policy.
pause
exit /b 0
:failed
echo.
echo Policy not applied or not verified. Read the Windows error above; earlier changes may remain.
pause
exit /b 1
exit /b %ERRORLEVEL%
:humpy_bad_args
echo ERROR: Use --help or run without arguments. 1>&2
exit /b 2
:humpy_help
echo Set-LocalPasswordPolicy.cmd
echo Administrator only. Sets local passwords to never expire and disables complexity checks.
exit /b 0
