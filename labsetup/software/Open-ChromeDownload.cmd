@echo off
setlocal DisableDelayedExpansion
if /i "%~1"=="--help" goto humpy_help
if /i "%~1"=="-Help" goto humpy_help
if /i "%~1"=="/?" goto humpy_help
if not "%~1"=="" goto humpy_bad_args
start "" "https://www.google.com/chrome/"
exit /b %ERRORLEVEL%
:humpy_bad_args
echo ERROR: Use --help or run without arguments. 1>&2
exit /b 2
:humpy_help
echo Open-ChromeDownload.cmd
echo Opens the official Chrome download page in the default browser.
exit /b 0
