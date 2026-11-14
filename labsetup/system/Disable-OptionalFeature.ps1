#Requires -Version 5.1
[CmdletBinding()]
param([switch]$Help)
# Compatibility entry only; the CMD performs its own prompts and UAC.
if ($Help) {
    & (Join-Path $PSScriptRoot 'Disable-OptionalFeature.cmd') '-Help'
} else {
    & (Join-Path $PSScriptRoot 'Disable-OptionalFeature.cmd')
}
exit $LASTEXITCODE
