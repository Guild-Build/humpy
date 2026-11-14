@echo off
setlocal DisableDelayedExpansion
if /i "%~1"=="--help" goto humpy_help
if /i "%~1"=="-Help" goto humpy_help
if /i "%~1"=="/?" goto humpy_help
if not "%~1"=="" goto humpy_bad_args
setlocal DisableDelayedExpansion
echo WARNING: Disables idle sleep timers on AC and battery for the current power plan.
echo This increases power use and can drain a battery. DC is unused on machines without one.
echo Display timeouts, locking, hibernation, lid and power-button actions stay unchanged.
echo Policy, Modern Standby and critical-battery actions can still limit this setting.
echo No restart, sign-out or power-plan switch will be performed.
"%SystemRoot%\System32\fltmc.exe" >nul 2>&1
if errorlevel 1 goto need_admin
"%SystemRoot%\System32\powercfg.exe" /query SCHEME_CURRENT SUB_SLEEP
if errorlevel 1 goto query_failed
"%SystemRoot%\System32\powercfg.exe" /change standby-timeout-ac 0
if errorlevel 1 goto change_failed
"%SystemRoot%\System32\powercfg.exe" /change standby-timeout-dc 0
if errorlevel 1 goto change_failed
echo Windows accepted both idle sleep timeouts as Never. Current plan sleep settings:
"%SystemRoot%\System32\powercfg.exe" /query SCHEME_CURRENT SUB_SLEEP
if errorlevel 1 goto readback_failed
echo Under Sleep after, AC and DC indexes should both read 0x00000000.
echo This is not a guarantee the machine stays awake: policy or OS behavior may override.
echo If sleep is unavailable on this VM, these timers have no effect.
set "ExitCode=0"
goto done
:need_admin
echo ERROR: Administrator access could not be verified. No power settings changed.
echo Right-click this CMD and select Run as administrator.
set "ExitCode=1"
goto done
:query_failed
echo ERROR: Cannot read current-plan sleep settings. No power settings changed.
echo Read the Windows error above; this OS or VM may not expose sleep settings.
set "ExitCode=1"
goto done
:change_failed
echo ERROR: Windows rejected a sleep timeout change. An earlier change may remain.
echo Read the Windows error above. Policy or OS restrictions are not bypassed.
set "ExitCode=1"
goto done
:readback_failed
echo ERROR: Changes were accepted but read-back failed. Settings may already be changed.
set "ExitCode=1"
:done
pause
exit /b %ExitCode%
exit /b %ERRORLEVEL%
:humpy_bad_args
echo ERROR: Use --help or run without arguments. 1>&2
exit /b 2
:humpy_help
echo Disable-Sleep.cmd
echo Administrator only. Sets the current power plan idle sleep timeout to Never on AC and battery.
exit /b 0
