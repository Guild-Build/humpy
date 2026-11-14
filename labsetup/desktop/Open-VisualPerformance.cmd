@echo off
setlocal DisableDelayedExpansion
if /i "%~1"=="--help" goto humpy_help
if /i "%~1"=="-Help" goto humpy_help
if /i "%~1"=="/?" goto humpy_help
if not "%~1"=="" goto humpy_bad_args
setlocal DisableDelayedExpansion
echo This opens Windows Performance Options only; it does NOT apply a preset.
echo Run as the intended user, not as a different administrator account.
echo WARNING: Best performance can remove animations, shadows and font smoothing.
echo In Visual Effects, choose "Adjust for best performance", then Apply and OK.
echo The power plan is unchanged. No restart or sign-out is forced.
if not exist "%SystemRoot%\System32\SystemPropertiesPerformance.exe" goto missing
start "" /wait "%SystemRoot%\System32\SystemPropertiesPerformance.exe"
if errorlevel 1 goto failed
echo Dialog closed. This launcher cannot verify which settings you applied.
exit /b 0
:missing
echo ERROR: Windows Performance Options is unavailable at the expected system path.
echo Open Advanced system settings, then Performance Settings, manually.
pause
exit /b 1
:failed
echo ERROR: Windows could not open or complete the dialog. No settings were applied by this launcher.
pause
exit /b 1
exit /b %ERRORLEVEL%
:humpy_bad_args
echo ERROR: Use --help or run without arguments. 1>&2
exit /b 2
:humpy_help
echo Open-VisualPerformance.cmd
echo Opens Windows Performance Options. It does not change any preference.
exit /b 0
