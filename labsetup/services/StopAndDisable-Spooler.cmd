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
set "SERVICE=Spooler"
if not "%~1"=="" goto usage
echo Stops printing and disables the Print Spooler startup. Printing will be unavailable.
echo Does not change SQL Server, Docker, WSL, Defender or Windows Update.
echo Current service configuration follows. No guaranteed RAM saving.
echo.
"%SystemRoot%\System32\sc.exe" qc %SERVICE%
if errorlevel 1 goto failed
"%SystemRoot%\System32\sc.exe" query %SERVICE%
if errorlevel 1 goto failed
echo.
"%SystemRoot%\System32\sc.exe" stop %SERVICE%
set "STOPCODE=%ERRORLEVEL%"
if not "%STOPCODE%"=="0" if not "%STOPCODE%"=="1062" goto failed
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -NonInteractive -Command "$ErrorActionPreference='Stop'; try { (Get-Service -Name $env:SERVICE).WaitForStatus('Stopped',[TimeSpan]::FromSeconds(15)); exit 0 } catch { [Console]::Error.WriteLine($_.Exception.Message); exit 1 }"
if errorlevel 1 goto failed
"%SystemRoot%\System32\sc.exe" config %SERVICE% start= disabled
if errorlevel 1 goto failed
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -NonInteractive -Command "$ErrorActionPreference='Stop'; try { $service=Get-Service -Name $env:SERVICE; if ($service.StartType -ne 'Disabled' -or $service.Status -ne 'Stopped') { throw 'Stopped/Disabled read-back did not match.' }; exit 0 } catch { [Console]::Error.WriteLine($_.Exception.Message); exit 1 }"
if errorlevel 1 goto failed
echo.
echo Verified: %SERVICE% is stopped and its startup is disabled.
echo See StopAndDisable-Spooler.md for the native undo commands.
pause
exit /b 0
:failed
echo.
echo Failed. Read the Windows error above. Earlier changes may remain; no automatic rollback.
pause
exit /b 1
:usage
echo No arguments needed. Double-click this CMD and approve Windows UAC if requested.
pause
exit /b 2
:humpy_help
echo Stops printing and disables the Print Spooler startup. Printing will be unavailable.
echo Run without arguments to apply. Windows UAC may be required.
exit /b 0
