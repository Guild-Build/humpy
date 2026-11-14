@echo off
setlocal DisableDelayedExpansion
if /i "%~1"=="--help" goto humpy_help
if /i "%~1"=="-Help" goto humpy_help
if /i "%~1"=="/?" goto humpy_help
if not "%~1"=="" goto humpy_bad_args
setlocal
if exist "ChromeStandaloneSetup64.exe" (
  echo ChromeStandaloneSetup64.exe already exists in the current folder. Move it before downloading again.
  pause
  exit /b 1
)
curl.exe --fail --show-error --location --proto "=https" --proto-redir "=https" --remove-on-error --output "ChromeStandaloneSetup64.exe" "https://dl.google.com/chrome/install/ChromeStandaloneSetup64.exe"
set "RC=%ERRORLEVEL%"
if "%RC%"=="0" echo Saved: "%CD%\ChromeStandaloneSetup64.exe"
pause
exit /b %RC%
exit /b %ERRORLEVEL%
:humpy_bad_args
echo ERROR: Use --help or run without arguments. 1>&2
exit /b 2
:humpy_help
echo Download-ChromeStandalone.cmd
echo Downloads ChromeStandaloneSetup64.exe to the current folder. Does not install.
exit /b 0
