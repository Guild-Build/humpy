# Rename PC

Double-click `Rename-Computer.cmd`, approve Windows UAC, enter the new name to apply.
Blank input cancels. Keep the CMD and PS1 together.

Names: 1-15 letters, digits or hyphens; no leading/trailing hyphen or digits-only names.
Choose a unique name on the network. Domain-joined computers are refused.

Windows applies the name after a manual restart. This tool never restarts the PC.
Connections using the old name may need updating. To undo, run again with the old
name and restart manually. Windows errors are shown; failures return exit code 2.

From an existing terminal: `Rename-Computer.cmd -NewName LAB-PC -Preview -NoPause`
previews without renaming. `-Help` shows this page. Arguments do not auto-elevate;
use an administrator terminal for an actual rename.
PowerShell execution-policy Bypass is process-only; enforced Group Policy still applies.

[Setup index](../README.md)
