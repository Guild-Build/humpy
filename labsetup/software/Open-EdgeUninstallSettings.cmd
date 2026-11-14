@echo off
setlocal DisableDelayedExpansion
if /i "%~1"=="--help" goto humpy_help
if /i "%~1"=="-Help" goto humpy_help
if /i "%~1"=="/?" goto humpy_help
if not "%~1"=="" goto humpy_bad_args
echo Find Microsoft Edge under Installed apps. Select Uninstall only if Windows offers it.
start "" ms-settings:appsfeatures
exit /b %ERRORLEVEL%
:humpy_bad_args
echo ERROR: Use --help or run without arguments. 1>&2
exit /b 2
:humpy_help
echo Open-EdgeUninstallSettings.cmd
echo Opens Installed apps. Does not uninstall Edge.
exit /b 0
