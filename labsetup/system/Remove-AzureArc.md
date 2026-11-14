# Remove local Azure Arc

Right-click Remove-AzureArc.cmd > Run as administrator. The CMD shows the detected agent and extensions, then applies. Standalone native CMD; no PowerShell launcher, helper or download.

Warning: local Arc management and ALL installed Arc extensions are removed. This
can remove Arc-managed monitoring/security/configuration software. Do not run on a managed host. No unrelated products or services are targeted.

Installed agent: remove local extensions; disconnect with --force-local-only;
uninstall the exact Azure Connected Machine Agent MSI found in the registry.
Setup-only: remove the Server 2025 AzureArcSetup~~~~ capability or disable the
Server 2022 AzureArcSetup feature using DISM. Missing/custom/ambiguous agent installs
and unsupported extension commands stop; no unsafe fallback or policy bypass.

No Azure login, Azure CLI or cloud resource deletion is performed. Cloud server
and extension records remain for separate cleanup by an authorized administrator
in the Azure portal. Never delete a VM resource merely to tidy its Arc record.
No embedded credentials. Azure Local VMs never receive plain disconnect.

Exit 3010 means restart manually and rerun to finish remaining local cleanup.
No forced restart or rollback: earlier changes can remain after a later failure.
MSI-retained installation folders/logs are not recursively deleted. A successful
local removal is not a claim that cloud resources or every historical file are gone.
Exit 0: native operations succeeded; 2: blocked/agent failure; other
nonzero codes: Windows removal failure. -Help is read-only.

Static sanity and a copied CMD help run passed; live removal/VM execution untested.
Microsoft procedures read while implementing:
1. https://learn.microsoft.com/en-us/azure/azure-arc/servers/uninstall-agent
2. https://learn.microsoft.com/en-us/azure/azure-arc/servers/azcmagent-disconnect
3. https://learn.microsoft.com/en-us/azure/azure-arc/servers/azcmagent-extension
4. https://learn.microsoft.com/en-us/azure/azure-arc/servers/onboard-windows-server
