# Set High performance

Run in Command Prompt:

```cmd
"X:\lab-snippets\labsetup\Set-HighPerformance.cmd"
```

The warning prints before the immediate switch; no confirmation gate or restart.
If Windows reports Access denied, use an administrator Command Prompt. No automatic elevation.

Activates the existing standard High performance GUID only. Increases potential power use, heat and battery drain. No sleep, display or lock timeout values are edited; switching plans does apply the selected plan's existing timeout values.

Lists the target first, displays the previous active plan, then checks the active GUID after switching. Exit 0 means verified active at that check; exit 1 means failure or unverified state. A later policy refresh can override the selection.

Missing/renamed-GUID custom plans, Modern Standby and OS/policy restrictions are not worked around. No new plan is created. The previous GUID printed on screen can be reactivated with `powercfg /setactive PREVIOUS-GUID`.

Validation: static inspection only. Not executed on this host or a VM.
