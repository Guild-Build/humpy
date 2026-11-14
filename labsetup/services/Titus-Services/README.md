# Titus service startup selections — eight independent commands

**LIVE TEST NOT RUN.** These are explicitly requested startup selections, not a recommended/default Windows Server 2025 configuration. No run-all command or shared runtime helper exists. Copy the one CMD you intend to run to a local VM folder; each contains its own implementation and full MIT notice.

| Command | Exact service | Startup | Dependency/risk warning |
| --- | --- | --- | --- |
| [Disable-CscService.cmd](Disable-CscService.cmd) | CscService | Disabled | Offline Files cache and network-share access can be affected; inspect dependent workflows first. |
| [Disable-DiagTrack.cmd](Disable-DiagTrack.cmd) | DiagTrack | Disabled | Connected User Experiences and Telemetry diagnostics are affected. This is not the full telemetry tweak. |
| [Disable-SharedAccess.cmd](Disable-SharedAccess.cmd) | SharedAccess | Disabled | ICS, hotspot and NAT can break, including virtualization networking that depends on this service. |
| [Disable-WerSvc.cmd](Disable-WerSvc.cmd) | WerSvc | Disabled | Removes crash reporting. Microsoft Windows Server 2016 Desktop Experience guidance says DO NOT DISABLE. This is NOT a recommended/default or validated Server 2025 setting. |
| [Disable-lfsvc.cmd](Disable-lfsvc.cmd) | lfsvc | Disabled | Location-dependent applications and location features can stop working. |
| [Disable-WSearch.cmd](Disable-WSearch.cmd) | WSearch | Disabled | Indexed file search can become unavailable or slower. Taskbar Search and its UI are not changed. |
| [Set-MapsBroker-Manual.cmd](Set-MapsBroker-Manual.cmd) | MapsBroker | Manual | Downloaded/offline-map management and update consumers may need to start this service on demand. |
| [Set-StorSvc-Manual.cmd](Set-StorSvc-Manual.cmd) | StorSvc | Manual | Storage-management/settings consumers may be affected or need an on-demand start. This does not change storage drivers or disks. |

## Run and inspect

Double-click one CMD. It warns, requests Windows UAC if needed, displays the actual prior StartType and running Status, and applies the requested startup type. `-Preview` reads only, `-Help` is non-mutating, and `-NoPause` skips the completion pause. A mapped/remote launcher inaccessible after UAC fails honestly; copy the CMD locally rather than weakening permissions.

Only `Set-Service -Name <exact-name> -StartupType <Disabled-or-Manual>` is used for the write, as in the pinned helper's normal startup operation. No target/dependent is force-stopped, stopped, started or restarted. A currently running service need not stop, and process count need not fall. Manual permits an on-demand/trigger/dependency start; it is not Disabled.

Fresh Get-Service read-back displays actual startup/running state. Already-matching startup is a verified no-op. Only the specific NoServiceFoundForGivenName error on the initial read is reported as not installed/no-op. Access, provider, malformed-result, configuration, concurrent-change and read-back errors remain failures; a missing service after an attempted write is NOT a successful no-op. Partial changes may remain; no rollback or restart is automatic. Prior output is not a complete backup of service configuration/delayed-start flags. Upstream OriginalType values are NOT assumed to be this VM's defaults.

Exit 0: verified startup, already set, true missing-service no-op, preview or help. Exit 1: runtime/UAC/provider/config/read-back failure, with the actual PowerShell error identity/message. Exit 2: unsupported CMD arguments. Native PowerShell launch failures may have other nonzero codes. Permission/policy blocks are not bypassed.

## Exact upstream scope and deliberate omissions

Pinned WinUtil commit: `8ec33e211f0724974088806b8623b0aa8afe5fc4`. Services supplies CscService, DiagTrack, SharedAccess, MapsBroker and StorSvc; Location supplies lfsvc; Telemetry supplies WerSvc; DisableSearchIndexing supplies WSearch. DiagTrack appears only once here. The Standard/Minimal/Advanced presets include Services and Telemetry; Location is in Standard/Advanced. WSearch's advanced tweak is NOT in those preset lists. This folder does not execute an entire preset/tweak.

The full upstream WSearch entry also has Stop-Service -Force code; that extra action is deliberately omitted. Telemetry's other registry/scripts and Location's registry bundle are omitted. No Defender sample submission, updates, Taskbar Search/UI or other settings are touched.

Existing `../StopAndDisable-DiagTrack.cmd` is itself narrow DiagTrack-only, but stops before disabling; it is not the broad upstream Telemetry bundle and is not reused. `../StopAndDisable-WindowsSearch.cmd` also stops before disabling. `../StopAndDisable-MapsBroker.cmd` stops and disables, which is NOT this Manual request. None is an exact startup-only fit; existing files are untouched.

**WerSvc caution:** Microsoft's [Windows Server 2016 Desktop Experience service guide](https://learn.microsoft.com/en-us/windows-server/security/windows-services/security-guidelines-for-disabling-system-services-in-windows-server) says **Do not disable**. Disabling removes crash reporting and related diagnostics. That guide is explicitly 2016, NOT Server 2025 validation. The requested command is provided with this warning, not as a recommendation.

## Attribution and license

Startup selections and Get-Service/Set-Service operation adapted from [ChrisTitusTech/winutil](https://github.com/ChrisTitusTech/winutil/tree/8ec33e211f0724974088806b8623b0aa8afe5fc4). Exact pinned sources: [config/tweaks.json](https://github.com/ChrisTitusTech/winutil/blob/8ec33e211f0724974088806b8623b0aa8afe5fc4/config/tweaks.json), [config/preset.json](https://github.com/ChrisTitusTech/winutil/blob/8ec33e211f0724974088806b8623b0aa8afe5fc4/config/preset.json), [Set-WinUtilService.ps1](https://github.com/ChrisTitusTech/winutil/blob/8ec33e211f0724974088806b8623b0aa8afe5fc4/functions/private/Set-WinUtilService.ps1).

The exact upstream [MIT license](LICENSE), **Copyright (c) 2022 CT Tech Group LLC**, is included unchanged in LICENSE and as a comment inside every standalone CMD. Provenance is pinned, not floating main. Local adaptations isolate one fixed service, retain startup-only behavior, print warnings, surface errors as nonzero and verify read-back. No WinUtil function/module is imported or executed.

Validation is limited to real non-mutating help/invalid-argument runs, syntax parsing and isolated mocked service operations. Service existence, role dependencies, UAC completion and live Server 2025 behavior remain unverified. Never run these all together to obtain a test pass.
