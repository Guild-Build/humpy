@echo off
setlocal DisableDelayedExpansion
set "LAB20_SELF=%~f0"
set "LAB20_ARGS=%*"
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoLogo -NoProfile -Command "$ErrorActionPreference='Stop'; try { $parts=[IO.File]::ReadAllText($env:LAB20_SELF) -split '(?m)^# POWERSHELL_PAYLOAD\r?$',2; if($parts.Count -ne 2){throw 'Embedded body missing.'}; & ([scriptblock]::Create($parts[1])) } catch { [Console]::Error.WriteLine('FAILED: '+$_.Exception.Message); exit 2 }"
exit /b %ERRORLEVEL%
# POWERSHELL_PAYLOAD
$ErrorActionPreference='Stop'
$code=0; $noPause=$false; $preview=$false; $help=$false; $value=$null
try {
    # Arguments are data, never PowerShell source.
    $tokens=@([regex]::Matches($env:LAB20_ARGS,'"[^"\r\n]*"|\S+') | ForEach-Object { $_.Value.Trim('"') })
    $noPause=$tokens -contains '-NoPause'
    for($i=0; $i -lt $tokens.Count; $i++) {
        switch -Regex ($tokens[$i]) {
            '^(?i)-Value$' {
                if($null -ne $value){throw 'Supply only one value.'}
                $i++; if($i -ge $tokens.Count){throw 'Missing value.'}
                $value=$tokens[$i]; break
            }
            '^(?i)-Preview$' { $preview=$true; break }
            '^(?i)-NoPause$' { $noPause=$true; break }
            '^(?i)(-Help|/\?)$' { $help=$true; break }
            '^\d+$' { if($null -ne $value){throw 'Supply only one value.'}; $value=$tokens[$i]; break }
            default { throw 'Unknown argument. Use -Value 25, optional -Preview/-NoPause, or -Help.' }
        }
    }
    if($help) {
        Write-Host 'Usage: Set-DefenderScanCPU.cmd [-Value] 25 [-Preview] [-NoPause]'
        Write-Host 'No value: prompt; blank cancels. Integers 5-100, or 0 for unlimited.'
        Write-Host 'Run as administrator to apply. No second confirmation; -Preview only reads.'
        Write-Host 'Only ScanAvgCPULoadFactor changes. Not a hard/system-wide CPU cap.'
        Write-Host 'Idle/manual scans may ignore it. Policy and tamper protection stay in force.'
        Write-Host 'Standalone CMD; requires Windows PowerShell 5.1 and active Microsoft Defender.'
    } else {
        Write-Host 'WARNING: Changes only the Microsoft Defender average scan CPU preference.'
        Write-Host 'Lower values can slow scans. 0 means unlimited; this is NOT a hard CPU cap.'
        Write-Host 'Idle/manual scans may ignore it. No protection, exclusions or idle-throttle changes.'
        Write-Host 'Policy/tamper protection are not bypassed. No restart or sign-out.'
        if($null -eq $value) {
            if([Console]::IsInputRedirected){Write-Host 'CPU percent (5-100, or 0 unlimited; blank cancels):'; $value=[Console]::ReadLine()}
            else {$value=Read-Host 'CPU percent (5-100, or 0 unlimited; blank cancels)'}
        }
        if([string]::IsNullOrWhiteSpace($value)){Write-Host 'Cancelled; nothing changed.'}
        else {
            $next=0
            if($value.Trim() -notmatch '^\d+$' -or -not [int]::TryParse($value.Trim(),[ref]$next) -or ($next -ne 0 -and ($next -lt 5 -or $next -gt 100))){throw 'Enter an integer 5-100, or 0 for unlimited. Nothing changed.'}
            if($next -eq 0){Write-Host 'WARNING: 0 removes the scan CPU preference limit; CPU usage can increase.'}
            foreach($name in @('Defender\Get-MpPreference','Defender\Set-MpPreference','Defender\Get-MpComputerStatus')) {
                if(-not (Get-Command $name -ErrorAction SilentlyContinue)){throw 'Microsoft Defender cmdlets are unavailable on this Windows installation.'}
            }
            if(-not (Get-Command Defender\Set-MpPreference).Parameters.ContainsKey('ScanAvgCPULoadFactor')){throw 'This Defender version does not expose ScanAvgCPULoadFactor.'}
            $status=Defender\Get-MpComputerStatus -ErrorAction Stop
            if(-not $status.AMServiceEnabled -or -not $status.AntivirusEnabled){throw 'Defender antivirus is not active. Services/protection modes will not be changed.'}
            $before=Defender\Get-MpPreference -ErrorAction Stop
            if($null -eq $before.PSObject.Properties['ScanAvgCPULoadFactor']){throw 'Defender did not return the CPU preference.'}
            Write-Host ('ScanAvgCPULoadFactor: {0} -> {1}' -f $before.ScanAvgCPULoadFactor,$next)
            Write-Host ('Keep prior value {0} to restore using this command.' -f $before.ScanAvgCPULoadFactor)
            if($before.DisableCpuThrottleOnIdleScans){Write-Host 'NOTE: Idle scan CPU throttling is disabled; that setting is unchanged.'}
            if($preview){Write-Host 'Preview only; nothing changed.'}
            elseif([int]$before.ScanAvgCPULoadFactor -eq $next){Write-Host 'Already set; nothing changed.'}
            else {
                $identity=[Security.Principal.WindowsIdentity]::GetCurrent()
                $principal=New-Object Security.Principal.WindowsPrincipal($identity)
                if(-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)){throw 'Run as administrator. No change attempted.'}
                Defender\Set-MpPreference -ScanAvgCPULoadFactor $next -ErrorAction Stop
                $after=Defender\Get-MpPreference -ErrorAction Stop
                if($null -eq $after.PSObject.Properties['ScanAvgCPULoadFactor'] -or [int]$after.ScanAvgCPULoadFactor -ne $next){throw 'Read-back mismatch. Policy/tamper protection may have blocked or overridden the write; inspect Defender settings.'}
                Write-Host ('Saved and read back: {0}. This does not prove scan CPU behavior.' -f $after.ScanAvgCPULoadFactor)
            }
        }
    }
} catch {
    Write-Host ('FAILED: '+$_.Exception.Message)
    Write-Host 'No automatic rollback. If a write was attempted, it may remain; inspect the preference.'
    $code=2
}
if(-not $noPause -and -not [Console]::IsInputRedirected -and -not [Console]::IsOutputRedirected){[void](Read-Host 'Press Enter to close')}
exit $code
