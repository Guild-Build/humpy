@echo off
setlocal DisableDelayedExpansion
if /i "%~1"=="/?" goto help
if /i "%~1"=="--help" goto help
if not "%~1"=="" exit /b 2
echo WARNING: Sets UAC to Never notify on this VM. Administrator apps can elevate without asking.
echo This changes the secure-desktop prompt setting too. Use only on the intended lab VM.
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoLogo -NoProfile -NonInteractive -Command "$ErrorActionPreference='Stop'; try { $id=[Security.Principal.WindowsIdentity]::GetCurrent(); $admin=[Security.Principal.WindowsPrincipal]::new($id); if(-not $admin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)){throw 'Right-click this CMD and choose Run as administrator on the VM.'}; $k='HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'; $old=Get-ItemProperty -LiteralPath $k; if($old.EnableLUA -ne 1){throw 'UAC is already disabled or its state is unknown. No settings changed.'}; Write-Host ('Previous values: ConsentPromptBehaviorAdmin='+$old.ConsentPromptBehaviorAdmin+', PromptOnSecureDesktop='+$old.PromptOnSecureDesktop); foreach($n in 'ConsentPromptBehaviorAdmin','PromptOnSecureDesktop'){New-ItemProperty -LiteralPath $k -Name $n -PropertyType DWord -Value 0 -Force | Out-Null}; $now=Get-ItemProperty -LiteralPath $k; if($now.EnableLUA -ne 1 -or $now.ConsentPromptBehaviorAdmin -ne 0 -or $now.PromptOnSecureDesktop -ne 0){throw 'Policy read-back did not match.'}; Write-Host 'Verified local settings: Never notify; EnableLUA remains 1. Group Policy may override these values.'; exit 0 } catch { [Console]::Error.WriteLine($_.Exception.Message); echo 'No automatic restart. If a write succeeded before a failure, it may remain applied.'; exit 1 }"
set "RC=%ERRORLEVEL%"
pause
exit /b %RC%
:help
echo Run as administrator on the intended lab VM. No typed input or automatic restart.
echo Sets Never notify only if EnableLUA is already 1. Does not disable UAC.
echo To restore your preferred prompt level, use Change User Account Control settings.
exit /b 0
