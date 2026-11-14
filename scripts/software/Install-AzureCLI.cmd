@echo off
setlocal DisableDelayedExpansion
if /i "%~1"=="--help" goto help
if not "%~1"=="" goto usage
echo WARNING: Downloads and installs or upgrades Microsoft Azure CLI x64 for this machine.
echo Run as administrator. Silent MSI installation; no forced reboot or Azure login.
echo Uses Microsoft's official HTTPS download and requires a valid Microsoft signature.
echo Installer stays in a new restricted folder beside this CMD.
echo No security-policy bypass or automatic elevation is attempted.
echo.
if /i "%PROCESSOR_ARCHITECTURE%"=="AMD64" goto archok
if /i "%PROCESSOR_ARCHITEW6432%"=="AMD64" goto archok
echo ERROR: Windows x64 is required. ARM64 and 32-bit Windows are not supported here.
exit /b 2
:archok
"%SystemRoot%\System32\fltmc.exe" >nul 2>&1
if errorlevel 1 goto admin
if not exist "%SystemRoot%\System32\curl.exe" goto nocurl
if not exist "%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" goto nops
set "AZCLI_STAGE=%~dp0AzureCLI-install-%RANDOM%-%RANDOM%"
if exist "%AZCLI_STAGE%" goto collision
mkdir "%AZCLI_STAGE%"
if errorlevel 1 goto stagefailed
"%SystemRoot%\System32\icacls.exe" "%AZCLI_STAGE%" /inheritance:r /grant:r "*S-1-5-18:(OI)(CI)F" "*S-1-5-32-544:(OI)(CI)F"
if errorlevel 1 goto aclfailed
set "AZCLI_MSI=%AZCLI_STAGE%\AzureCLI-x64.msi"
echo [1] Downloading the official Microsoft Azure CLI x64 MSI...
"%SystemRoot%\System32\curl.exe" --fail --location --proto "=https" --proto-redir "=https" --tlsv1.2 --connect-timeout 30 --max-time 1800 --output "%AZCLI_MSI%" "https://aka.ms/installazurecliwindowsx64"
set "ExitCode=%ERRORLEVEL%"
if not "%ExitCode%"=="0" goto downloadfailed
echo [2] Checking Microsoft Authenticode signature using a short PowerShell command...
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoLogo -NoProfile -Command "$ErrorActionPreference='Stop'; try { $s=Get-AuthenticodeSignature -LiteralPath $env:AZCLI_MSI; if($s.Status -ne 'Valid' -or $s.SignerCertificate.Subject -notmatch '(?:^|,\s*)O=Microsoft Corporation(?:,|$)'){throw 'A valid Microsoft Corporation signature is required.'}; Write-Host 'Microsoft signature verified.' } catch { Write-Host $_.Exception.Message; exit 2 }"
set "ExitCode=%ERRORLEVEL%"
if not "%ExitCode%"=="0" goto signaturefailed
echo [3] Installing silently. This may take several minutes.
"%SystemRoot%\System32\msiexec.exe" /i "%AZCLI_MSI%" /qn /norestart REBOOT=ReallySuppress
set "ExitCode=%ERRORLEVEL%"
if "%ExitCode%"=="0" echo Azure CLI installation completed. Open a new terminal to use az.
if "%ExitCode%"=="3010" echo Azure CLI installed; Windows requests a manual restart. No restart was forced.
if not "%ExitCode%"=="0" if not "%ExitCode%"=="3010" echo Windows Installer did not report success. See the exit code.
echo Windows Installer exit code: %ExitCode%
echo Retained folder: "%AZCLI_STAGE%"
pause
exit /b %ExitCode%
:admin
echo ERROR: Administrator check failed. Right-click this CMD and choose Run as administrator.
echo If Windows policy blocks it, this command cannot override that policy.
exit /b 5
:nocurl
echo ERROR: Built-in curl.exe is unavailable. No download or installation performed.
exit /b 2
:nops
echo ERROR: Windows PowerShell is unavailable; signature verification is required.
exit /b 2
:collision
echo ERROR: Staging folder already exists. Nothing overwritten; run again.
exit /b 2
:stagefailed
echo ERROR: Cannot create a staging folder beside this CMD. Use a writable local NTFS folder.
exit /b 2
:aclfailed
echo ERROR: Could not restrict staging-folder access. No download or installation performed.
exit /b 2
:downloadfailed
echo ERROR: Download failed with exit %ExitCode%. Nothing installed; partial download may remain.
exit /b %ExitCode%
:signaturefailed
echo ERROR: Signature verification or PowerShell launch failed with exit %ExitCode%.
echo Nothing installed. No alternate launch or policy bypass will be attempted.
exit /b %ExitCode%
:usage
echo ERROR: No installation arguments are supported. Use --help for instructions.
exit /b 2
:help
echo Install-AzureCLI.cmd: official Microsoft Azure CLI x64 MSI installer.
echo Run this CMD as administrator from a local NTFS folder. No extra scripts required.
echo WARNING: Installs or upgrades Azure CLI machine-wide. No Azure login or forced reboot.
echo Requires built-in curl, Windows PowerShell signature verification and Windows Installer.
echo Exit 0: installed. Exit 3010: installed, manual restart needed. Other codes: inspect output.
echo Installer is retained in a restricted subfolder beside this CMD.
exit /b 0
