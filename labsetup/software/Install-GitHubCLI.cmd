@echo off
setlocal DisableDelayedExpansion
if /i "%~1"=="-Help" goto help
if /i "%~1"=="--help" goto help
if /i "%~1"=="/?" goto help
if not "%~1"=="" goto usage
echo WARNING: Installs GitHub CLI 2.104.0 for Windows x64 using its official MSI.
echo Administrator permission is required. No account login or forced reboot.
echo Downloads only from GitHub over HTTPS and checks the pinned official SHA256.
set "Native=%SystemRoot%\System32"
if exist "%SystemRoot%\Sysnative\cmd.exe" set "Native=%SystemRoot%\Sysnative"
if /i "%PROCESSOR_ARCHITECTURE%"=="AMD64" goto archok
if /i "%PROCESSOR_ARCHITEW6432%"=="AMD64" goto archok
echo ERROR: This installer is for Windows x64, not ARM64 or 32-bit Windows.
set "Result=2"
goto done
:archok
"%Native%\fltmc.exe" >nul 2>&1
if not errorlevel 1 goto admin
echo ERROR: Run this CMD as administrator from a local folder.
set "Result=5"
goto done
:admin
for %%T in (curl.exe certutil.exe findstr.exe msiexec.exe icacls.exe) do if not exist "%Native%\%%T" goto prerequisites
set "Stage=%ProgramData%\LabSnippets\GitHubCLI-2.104.0-%RANDOM%-%RANDOM%"
if exist "%Stage%" goto stagingfailed
mkdir "%Stage%"
if errorlevel 1 goto stagingfailed
"%Native%\icacls.exe" "%Stage%" /inheritance:r /grant:r "*S-1-5-18:(OI)(CI)F" "*S-1-5-32-544:(OI)(CI)F" >nul
if errorlevel 1 goto stagingfailed
echo Installer folder: "%Stage%"
"%Native%\curl.exe" --fail --show-error --location --proto =https --proto-redir =https --connect-timeout 20 --max-time 600 --output "%Stage%\GitHubCLI.msi" "https://github.com/cli/cli/releases/download/v2.104.0/gh_2.104.0_windows_amd64.msi"
if errorlevel 1 goto downloadfailed
"%Native%\certutil.exe" -hashfile "%Stage%\GitHubCLI.msi" SHA256 | "%Native%\findstr.exe" /I /X /C:"cc89beb33ee020669efac70270aff55ca3ad52321aa813307537f2fe9237cc6e" >nul
if errorlevel 1 goto hashfailed
echo Official SHA256 verified. Installing unattended; this may take a moment.
"%Native%\msiexec.exe" /i "%Stage%\GitHubCLI.msi" /qn /norestart REBOOT=ReallySuppress
set "Result=%ERRORLEVEL%"
echo MSI exit code: %Result%.
if "%Result%"=="0" echo SUCCESS: MSI completed. Open a new terminal and run gh --version.
if "%Result%"=="3010" echo SUCCESS: MSI requires a restart. Restart manually when ready.
if "%Result%"=="1641" echo WARNING: MSI reported a restart initiated despite restart suppression.
if not "%Result%"=="0" if not "%Result%"=="3010" if not "%Result%"=="1641" echo ERROR: MSI did not complete successfully. See the Windows Installer exit code above.
goto done
:downloadfailed
echo ERROR: Download failed. Nothing installed. Check the curl error above.
set "Result=2"
goto done
:hashfailed
echo ERROR: SHA256 check failed or is unavailable. Nothing installed.
set "Result=2"
goto done
:stagingfailed
echo ERROR: Cannot create or secure a new local installer folder. Nothing installed.
set "Result=2"
goto done
:prerequisites
echo ERROR: A required Windows tool is unavailable. Nothing installed.
echo Required: curl, certutil, findstr, icacls and msiexec.
set "Result=2"
:done
echo If downloaded, the MSI is retained in the staging folder.
pause
exit /b %Result%
:help
echo Install-GitHubCLI.cmd: Run as administrator from a local folder.
echo Pins official GitHub CLI 2.104.0 Windows x64 MSI and official SHA256.
echo Uses native curl, certutil and msiexec. No WinGet, Chocolatey or sibling files.
echo MSI installs unattended with restart suppression.
exit /b 0
:usage
echo ERROR: Run without arguments to install, or use -Help. Nothing installed.
exit /b 2
