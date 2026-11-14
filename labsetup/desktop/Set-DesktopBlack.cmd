@echo off
setlocal DisableDelayedExpansion
if /i "%~1"=="-Help" goto help
if /i "%~1"=="--help" goto help
if not "%~1"=="" goto usage
echo WARNING: Removes this user's desktop picture and sets the desktop color to solid black.
echo Run normally as the intended signed-in user, not as another account or administrator.
echo Lock screen, dark theme and taskbar settings are not changed.
echo No automatic sign-out, Explorer restart or managed-policy change.
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoLogo -NoProfile -Command "$ErrorActionPreference='Stop'; try { if ([Diagnostics.Process]::GetCurrentProcess().SessionId -eq 0) { throw 'Run normally in the intended user desktop session, not as a service.' }; foreach ($path in @('HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System','HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System','HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\ActiveDesktop','HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\ActiveDesktop','HKLM:\Software\Microsoft\Windows\CurrentVersion\PersonalizationCSP','HKLM:\Software\Microsoft\PolicyManager\current\device\Personalization')) { if (Test-Path -LiteralPath $path -ErrorAction Stop) { $p=Get-ItemProperty -LiteralPath $path -ErrorAction Stop; if ($p.PSObject.Properties['Wallpaper'] -or $p.NoChangingWallPaper -or $p.DesktopImageUrl -or $p.DesktopImagePath) { throw 'A wallpaper restriction or managed image is configured. Ask its administrator; no policy was changed.' }; }; }; $q=[char]34; Add-Type -Name DesktopBlackNative -Namespace Lab -MemberDefinition ('[DllImport('+$q+'user32.dll'+$q+', CharSet=CharSet.Unicode, SetLastError=true)] public static extern bool SystemParametersInfo(uint action,uint parameter,string value,uint flags); [DllImport('+$q+'user32.dll'+$q+', SetLastError=true)] public static extern bool SetSysColors(int count,int[] elements,int[] colors);'); $colors=Get-Item -LiteralPath 'HKCU:\Control Panel\Colors' -ErrorAction Stop; Set-ItemProperty -LiteralPath $colors.PSPath -Name Background -Value '0 0 0' -ErrorAction Stop; if (-not [Lab.DesktopBlackNative]::SetSysColors(1,[int[]]@(1),[int[]]@(0))) { throw 'Windows rejected the desktop background color.' }; if (-not [Lab.DesktopBlackNative]::SystemParametersInfo(20,0,'',3)) { throw ('Windows rejected removing the desktop picture. Error '+[Runtime.InteropServices.Marshal]::GetLastWin32Error()) }; Write-Host 'Desktop picture cleared and black color requested. Visible appearance is not verified.'; Write-Host 'If unchanged, refresh the desktop or reopen Settings > Personalization > Background.'; Write-Host 'No Explorer restart or sign-out was performed. Managed policy may override the preference.'; exit 0 } catch { Write-Host ('FAILED: '+$_.Exception.Message); Write-Host 'Earlier preference changes may remain; no automatic rollback.'; exit 2 }"
set "ExitCode=%ERRORLEVEL%"
goto done
:usage
echo Run without arguments or use -Help.
exit /b 2
:help
echo Set the current signed-in user's desktop to solid black without a picture.
echo Run normally to apply immediately. No helpers, elevation or automatic restart.
echo Requires permitted built-in Windows PowerShell and Windows desktop APIs.
echo Managed wallpaper restrictions stop the command; appearance is not verified here.
exit /b 0
:done
pause
exit /b %ExitCode%
