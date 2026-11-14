#Requires -Version 5.1
[CmdletBinding()]
param([switch]$NoPause, [switch]$Help)
$ErrorActionPreference='Stop'
function Test-LabElevated {
    $id=[Security.Principal.WindowsIdentity]::GetCurrent()
    return (New-Object Security.Principal.WindowsPrincipal($id)).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}
function Get-LabAgeText {
    param($Date)
    if (-not $Date) { return 'never seen' }
    $days=[int][Math]::Floor(((Get-Date)-[datetime]$Date).TotalDays)
    return "$days day(s) ago, $(([datetime]$Date).ToString('yyyy-MM-dd'))"
}

function Get-LabDefenderLoad {
    $cores=[Environment]::ProcessorCount
    $samples=@()
    for ($i=0; $i -lt 3; $i++) {
        $process=Get-CimInstance Win32_PerfFormattedData_PerfProc_Process -Filter "Name='MsMpEng'" -ErrorAction SilentlyContinue
        if ($process) { $samples+=[double]$process.PercentProcessorTime; $memory=[double]$process.WorkingSetPrivate }
        Start-Sleep -Milliseconds 700
    }
    $status=Get-MpComputerStatus -ErrorAction Stop
    $preference=Get-MpPreference -ErrorAction Stop
    $exclusions='run as administrator to read'
    if (Test-LabElevated) { $exclusions=[string]@($preference.ExclusionPath | Where-Object {$_}).Count }
    $cpu='not visible'
    if ($samples.Count) { $cpu=('{0:N1}% of the machine now' -f (($samples | Measure-Object -Average).Average/$cores)) }
    $memoryText='not visible'; if ($memory) { $memoryText=('{0:N0} MB private' -f ($memory/1MB)) }
    return [pscustomobject][ordered]@{
        'Defender CPU now'=$cpu
        'Defender memory'=$memoryText
        'Real-time protection'=[bool]$status.RealTimeProtectionEnabled
        'Scan CPU average limit'=$(if ($preference.ScanAvgCPULoadFactor -eq 0) {'none'} else {"$($preference.ScanAvgCPULoadFactor)%"})
        'Throttle idle scans too'=-not [bool]$preference.DisableCpuThrottleOnIdleScans
        'Scheduled scans only when idle'=[bool]$preference.ScanOnlyIfIdleEnabled
        'Last quick scan'=Get-LabAgeText $status.QuickScanEndTime
        'Last full scan'=Get-LabAgeText $status.FullScanEndTime
        'Intelligence age'="$($status.AntivirusSignatureAge) day(s), version $($status.AntivirusSignatureVersion)"
        'Folder exclusions'=$exclusions
    }
}

$code=0
try {
    if ($Help) {
        Get-Content -LiteralPath (Join-Path $PSScriptRoot 'Show-DefenderLoad.md') | Out-Host
    } else {
        Write-Host 'Sampling Defender for about two seconds (read-only)...'
        Get-LabDefenderLoad | Format-List | Out-Host
    }
} catch { Write-Host ('FAILED: ' + $_.Exception.Message); $code=2 }
if (-not $NoPause -and -not [Console]::IsInputRedirected -and -not [Console]::IsOutputRedirected) {
    [void](Read-Host 'Press Enter to close')
}
exit $code
