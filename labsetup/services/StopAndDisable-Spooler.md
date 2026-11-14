# Disable Print Spooler

**Double-click `StopAndDisable-Spooler.cmd`**, approve Windows UAC if requested,
then the command displays the prior state and applies. No arguments or extra prompt.

Targets only **Spooler**. Printing, including virtual printers that require the spooler,
will be unavailable. Do not use on a print server or while printing is needed.
SQL Server, Docker, WSL, Defender and Windows Update are not changed.
Use on an authorized standalone Windows lab machine, not to override organization policy.

Stops the service without forcing dependents, waits up to 15 seconds for Stopped,
then disables startup and checks both values. A missing service or failed operation
is an error; earlier changes may remain. No reboot or automatic rollback.

## Undo

Use the prior state shown in the console and inspect current state first. In an
administrator Command Prompt, restore the original startup type using **one** of:

```cmd
sc.exe config Spooler start= auto
sc.exe config Spooler start= delayed-auto
sc.exe config Spooler start= demand
sc.exe config Spooler start= disabled
```

Use `delayed-auto` only if the original was delayed automatic. Run
`sc.exe start Spooler` **only if it was originally running**, then check with
`sc.exe qc Spooler` and `sc.exe query Spooler`. Do not undo someone else's later changes.

Exit 0 means verified, 1 means failure, and 2 means unsupported arguments. No live service disable or RAM-saving
measurement was performed during this refactor.

[Setup index](../README.md)
