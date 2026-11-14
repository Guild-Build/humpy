# Set-StaticIP

**Double-click the CMD** and approve Windows UAC if asked. Answer its prompts; no arguments are required. The result stays visible until a key is pressed. No policy or consent bypass.

Enter interface name, IPv4 address, dotted subnet mask, gateway (or none), primary DNS and optional secondary DNS. Uses netsh. This replaces that adapter IPv4/default gateway/DNS and can disconnect RDP: use the local/VM console. Later failure can leave earlier changes applied; no automatic rollback.


Windows validates the values and reports errors. Native operations have not been
exercised in this refactor. The inline UAC prompt requires Windows PowerShell;
the action itself uses native commands.

[Setup index](../README.md)
