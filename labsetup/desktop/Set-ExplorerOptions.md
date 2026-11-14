# Exact File Explorer Folder Options

Standalone CMD for Windows Server 2025 Desktop Experience build 26100, using Windows PowerShell 5.1. Double-click unelevated as the intended Explorer user. No administrator launch or different-user substitution. Preview: `Set-ExplorerOptions.cmd -Preview -NoPause`. Help: `Set-ExplorerOptions.cmd -Help -NoPause`.

## Only these five changes

1. General / Privacy: recently used files OFF: HKCU Explorer ShowRecent=0.
2. General / Privacy: frequently used folders OFF: HKCU Explorer ShowFrequent=0.
3. General / Privacy: Office.com files OFF: HKCU Explorer ShowCloudFilesInQuickAccess=0.
4. View: Hide extensions for known file types OFF: HKCU Explorer/Advanced HideFileExt=0.
5. View: Show hidden files, folders and drives ON: HKCU Explorer/Advanced Hidden=1.

Explorer here means Software/Microsoft/Windows/CurrentVersion/Explorer; all five values are DWORDs. No history is cleared, no Search preference is touched, and no unrelated preference/policy is reset.

## UI and protected-files preflight

Checks the actual product/build/installation type and refuses other editions/builds or Server Core. This is a compatibility guard, NOT evidence that every checkbox exists. Missing preference values do not establish whether their UI controls exist.

Close Folder Options before running so an old dialog cannot save stale values. Use -Preview to inspect the five registry targets without writing. The command applies directly otherwise; it cannot verify the UI or substitute for missing controls.

Before any changes and each write, ShowSuperHidden must be DWORD 0. If unset, the corresponding machine Folder Options schema must establish a ShowSuperHidden default of 0 at the exact Advanced key. Otherwise it stops and asks you to manually ensure Hide protected operating system files is checked. It NEVER writes ShowSuperHidden or resets that checkbox itself. An unsafe, unknown or concurrently changed protected-file state blocks further writes.

## Verification and limitations

Shows old and requested values, checks for concurrent changes, skips matching values and reads each write back. Unexpected types/values are refused. Partial-write failures list attempted settings; no automatic rollback. Registry read-back is not visual UI confirmation, nor proof against later policy overrides.

Reopen Folder Options and visually check the five controls. Close an already-open dialog without saving stale controls. Refresh/reopen Explorer windows manually if needed; there is no forced Explorer restart, sign-out or system restart. Report any checkbox that is absent, different or unchanged on that build.

Exit 0: preference read-back/no-op/preview; this never claims UI verification. Exit 2: guard/write/verification failure, possibly partial after a write. Launcher failures may return another nonzero code.

Checked with inert fixtures and actual non-mutating help/invalid-argument entry points only. OS/identity/registry boundaries were mocked; no settings were changed, no Server 2025 execution or target UI pass is claimed.
