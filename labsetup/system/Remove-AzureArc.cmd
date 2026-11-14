@echo off
setlocal DisableDelayedExpansion
if /i "%~1"=="-Help" goto help
if /i "%~1"=="--help" goto help
if not "%~1"=="" goto usage
"%SystemRoot%\System32\fltmc.exe" >nul 2>&1
if errorlevel 1 goto admin
setlocal EnableDelayedExpansion
set "ARC_AGENT=%ProgramFiles%\AzureConnectedMachineAgent\azcmagent.exe"
if not exist "!ARC_AGENT!" if defined ProgramW6432 set "ARC_AGENT=%ProgramW6432%\AzureConnectedMachineAgent\azcmagent.exe"
set "ARC_PRODUCT="
set "ARC_PRODUCTCOUNT=0"
for %%V in (64 32) do (
    for /f "delims=" %%K in ('reg.exe query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" /s /v DisplayName /f "Azure Connected Machine Agent" /d /e /reg:%%V 2^>nul ^| findstr.exe /B /L /C:HKEY_LOCAL_MACHINE') do (
        for %%G in ("%%K") do set "ARC_PRODUCT=%%~nxG"
        set /a ARC_PRODUCTCOUNT+=1 >nul
    )
)
if !ARC_PRODUCTCOUNT! GTR 1 goto ambiguous
if defined ARC_PRODUCT (
    set ARC_PRODUCT | "%SystemRoot%\System32\findstr.exe" /R /X /C:"ARC_PRODUCT={[0-9A-Fa-f-]*}" >nul
    if errorlevel 1 goto ambiguous
    if not exist "!ARC_AGENT!" goto incomplete
    echo Installed Connected Machine agent; its registration/connection state follows:
    "!ARC_AGENT!" show
    if errorlevel 1 goto agentfailed
    echo Installed Arc extensions:
    "!ARC_AGENT!" extension list
    if errorlevel 1 goto agentfailed
) else (
    if exist "!ARC_AGENT!" goto incomplete
    "%SystemRoot%\System32\sc.exe" query himds >nul 2>&1
    if not errorlevel 1 goto incomplete
    echo No Connected Machine MSI/agent found. Checking setup-only integration.
)
set "ARC_SETUP="
"%SystemRoot%\System32\dism.exe" /Online /English /Get-CapabilityInfo /CapabilityName:AzureArcSetup~~~~ >nul 2>&1
if not errorlevel 1 set "ARC_SETUP=capability"
if not defined ARC_SETUP (
    "%SystemRoot%\System32\dism.exe" /Online /English /Get-FeatureInfo /FeatureName:AzureArcSetup >nul 2>&1
    if not errorlevel 1 set "ARC_SETUP=feature"
)
if not defined ARC_SETUP if not defined ARC_PRODUCT goto unsupported
echo WARNING: Removes local Azure Arc management, not just its tray icon.
if defined ARC_PRODUCT echo This uninstalls ALL Arc extensions and the Connected Machine agent, and clears local registration.
echo Arc-managed monitoring/security/configuration may stop. Do not run on a managed host.
echo Azure cloud resources are NOT deleted. No Azure credentials are used; stale resources need separate cleanup.
echo Supported setup integration is removed too. No forced restart or unrelated service edits.
if defined ARC_PRODUCT (
    "!ARC_AGENT!" extension remove --all
    if errorlevel 1 goto agentfailed
    "!ARC_AGENT!" disconnect --force-local-only
    if errorlevel 1 goto agentfailed
    start "" /wait "%SystemRoot%\System32\msiexec.exe" /x "!ARC_PRODUCT!" /passive /norestart
    set "ExitCode=!ERRORLEVEL!"
    if "!ExitCode!"=="3010" goto reboot
    if not "!ExitCode!"=="0" goto failed
)
if not defined ARC_SETUP goto partial
if "!ARC_SETUP!"=="capability" "%SystemRoot%\System32\dism.exe" /Online /Remove-Capability /CapabilityName:AzureArcSetup~~~~ /NoRestart
if "!ARC_SETUP!"=="feature" "%SystemRoot%\System32\dism.exe" /Online /Disable-Feature /FeatureName:AzureArcSetup /NoRestart
set "ExitCode=!ERRORLEVEL!"
if "!ExitCode!"=="3010" goto reboot
if not "!ExitCode!"=="0" goto failed
echo Supported local Arc removal completed. Cloud records and retained logs/folders are not deleted.
goto done
:admin
echo Administrator required. Right-click this CMD and choose Run as administrator.
set "ExitCode=2"
goto done
:ambiguous
echo Ambiguous or unsupported agent installer record. Nothing removed; inspect Installed apps.
set "ExitCode=2"
goto done
:incomplete
echo Partial/custom agent installation detected. Cannot safely identify and disconnect/uninstall it automatically.
set "ExitCode=2"
goto done
:agentfailed
echo Agent command failed or is unsupported. Read its error; later steps were not run.
echo Older agents may lack local extension removal. Use the supported agent cleanup procedure first.
set "ExitCode=2"
goto done
:unsupported
echo No registered agent or supported Arc Setup identifier found. Nothing removed; inspect Optional features.
set "ExitCode=2"
goto done
:partial
echo Agent removed, but Arc Setup is unavailable/unsupported here. Setup cleanup is unconfirmed.
set "ExitCode=2"
goto done
:reboot
echo Restart required. Restart manually, then rerun to finish any remaining local cleanup.
goto done
:failed
echo Windows removal failed. Read its error; earlier changes may remain. No automatic rollback.
goto done
:usage
echo Run without arguments as administrator, or use -Help.
exit /b 2
:help
echo Remove local Azure Arc: extensions, local registration, MSI agent and supported setup integration.
echo Run as administrator only on the intended lab. No extra confirmation.
echo No cloud resource deletion, Azure login, forced restart or PowerShell launcher.
echo Unsupported/partial installations stop explicitly. Leftover logs/folders are not recursively deleted.
exit /b 0
:done
pause
exit /b %ExitCode%
