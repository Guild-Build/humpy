# Disable Windows Search

**Double-click `StopAndDisable-WindowsSearch.cmd`**, approve Windows UAC if requested,
then the command displays the prior state and applies. No arguments or extra prompt.

Targets only **WSearch**. Indexed file searches and applications that depend on indexing
may be slower or unavailable. Running dependent services cause the native stop to fail;
this script never force-stops them. Review Work Folders and media-sharing dependencies first.
SQL Server, Docker, WSL, Defender and Windows Update are not changed.
Use on an authorized standalone Windows lab machine, not to override organization policy.

Stops the service without forcing dependents, waits up to 15 seconds for Stopped,
then disables startup and checks both values. A missing service or failed operation
is an error; earlier changes may remain. No reboot or automatic rollback.

## Undo

Use the prior state shown in the console and inspect current state first. In an
administrator Command Prompt, restore the original startup type using **one** of:

```cmd
sc.exe config WSearch start= auto
sc.exe config WSearch start= delayed-auto
sc.exe config WSearch start= demand
sc.exe config WSearch start= disabled
```

Use `delayed-auto` only if the original was delayed automatic. Run
`sc.exe start WSearch` **only if it was originally running**, then check with
`sc.exe qc WSearch` and `sc.exe query WSearch`. Do not undo someone else's later changes.

Exit 0 means verified, 1 means failure, and 2 means unsupported arguments. No live service disable or RAM-saving
measurement was performed during this refactor.

[Setup index](../README.md)
