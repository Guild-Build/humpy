# Hide Task View button

Double-click Hide-TaskView.cmd locally as the signed-in user on Windows Server 2025 Desktop Experience. No elevation or alternate administrator account. Use /? for help.

Only HKCU/Software/Microsoft/Windows/CurrentVersion/Explorer/Advanced/ShowTaskViewButton is set to DWORD 0 and read back. The Advanced key is created if absent. Search, alignment and every other taskbar setting are untouched. Hiding the button does not disable virtual desktops; Win+Tab remains available.

This is Explorer's local visibility preference, not a guarantee of visible appearance. No forced Explorer restart/sign-out or policy bypass. If the button remains visible, open Taskbar settings and switch Task view off, or sign out and back in yourself when convenient. Restore the button through Taskbar settings > Task view > On. Managed policy, custom shells or future Windows changes may ignore/override this preference. Server Core has no applicable Explorer taskbar; this command does not add one. Other OS versions are not validated.

Exit 0: saved/read back or help. Exit 2: invalid arguments or caught failure; an attempted write may remain. PowerShell launch failures may return another nonzero code. A closing pause keeps output visible. Registry readback is not proof of visible appearance.

No live registry mutation or production VM test was performed during authoring.
