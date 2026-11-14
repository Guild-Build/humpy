# Disable automatic locking

Run `Disable-AutoLock.cmd` as administrator under the intended signed-in user's own account. Do not supply a different administrator's credentials: HKCU would target that other account. No confirmation gate; the command prints its warning before making changes.

1. **Security warning:** an unattended signed-in session is exposed.
2. Disables the current user's screen saver (ScreenSaveActive=0) and Dynamic Lock (EnableGoodbye=0). Disables the machine-wide interactive-logon inactivity timeout (InactivityTimeoutSecs=0), affecting all users. No auto-login, password removal, Defender, network, RDP or power changes.
3. Refuses domain/Entra-joined devices, detected MDM enrollment and explicit screen-saver policy. Checks are conservative, not exhaustive management discovery; access/OS errors fail before writes. It never deletes enforcement settings to work around management.
4. Registry writes are checked individually. Partial writes can remain if a later write fails. Exit 0 means settings saved, not that Windows' effective lock behavior was tested.
5. Existing sessions can cache settings. A later manual sign-out/sign-in or restart may be needed; the command does neither. Sleep/wake sign-in, presence-sensing lock, RDP/session-disconnect behavior, third-party tools and other enforced policy remain unchanged. Unsupported features/editions may ignore a saved value; no universal unlock guarantee.
6. There is no automatic undo or runtime backup. Before running, note existing values if exact restoration is required. Re-enable desired behavior through Screen Saver Settings, Sign-in options / Dynamic Lock and Local Security Policy / Interactive logon: Machine inactivity limit (where available).

Validation: static inspection and PowerShell parsing only; not execution-tested on this host or a Windows VM.
