# Disable one Windows optional feature

Double-click Disable-OptionalFeature.cmd and approve UAC. The CMD stands alone; no
PS1, helper, engine or download is needed for this operation. Its small UAC request
uses built-in Windows PowerShell; DISM performs the feature operations.

Enter one exact name from the feature list to apply. Blank cancels. Names are validated before DISM checks that the
feature exists. No wildcard, batch list, payload removal or automatic restart.

Warning: disabling a feature can break applications or dependent Windows roles.
Use only with authorization on that machine. Unsupported OS/features, pending
servicing work, permissions and managed policy are reported by DISM, not bypassed.
This lists DISM optional features, not every installed application, capability or
Server Manager role. Do not guess a different target when DISM rejects the name.

Exit 0: DISM success, help or cancellation. Exit 3010: restart required; restart
manually and inspect the feature afterwards. Other errors retain DISM's code;
invalid input returns 2. Partial changes may remain after failure.

No Simple.ps1 receipt is created; Restore-OptionalFeature.cmd cannot undo this run. To restore a feature,
use Windows Features or Server Manager and its required installation source; this
command does not promise automatic rollback. Keep the original state you reviewed.

-Help shows usage without elevation or a feature change. Other old CLI options
(-Name, -Preview, -NoPause) are not supported; the replacement is interactive.
The optional PS1 is only a compatibility launcher for the standalone CMD.
No live feature was disabled during checks.

[Setup index](../README.md)
