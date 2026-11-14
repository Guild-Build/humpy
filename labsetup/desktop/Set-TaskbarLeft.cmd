@echo off
setlocal DisableDelayedExpansion
if /i "%~1"=="/?" goto help
if /i "%~1"=="-Help" goto help
if not "%~1"=="" goto bad_args
echo WARNING: Sets taskbar alignment to Left for the current user on Windows 11 or Server 2025 Desktop Experience.
echo Run normally as the intended user; administrator rights are not needed.
echo No Explorer restart or sign-out is forced. Other taskbar settings stay unchanged.
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoLogo -NoProfile -Command "$ErrorActionPreference='Stop'; try { function Test-TaskbarSupport($ProductType,$Build,$InstallationType) { if($ProductType -eq 1){return ([int]$Build -ge 22000)}; return ($ProductType -in @(2,3) -and [int]$Build -eq 26100 -and $InstallationType -eq 'Server') }; $os=Get-CimInstance Win32_OperatingSystem; if($os.ProductType -eq 1 -and [int]$os.BuildNumber -lt 22000){Write-Host 'Windows 10 or earlier: centered Windows 11 taskbar alignment does not apply. Nothing changed.'; exit 0}; $installationType=''; if($os.ProductType -ne 1){$installationType=(Get-ItemProperty -LiteralPath 'HKLM:/SOFTWARE/Microsoft/Windows NT/CurrentVersion' -Name InstallationType).InstallationType}; if(-not (Test-TaskbarSupport $os.ProductType $os.BuildNumber $installationType)){throw 'Unsupported OS: requires Windows 11 client or Windows Server 2025 build 26100 Desktop Experience. Server Core and other Server releases are not supported.'}; $path='HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; if(-not (Test-Path -LiteralPath $path)){New-Item -Path $path -Force | Out-Null}; New-ItemProperty -LiteralPath $path -Name TaskbarAl -PropertyType DWord -Value 0 -Force | Out-Null; $actual=Get-ItemPropertyValue -LiteralPath $path -Name TaskbarAl; if($actual -ne 0){throw 'TaskbarAl read-back did not match.'}; Write-Host 'Saved and read back: TaskbarAl=0 (Left).'; Write-Host 'If unchanged visually, use Settings > Personalization > Taskbar > Taskbar behaviors > Taskbar alignment > Left.'; Write-Host 'Explorer may apply it later. Policy, custom shells or future Windows changes may override or ignore it.'; exit 0 } catch { [Console]::Error.WriteLine('FAILED: '+$_.Exception.Message); [Console]::Error.WriteLine('If writing succeeded before failure, the preference may remain changed.'); exit 2 }"
set "ExitCode=%ERRORLEVEL%"
pause
exit /b %ExitCode%
:bad_args
echo ERROR: No arguments are needed. Use /? for help.
exit /b 2
:help
echo Usage: Set-TaskbarLeft.cmd
echo Windows 11 or Server 2025 Desktop Experience current-user alignment only. Run normally, not as another user.
echo No administrator rights, Explorer restart or forced sign-out. Final pause keeps output visible.
echo Windows 10 and earlier: no change. Server requires build 26100 and Desktop Experience.
echo Server Core and other Server releases: unsupported.
exit /b 0
