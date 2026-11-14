@echo off
setlocal DisableDelayedExpansion
if /i "%~1"=="--help" goto help
if not "%~1"=="" goto usage
echo WARNING: Installs Google Chrome for all users. No automatic restart.
echo Requires Windows x64, administrator rights, curl.exe and Windows PowerShell.
echo No security policy is changed. A blocked download or signature check stops here.
"%SystemRoot%\System32\fltmc.exe" >nul 2>&1
if errorlevel 1 goto admin
if /i "%PROCESSOR_ARCHITECTURE%"=="AMD64" goto prerequisites
if /i "%PROCESSOR_ARCHITEW6432%"=="AMD64" goto prerequisites
echo ERROR: This installer requires Windows x64.
set "ExitCode=2"
goto finish
:prerequisites
set "CURL=%SystemRoot%\System32\curl.exe"
if exist "%SystemRoot%\Sysnative\curl.exe" set "CURL=%SystemRoot%\Sysnative\curl.exe"
if not exist "%CURL%" goto missing
if not exist "%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" goto missing
:staging
set "Stage=local staging"
set "CHROME_DIR=%ProgramData%\lab-snippets-chrome-%RANDOM%-%RANDOM%"
if exist "%CHROME_DIR%" goto collision
mkdir "%CHROME_DIR%"
if errorlevel 1 goto failed
rem Restrict this newly created staging folder, not any system or existing folder.
icacls "%CHROME_DIR%" /inheritance:r /grant:r "*S-1-5-18:(OI)(CI)F" "*S-1-5-32-544:(OI)(CI)F" >nul
if errorlevel 1 goto failed
set "CHROME_MSI=%CHROME_DIR%\ChromeEnterprise64.msi"
echo Staging: %CHROME_DIR%
set "Stage=official HTTPS download"
"%CURL%" --fail --location --proto =https --proto-redir =https --connect-timeout 30 --max-time 1800 --output "%CHROME_MSI%" "https://dl.google.com/dl/chrome/install/googlechromestandaloneenterprise64.msi"
if errorlevel 1 goto failed
set "Stage=Google publisher signature verification"
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoLogo -NoProfile -Command "$ErrorActionPreference='Stop'; try { $s=Get-AuthenticodeSignature -LiteralPath $env:CHROME_MSI; if ($s.Status -ne 'Valid' -or $null -eq $s.SignerCertificate -or $s.SignerCertificate.Subject -notmatch '(?:^|,\s*)(?:CN|O)=Google (?:LLC|Inc\.?)\s*(?:,|$)') { throw 'A valid Google publisher signature is required.' }; Write-Host 'Google publisher signature verified.'; exit 0 } catch { Write-Error $_; exit 2 }"
if errorlevel 1 goto failed
echo Installing Chrome.
set "Stage=Windows Installer"
start "" /wait "%SystemRoot%\System32\msiexec.exe" /i "%CHROME_MSI%" /qn /norestart REBOOT=ReallySuppress
set "ExitCode=%ERRORLEVEL%"
if "%ExitCode%"=="0" echo Chrome installation completed.
if "%ExitCode%"=="3010" echo Chrome installed. Restart required; restart manually when ready.
if not "%ExitCode%"=="0" if not "%ExitCode%"=="3010" echo Installation did not report success. MSI exit: %ExitCode%
echo MSI retained in "%CHROME_DIR%".
goto finish
:failed
set "ExitCode=%ERRORLEVEL%"
if "%ExitCode%"=="0" set "ExitCode=2"
echo FAILED at %Stage%. Exit code: %ExitCode%
echo Files retained at %CHROME_DIR%
goto finish
:collision
echo ERROR: Staging path already exists. Nothing overwritten; run again.
set "ExitCode=2"
goto finish
:admin
echo ERROR: Right-click this CMD and choose Run as administrator. Approve normal UAC.
set "ExitCode=5"
goto finish
:missing
echo ERROR: Built-in curl.exe or Windows PowerShell is unavailable. Nothing installed.
set "ExitCode=2"
goto finish
:finish
echo Exit code: %ExitCode%
pause
exit /b %ExitCode%
:usage
echo Usage: Install-Chrome.cmd [--help]
exit /b 2
:help
echo Run as administrator, to download and install official Chrome x64.
echo Requires native curl.exe and Windows PowerShell. No WinGet or Chocolatey.
echo Downloads to a unique restricted local ProgramData folder, verifies Google signature,
echo then runs Windows Installer silently. No automatic reboot. Exit 3010 means restart required.
echo Keeps the verified MSI in the staging folder. Security/policy blocks are reported, never bypassed.
exit /b 0
