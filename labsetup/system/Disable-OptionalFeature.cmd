@echo off
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
if /i "%~1"=="-Help" goto help
if /i "%~1"=="--help" goto help
if not "%~1"=="" goto usage
echo WARNING: Disabling a feature can break applications or dependent Windows roles.
echo Enter one exact feature to apply. No payload removal or automatic restart.
"%SystemRoot%\System32\dism.exe" /Online /Get-Features /Format:Table
set "ExitCode=%ERRORLEVEL%"
if not "%ExitCode%"=="0" goto failed
set "LAB_COMPONENT="
set /p "LAB_COMPONENT=Exact optional feature name from the list (blank cancels): "
if not defined LAB_COMPONENT goto cancelled
set LAB_COMPONENT | "%SystemRoot%\System32\findstr.exe" /R /X /C:"LAB_COMPONENT=[A-Za-z0-9][A-Za-z0-9_.-]*" >nul
if errorlevel 1 goto invalid
setlocal EnableDelayedExpansion
"%SystemRoot%\System32\dism.exe" /Online /Get-FeatureInfo /FeatureName:!LAB_COMPONENT!
set "ExitCode=!ERRORLEVEL!"
if not "!ExitCode!"=="0" goto failed
"%SystemRoot%\System32\dism.exe" /Online /Disable-Feature /FeatureName:!LAB_COMPONENT! /NoRestart
set "ExitCode=!ERRORLEVEL!"
if "!ExitCode!"=="3010" goto reboot
if not "!ExitCode!"=="0" goto failed
echo DISM completed the request. Read the output above.
goto done
:reboot
echo DISM requires a restart. Restart manually when ready, then inspect the feature.
goto done
:cancelled
echo Cancelled. No feature disabled.
set "ExitCode=0"
goto done
:invalid
echo Invalid name: use one exact feature name, letters, digits, dot, underscore or hyphen.
set "ExitCode=2"
goto done
:usage
echo This standalone CMD is interactive. Run without arguments, or use -Help.
set "ExitCode=2"
goto done
:help
echo Disable one online Windows optional feature using DISM.
echo Double-click, approve Windows UAC if requested, and enter one exact feature name to apply.
echo No sibling files needed. No payload removal or automatic restart.
echo Unsupported names, operating systems or policy restrictions remain DISM errors.
set "ExitCode=0"
goto done
:failed
echo DISM failed. Read its Windows error above; earlier effects may remain.
echo This command does not bypass managed policy or perform automatic rollback.
:done
if "%~1"=="" pause
exit /b %ExitCode%
