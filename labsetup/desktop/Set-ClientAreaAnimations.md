# Current-user client-area animations

The CMD stands alone: it contains its PowerShell implementation. No sibling PS1, Simple.ps1, engine, install or administrator rights needed. Run as the intended user. Windows PowerShell 5.1 and permitted Add-Type/native interop are required.

1. Double-click to enter on/off (true/false also accepted); blank cancels.
2. Command Prompt: `Set-ClientAreaAnimations.cmd -Value off -NoPause`.
3. Read-only preview: `Set-ClientAreaAnimations.cmd -Value off -Preview -NoPause`.
4. Usage: `Set-ClientAreaAnimations.cmd -Help -NoPause`.

The warning precedes the change. A supplied value applies immediately without a separate review gate. Unknown options or invalid values fail before mutation.

Uses Windows SystemParametersInfo SPI_GETCLIENTAREAANIMATION / SPI_SETCLIENTAREAANIMATION, persists the preference and broadcasts a change notification. It does not modify menu animations, minimize/maximize animation, unrelated visual effects or timeouts. No forced Explorer restart/sign-out.

Reads and displays the previous value and restore command, then verifies the result. To undo, run again with that previous on/off value. This standalone version does not create helper-engine undo receipts; Restore-LabSetting.cmd cannot undo its new changes. Existing receipts are untouched. The PS1 companion is also self-contained, but optional.

Policy, application settings or a remote session may override/ignore the preference. No policy bypass; Windows/API failures report errors. Read-back confirms the preference, not visible animation in every app. No guaranteed speed improvement.

Exit 0: verified, unchanged, preview, help or cancelled. Exit 2: invalid input/API/verification failure; a failed verification may follow a change. PowerShell launch failures may have other nonzero exit codes.

Validation: static parsing and help/invalid-input checks only; no live setting mutation or production VM test.
