#Requires -Version 5.1
# Menu animation and legacy undo support. No action on load.
$script:LabFeatures = @('TelnetClient','TFTP','WorkFolders-Client','Printing-XPSServices-Features')

function Read-LabInput($Prompt) {
    if ([Console]::IsInputRedirected) { Write-Host $Prompt; return [Console]::ReadLine() }
    return Read-Host $Prompt
}
function Get-LabIdentity {
    $machine = [guid](Get-CimInstance Win32_ComputerSystemProduct).UUID
    if ($machine -eq [guid]::Empty -or $machine.ToString() -eq 'ffffffff-ffff-ffff-ffff-ffffffffffff') { throw 'Cannot establish machine identity.' }
    return "$machine/$([Security.Principal.WindowsIdentity]::GetCurrent().User.Value)"
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
function Assert-LabName($Kind, $Name) {
    switch ($Kind) {
        'feature' { if ($Name -notin $script:LabFeatures) { throw 'Choose one listed component, without wildcards.' }; return }
        'exclusion' { if ((Get-LabFolder $Name) -ine $Name) { throw 'Use the full normalized folder path.' }; return }
        {$_ -in @('animations','menus','cpu','idle','updates')} { if ($Name) { throw 'Unexpected target name.' }; return }
        default { throw 'Unknown operation.' }
    }
}
function Assert-LabValue($Kind, $Value) {
    $integer = $Value -is [int] -or $Value -is [long]
    switch ($Kind) {
        {$_ -in @('animations','menus','idle','exclusion')} { if ($Value -is [bool]) { return } }
        'cpu' { if ($integer -and ($Value -eq 0 -or ($Value -ge 5 -and $Value -le 100))) { return } }
        'updates' { if ($null -eq $Value -or ($integer -and $Value -in @(0,1))) { return } }
        'feature' { if ($Value -is [string] -and $Value -in @('Enabled','Disabled')) { return } }
    }
    throw 'Invalid setting value.'
}
function Get-LabAnimation($Kind, $Value, [switch]$Write) {
    if (-not ('LabSnippets.Preferences' -as [type])) {
        Add-Type @'
using System;
using System.Runtime.InteropServices;
namespace LabSnippets {
    public static class Preferences {
        [DllImport("user32.dll", EntryPoint="SystemParametersInfoW", SetLastError=true)]
        [return: MarshalAs(UnmanagedType.Bool)]
        public static extern bool Get(uint action, uint param, ref int value, uint flags);
        [DllImport("user32.dll", EntryPoint="SystemParametersInfoW", SetLastError=true)]
        [return: MarshalAs(UnmanagedType.Bool)]
        public static extern bool Set(uint action, uint param, IntPtr value, uint flags);
    }
}
'@
    }
    $get=0x1042; $set=0x1043
    if ($Kind -eq 'menus') { $get=0x1002; $set=0x1003 }
    $current=0
    if ($Write) {
        if (-not [LabSnippets.Preferences]::Set($set,0,[IntPtr][int]$Value,3)) { throw 'Cannot save animation setting.' }
    } elseif (-not [LabSnippets.Preferences]::Get($get,0,[ref]$current,0)) { throw 'Cannot read animation setting.' }
    else { return [bool]$current }
}
function Get-LabValue($Kind, $Name) {
    switch ($Kind) {
        {$_ -in @('animations','menus')} { return Get-LabAnimation $Kind }
        'cpu' {
            $p=(Get-MpPreference).PSObject.Properties['ScanAvgCPULoadFactor']
            if (-not $p) { throw 'Defender CPU preference unavailable.' }; return [int]$p.Value
        }
        'idle' {
            $p=(Get-MpPreference).PSObject.Properties['DisableCpuThrottleOnIdleScans']
            if (-not $p) { throw 'Defender idle preference unavailable.' }; return -not [bool]$p.Value
        }
        'exclusion' { return $Name -in @((Get-MpPreference).ExclusionPath) }
        'updates' {
            $path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU'
            if (-not (Test-Path -LiteralPath $path)) { return $null }
            $key = Get-Item -LiteralPath $path
            if (-not $key -or 'NoAutoUpdate' -notin $key.GetValueNames()) { return $null }
            if ($key.GetValueKind('NoAutoUpdate') -ne 'DWord') { throw 'Unexpected update policy type.' }
            return [int]$key.GetValue('NoAutoUpdate')
        }
        'feature' {
            $state = [string](Get-WindowsOptionalFeature -Online -FeatureName $Name).State
            if ($state -notin @('Enabled','Disabled')) { throw "Component is absent, pending or its payload was removed: $state" }
            return $state
        }
        default { throw 'Unknown operation.' }
    }
}
function Set-LabValue($Kind, $Name, $Value) {
    Assert-LabName $Kind $Name
    Assert-LabValue $Kind $Value
    switch ($Kind) {
        {$_ -in @('animations','menus')} { Get-LabAnimation $Kind $Value -Write }
        'cpu' { Set-MpPreference -ScanAvgCPULoadFactor $Value }
        'idle' { Set-MpPreference -DisableCpuThrottleOnIdleScans (-not $Value) }
        'exclusion' {
            if ($Value) { Add-MpPreference -ExclusionPath $Name }
            else { Remove-MpPreference -ExclusionPath $Name }
        }
        'updates' {
            $path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU'
            if ($null -eq $Value) { Remove-ItemProperty -LiteralPath $path -Name NoAutoUpdate }
            else {
                New-Item -Path $path -Force | Out-Null
                New-ItemProperty -LiteralPath $path -Name NoAutoUpdate -PropertyType DWord -Value $Value -Force | Out-Null
            }
        }
        'feature' {
            if ($Value -eq 'Disabled') { $result=Disable-WindowsOptionalFeature -Online -FeatureName $Name -NoRestart }
            else { $result=Enable-WindowsOptionalFeature -Online -FeatureName $Name -NoRestart }
            return [bool]$result.RestartNeeded
        }
    }
    return $false
}
function Same-LabValue($Left, $Right) {
    return (ConvertTo-Json -InputObject $Left -Compress) -ceq (ConvertTo-Json -InputObject $Right -Compress)
}
function Restore-LabRecord($Path, [switch]$Trim, [switch]$Preview) {
    if ($Path -notmatch '^[A-Za-z]:[\\/]' -or -not $Path.EndsWith('.undo.json',[StringComparison]::OrdinalIgnoreCase)) {
        throw 'Choose a local .undo.json file created by these snippets.'
    }
    $file=Get-Item -LiteralPath $Path
    if ($file.PSIsContainer -or $file.Length -gt 65536 -or $file.Attributes -band [IO.FileAttributes]::ReparsePoint) { throw 'Use one small, local undo JSON file.' }
    $original=[IO.File]::ReadAllText($file.FullName)
    $r=$original | ConvertFrom-Json
    if ($r.schema -ne 1 -or $r.owner -cne (Get-LabIdentity)) { throw 'Foreign record: machine/user must match.' }
    if ($r.kind -eq 'app' -or ($Trim -and $r.kind -ne 'feature') -or (-not $Trim -and $r.kind -eq 'feature')) {
        throw 'Wrong recovery command. Use Restore-OptionalFeature for components or Restore-LabSetting for settings. Apps require reinstallation.'
    }
    Assert-LabName $r.kind $r.name
    Assert-LabValue $r.kind $r.before; Assert-LabValue $r.kind $r.after
    if (($r.kind -eq 'feature' -and ($r.before -ne 'Enabled' -or $r.after -ne 'Disabled')) -or
        ($r.kind -eq 'exclusion' -and ($r.before -ne $false -or $r.after -ne $true))) {
        throw 'This record is not a change produced by the matching snippet.'
    }
    Assert-LabMachine $r.kind
    if ($r.status -eq 'undone') { Write-Host 'Already restored.'; return 0 }
    if ($r.status -notin @('applied','restart-required')) { throw 'Pending/failed record; inspect manually rather than guessing.' }
    if (-not (Same-LabValue (Get-LabValue $r.kind $r.name) $r.after)) { throw 'Current value differs from the recorded change; will not overwrite it.' }
    if ($r.kind -eq 'updates' -and $r.before -eq 1) { Write-Host 'HIGH RISK: restoring NoAutoUpdate=1 disables automatic updates; patching becomes manual.' }
    Write-Host "Restore $($r.kind) $($r.name) to $(ConvertTo-Json -InputObject $r.before -Compress)"
    if ($Preview) { Write-Host 'Preview only.'; return 0 }
    if ([IO.File]::ReadAllText($file.FullName) -cne $original -or -not (Same-LabValue (Get-LabValue $r.kind $r.name) $r.after)) { throw 'Record or current value changed before the restore.' }
    if (Set-LabValue $r.kind $r.name $r.before) {
        Write-Host 'Restart manually, then inspect the component. Record retained for manual verification.'; return 3
    }
    if (-not (Same-LabValue (Get-LabValue $r.kind $r.name) $r.before)) { throw 'Restore did not verify; inspect manually.' }
    Write-Host 'Restored and verified.'; return 0
}
