# Open visual performance options

Double-click Open-VisualPerformance.cmd locally as the intended Windows user. It opens the supported Windows Performance Options dialog; it does not apply a preset. Do not run as a different administrator account.

In **Visual Effects**, select **Adjust for best performance**, then **Apply** and **OK**. Applying that choice may disable animations, shadows and font smoothing. You can later return to the same dialog to choose another preset or custom effects.

The launcher uses the built-in SystemPropertiesPerformance.exe. It has no helper, registry writes, elevation request, power-plan change, forced restart or sign-out. It waits for the dialog to close but cannot verify your selection or whether you applied it. Missing executable/launch errors are reported. OS or managed policy may limit available options; no bypass is attempted.

Checks: source/path and batch targets inspected; executable existence confirmed on the authoring host without launching it. The dialog and production VM behavior were not execution-tested. Selecting and applying the preset remain your actions.
