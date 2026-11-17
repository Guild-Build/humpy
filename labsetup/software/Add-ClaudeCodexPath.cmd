@echo off
setlocal DisableDelayedExpansion
rem Saved before any shift: shift also moves %0.
set "CC_PATH_DIR=%~dp0"
if /i "%~1"=="/?" goto help
if /i "%~1"=="--help" goto help
if /i "%~1"=="-Help" goto help
set "CC_PATH_ARGS="
:parse
if "%~1"=="" goto run
if /i "%~1"=="-Preview" (set "CC_PATH_ARGS=%CC_PATH_ARGS% -Preview"& shift& goto parse)
if /i "%~1"=="-NoPause" (set "CC_PATH_ARGS=%CC_PATH_ARGS% -NoPause"& shift& goto parse)
echo ERROR: Use -Preview, -NoPause or -Help only. Nothing changed.
exit /b 2
:run
if not exist "%CC_PATH_DIR%Update-CliPath.cmd" goto missing
echo Adding the folders of claude and codex to this user's PATH.
call "%CC_PATH_DIR%Update-CliPath.cmd" -Tools "claude,codex"%CC_PATH_ARGS%
exit /b %ERRORLEVEL%
:missing
echo ERROR: Keep Update-CliPath.cmd in the same folder as this command. Nothing changed.
exit /b 2
:help
echo Double-click as the intended ordinary user. Adds the folders of the installed claude and codex
echo commands to this user's PATH through Update-CliPath.cmd, which must sit beside this file.
echo -Preview shows the change without writing. -NoPause skips the close prompt.
echo Nothing is installed. Machine PATH is never written. Open a fresh terminal afterwards.
exit /b 0
