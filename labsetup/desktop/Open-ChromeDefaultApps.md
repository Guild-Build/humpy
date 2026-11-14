# Choose Chrome as default browser

1. Install Google Chrome, then double-click Open-ChromeDefaultApps.cmd as the intended user. No administrator rights or companion files needed. Use /? for help.
2. Checks registered App Paths and standard per-user, Program Files and Program Files (x86) folders for chrome.exe. If missing, reports the prerequisite and stops. Custom/portable installations outside those paths may not be detected. A binary does not prove Default apps registration.
3. Opens the supported Settings URI ms-settings:defaultapps. Windows 11: choose Google Chrome and click Set default. Windows 10: choose Chrome under Web browser and confirm Windows prompts. Controls vary by version and policy. If Chrome is absent, complete/repair its installation.
4. **Does not set or verify the default browser.** Only requests the selection screen. You make the choice. Exit 0 means the launch request was accepted, not that the UI displayed or your choice succeeded. Check Default apps afterward for intended HTTP/HTTPS browser associations; the command does not change unrelated associations.
5. No UserChoice/hash manipulation, registry writes, policy takeover, browser removal, sign-out or restart. Windows policy remains authoritative. Server and pre-Windows-10 clients are unsupported. Settings must be available.
6. Exit 2: unsupported OS, missing Chrome, invalid arguments or launch/check failure. Final pause preserves instructions. Safe checks only: PowerShell parsing, help and invalid-argument execution. No Settings launch, host default change or target-VM/UI test.
