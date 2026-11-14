# Set the Windows time zone

Double-click Set-TimeZone.cmd. It shows the current zone and the native TZUTIL list.
Enter one exact Windows time zone ID to apply it. No zone is assumed.
Blank input still cancels. The CMD is standalone; PowerShell and sibling files are not required.

Warning: time zone is a machine-wide Windows preference affecting all users and
local-time displays/schedules. DST follows the selected zone. This command does not
set the clock, configure NTP, change services, disable DST explicitly or restart.
Use only with authority to change this machine's time zone. If Windows denies the
operation, run it from an authorized administrator terminal; no policy is bypassed.

TZUTIL validates whether the exact ID exists. Invalid characters and extra switches
are refused before invocation; unsupported IDs or OS/permission failures remain errors.
After success, the current Windows zone is displayed. To undo, run again and select
the original zone shown before the change. No unattended/default zone or bulk changes.

-Help shows usage without changes. Exit 0 means saved/help/cancelled; 1 means Windows
reported failure; 2 means invalid input/usage.
Static checks and non-mutating help checks only. LIVE TEST NOT RUN: no live time-zone
change tested. The final completion pause remains.
