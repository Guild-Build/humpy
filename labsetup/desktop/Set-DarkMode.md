# Set dark mode

Double-click Set-DarkMode.cmd as the user whose appearance should change. It warns and applies immediately. Use -Help to inspect without applying. No helper or administrator rights
are needed. The final completion pause remains.

Warning: changes only the current user's Windows and supported apps to dark appearance.
It sets AppsUseLightTheme and SystemUsesLightTheme to DWORD 0 under
HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize.
Other users and other settings are untouched. Applications may override these preferences.
Some Windows versions or apps may need reopening or signing out before the change appears.
The command never restarts Windows or Explorer and does not sign you out.

To choose light again, use Settings > Personalization > Colors > Light.
Failure is shown and returns exit 1; one preference may already have changed.
No live theme change was tested.

[Setup index](../README.md)
