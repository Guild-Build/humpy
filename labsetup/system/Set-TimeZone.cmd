@echo off
setlocal DisableDelayedExpansion
if /i "%~1"=="-Help" goto help
if /i "%~1"=="--help" goto help
if not "%~1"=="" goto usage
echo Current Windows time zone:
"%SystemRoot%\System32\tzutil.exe" /g
if errorlevel 1 goto failed
echo Available zones: use the exact ID on the line below each display name.
"%SystemRoot%\System32\tzutil.exe" /l
if errorlevel 1 goto failed
set "LAB_TIMEZONE="
set /p "LAB_TIMEZONE=Exact Windows time zone ID (blank cancels): "
if not defined LAB_TIMEZONE goto cancelled
set LAB_TIMEZONE | "%SystemRoot%\System32\findstr.exe" /R /X /C:"LAB_TIMEZONE=[A-Za-z0-9][A-Za-z0-9 .()+-]*" >nul
if errorlevel 1 goto invalid
setlocal EnableDelayedExpansion
echo WARNING: Changes this machine's time zone for all users to !LAB_TIMEZONE!.
echo No clock, NTP, service or automatic restart change. DST follows the chosen zone.
"%SystemRoot%\System32\tzutil.exe" /s "!LAB_TIMEZONE!"
if errorlevel 1 goto failed
echo Saved. Current Windows time zone:
"%SystemRoot%\System32\tzutil.exe" /g
if errorlevel 1 goto failed
set "ExitCode=0"
goto done
:cancelled
echo Cancelled. No time zone changed.
set "ExitCode=0"
goto done
:invalid
echo Invalid ID characters. Use an exact ID from the Windows list; no extra options.
set "ExitCode=2"
goto done
:failed
echo Windows could not complete the request. Read the error above; no policy is bypassed.
echo If access was denied, run from an authorized administrator terminal.
set "ExitCode=1"
goto done
:usage
echo Run without arguments for zone selection, or use -Help.
exit /b 2
:help
echo Set this machine's Windows time zone with native TZUTIL.
echo Run without arguments; entering an exact listed ID applies it. No zone is assumed.
echo Blank input cancels. No extra Y prompt, helper, PowerShell, clock sync or restart.
exit /b 0
:done
pause
exit /b %ExitCode%
