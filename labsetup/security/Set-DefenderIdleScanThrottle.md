# Defender idle scan throttling

The CMD is standalone: copy just this file to the Windows machine. Requires Windows PowerShell 5.1 and supported Microsoft Defender cmdlets, not Simple.ps1 or any sibling file. The optional same-stem PS1 implements the same operation independently.

Run from an administrator terminal, or right-click Run as administrator and enter on/off. No automatic UAC relaunch, review gate, restart or security-policy bypass.

Examples:

1. Apply: `Set-DefenderIdleScanThrottle.cmd -Value on -NoPause`
2. Read-only preview: `Set-DefenderIdleScanThrottle.cmd -Value off -Preview -NoPause`
3. Help: `Set-DefenderIdleScanThrottle.cmd -Help -NoPause`

On/true ENABLES idle-scan CPU throttling by setting DisableCpuThrottleOnIdleScans to false. Off/false DISABLES only that throttle by setting the preference to true. This does not disable Defender, scanning, real-time protection, or change ScanAvgCPULoadFactor. Throttling may lengthen scans; disabling it can increase CPU use during idle scans.

The warning and original preference are printed before changes. Blank interactive input cancels. Invalid values are rejected. The write is followed by preference readback; that does not prove scan CPU behavior. Unsupported cmdlets/parameters and native permission/policy errors are reported; management or tamper protection may reject or later override a setting. No artificial domain/pending-restart gates.

Exit 0: matching preference, preview, help or cancellation. Exit 2: rejected/failed; a prior write may remain. PowerShell launch failures may return another nonzero code. No automatic undo record: retain the displayed original value, then use that value to restore it.

Validation: static/source checks only; no Defender preference was changed on this host or a VM.
