# Add a user to local Administrators

Double-click, approve Windows UAC if requested, and enter the existing local user name,
and read the Windows result. No arguments are required; the window stays open.
From an Administrator Command Prompt you can also supply the name:

```cmd
Add-LocalAdmin.cmd "alice"
```

The operation is simply:

```cmd
net localgroup Administrators "alice" /add
```

Use an existing account. This grants full local administrator privileges. It does
not create the user, change passwords, remove anyone else or approve its own UAC prompt.
Windows displays the result and supplies the exit code, including already-member
errors. Sign out/in afterwards to refresh that user's access token.

The CMD calls Windows directly. PowerShell is used only for the inline UAC request.

The literal group name is for English Windows. On translated Windows, use the
actual local Administrators group name. This is a local workstation/server step,
not a domain-controller administration script.

Add-LocalAdminInteractive.cmd does the same operation but always asks for the name.
Native apply is unverified.

[Setup index](../README.md)
