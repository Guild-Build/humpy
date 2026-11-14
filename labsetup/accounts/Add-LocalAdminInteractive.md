# Add a user to local Administrators (interactive)

**Double-click the CMD** and approve Windows UAC if asked. Answer its prompts; no arguments are required. The result stays visible until a key is pressed. No policy or consent bypass.

Enter an existing local user name. Uses native net localgroup to add the computer-qualified local user to Administrators. Grants full local administrative privileges. Does not create a user or change passwords. Requires the English Windows group name Administrators. Sign out/in for a fresh token; the script does not sign you out.


Windows validates the values and reports errors. Native operations have not been
exercised in this refactor. The inline UAC prompt requires Windows PowerShell;
the action itself uses native commands.

[Setup index](../README.md)
