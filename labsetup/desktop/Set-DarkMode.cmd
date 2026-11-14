@echo off
setlocal DisableDelayedExpansion
if /i "%~1"=="-Help" goto help
if /i "%~1"=="--help" goto help
if not "%~1"=="" exit /b 2
echo WARNING: Sets dark appearance for the current user's Windows and supported apps.
echo Other users are unchanged. Some apps override this preference or need reopening.
echo No administrator rights or automatic restart. Run as the user you want to change.
"%SystemRoot%\System32\reg.exe" add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v AppsUseLightTheme /t REG_DWORD /d 0 /f
if errorlevel 1 goto failed
"%SystemRoot%\System32\reg.exe" add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v SystemUsesLightTheme /t REG_DWORD /d 0 /f
if errorlevel 1 goto failed
echo Dark preferences saved. Reopen apps or sign out later if the appearance has not changed.
set "ExitCode=0"
goto done
:failed
echo Failed. Read the Windows error above; an earlier preference change may remain.
set "ExitCode=1"
:done
pause
exit /b %ExitCode%
:help
echo Sets current-user Windows and app dark mode. Run without arguments to apply.
exit /b 0
