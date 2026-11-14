# Disable automatic display-off

Run `Disable-ScreenTimeout.cmd` on the target Windows machine, or right-click **Run as administrator** if access is denied. It prints its warning and applies immediately; the final pause keeps results visible. No confirmation gate or helper files.

Only the current plan's AC and DC monitor timeout is set to zero (Never), using Windows powercfg. Sleep, locking, screen saver settings and plan selection stay unchanged. DC is stored even without a battery, where it has no practical effect. More display-on time uses more power and battery.

Powercfg errors are displayed and return exit code 1; earlier successful changes may remain. Policy may reject or override settings. VMs may not expose a meaningful display power setting, and this does not configure the remote client's physical screen or session timeout. The before/after query is displayed, not saved; note the original VIDEOIDLE indexes if you want to restore them later through Windows Power Options. Zero indexes are Never.

Static checks only; not execution-tested on the VM.
