#Requires -Version 5.1
[CmdletBinding()]
param([string]$Value, [switch]$Preview, [switch]$NoPause, [switch]$Help)
# Compatibility launcher only. The CMD contains the complete implementation.
$ErrorActionPreference='Stop'
try {
    $forward=@()
    if($PSBoundParameters.ContainsKey('Value')) {
        $n=0
        if($Value -notmatch '^\d+$' -or -not [int]::TryParse($Value,[ref]$n) -or ($n -ne 0 -and ($n -lt 5 -or $n -gt 100))){throw 'Enter an integer 5-100, or 0 for unlimited.'}
        $forward+=@('-Value',[string]$n)
    }
    if($Preview){$forward+='-Preview'}
    if($NoPause){$forward+='-NoPause'}
    if($Help){$forward+='-Help'}
    & (Join-Path $PSScriptRoot 'Set-DefenderScanCPU.cmd') @forward
    exit $LASTEXITCODE
} catch { [Console]::Error.WriteLine('FAILED: '+$_.Exception.Message); exit 2 }
