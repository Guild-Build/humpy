# Update explicitly selected CLI paths

Double-click as the intended ordinary user, not an administrator, and enter an explicit list such as claude,codex,gh. Nothing is selected by default.

1. Preview: `Update-CliPath.cmd -Tools claude,codex,gh -Preview -NoPause`.
2. Apply: omit -Preview and supply or enter the exact tool list.
3. -Help is non-mutating. -NoPause skips the final close prompt.

## Scope and safety

This deliberately updates USER PATH only. It reads machine PATH for deduplication and shows machine changes as none. It never promotes user-writable/npm/shim folders into system PATH and never requests elevation. Elevated sessions are refused; another account would mean another user PATH, so run as the intended account. Machine-wide PATH editing is not implemented.

Only explicitly listed command names are considered. claude, codex and gh first use bounded Windows command resolution, then a few exact expected executable locations: user .local/bin and npm for Claude; user npm, .local/bin and .cargo/bin for Codex; Program Files/GitHub CLI and LocalAppData/Programs/GitHub CLI for gh. Multiple known installations are reported as unresolved rather than guessed. Additional explicitly listed command names use command resolution only, with no guessed locations. Tools are never executed, installed or recursively searched.

The proposal shows resolved executables, user additions and all unresolved names before writing. All additions are deduplicated against the persisted user/machine PATH and each other, case-insensitively with normalized slashes, balanced quotes and expandable variables for comparison only. Existing entries, duplicates, order, raw variable text and registry type are preserved. Only genuinely missing directory strings are appended. No setx, truncation or stored expansion. Alias/junction equivalence is not guessed.

Concurrent PATH edits abort before writing. One user registry value is written and read back; failures after a write are reported as potentially partial. Resolved tools can be added while unresolved tools remain, but that partial result is shown before writing and returns code 3. The previous raw user PATH is printed before writing. No automatic rollback.

## Fresh environment and exit status

Existing processes are not changed or broadcast to. Sign out and back in, then open a fresh terminal for a guaranteed refreshed environment; new shells launched by stale parents may inherit stale PATH. The command never signs out or restarts anything.

0: complete, no-op, preview or cancelled. 2: invalid input/rights/write/verification failure. 3: unresolved tools, including an explicitly reported partial addition. PowerShell launch failures may use another nonzero status. Windows policy is not bypassed. Requires Windows PowerShell 5.1.

Checked with inert planner/control-flow fixtures and non-mutating help/invalid argument entry points only. No persistent PATH changes or VM execution were tested.
