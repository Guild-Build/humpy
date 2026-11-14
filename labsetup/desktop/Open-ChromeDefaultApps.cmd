@echo off
setlocal DisableDelayedExpansion
if /i "%~1"=="/?" goto help
if /i "%~1"=="-Help" goto help
if not "%~1"=="" goto bad_args
echo WARNING: Opens Windows Default apps for the current user to choose Google Chrome.
echo You must confirm in Windows. This command does NOT set the default itself.
echo Install Chrome first. Run normally as the intended user; no administrator rights needed.
echo No browser removal, policy takeover, registry bypass or restart.
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoLogo -NoProfile -Command "$ErrorActionPreference='Stop'; try { $os=Get-CimInstance Win32_OperatingSystem; if($os.ProductType -ne 1 -or [int]$os.BuildNumber -lt 10240){throw 'Requires Windows 10/11 desktop client with Settings.'}; $candidates=@(); foreach($root in @($env:LOCALAPPDATA,$env:ProgramFiles,[Environment]::GetEnvironmentVariable('ProgramFiles(x86)'))){if($root){$candidates+=Join-Path $root 'Google\Chrome\Application\chrome.exe'}}; foreach($key in @('HKCU:\Software\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe','HKLM:\Software\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe','HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe')){if(Test-Path -LiteralPath $key){$p=(Get-Item -LiteralPath $key).GetValue(''); if($p){$candidates+=[Environment]::ExpandEnvironmentVariables([string]$p).Trim([char]34)}}}; $found=@($candidates | Where-Object {Test-Path -LiteralPath $_ -PathType Leaf}); if($found.Count -eq 0){throw 'Chrome not found in registered App Paths or standard install folders. Install Chrome first, then rerun. Custom/portable installs may need Windows app registration.'}; Write-Host ('Chrome found: '+$found[0]); Write-Host 'Windows 11: select Google Chrome under Default apps, then click Set default.'; Write-Host 'Windows 10: under Web browser, choose Google Chrome and confirm Windows prompts.'; Write-Host 'If Chrome is missing from the choices, complete or repair its installation. Managed policy may prevent selection.'; Start-Process -FilePath 'ms-settings:defaultapps' -WindowStyle Normal -ErrorAction Stop; Write-Host 'Default apps launch requested. Choose Chrome there; no default-browser change has been verified.'; exit 0 } catch { [Console]::Error.WriteLine('FAILED: '+$_.Exception.Message); exit 2 }"
set "ExitCode=%ERRORLEVEL%"
pause
exit /b %ExitCode%
:bad_args
echo ERROR: No arguments are needed. Use /? for help.
exit /b 2
:help
echo Usage: Open-ChromeDefaultApps.cmd
echo Run normally after installing Google Chrome on Windows 10 or 11.
echo Opens Windows Default apps only. You select Chrome and confirm in Windows.
echo Does not silently change defaults or bypass policy. Final pause keeps instructions visible.
exit /b 0
