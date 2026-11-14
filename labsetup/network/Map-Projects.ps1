#Requires -Version 5.1
[CmdletBinding()]
param([switch]$Preview,[switch]$NoPause,[switch]$Help,[switch]$Yes) # -Yes kept for old calls
function Initialize-ProjectDriveNative {
 if ('Lab.ProjectDriveNative' -as [type]) { return }
 Add-Type -TypeDefinition @'
using System;
using System.Text;
using System.Runtime.InteropServices;
namespace Lab {
 public static class ProjectDriveNative {
  [DllImport("kernel32.dll",CharSet=CharSet.Unicode,SetLastError=true)] public static extern uint QueryDosDevice(string name,StringBuilder target,int size);
  [DllImport("kernel32.dll",SetLastError=true)] public static extern uint GetLogicalDrives();
  [DllImport("mpr.dll",CharSet=CharSet.Unicode)] public static extern int WNetGetConnection(string local,StringBuilder remote,ref int size);
 }
}
'@
}
function Get-ProjectDriveClassification {
 param([AllowNull()][string]$Target,[uint32]$LogicalMask,[int]$NetworkCode)
 if (!$LogicalMask) { throw 'GetLogicalDrives failed.' }
 if ($NetworkCode -ne 0 -and $NetworkCode -ne 2250) { throw "Network query uncertain: $NetworkCode" }
 if ($NetworkCode -eq 0) { return 'Occupied' }
 if ($Target) { if ($Target.TrimEnd('\') -ieq '\??\C:\projects') { return 'Same' }; return 'Occupied' }
 if ($LogicalMask -band (1 -shl 15)) { return 'Occupied' }
 return 'Free'
}
function Get-ProjectDriveState {
 Initialize-ProjectDriveNative
 $b=New-Object Text.StringBuilder 32768
 $n=[Lab.ProjectDriveNative]::QueryDosDevice('P:',$b,$b.Capacity)
 if (!$n) { $e=[Runtime.InteropServices.Marshal]::GetLastWin32Error(); if ($e -ne 2) { throw "QueryDosDevice failed: $e" }; $t=$null } else { $t=$b.ToString() }
 $mask=[Lab.ProjectDriveNative]::GetLogicalDrives(); if (!$mask) { throw 'GetLogicalDrives failed.' }
 $net=New-Object Text.StringBuilder 32768; $size=$net.Capacity
 $e=[Lab.ProjectDriveNative]::WNetGetConnection('P:',$net,[ref]$size)
 return Get-ProjectDriveClassification -Target $t -LogicalMask $mask -NetworkCode $e
}
function Get-ProjectRootTarget {
 Initialize-ProjectDriveNative
 $rootTarget=New-Object Text.StringBuilder 32768
 if (![Lab.ProjectDriveNative]::QueryDosDevice('C:',$rootTarget,$rootTarget.Capacity)) { throw 'Cannot verify C: device.' }
 return $rootTarget.ToString()
}
function Get-ProjectSourceItem {
 param([string]$Path)
 try { return Get-Item -LiteralPath $Path -Force -ErrorAction Stop }
 catch [System.Management.Automation.ItemNotFoundException] { if ($Path -eq 'C:\projects') { return $null }; throw }
}
function Get-ProjectSourceState {
 $rootTarget=Get-ProjectRootTarget
 if (!$rootTarget.StartsWith('\Device\HarddiskVolume',[StringComparison]::OrdinalIgnoreCase)) { throw 'C: is not a direct local volume.' }
 foreach ($path in @('C:\','C:\projects')) {
  $item=Get-ProjectSourceItem $path
  if ($null -eq $item) { if ($path -eq 'C:\projects') { return 'Missing' }; throw 'C: root is missing.' }
  if (($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) { throw "Reparse point rejected: $path" }
  if (!$item.PSIsContainer) { throw "Not a directory: $path" }
 }
 return 'Ready'
}
function New-ProjectSource { [void](New-Item -ItemType Directory -Path 'C:\projects' -ErrorAction Stop) }
function Set-ProjectDrive {
 & "$env:SystemRoot\System32\subst.exe" 'P:' 'C:\projects'
 if ($LASTEXITCODE -ne 0) { throw "SUBST failed ($LASTEXITCODE); no cleanup attempted." }
}
function Invoke-ProjectDrive {
 param([switch]$Preview)
 Write-Host 'SUBST P: -> C:\projects (no files moved). Temporary user/session mapping; elevation may differ.'
 $drive=Get-ProjectDriveState
 if ($drive -eq 'Same') { if ((Get-ProjectSourceState) -ne 'Ready') { throw 'Existing mapping source is missing or unsafe.' }; Write-Host 'Already mapped; no change.'; return }
 if ($drive -ne 'Free') { throw 'P: occupied or uncertain; existing drive untouched.' }
 $source=Get-ProjectSourceState
 if ($source -notin @('Ready','Missing')) { throw 'Source state uncertain.' }
 if ($Preview) { Write-Host "Source: $source. Preview only."; return }
 if ($source -eq 'Missing') {
  if ((Get-ProjectSourceState) -ne 'Missing') { throw 'Source changed; no folder created.' }
  New-ProjectSource
 } elseif ($source -ne 'Ready') { throw 'Source state uncertain.' }
 if ((Get-ProjectSourceState) -ne 'Ready') { throw 'Source not safe.' }
 if ((Get-ProjectDriveState) -ne 'Free') { throw 'P: became occupied; no mapping attempted.' }
 Set-ProjectDrive
 if ((Get-ProjectDriveState) -ne 'Same') { throw 'Mapping verification failed; no cleanup attempted.' }
 Write-Host 'Verified: P: maps to C:\projects.'
}
$ErrorActionPreference='Stop'; $code=0
try {
 if ($Help) { Get-Content -LiteralPath (Join-Path $PSScriptRoot 'Map-Projects.md') -Encoding UTF8 | Write-Host }
 else {
  Invoke-ProjectDrive -Preview:$Preview
 }
} catch { Write-Host ('BLOCKED: ' + $_.Exception.Message); $code=2 }
if (!$NoPause -and ![Console]::IsInputRedirected -and ![Console]::IsOutputRedirected) { [void](Read-Host 'Press Enter to close') }
exit $code
