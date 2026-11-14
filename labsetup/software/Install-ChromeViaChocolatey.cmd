@echo off
if /i "%~1"=="/?" goto help
if not "%~1"=="" exit /b 2
echo WARNING: Installs Google Chrome using your configured Chocolatey source.
choco install googlechrome -y
set "RC=%ERRORLEVEL%"
echo Chocolatey exit code: %RC%
pause
exit /b %RC%
:help
echo Run as administrator on the target VM with Chocolatey already installed.
echo Installs Google Chrome through your configured Chocolatey source.
exit /b 0
