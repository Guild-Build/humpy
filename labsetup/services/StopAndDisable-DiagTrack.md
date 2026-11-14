# Disable Windows Telemetry

**Double-click `StopAndDisable-DiagTrack.cmd`**, approve Windows UAC if requested,
then the command displays the prior state and applies. No arguments or extra prompt.

Targets only **DiagTrack**, Connected User Experiences and Telemetry. Disabling it
reduces diagnostic reporting; it does **not** disable every Windows telemetry path.
Defender, Windows Update, error reporting, SQL Server, Docker and WSL are untouched.
Use on an authorized standalone Windows lab machine, not to override organization policy.

Stops the service without forcing dependents, waits up to 15 seconds for Stopped,
then disables startup and checks both values. A missing service or failed operation
is an error; earlier changes may remain. No reboot or automatic rollback.

## Undo

Use the prior state shown in the console and inspect current state first. In an
administrator Command Prompt, restore the original startup type using **one** of:

```cmd
sc.exe config DiagTrack start= auto
sc.exe config DiagTrack start= delayed-auto
sc.exe config DiagTrack start= demand
sc.exe config DiagTrack start= disabled
```

Use `delayed-auto` only if the original was delayed automatic. Run
`sc.exe start DiagTrack` **only if it was originally running**, then check with
`sc.exe qc DiagTrack` and `sc.exe query DiagTrack`. Do not undo someone else's later changes.

Exit 0 means verified, 1 means failure, and 2 means unsupported arguments. No live service disable or RAM-saving
measurement was performed during this refactor.

[Setup index](../README.md)
