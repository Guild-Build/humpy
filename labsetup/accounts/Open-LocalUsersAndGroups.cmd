@echo off
setlocal
if /i "%~1"=="/?" goto help
if /i "%~1"=="--help" goto help
if not exist "%SystemRoot%\System32\lusrmgr.msc" (
  echo Local Users and Groups is not available on this Windows installation.
  pause
  exit /b 1
)
start "" "%SystemRoot%\System32\mmc.exe" "%SystemRoot%\System32\lusrmgr.msc"
exit /b %ERRORLEVEL%
:help
echo Opens the classic Local Users and Groups console on this machine.
echo No accounts or group memberships are changed by this launcher.
exit /b 0
