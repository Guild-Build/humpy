# Show Defender load

Three samples of Defender CPU (normalized to the whole machine), private memory,
protection state, scan preferences, scan ages, signature age and exclusion count.
Run as administrator to see the exclusion count. Missing process counters are
reported as not visible, not zero. This snapshot does not diagnose every slowdown.

Double-click Show-DefenderLoad.cmd, or use -NoPause in a terminal.
Keep its same-named PS1 beside it. -Help prints this page without inspection.
Windows PowerShell 5.1 and the relevant Windows module are required; no Python or
external helpers. Unsupported mutation arguments are rejected.

Read-only. Missing permissions/modules fail explicitly. Local output can reveal
machine/account/path information; keep it private. Exit 0 means completed; 2 means
inspection failed. Offline checks are not
live-machine acceptance.

[Setup index](../README.md)
