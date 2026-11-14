# Set-LocalPasswordPolicy

**Double-click the CMD** and approve Windows UAC if asked. Applies immediately; no arguments. The result stays visible until a key is pressed. No policy or consent bypass.

Sets only maximum password age to never and complexity to disabled. Keep LocalPasswordPolicy.inf beside the CMD. Windows requires secedit for complexity; the INF contains only these two settings and required headers. Record those two values in Local Security Policy before running if you need to restore them. The temporary secedit database is not an undo record. No automatic rollback. For standalone lab machines, not domain controllers.


Windows validates the values and reports errors. Native operations have not been
exercised in this refactor. The inline UAC prompt requires Windows PowerShell;
the action uses native secedit. Windows may keep its own security-engine diagnostics.

[Setup index](../README.md)
