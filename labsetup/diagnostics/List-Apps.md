# List apps

Lists current-user Appx packages, not all installed desktop software, other
users or provisioned-image packages. Does not remove anything.

Double-click List-Apps.cmd, or use -NoPause in a terminal.
Keep its same-named PS1 beside it. -Help prints this page without inspection.
Windows PowerShell 5.1 and the relevant Windows module are required; no Python or
external helpers. Unsupported mutation arguments are rejected.

Read-only. Missing permissions/modules fail explicitly. Local output can reveal
machine/account/path information; keep it private. Exit 0 means completed; 2 means
inspection failed. Offline checks are not
live-machine acceptance.

[Setup index](../README.md)
