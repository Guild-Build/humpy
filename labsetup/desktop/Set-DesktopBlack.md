# Solid black desktop, no picture

Run Set-DesktopBlack.cmd normally in the intended signed-in user's desktop session.
It warns and applies immediately. Do not launch to inspect or cancel. -Help is read-only.
Do not use Run as a different user. The completion pause remains.
This standalone CMD needs permitted Windows PowerShell 5.1 and desktop APIs, no
helper file, package install or elevation. It does not bypass application control
or PowerShell restrictions; a launch/compilation failure is an error, not success.

It persists only the user's desktop background color as black, calls SetSysColors
for COLOR_BACKGROUND, and clears the desktop wallpaper using the supported
SystemParametersInfo SPI_SETDESKWALLPAPER action with persistence/change notification.
It does not change lock screen, dark/light theme, taskbar, Search or another account.

Common policy wallpaper/restriction and managed-image settings are checked before
writing. A detected policy stops the operation; no policy is removed or changed.
This is not a complete management-policy audit; policy may reapply later. Ask the
policy administrator if blocked instead of trying to defeat it.

Windows API success is NOT proof of visible appearance. If unchanged, manually
refresh the desktop or reopen Settings > Personalization > Background and inspect
Solid color / Black. No Explorer restart, forced sign-out or reboot is performed.
To change back later, select a picture/color there; the previous picture is not
deleted, but its preference is not automatically backed up or restored by this CMD.

Exit 0: API calls completed/help; nonzero: error, possibly partial preference
changes. -Help makes no changes.
Only static/parser/help checks were performed for delivery; real host/VM wallpaper
and visible appearance remain untested. LIVE TEST NOT RUN.
