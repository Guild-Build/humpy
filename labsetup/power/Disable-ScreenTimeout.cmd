@echo off
setlocal DisableDelayedExpansion
if /i "%~1"=="--help" goto humpy_help
if /i "%~1"=="-Help" goto humpy_help
if /i "%~1"=="/?" goto humpy_help
if not "%~1"=="" goto humpy_bad_args
setlocal DisableDelayedExpansion
echo WARNING: Disables automatic display-off on AC and battery for the current power plan.
echo Keeping a display on increases power use and drains batteries faster.
echo Sleep, locking, screen savers and the selected power plan are not changed.
echo Managed policy or unsupported VM hardware may prevent or override this setting.
echo DC is saved too, but has no practical effect on a machine without a battery.
echo.
echo Current display settings:
"%SystemRoot%\System32\powercfg.exe" /query SCHEME_CURRENT SUB_VIDEO
if errorlevel 1 goto failed
"%SystemRoot%\System32\powercfg.exe" /change monitor-timeout-ac 0
if errorlevel 1 goto failed
"%SystemRoot%\System32\powercfg.exe" /change monitor-timeout-dc 0
if errorlevel 1 goto failed
echo.
echo Windows accepted AC and DC display-off timeout of 0 minutes, meaning Never.
echo Display settings readback; VIDEOIDLE AC and DC indexes should both be 0x00000000:
"%SystemRoot%\System32\powercfg.exe" /query SCHEME_CURRENT SUB_VIDEO
if errorlevel 1 goto failed
echo Policy, sleep, locking or the remote client may still blank the screen.
set "ExitCode=0"
goto done
:failed
echo ERROR: Operation failed. Read the Windows error above; no policy bypass was attempted.
echo If access was denied, run this CMD as administrator. Unsupported settings need OS support.
echo An earlier timeout change may remain; changes are not rolled back automatically.
set "ExitCode=1"
:done
pause
exit /b %ExitCode%
exit /b %ERRORLEVEL%
:humpy_bad_args
echo ERROR: Use --help or run without arguments. 1>&2
exit /b 2
:humpy_help
echo Disable-ScreenTimeout.cmd
echo Sets the current power plan display-off timeout to Never on AC and battery.
exit /b 0
