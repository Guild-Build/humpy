# Undo one component change

Keep the CMD, its same-named PS1, and [Simple.ps1](Simple.ps1) in this folder.
No other project, Python runtime or package install is needed. Windows PowerShell 5.1.

Double-click for UAC, or use an administrator terminal.
Enter an existing compatible historical component receipt. Disable-OptionalFeature.cmd does not create these receipts.
Blank input or EOF cancels. Selecting a valid record applies directly unless -Preview.

Example: Restore-OptionalFeature.cmd -Receipt D:\Lab\logs\RECORD.undo.json -Preview -NoPause
Remove -Preview to apply. -Help prints this page.

## Risk and recovery

Restores that component, not apps or service before.txt files. Windows may require a manual restart. The existing receipt is not rewritten.

Accepts only these snippets' .undo.json records, not old engine receipts. Machine and user must match. A changed current value, malformed/pending record or changed record before the restore is refused.

Only use on an authorized standalone lab. Domain, cloud-join/MDM registration and
pending-restart signals block changes; this is not a complete management-policy audit.
Windows permissions, managed policy and Defender tamper protection remain in force.

Exit 0: verified, preview, no-op or cancelled. Exit 2: rejected/failed; earlier effects
may remain. Exit 3: restart manually and inspect the component. Never an automatic
restart or rollback. Run only one change/recovery at a time.

Offline checks use harmless substitutes; live device mutation is not yet accepted.
[Setup index](../README.md)
