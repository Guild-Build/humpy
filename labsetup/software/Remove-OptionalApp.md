# Remove one current-user app

Copy only **Remove-OptionalApp.cmd**. It is standalone and uses built-in Windows PowerShell 5.1/Appx cmdlets, not Simple.ps1, any sibling script or external engine. The PS1 remains an optional independent equivalent.

Run as the intended user; no elevation is requested. Another account means that account's apps. No all-user uninstall, image deprovisioning, desktop/MSI uninstall or wildcard removal.

1. Double-click: lists supported installed apps. Enter one exact Name.
2. Preview: Remove-OptionalApp.cmd -Name Microsoft.BingNews -Preview -NoPause
3. Remove: Remove-OptionalApp.cmd -Name Microsoft.BingNews. The exact name applies directly; blank or EOF at the selection does nothing.
4. Help: Remove-OptionalApp.cmd -Help -NoPause. The original seven optional-app names remain the only allowed targets. Missing apps are a harmless no-op.

**Warning:** removal can permanently lose local app data. Back up needed data first. Framework, resource, non-removable, ambiguous and depended-on packages are refused. Identity and dependencies are rechecked before removal; success requires a post-removal registration check.

The generic helper and its unrelated lab/pending-restart gates are no longer involved. Windows permissions and policy still apply; no bypass. Protected or managed apps may fail with the Windows error shown. Other users and image provisioning remain unchanged; Windows can reinstall apps later. No automatic restart, rollback or reinstall. Reinstall from a trusted source for recovery; data recovery is not guaranteed.

Exit 0: verified removal, preview, help, no-op or cancellation. Exit 2: rejected/failed; partial effects may remain if removal began. Windows editions without Appx cmdlets report that limitation. Pauses at completion unless -NoPause or redirected I/O.

Validation: static parsing and non-mutating help/invalid-input checks only; no live uninstall test.
