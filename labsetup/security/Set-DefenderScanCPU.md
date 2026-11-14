# Defender average scan CPU

Copy just **Set-DefenderScanCPU.cmd**. It embeds its own PowerShell implementation; no engine, Simple.ps1, sibling PS1 or documentation is needed. Requires Windows PowerShell 5.1 and the Windows Microsoft Defender module.

1. Right-click **Run as administrator**, then enter the percentage. Blank cancels. No second confirmation/review gate.
2. Elevated Command Prompt: `Set-DefenderScanCPU.cmd -Value 25 -NoPause`. Positional `25` also works. Allowed integers: 5-100, or 0 for unlimited.
3. Read-only: `Set-DefenderScanCPU.cmd -Value 25 -Preview -NoPause`. Help: `Set-DefenderScanCPU.cmd -Help -NoPause`. Preview requires available, active Defender.
4. Warning: lower values may extend scans; 0 removes the limit. ScanAvgCPULoadFactor is an average scan preference, **not a hard CPU cap** or system-wide limit. Idle/manual scans may ignore it. Existing idle-throttle settings are reported where available, never changed.
5. Only Set-MpPreference -ScanAvgCPULoadFactor is written. Protection, services, exclusions and other scan preferences are unchanged. No automatic elevation, installation, restart or sign-out. Inactive/unavailable Defender is reported, not enabled. Policy and tamper protection remain in force; read-back mismatch fails. Policy can later override successful read-back.
6. Previous value is displayed, not saved. To restore, run with that value. No legacy undo receipt is produced. The retained PS1 is an optional compatibility launcher for this CMD, with no Simple.ps1 dependency.
7. Exit 0: saved/read back, already set, preview, help or cancellation. Exit 2: invalid input or failure. A successful write can remain if verification fails. Use -NoPause in automation.
8. Non-mutating parser/help/invalid-input checks only; preference mutation and target-VM behavior remain untested.
