@echo off
setlocal DisableDelayedExpansion
if /i "%~1"=="--help" goto humpy_help
if /i "%~1"=="-Help" goto humpy_help
if /i "%~1"=="/?" goto humpy_help
if not "%~1"=="" goto humpy_bad_args
setlocal DisableDelayedExpansion
echo WARNING: Activates the existing Windows High performance power plan now.
echo This may increase power use, heat and battery drain.
echo No timeout values are edited, but the selected plan's existing timeouts apply.
echo No restart, plan creation or policy bypass is performed.
set "PowerCfg=%SystemRoot%\System32\powercfg.exe"
set "HighPlan=8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c"
if not exist "%PowerCfg%" goto missing
"%PowerCfg%" /list | "%SystemRoot%\System32\findstr.exe" /I /L /C:"%HighPlan%"
if errorlevel 1 goto unavailable
echo Previous active plan:
"%PowerCfg%" /getactivescheme
if errorlevel 1 goto queryfailed
"%PowerCfg%" /setactive %HighPlan%
if errorlevel 1 goto failed
"%PowerCfg%" /getactivescheme | "%SystemRoot%\System32\findstr.exe" /I /L /C:"%HighPlan%"
if errorlevel 1 goto unverified
echo SUCCESS: High performance is the active plan at this check.
exit /b 0
:missing
echo ERROR: Windows powercfg.exe is unavailable. No change attempted.
exit /b 1
:unavailable
echo ERROR: The standard High performance plan was not found, or listing failed.
echo Modern Standby, the OS, or policy may limit available plans. No change attempted.
exit /b 1
:queryfailed
echo ERROR: Could not read the current plan. No change attempted.
exit /b 1
:failed
echo ERROR: Windows rejected the switch. Read its error above.
echo For Access denied, rerun from an administrator Command Prompt.
echo OS or enforced policy restrictions are not bypassed.
exit /b 1
:unverified
echo ERROR: The switch returned success, but the active plan could not be verified.
echo A change may have occurred; inspect powercfg /getactivescheme and policy.
exit /b 1
exit /b %ERRORLEVEL%
:humpy_bad_args
echo ERROR: Use --help or run without arguments. 1>&2
exit /b 2
:humpy_help
echo Set-HighPerformance.cmd
echo Activates the existing standard High performance power plan.
exit /b 0
