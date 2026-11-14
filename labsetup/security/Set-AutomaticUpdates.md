# HIGH RISK: automatic updates policy

The CMD works alone using Windows PowerShell 5.1. No sibling script or engine is needed. The same-stem PS1 is an independent optional entry point.

1. Preview: Set-AutomaticUpdates.cmd -Value true -Preview -NoPause
2. Disable automatic updates: use -Value true (or on) from an administrator terminal.
3. Re-enable the local automatic-update setting: -Value false (or off). This sets NoAutoUpdate=0; other policies still apply.
4. Remove only this override: -Value reset. Deletes only NoAutoUpdate, not the key or other settings.
5. Help: -Help -NoPause. Without -Value it asks for true/false/reset; blank cancels. No automatic elevation.

HIGH RISK: disabling automatic updates can leave known security vulnerabilities unpatched. Arrange manual OS patching. This does not promise to stop all updates/downloads/restarts, and Defender intelligence behavior is not guaranteed. No services, Defender settings, network access or managed-policy enforcement are disabled.

The only setting changed is HKLM/SOFTWARE/Policies/Microsoft/Windows/WindowsUpdate/AU/NoAutoUpdate, the Configure Automatic Updates policy value. Requires a supporting Pro, Enterprise, Education, IoT Enterprise or Server edition; Home and unrecognized editions are refused. Domain/MDM policy may reject, replace or override this local registry preference. No management controls are bypassed or forced policy refresh run. Readback does not prove effective update behavior. Check Windows Update; policy refresh or a manual restart may be needed.

Keep the original value printed before changes: restore 1 with true, 0 with false, or absent with reset. No undo helper/record is required or created; Restore-LabSetting.cmd is not the recovery path. Unexpected existing types/values and concurrent changes before the write are refused.

Exit 0: matched readback, already set, preview, help or cancellation. Exit 2: invalid/failed; an attempted write may remain. PowerShell launch failures can return another nonzero code. No restart or rollback is automatic. Actual policy application/effective behavior on the production VM remain untested.
