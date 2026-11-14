# Current-user menu animations

Keep the CMD and its same-named PS1 together. Keep [Simple.ps1](../recovery/Simple.ps1) in the sibling recovery folder.
No other project, Python runtime or package install is needed. Windows PowerShell 5.1.

Run in the intended user session; no elevation is requested.
Enter on/off (or true/false) to apply. Blank or EOF cancels.

Example: Set-MenuAnimations.cmd -Value off -Preview -NoPause
Remove -Preview to apply. -Help prints this page.

## Risk and recovery

Changes menu animation preference immediately. No guaranteed speedup.

To undo, rerun with the previous value shown in the console. No new undo record is created.

Only use on an authorized standalone lab. Domain, cloud-join/MDM registration and
pending-restart signals block changes; this is not a complete management-policy audit.
Windows permissions, managed policy and Defender tamper protection remain in force.

Exit 0: verified, preview, no-op or cancelled. Exit 2: rejected/failed; earlier effects
may remain. No automatic restart or rollback.

Offline checks use harmless substitutes; live device mutation is not yet accepted.
[Setup index](../README.md)
