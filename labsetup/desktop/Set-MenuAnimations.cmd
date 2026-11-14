@echo off
setlocal DisableDelayedExpansion
echo LOW RISK: Tuning changes behavior; this is not a guaranteed RAM saving.
set "LAB_CLICK_PAUSE="
if "%~1"=="" set "LAB_CLICK_PAUSE=-NoPause"
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy Bypass -File "%~dp0Set-MenuAnimations.ps1" %* %LAB_CLICK_PAUSE%

set "ExitCode=%ERRORLEVEL%"
if "%~1"=="" pause
exit /b %ExitCode%
