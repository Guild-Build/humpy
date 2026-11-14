# Map C:\projects as P:

Run `Map-Projects.cmd` in the **same user/session as your applications**, normally
without elevation. It applies directly, unless -Preview is used.

```cmd
Map-Projects.cmd
Map-Projects.cmd -Preview -NoPause
```

1. Creates `C:\projects` if missing.
2. Adds `P:` as a SUBST alias for that folder. No copying, partitioning or formatting.
3. Refuses an occupied/uncertain P: drive; never replaces a real disk, share or other mapping.
4. An existing identical mapping with a valid source is a no-op. Files and reparse
   points in place of the source folder are refused.
5. **Temporary user/session mapping**: not persistent across sign-out/reboot.
   Elevated and ordinary processes may see different drive mappings. No startup
   task, registry entry or service is installed.

`-Preview` changes no drive/folder settings. `-NoPause` skips the closing pause;
`-Help` displays this page. Use `call` from another CMD and check `errorlevel`.
Exit 0 means preview, already mapped or verified; 2 means blocked/uncertain.

Keep the same-named CMD and PS1 together. Built-in Windows PowerShell 5.1 is
required. The PS1 uses native Windows device queries to reject occupied mappings;
it does not require another repository or a shared helper folder.

## Undo and limits

First run `subst` to inspect the mappings. **Only if P: is still this exact
C:\projects SUBST**, `subst P: /D` removes the alias, not the source folder or files.
Never remove an unrelated drive/mapping. Sign-out/reboot also discards this alias.

There is no automatic cleanup on failure. A failure can leave a newly created
folder or mapping; inspect actual state before intervening. Checks and SUBST are
not atomic: do not run another drive/source editor concurrently. Native mapping
was not exercised on this machine; only offline checks are claimed.

[Setup index](../README.md)
