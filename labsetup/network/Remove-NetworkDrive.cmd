@echo off
setlocal DisableDelayedExpansion
if /i "%~1"=="/?" goto help
if /i "%~1"=="--help" goto help
if not "%~1"=="" exit /b 2
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoLogo -NoProfile -Command "$ErrorActionPreference='Stop'; try { $m=@(Get-SmbMapping | Where-Object {$_.LocalPath -match '^[A-Z]:$'}); if(-not $m.Count){Write-Host 'No mapped network drives in this session.';exit 0}; $m | Format-Table LocalPath,RemotePath,Status -AutoSize | Out-Host; $d=(Read-Host 'Drive letter to disconnect (blank cancels)').Trim().ToUpperInvariant(); if(-not $d){exit 0}; if($d -notmatch '^[A-Z]:?$'){throw 'Enter one drive letter from the list.'}; $d=$d.TrimEnd(':')+':'; $hit=@($m | Where-Object {$_.LocalPath -ieq $d}); if($hit.Count -ne 1){throw 'That letter is not a unique SMB mapping in this session.'}; Write-Host ('Disconnecting '+$d+' '+$hit[0].RemotePath); Remove-SmbMapping -LocalPath $d -UpdateProfile -Confirm:$false; if(@(Get-SmbMapping | Where-Object {$_.LocalPath -ieq $d}).Count){throw 'Mapping still present.'}; Write-Host 'Mapping removed.'; exit 0 } catch { [Console]::Error.WriteLine($_.Exception.Message); exit 1 }"
set "RC=%ERRORLEVEL%"
pause
exit /b %RC%
:help
echo Run normally as the user who mapped the network drive. Choose one listed letter.
echo Disconnects only that SMB mapping and removes its reconnect entry. Does not delete files or remove SUBST drives.
exit /b 0
