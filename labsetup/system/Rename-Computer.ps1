#Requires -Version 5.1
[CmdletBinding()]
param([string]$NewName, [switch]$Preview, [switch]$NoPause, [switch]$Help)
$ErrorActionPreference = 'Stop'
$code = 0
try {
    if ($Help) {
        Get-Content -LiteralPath (Join-Path $PSScriptRoot 'Rename-Computer.md') | Write-Host
    } else {
        $pc = Get-CimInstance -ClassName Win32_ComputerSystem -ErrorAction Stop
        if ($pc.PartOfDomain) { throw 'Domain-joined PC: ask the domain administrator to rename it.' }
        Write-Host ('Current PC name: ' + $pc.Name)
        if (-not $NewName) { $NewName = Read-Host 'New PC name (blank cancels)' }
        if ([string]::IsNullOrWhiteSpace($NewName)) {
            Write-Host 'Cancelled. Nothing changed.'
        } else {
            $NewName = $NewName.Trim()
            if ($NewName -notmatch '^[A-Za-z0-9](?:[A-Za-z0-9-]{0,13}[A-Za-z0-9])?$' -or $NewName -match '^\d+$') {
                throw 'Use 1-15 letters/digits/hyphens, no leading/trailing hyphen, and not digits only.'
            }
            if ($NewName -ieq $pc.Name) {
                Write-Host 'That is already the current name. Nothing changed.'
            } elseif ($Preview) {
                Write-Host ('Preview only: rename ' + $pc.Name + ' to ' + $NewName + '. Restart required; not performed.')
            } else {
                Write-Host 'Use a unique network name. Connections may need the new name after restart.'
                $result = Rename-Computer -NewName $NewName -PassThru -Force -ErrorAction Stop
                if (-not $result.HasSucceeded) { throw 'Windows did not report a successful rename.' }
                Write-Host ('Rename accepted: ' + $NewName + '. Restart manually when ready to apply it. No restart performed.')
            }
        }
    }
} catch {
    Write-Host ('FAILED: ' + $_.Exception.Message)
    $code = 2
}
if (-not $NoPause -and -not [Console]::IsInputRedirected -and -not [Console]::IsOutputRedirected) {
    [void](Read-Host 'Press Enter to close')
}
exit $code
