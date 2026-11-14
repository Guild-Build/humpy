# Disable SQL Server Telemetry

**Double-click `StopAndDisable-SQLServerTelemetry.cmd`**, approve Windows UAC if requested,
then the command displays the prior state and applies. No arguments or extra prompt.

Targets only **SQLTELEMETRY**, the default SQL Server instance's usage/diagnostic
reporting service. Named-instance telemetry is not selected. It never stops the
database engine or SQL Agent and never changes SQL memory, Defender, updates or Docker.
Use on an authorized standalone Windows lab machine, not to override organization policy.

Stops the service without forcing dependents, waits up to 15 seconds for Stopped,
then disables startup and checks both values. A missing service or failed operation
is an error; earlier changes may remain. No reboot or automatic rollback.

## Undo

Use the prior state shown in the console and inspect current state first. In an
administrator Command Prompt, restore the original startup type using **one** of:

```cmd
sc.exe config SQLTELEMETRY start= auto
sc.exe config SQLTELEMETRY start= delayed-auto
sc.exe config SQLTELEMETRY start= demand
sc.exe config SQLTELEMETRY start= disabled
```

Use `delayed-auto` only if the original was delayed automatic. Run
`sc.exe start SQLTELEMETRY` **only if it was originally running**, then check with
`sc.exe qc SQLTELEMETRY` and `sc.exe query SQLTELEMETRY`. Do not undo someone else's later changes.

Exit 0 means verified, 1 means failure, and 2 means unsupported arguments. No live service disable or RAM-saving
measurement was performed during this refactor.

[Setup index](../README.md)
