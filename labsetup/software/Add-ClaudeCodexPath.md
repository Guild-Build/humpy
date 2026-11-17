# Add Claude and Codex to PATH

Double-click as the intended ordinary user, not an administrator. A fixed action: it runs
[Update-CliPath.cmd](Update-CliPath.cmd) with the tool list `claude,codex`, so nothing is typed.
Keep Update-CliPath.cmd in the same folder; without it the command stops and changes nothing.

1. Preview: `Add-ClaudeCodexPath.cmd -Preview -NoPause`.
2. Apply: double-click, or `Add-ClaudeCodexPath.cmd -NoPause`.
3. -Help is non-mutating.

Scope, safety and exit codes are Update-CliPath's: user PATH only, missing folders appended, nothing installed,
elevated sessions refused. 0 complete or nothing to add, 2 failure, 3 a tool was not found.

Where the tools are looked for: claude in the user `.local\bin` (native installer) or npm; codex in the user npm
folder, beside a Node.js zip in `%LOCALAPPDATA%\Programs\nodejs` (npm's global prefix there is the Node folder),
`.local\bin` or `.cargo\bin`. A Codex npm shim also needs `node` on PATH; with the Node zip it is the same folder.

Programs that were already open keep their old PATH, including terminals inside an app. Restart them, or sign out
and back in, then open a fresh terminal.

Checked on one Windows 11 laptop with Claude Code installed natively and Codex installed with npm from a Node.js zip:
-Help, invalid arguments, preview and apply. Not checked on a VM or with Node.js from the MSI.
