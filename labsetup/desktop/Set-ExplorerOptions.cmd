@echo off
setlocal DisableDelayedExpansion
set "EXPLORER_OPTIONS_SELF=%~f0"
set "EXPLORER_OPTIONS_PREVIEW="
set "EXPLORER_OPTIONS_HELP="
set "EXPLORER_OPTIONS_NOPAUSE="
:parse
if "%~1"=="" goto run
if /i "%~1"=="-Preview" (set "EXPLORER_OPTIONS_PREVIEW=1"& shift& goto parse)
if /i "%~1"=="-NoPause" (set "EXPLORER_OPTIONS_NOPAUSE=1"& shift& goto parse)
if /i "%~1"=="-Help" (set "EXPLORER_OPTIONS_HELP=1"& shift& goto parse)
echo ERROR: Use -Preview, -NoPause or -Help. No settings changed.
exit /b 2
:run
set "EXPLORER_OPTIONS_PS=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"
if exist "%SystemRoot%\Sysnative\WindowsPowerShell\v1.0\powershell.exe" set "EXPLORER_OPTIONS_PS=%SystemRoot%\Sysnative\WindowsPowerShell\v1.0\powershell.exe"
"%EXPLORER_OPTIONS_PS%" -NoLogo -NoProfile -Command "try { $body=([IO.File]::ReadAllText($env:EXPLORER_OPTIONS_SELF) -split '(?m)^# EXPLORER_OPTIONS_BODY\r?$',2)[1]; if(-not $body){throw 'Embedded script missing'}; & ([scriptblock]::Create($body)) } catch { Write-Host ('FAILED: '+$_.Exception.Message); exit 2 }"
exit /b %ERRORLEVEL%
# EXPLORER_OPTIONS_BODY
$ErrorActionPreference='Stop'
$script:Attempted=@()
$base='Software\Microsoft\Windows\CurrentVersion\Explorer'
function Settings {
    @(
        @{Path=$base;Name='ShowRecent';Value=0;Label='General / Privacy: recently used files OFF'},
        @{Path=$base;Name='ShowFrequent';Value=0;Label='General / Privacy: frequently used folders OFF'},
        @{Path=$base;Name='ShowCloudFilesInQuickAccess';Value=0;Label='General / Privacy: Office.com files OFF'},
        @{Path="$base\Advanced";Name='HideFileExt';Value=0;Label='View: Hide extensions for known file types OFF'},
        @{Path="$base\Advanced";Name='Hidden';Value=1;Label='View: Show hidden files, folders and drives ON'}
    )
}
function Target-User {
    $id=[Security.Principal.WindowsIdentity]::GetCurrent()
    $principal=New-Object Security.Principal.WindowsPrincipal($id)
    if ($principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { throw 'Run unelevated as the intended Explorer user, not another administrator account.' }
    return $id.Name
}
function Target-Build {
    $key=[Microsoft.Win32.Registry]::LocalMachine.OpenSubKey('SOFTWARE\Microsoft\Windows NT\CurrentVersion')
    try {
        if (-not $key) { throw 'Cannot identify Windows edition/build.' }
        $product=[string]$key.GetValue('ProductName'); $build=[string]$key.GetValue('CurrentBuildNumber'); $type=[string]$key.GetValue('InstallationType')
        Write-Host "Detected: $product; build $build; installation $type."
        if ($product -notlike '*Windows Server 2025*' -or $build -ne '26100' -or $type -ne 'Server') {
            throw 'This command is scoped to Windows Server 2025 Desktop Experience build 26100. Other builds/Server Core are not validated.'
        }
    } finally { if ($key) { $key.Dispose() } }
}
function Read-Preference($Path,$Name) {
    $key=[Microsoft.Win32.Registry]::CurrentUser.OpenSubKey($Path)
    try {
        if (-not $key -or $Name -notin @($key.GetValueNames())) { return [pscustomobject]@{Exists=$false;Value=$null} }
        if ($key.GetValueKind($Name) -ne [Microsoft.Win32.RegistryValueKind]::DWord) { throw "Unexpected registry type for $Name; nothing else will be changed." }
        return [pscustomobject]@{Exists=$true;Value=[int]$key.GetValue($Name)}
    } finally { if ($key) { $key.Dispose() } }
}
function Protected-Default {
    $key=[Microsoft.Win32.Registry]::LocalMachine.OpenSubKey('SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\Folder\SuperHidden')
    try {
        return $key -and $key.GetValue('ValueName') -eq 'ShowSuperHidden' -and $key.GetValue('RegPath') -ieq "$base\Advanced" -and
            'DefaultValue' -in @($key.GetValueNames()) -and $key.GetValueKind('DefaultValue') -eq [Microsoft.Win32.RegistryValueKind]::DWord -and
            [int]$key.GetValue('DefaultValue') -eq 0
    } finally { if ($key) { $key.Dispose() } }
}
function Guard-ProtectedFiles {
    $guard=Read-Preference "$base\Advanced" 'ShowSuperHidden'
    if ($guard.Exists) {
        if ($guard.Value -ne 0) { throw 'Protected OS files are currently enabled or the value is unknown. No changes: manually enable Hide protected operating system files, then rerun.' }
    } elseif (-not (Protected-Default)) {
        throw 'Cannot establish that protected OS files stay hidden. Missing values do NOT prove a checkbox is absent. Manually check Hide protected operating system files and Apply, then rerun.'
    }
}
function Same-Preference($A,$B) { return $A.Exists -eq $B.Exists -and $A.Value -eq $B.Value }
function Write-Preference($Setting) {
    $key=[Microsoft.Win32.Registry]::CurrentUser.CreateSubKey($Setting.Path)
    try { $key.SetValue($Setting.Name,[int]$Setting.Value,[Microsoft.Win32.RegistryValueKind]::DWord) }
    finally { if ($key) { $key.Dispose() } }
}
function Invoke-Options([bool]$Preview) {
    Write-Host 'WARNING: Changes only five requested File Explorer preferences for the CURRENT USER.'
    Write-Host 'No history clearing, protected-OS-file change, other options, policy change or Explorer restart.'
    $who=Target-User; Write-Host "Target account: $who"
    Target-Build
    Guard-ProtectedFiles
    $settings=@(Settings); $before=@{}
    foreach ($s in $settings) {
        $old=Read-Preference $s.Path $s.Name
        $allowed=@(0,1); if ($s.Name -eq 'Hidden') { $allowed=@(1,2) }
        if ($old.Exists -and $old.Value -notin $allowed) { throw "Unexpected existing $($s.Name) value; no preferences written." }
        $before[$s.Name]=$old
        $previous='<not explicitly set>'; if ($old.Exists) { $previous=[string]$old.Value }
        Write-Host ("{0} [{1}: {2} -> {3}]" -f $s.Label,$s.Name,$previous,$s.Value)
    }
    Write-Host 'Registry presence/absence cannot prove a checkbox is available. Target UI is unverified.'
    if ($Preview) { Write-Host 'Preview only; nothing written.'; return 0 }
    Guard-ProtectedFiles
    foreach ($s in $settings) {
        if (-not (Same-Preference $before[$s.Name] (Read-Preference $s.Path $s.Name))) { throw 'A requested preference changed before the write; rerun. Nothing written.' }
    }
    foreach ($s in $settings) {
        if ($before[$s.Name].Exists -and $before[$s.Name].Value -eq $s.Value) { continue }
        Guard-ProtectedFiles
        if (-not (Same-Preference $before[$s.Name] (Read-Preference $s.Path $s.Name))) { throw "Concurrent change to $($s.Name); earlier writes may remain." }
        $script:Attempted+=$s.Name
        Write-Preference $s
        $after=Read-Preference $s.Path $s.Name
        if (-not $after.Exists -or $after.Value -ne $s.Value) { throw "Read-back failed for $($s.Name); inspect the target user preferences." }
    }
    Guard-ProtectedFiles
    Write-Host 'Requested preference DWORDs read back as requested. This is NOT target UI confirmation.'
    Write-Host 'Close Folder Options without saving stale controls, then reopen it and check the five controls.'
    Write-Host 'Refresh/reopen Explorer windows manually if needed. No forced restart or sign-out.'
    Write-Host 'If Office.com or another checkbox is absent/different/unchanged, report that build/UI limitation; policy may override these preferences.'
    return 0
}
$code=0
try {
    if ($env:EXPLORER_OPTIONS_HELP -eq '1') {
        Write-Host 'Set-ExplorerOptions.cmd [-Preview] [-NoPause] [-Help]'
        Write-Host 'Server 2025 Desktop Experience build 26100; intended unelevated user only.'
        Write-Host 'Five exact preferences, protected-OS-files guard, no UI check. No Explorer restart.'
    } else { $code=Invoke-Options ($env:EXPLORER_OPTIONS_PREVIEW -eq '1') }
} catch {
    Write-Host ('FAILED: '+$_.Exception.Message)
    if ($script:Attempted.Count) { Write-Host ('Potential partial changes: '+($script:Attempted -join ', ')+'. No automatic rollback.') }
    $code=2
}
if ($env:EXPLORER_OPTIONS_NOPAUSE -ne '1' -and -not [Console]::IsInputRedirected -and -not [Console]::IsOutputRedirected) { [void](Read-Host 'Press Enter to close') }
exit $code
