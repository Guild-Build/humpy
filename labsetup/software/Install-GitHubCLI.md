# Install GitHub CLI

From a local folder, right-click Install-GitHubCLI.cmd and choose Run as administrator. Installs the official Windows x64 MSI unattended. No WinGet, Chocolatey, companion file or account login needed. -Help is non-installing.

Pinned release: 2.104.0. Official URL: https://github.com/cli/cli/releases/download/v2.104.0/gh_2.104.0_windows_amd64.msi

Official SHA256: cc89beb33ee020669efac70270aff55ca3ad52321aa813307537f2fe9237cc6e

The digest was matched against both GitHub's release API asset digest and the release's gh_2.104.0_checksums.txt. Download uses normal Windows curl with HTTPS-only redirects; certutil computes SHA256 and an exact match is required before msiexec. No signature claim is made.

The elevated installer stages in a new restricted ProgramData folder. No launcher copy, PowerShell payload or security-policy change.

Windows x64 and native curl/certutil/findstr/icacls/msiexec required. Missing administrator rights, prerequisites, download or digest verification stop before installation. Exit 5 means administrator rights required; 2 is another early failure. MSI codes are returned unchanged: 0 success, 3010 success/restart required; other codes are reported explicitly. /norestart and REBOOT=ReallySuppress request no reboot.

The local stage path and MSI exit code are printed. The MSI is retained. A successful MSI may require a new terminal for gh on PATH. A newer installed version may cause MSI to refuse this pinned version; its status is not hidden.

Checks are limited to non-installing help/invalid arguments, source checks and official metadata/digest reads. No MSI download/execution, Defender clearance or production VM success has been tested.
