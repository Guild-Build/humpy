@echo off
setlocal DisableDelayedExpansion
set "CLI_PATH_SELF=%~f0"
set "CLI_PATH_TOOLS="
set "CLI_PATH_PREVIEW="
set "CLI_PATH_HELP="
set "CLI_PATH_NOPAUSE="
:parse
if "%~1"=="" goto run
if /i "%~1"=="-Tools" goto tools
if /i "%~1"=="-Preview" (set "CLI_PATH_PREVIEW=1"& shift& goto parse)
if /i "%~1"=="-NoPause" (set "CLI_PATH_NOPAUSE=1"& shift& goto parse)
if /i "%~1"=="-Help" (set "CLI_PATH_HELP=1"& shift& goto parse)
goto invalid
:tools
if defined CLI_PATH_TOOLS goto invalid
if "%~2"=="" goto invalid
set "CLI_PATH_TOOLS=%~2"
if "%CLI_PATH_TOOLS:~0,1%"=="-" goto invalid
shift
shift
:tools_more
rem cmd splits an unquoted claude,codex into separate arguments; rejoin them until the next switch.
if "%~1"=="" goto parse
set "CLI_PATH_NEXT=%~1"
if "%CLI_PATH_NEXT:~0,1%"=="-" goto parse
set "CLI_PATH_TOOLS=%CLI_PATH_TOOLS%,%~1"
shift
goto tools_more
:invalid
echo ERROR: Use -Tools claude,codex,gh, -Preview, -NoPause or -Help. Nothing changed.
exit /b 2
:run
set "CLI_PS=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"
if exist "%SystemRoot%\Sysnative\WindowsPowerShell\v1.0\powershell.exe" set "CLI_PS=%SystemRoot%\Sysnative\WindowsPowerShell\v1.0\powershell.exe"
"%CLI_PS%" -NoLogo -NoProfile -Command "try { $body=([IO.File]::ReadAllText($env:CLI_PATH_SELF) -split '(?m)^# CLI_PATH_BODY\r?$',2)[1]; if(-not $body){throw 'Embedded script missing'}; & ([scriptblock]::Create($body)) } catch { Write-Host ('FAILED: '+$_.Exception.Message); exit 2 }"
exit /b %ERRORLEVEL%
# CLI_PATH_BODY
$ErrorActionPreference='Stop'
$script:WriteAttempted=$false
function Read-Input($Prompt) {
    if ([Console]::IsInputRedirected) { Write-Host $Prompt; return [Console]::ReadLine() }
    Read-Host $Prompt
}
function Get-RequestedTools($Text) {
    if ($Text.Length -gt 1024) { throw 'Tool list is too long.' }
    $names=@(); foreach ($name in ($Text -split '[,;\s]+')) {
        if (-not $name) { continue }
        if ($name -notmatch '^[A-Za-z][A-Za-z0-9_-]{0,63}$') { throw 'Use command names such as claude,codex,gh; not paths, wildcards or arguments.' }
        if ($name -notin $names) { $names+=$name.ToLowerInvariant() }
    }
    if ($names.Count -gt 20) { throw 'At most 20 explicitly named tools per run.' }
    return $names
}
function Get-PathSnapshot($Scope) {
    if ($Scope -eq 'User') { $key=[Microsoft.Win32.Registry]::CurrentUser.OpenSubKey('Environment') }
    else { $key=[Microsoft.Win32.Registry]::LocalMachine.OpenSubKey('SYSTEM\CurrentControlSet\Control\Session Manager\Environment') }
    try {
        if (-not $key -or 'Path' -notin @($key.GetValueNames())) {
            return [pscustomobject]@{Exists=$false;Raw='';Kind=[Microsoft.Win32.RegistryValueKind]::ExpandString}
        }
        $kind=$key.GetValueKind('Path')
        if ($kind -notin @([Microsoft.Win32.RegistryValueKind]::String,[Microsoft.Win32.RegistryValueKind]::ExpandString)) { throw "$Scope PATH has an unsupported registry type." }
        return [pscustomobject]@{Exists=$true;Raw=[string]$key.GetValue('Path','',[Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames);Kind=$kind}
    } finally { if ($key) { $key.Dispose() } }
}
function Normalize-Directory($Value,[bool]$Expand) {
    $v=$Value.Trim()
    if ($v.StartsWith('"') -and $v.EndsWith('"') -and $v.Length -ge 2) { $v=$v.Substring(1,$v.Length-2) }
    if ($v.Contains('"')) { return $null }
    if ($Expand) { $v=[Environment]::ExpandEnvironmentVariables($v) }
    if ($v -notmatch '^[A-Za-z]:[\\/]' -or $v.Contains('%')) { return $null }
    try { $v=[IO.Path]::GetFullPath($v); if ($v.Length -gt 3) { $v=$v.TrimEnd('\') }; return $v }
    catch { return $null }
}
function Resolve-Cli($Name) {
    $found=@(Get-Command -Name $Name -CommandType Application -ErrorAction SilentlyContinue)
    if ($found.Count) { return [string]$found[0].Source }
    $candidates=@()
    switch ($Name) {
        'claude' { $candidates=@("$env:USERPROFILE\.local\bin\claude.exe","$env:APPDATA\npm\claude.cmd") }
        'codex' { $candidates=@("$env:APPDATA\npm\codex.cmd","$env:LOCALAPPDATA\Programs\nodejs\codex.cmd","$env:USERPROFILE\.local\bin\codex.exe","$env:USERPROFILE\.cargo\bin\codex.exe") }
        'gh' { $candidates=@("$env:ProgramFiles\GitHub CLI\gh.exe","$env:LOCALAPPDATA\Programs\GitHub CLI\gh.exe") }
    }
    $present=@($candidates | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf })
    if ($present.Count -gt 1) { throw 'Multiple known installations found; select the intended one in your current shell PATH first.' }
    if ($present.Count) { return [string]$present[0] }
    return $null
}
function Get-Plan($Names,$User,$Machine) {
    $known=@(); foreach ($snapshot in @($Machine,$User)) {
        foreach ($entry in ($snapshot.Raw -split ';')) {
            $normalized=Normalize-Directory $entry ($snapshot.Kind -eq [Microsoft.Win32.RegistryValueKind]::ExpandString)
            if ($normalized -and $normalized -notin $known) { $known+=$normalized }
        }
    }
    $add=@(); $resolved=@(); $missing=@()
    foreach ($name in $Names) {
        try {
            $exe=Resolve-Cli $name
            if (-not $exe) { throw 'Not resolved; nothing installed or recursively searched.' }
            if ($exe -notmatch '^[A-Za-z]:[\\/]' -or $exe -match '[;%\r\n]') { throw 'Only literal local executable paths without PATH delimiters are accepted.' }
            $directory=Normalize-Directory ([IO.Path]::GetDirectoryName($exe)) $false
            if (-not $directory) { throw 'Cannot normalize the executable directory safely.' }
            $resolved+=[pscustomobject]@{Name=$name;Exe=$exe;Directory=$directory}
            if ($directory -notin $known) { $add+=$directory; $known+=$directory }
        } catch { $missing+="$name : $($_.Exception.Message)" }
    }
    $next=$User.Raw
    if ($add.Count) { if ($next.Length -and -not $next.EndsWith(';')) { $next+=';' }; $next+=($add -join ';') }
    if ($next.Length -gt 32766) { throw 'Proposed user PATH is too long; nothing changed.' }
    [pscustomobject]@{Add=$add;Resolved=$resolved;Missing=$missing;Next=$next}
}
function Same-Snapshot($A,$B) { return $A.Exists -eq $B.Exists -and $A.Kind -eq $B.Kind -and $A.Raw -ceq $B.Raw }
function Get-TargetIdentity {
    $id=[Security.Principal.WindowsIdentity]::GetCurrent()
    $principal=New-Object Security.Principal.WindowsPrincipal($id)
    if ($principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { throw 'Run unelevated as the intended user. An elevated/different administrator account is not a safe user-PATH target.' }
    return $id.Name
}
function Confirm-Executables($Plan) {
    foreach ($item in $Plan.Resolved) { if (-not (Test-Path -LiteralPath $item.Exe -PathType Leaf)) { throw "Executable disappeared: $($item.Exe)" } }
}
function Write-UserPath($Value,$Kind) {
    $key=[Microsoft.Win32.Registry]::CurrentUser.CreateSubKey('Environment')
    try { $key.SetValue('Path',$Value,$Kind) } finally { if ($key) { $key.Dispose() } }
}
function Invoke-CliPath($Text,[bool]$Preview) {
    Write-Host 'WARNING: Adds only explicitly selected executable folders to the CURRENT USER PATH.'
    Write-Host 'Machine PATH is read for comparison and NEVER written. No installations or elevation.'
    Write-Host 'Existing entries/order and registry value type are preserved; only missing directories are appended.'
    $who=Get-TargetIdentity
    Write-Host "Target account: $who (current user only)."
    if ([string]::IsNullOrWhiteSpace($Text)) { $Text=Read-Input 'Explicit command list, e.g. claude,codex,gh (blank cancels)' }
    if ([string]::IsNullOrWhiteSpace($Text)) { Write-Host 'Cancelled.'; return 0 }
    $names=@(Get-RequestedTools $Text)
    if (-not $names.Count) { throw 'No command names supplied.' }
    $user=Get-PathSnapshot 'User'; $machine=Get-PathSnapshot 'Machine'
    $plan=Get-Plan $names $user $machine
    foreach ($item in $plan.Resolved) { Write-Host ("Resolved {0}: {1}" -f $item.Name,$item.Exe) }
    Write-Host 'Proposed MACHINE changes: none (user-writable/npm/shim folders are never promoted).'
    Write-Host 'Proposed USER additions:'
    if (-not $plan.Add.Count) { Write-Host '  None.' }
    foreach ($directory in $plan.Add) { Write-Host "  + $directory" }
    Write-Host 'Unresolved tools:'
    if (-not $plan.Missing.Count) { Write-Host '  None.' }
    foreach ($item in $plan.Missing) { Write-Host "  $item" }
    if ($Preview -or -not $plan.Add.Count) {
        Write-Host 'Nothing changed.'
        if ($plan.Missing.Count) { return 3 }; return 0
    }
    if (-not (Same-Snapshot $user (Get-PathSnapshot 'User')) -or -not (Same-Snapshot $machine (Get-PathSnapshot 'Machine'))) { throw 'PATH changed before the write; rerun. Nothing written.' }
    Confirm-Executables $plan
    Write-Host ('Previous raw user PATH: '+$user.Raw)
    $script:WriteAttempted=$true
    Write-UserPath $plan.Next $user.Kind
    $saved=Get-PathSnapshot 'User'
    if (-not $saved.Exists -or $saved.Raw -cne $plan.Next -or $saved.Kind -ne $user.Kind) { throw 'Write attempted but read-back differs. Inspect this user PATH before retrying.' }
    Write-Host 'Saved and verified USER PATH only. This process and existing shells are unchanged.'
    Write-Host 'Sign out and back in, then open a fresh terminal for a guaranteed refreshed environment.'
    Write-Host 'A new shell launched from an old parent may inherit stale PATH. No sign-out/restart is performed.'
    if ($plan.Missing.Count) { Write-Host 'Partial result: resolved tools added; unresolved tools remain.'; return 3 }
    return 0
}
$code=0
try {
    if ($env:CLI_PATH_HELP -eq '1') {
        Write-Host 'Update-CliPath.cmd [-Tools claude,codex,gh] [-Preview] [-NoPause] [-Help]'
        Write-Host 'No default list. Other explicitly listed names use command resolution only.'
        Write-Host 'User PATH only; run unelevated as the intended user. Explicitly selected tools only.'
    } else { $code=Invoke-CliPath $env:CLI_PATH_TOOLS ($env:CLI_PATH_PREVIEW -eq '1') }
} catch {
    Write-Host ('FAILED: '+$_.Exception.Message)
    if ($script:WriteAttempted) { Write-Host 'A write was attempted; a change may remain. No automatic rollback.' }
    $code=2
}
if ($env:CLI_PATH_NOPAUSE -ne '1' -and -not [Console]::IsInputRedirected -and -not [Console]::IsOutputRedirected) { [void](Read-Host 'Press Enter to close') }
exit $code
