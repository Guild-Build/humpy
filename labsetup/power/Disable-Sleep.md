# Disable automatic idle sleep

1. Right-click Disable-Sleep.cmd and choose **Run as administrator**, or run it from an elevated Command Prompt. No confirmation gate; the warning prints before changes. The final pause keeps results visible.
2. Uses Windows powercfg to set standby-timeout-ac and standby-timeout-dc to 0 (Never) on the current plan. No plan switch. Battery/DC values are dormant on devices without a battery. Do not switch plans while it runs.
3. Warning: increased power use and battery drain. It does not change display timers, locking, hibernation timers, lid/button actions, or critical-battery protection. Manual sleep remains possible.
4. Enforced policy, Modern Standby and unsupported VM sleep states can prevent the intended behavior. Windows errors remain visible; restrictions are not bypassed. Accepted writes do not prove effective behavior.
5. The command displays sleep settings before and after. Under Sleep after, both AC/DC indexes should be 0x00000000. Read-back is displayed for inspection, not automatically parsed. powercfg /a can separately show supported sleep states.
6. Failures exit 1 after the closing pause; earlier writes can remain. Success exits 0. The administrator check uses fltmc and fails closed if that check is unavailable.
7. To undo, use Power Options to restore the prior Sleep after values shown before changes. No automatic rollback or stored backup of power settings.
8. Validation: static source checks only; not executed on this host or tested in the target VM.
