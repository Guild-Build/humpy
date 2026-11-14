# Add-LocalUser

**Double-click the CMD** and approve Windows UAC if asked. Answer its prompts; no arguments are required. The result stays visible until a key is pressed. No policy or consent bypass.

Enter the new local user name. Windows asks for the password twice without displaying it. Uses native net user /add; existing users are not reset. Existing password policy applies.


Windows validates the values and reports errors. Native operations have not been
exercised in this refactor. The inline UAC prompt requires Windows PowerShell;
the action itself uses native commands.

[Setup index](../README.md)
