#Requires -Version 5.1
[CmdletBinding()]
param([string]$Value, [switch]$Preview, [switch]$NoPause, [switch]$Help)
$ErrorActionPreference='Stop'
$code=0
function Read-Answer($Prompt) {
    if ([Console]::IsInputRedirected) { Write-Host $Prompt; return [Console]::ReadLine() }
    return Read-Host $Prompt
}
function Assert-LabMachine($Kind) {
    if ((Get-CimInstance Win32_ComputerSystem).PartOfDomain) { throw 'Standalone labs only; domain member refused.' }
    foreach ($path in @('HKLM:\SYSTEM\CurrentControlSet\Control\CloudDomainJoin\JoinInfo',
                        'HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\Accounts')) {
        if ((Test-Path $path) -and @(Get-ChildItem $path).Count) { throw 'Device management registration found; nothing changed.' }
    }
    if ($Kind -notin @('animations','menus','app')) {
        $id = [Security.Principal.WindowsIdentity]::GetCurrent()
        if (-not (New-Object Security.Principal.WindowsPrincipal($id)).IsInRole(
            [Security.Principal.WindowsBuiltInRole]::Administrator)) { throw 'Use an administrator terminal.' }
    }
    foreach ($path in @('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending',
                        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired')) {
        if (Test-Path $path) { throw 'Windows has a pending restart. Restart manually before changing settings.' }
    }
}
function Get-LabFolder($Path) {
    if ($Path -notmatch '^[A-Za-z]:[\\/]' -or $Path -match '[*?\[\]~]') { throw 'Use a full local folder path, not a wildcard, UNC or short alias.' }
    $full = [IO.Path]::GetFullPath($Path).TrimEnd('\')
    if ($full.Length -le 3 -or ([IO.DriveInfo]::new([IO.Path]::GetPathRoot($full))).DriveType -ne 'Fixed') {
        throw 'A folder on a fixed local drive is required; whole drives are refused.'
    }
    foreach ($protected in @($env:SystemRoot,$env:ProgramFiles,[Environment]::GetEnvironmentVariable('ProgramFiles(x86)'),$env:ProgramData,
                             (Split-Path $env:USERPROFILE -Parent))) {
        if ($protected -and ($full -ieq $protected -or $full.StartsWith($protected.TrimEnd('\')+'\',[StringComparison]::OrdinalIgnoreCase))) {
            throw 'System, program and profile folders cannot be excluded.'
        }
    }
    $item = Get-Item -LiteralPath $full -Force
    if (-not $item.PSIsContainer) { throw 'An existing folder is required.' }
    while ($item) {
        if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) { throw 'Linked folders are refused.' }
        $item = $item.Parent
    }
    return $full
}

function Get-SelectedFolder($Path) {
    if ($Path -notmatch '^[A-Za-z]:[\/]' -or $Path.Substring(2).Contains(':') -or $Path -match '[*?\[\]~%]') {
        throw 'Use a full local project-folder path, without wildcards, aliases or environment expressions.'
    }
    foreach ($segment in ($Path.Substring(3) -split '[\/]')) {
        if ($segment -and $segment -match '[. ]$') { throw 'Dot navigation and trailing dots/spaces are refused.' }
    }
    $full=Get-LabFolder $Path
    foreach ($protected in @($env:SystemRoot,$env:ProgramFiles,[Environment]::GetEnvironmentVariable('ProgramFiles(x86)'),$env:ProgramData,(Split-Path $env:USERPROFILE -Parent))) {
        if ($protected -and $protected.StartsWith($full.TrimEnd('\')+'\',[StringComparison]::OrdinalIgnoreCase)) {
            throw 'Parents of system, program or profile folders cannot be excluded.'
        }
    }
    return $full
}
try {
    if ($Help) {
        Write-Host 'Add-DefenderFolderExclusion.cmd [-Value "full folder path"] [-Preview] [-NoPause] [-Help]'
        Write-Host 'One existing local project folder. Administrator terminal required; an exact folder selection applies directly.'
    } else {
        Write-Host 'HIGH RISK: An exclusion reduces malware protection for the folder and its contents.'
        Write-Host 'No defaults. Whole drives, system/program/profile folders and linked folders are refused.'
        if ([string]::IsNullOrWhiteSpace($Value)) { $Value=Read-Answer 'One existing local project folder (blank cancels)' }
        if ([string]::IsNullOrWhiteSpace($Value)) { Write-Host 'Cancelled.' }
        else {
            $folder=Get-SelectedFolder $Value.Trim().Trim('"')
            Assert-LabMachine 'exclusion'
            Get-Command Get-MpPreference,Add-MpPreference -ErrorAction Stop | Out-Null
            $before=Get-MpPreference -ErrorAction Stop
            if (-not $before.PSObject.Properties['ExclusionPath']) { throw 'Defender exclusion preference unavailable.' }
            Write-Host ('Selected folder: '+$folder)
            if ($folder -in @($before.ExclusionPath)) { Write-Host 'Already excluded. Nothing changed.' }
            elseif ($Preview) { Write-Host 'Preview only. Nothing changed.' }
            else {
                Assert-LabMachine 'exclusion'
                if ((Get-SelectedFolder $folder) -ine $folder) { throw 'Target changed before the write.' }
                Write-Host ('Recovery if needed: Remove-MpPreference -ExclusionPath '+"'"+$folder.Replace("'","''")+"'")
                Add-MpPreference -ExclusionPath $folder -ErrorAction Stop
                if ($folder -notin @((Get-MpPreference -ErrorAction Stop).ExclusionPath)) {
                    throw 'Change did not verify. Inspect Defender; policy/tamper protection may have rejected it.'
                }
                Write-Host 'Verified: selected folder is listed as excluded. Other exclusions were not replaced.'
                Write-Host 'Policy may override this later. No Defender or tamper-protection bypass attempted.'
            }
        }
    }
} catch { Write-Host ('FAILED: '+$_.Exception.Message); $code=2 }
if (-not $NoPause -and -not [Console]::IsInputRedirected -and -not [Console]::IsOutputRedirected) {
    [void](Read-Host 'Press Enter to close')
}
exit $code
