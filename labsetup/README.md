# Lab setup

Run only the command you need. Commands are grouped by purpose, not a run order.
Keep the listed companions with their command. Fixed actions apply on launch;
commands that need a target or value ask for it. Windows UAC and policy still apply.

[Standalone software kit](../scripts/software/)

## Accounts

1. [Add-LocalUser.cmd](accounts/Add-LocalUser.cmd) ([notes](accounts/Add-LocalUser.md))
1. [Set-LocalPasswordPolicy.cmd](accounts/Set-LocalPasswordPolicy.cmd) ([notes](accounts/Set-LocalPasswordPolicy.md))
1. [Add-LocalAdminInteractive.cmd](accounts/Add-LocalAdminInteractive.cmd) ([notes](accounts/Add-LocalAdminInteractive.md))
1. [Add-LocalAdmin.cmd](accounts/Add-LocalAdmin.cmd) ([notes](accounts/Add-LocalAdmin.md))
1. [Open-LocalUsersAndGroups.cmd](accounts/Open-LocalUsersAndGroups.cmd)

## Networking and drives

1. [Set-StaticIPv4.cmd](network/Set-StaticIPv4.cmd) ([notes](network/Set-StaticIPv4.md))
1. [Enable-RemoteDesktop.cmd](network/Enable-RemoteDesktop.cmd) ([notes](network/Enable-RemoteDesktop.md))
1. [Map-Projects.cmd](network/Map-Projects.cmd) ([notes](network/Map-Projects.md))
1. [Map-ProjectsDrive.cmd](network/Map-ProjectsDrive.cmd)
1. [Register-ProjectsDriveAtLogon.cmd](network/Register-ProjectsDriveAtLogon.cmd)
1. [Remove-NetworkDrive.cmd](network/Remove-NetworkDrive.cmd)

## Windows setup

1. [Rename-Computer.cmd](system/Rename-Computer.cmd) ([notes](system/Rename-Computer.md))
1. [Disable-OptionalFeature.cmd](system/Disable-OptionalFeature.cmd) ([notes](system/Disable-OptionalFeature.md))
1. [Remove-AzureArc.cmd](system/Remove-AzureArc.cmd) ([notes](system/Remove-AzureArc.md))
1. [Set-TimeZone.cmd](system/Set-TimeZone.cmd) ([notes](system/Set-TimeZone.md))
1. [Set-EasternTimeZone.cmd](system/Set-EasternTimeZone.cmd)

## Desktop

1. [Set-ClientAreaAnimations.cmd](desktop/Set-ClientAreaAnimations.cmd) ([notes](desktop/Set-ClientAreaAnimations.md))
1. [Set-MenuAnimations.cmd](desktop/Set-MenuAnimations.cmd) ([notes](desktop/Set-MenuAnimations.md))
1. [Set-DarkMode.cmd](desktop/Set-DarkMode.cmd) ([notes](desktop/Set-DarkMode.md))
1. [Hide-TaskView.cmd](desktop/Hide-TaskView.cmd) ([notes](desktop/Hide-TaskView.md))
1. [Open-VisualPerformance.cmd](desktop/Open-VisualPerformance.cmd) ([notes](desktop/Open-VisualPerformance.md))
1. [Open-ChromeDefaultApps.cmd](desktop/Open-ChromeDefaultApps.cmd) ([notes](desktop/Open-ChromeDefaultApps.md))
1. [Set-DesktopBlack.cmd](desktop/Set-DesktopBlack.cmd) ([notes](desktop/Set-DesktopBlack.md))
1. [Set-ExplorerOptions.cmd](desktop/Set-ExplorerOptions.cmd) ([notes](desktop/Set-ExplorerOptions.md))
1. [Set-TaskbarLeft.cmd](desktop/Set-TaskbarLeft.cmd) ([notes](desktop/Set-TaskbarLeft.md))

Menu animations also uses [recovery/Simple.ps1](recovery/Simple.ps1); keep this layout.

## Power, display and idle lock

1. [Disable-AutoLock.cmd](power/Disable-AutoLock.cmd) ([notes](power/Disable-AutoLock.md))
1. [Disable-ScreenTimeout.cmd](power/Disable-ScreenTimeout.cmd) ([notes](power/Disable-ScreenTimeout.md))
1. [Disable-Sleep.cmd](power/Disable-Sleep.cmd) ([notes](power/Disable-Sleep.md))
1. [Set-HighPerformance.cmd](power/Set-HighPerformance.cmd) ([notes](power/Set-HighPerformance.md))

## Security and updates

1. [Set-DefenderScanCPU.cmd](security/Set-DefenderScanCPU.cmd) ([notes](security/Set-DefenderScanCPU.md))
1. [Set-DefenderIdleScanThrottle.cmd](security/Set-DefenderIdleScanThrottle.cmd) ([notes](security/Set-DefenderIdleScanThrottle.md))
1. [Add-DefenderFolderExclusion.cmd](security/Add-DefenderFolderExclusion.cmd) ([notes](security/Add-DefenderFolderExclusion.md))
1. [Set-AutomaticUpdates.cmd](security/Set-AutomaticUpdates.cmd) ([notes](security/Set-AutomaticUpdates.md))
1. [Set-UACNeverNotify.cmd](security/Set-UACNeverNotify.cmd)

## Services

1. [StopAndDisable-SQLServerTelemetry.cmd](services/StopAndDisable-SQLServerTelemetry.cmd) ([notes](services/StopAndDisable-SQLServerTelemetry.md))
1. [StopAndDisable-DiagTrack.cmd](services/StopAndDisable-DiagTrack.cmd) ([notes](services/StopAndDisable-DiagTrack.md))
1. [StopAndDisable-Spooler.cmd](services/StopAndDisable-Spooler.cmd) ([notes](services/StopAndDisable-Spooler.md))
1. [StopAndDisable-WindowsSearch.cmd](services/StopAndDisable-WindowsSearch.cmd) ([notes](services/StopAndDisable-WindowsSearch.md))
1. [StopAndDisable-SysMain.cmd](services/StopAndDisable-SysMain.cmd) ([notes](services/StopAndDisable-SysMain.md))
1. [StopAndDisable-MapsBroker.cmd](services/StopAndDisable-MapsBroker.cmd) ([notes](services/StopAndDisable-MapsBroker.md))
1. [Set-MSDTCManual.cmd](services/Set-MSDTCManual.cmd)
1. [Titus startup-only service commands](services/Titus-Services/README.md)

## Software

1. [Remove-OptionalApp.cmd](software/Remove-OptionalApp.cmd) ([notes](software/Remove-OptionalApp.md))
1. [Download-Chocolatey.cmd](software/Download-Chocolatey.cmd)
1. [Download-ChromeStandalone.cmd](software/Download-ChromeStandalone.cmd)
1. [Install-Chocolatey.ps1](software/Install-Chocolatey.ps1)
1. [Install-Chrome.cmd](software/Install-Chrome.cmd)
1. [Install-ChromeViaChocolatey.cmd](software/Install-ChromeViaChocolatey.cmd)
1. [Install-ClaudeCode.cmd](software/Install-ClaudeCode.cmd)
1. [Install-GitHubCLI.cmd](software/Install-GitHubCLI.cmd) ([notes](software/Install-GitHubCLI.md))
1. [Open-ChromeDownload.cmd](software/Open-ChromeDownload.cmd)
1. [Open-EdgeUninstallSettings.cmd](software/Open-EdgeUninstallSettings.cmd)
1. [Update-CliPath.cmd](software/Update-CliPath.cmd) ([notes](software/Update-CliPath.md))

## Read-only diagnostics

1. [List-Apps.cmd](diagnostics/List-Apps.cmd) ([notes](diagnostics/List-Apps.md))
1. [List-Components.cmd](diagnostics/List-Components.cmd) ([notes](diagnostics/List-Components.md))
1. [List-StartupCommands.cmd](diagnostics/List-StartupCommands.cmd) ([notes](diagnostics/List-StartupCommands.md))
1. [Show-DefenderLoad.cmd](diagnostics/Show-DefenderLoad.cmd) ([notes](diagnostics/Show-DefenderLoad.md))
1. [Show-Resources.cmd](diagnostics/Show-Resources.cmd) ([notes](diagnostics/Show-Resources.md))

## Legacy recovery

1. [Restore-OptionalFeature.cmd](recovery/Restore-OptionalFeature.cmd) ([notes](recovery/Restore-OptionalFeature.md))
1. [Restore-LabSetting.cmd](recovery/Restore-LabSetting.cmd) ([notes](recovery/Restore-LabSetting.md))

These commands use existing matching receipts only. They do not create or rewrite receipts.
