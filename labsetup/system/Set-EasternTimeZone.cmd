@echo off
setlocal DisableDelayedExpansion
if /i "%~1"=="/?" goto help
if /i "%~1"=="--help" goto help
if not "%~1"=="" exit /b 2
set "TZUTIL=%SystemRoot%\System32\tzutil.exe"
echo Setting this VM to Eastern time for all users, with daylight saving enabled.
"%TZUTIL%" /s "Eastern Standard Time"
if errorlevel 1 goto failed
"%TZUTIL%" /g | "%SystemRoot%\System32\findstr.exe" /i /x /l /c:"Eastern Standard Time"
if errorlevel 1 goto unverified
echo Verified: Eastern time is active.
pause
exit /b 0
:failed
echo Windows refused the change. If access was denied, run this file as administrator on the VM.
pause
exit /b 1
:unverified
echo The change was requested, but the active time zone could not be verified.
pause
exit /b 1
:help
echo Double-click on the intended VM. Sets Eastern Standard Time with normal daylight saving.
echo No typed zone or confirmation. Does not set the clock, configure NTP or restart Windows.
exit /b 0
