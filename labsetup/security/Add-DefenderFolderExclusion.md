# HIGH RISK: add one Defender folder exclusion

The CMD stands alone; no sibling or helper needed. Windows PowerShell 5.1 and Defender cmdlets required. Optional PS1 is also standalone.

Run from an administrator Command Prompt; no automatic elevation or policy bypass.

1. Preview: `Add-DefenderFolderExclusion.cmd -Value "D:/Projects/Example" -Preview -NoPause`.
2. Remove -Preview to apply to the exact selected folder.
3. Without -Value, enter one folder; blank/EOF cancels. Quote paths with spaces.
4. -Help prints usage; -NoPause skips the closing prompt.

HIGH RISK: reduces malware protection for the selected folder and its contents. No default path. Whole drives, UNC/network/removable paths, system/program/profile folders or their parents, wildcards, short aliases, linked folders/ancestors, dot navigation and trailing dots/spaces are refused. Choose one narrow existing project folder on a fixed local drive.

Original standalone-lab restrictions remain: domain membership, cloud/MDM registration and pending Windows restart signals block changes. This is not a complete policy audit. Defender permissions, policy and tamper protection remain in force; errors are not bypassed.

Shows the target, revalidates it, adds only that exclusion using Add-MpPreference, then reads back ExclusionPath. Other exclusions are not replaced; an already-listed target is unchanged. No restart/sign-out.

Displays the exact manual Remove-MpPreference recovery command before adding. New runs do not generate old legacy undo receipts; existing receipts remain untouched. Use recovery only for an exclusion added by this run. Failed verification may follow a partial change: inspect Defender, do not assume rollback.

Exit 0: verified, already present, preview, help or cancelled. Exit 2: rejected/failed. PowerShell launch errors may use other nonzero codes.

Checks: embedded PowerShell parses; help and invalid-input paths executed safely. No Defender mutation or production VM test.
