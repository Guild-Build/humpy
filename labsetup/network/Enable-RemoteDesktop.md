# Enable Remote Desktop

**Double-click `Enable-RemoteDesktop.cmd`** and approve Windows UAC if requested. No arguments.
It applies immediately. The result stays visible until you press a key.

Plain Windows `reg`, `netsh` and `sc` commands:

1. Require Network Level Authentication (NLA).
2. Create/enable the named TCP 3389 firewall rule on all network profiles,
   restricted to LocalSubnet sources. This also works on a fresh machine whose
   network is classified Public; it does not change that classification. Other
   firewall rules are not changed and may already permit broader access.
3. Enable RDP, set TermService to Automatic and start it. An already-running
   service is accepted; it is not stopped or restarted.

Windows Pro/Enterprise/Education or Server with the **default RDP port 3389**.
Use an account allowed to sign in remotely, with a nonblank password. Domain policy,
other firewall rules and routers can still affect access; no remote login is tested.

The CMD runs alone. A small inline PowerShell request opens the normal Windows UAC
prompt when needed; the operation itself uses native reg/netsh/sc. No Python,
compilation or shared helper. Old command-line options are rejected.
No unrestricted-source rule, UDP rule, user membership or password change is made.

On an error it stops and leaves the Windows error visible. Earlier changes may
remain; there is no automatic rollback. Exit 0 means the commands succeeded,
1 means a command failed, and 2 means arguments were supplied. Live RDP enablement
was not run on this development machine.

The existing firewall rule name is retained for compatibility, not replaced by a
second rule. Local rule names are identifiers, not an external project dependency.

[Setup index](../README.md)
