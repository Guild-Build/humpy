#Requires -Version 5.1
[CmdletBinding()]
param([string]$Name, [switch]$Preview, [switch]$NoPause, [switch]$Help)
$ErrorActionPreference='Stop'
$code=0
$allowed=@('Microsoft.BingNews','Microsoft.BingWeather','Microsoft.GetHelp','Microsoft.Getstarted','Microsoft.MicrosoftSolitaireCollection','Microsoft.People','Microsoft.YourPhone')
function Read-Answer([string]$Prompt) {
    if ([Console]::IsInputRedirected) { Write-Host $Prompt; return [Console]::ReadLine() }
    return Read-Host $Prompt
}
function Get-SelectedApp([string]$ExactName) {
    $all=@(Get-AppxPackage -ErrorAction Stop)
    $found=@($all | Where-Object { $_.Name -eq $ExactName })
    if ($found.Count -eq 0) { return $null }
    if ($found.Count -ne 1) { throw 'Multiple package identities match. Nothing removed; inspect Windows package state.' }
    $app=$found[0]
    if ($app.IsFramework -or $app.IsResourcePackage -or $app.NonRemovable) { throw 'Framework, resource or non-removable package refused.' }
    if ([string]::IsNullOrWhiteSpace($app.PackageFullName)) { throw 'Package identity unavailable.' }
    foreach ($other in $all) {
        if ($other.PackageFullName -ne $app.PackageFullName -and $app.PackageFullName -in @($other.Dependencies.PackageFullName)) {
            throw ('Another installed package depends on this app: '+$other.Name)
        }
    }
    return $app
}
try {
    Write-Host 'WARNING: Selecting an app removes it and can permanently lose its local data. Back up first.'
    Write-Host 'CURRENT USER ONLY. No all-user removal, provisioning change, automatic reinstall or restart.'
    if ($Help) {
        Write-Host 'Usage: Remove-OptionalApp.cmd [-Name EXACT_NAME] [-Preview] [-NoPause] [-Help]'
        Write-Host 'No name: list supported installed apps and ask for one exact name. Blank cancels.'
        Write-Host 'Only the seven original optional-app names below are supported; no wildcards.'
        $allowed | ForEach-Object { Write-Host $_ }
        Write-Host 'Selecting one exact app applies immediately unless -Preview. Run as the intended user.'
    } else {
        $null=Get-Command Get-AppxPackage,Remove-AppxPackage -ErrorAction Stop
        Write-Host ('Target user: '+[Security.Principal.WindowsIdentity]::GetCurrent().Name)
        if ([string]::IsNullOrWhiteSpace($Name)) {
            $installed=@(Get-AppxPackage -ErrorAction Stop | Where-Object { $_.Name -in $allowed })
            if ($installed.Count -eq 0) { Write-Host 'None of the supported optional apps is installed for this user.' }
            else {
                $installed | Select-Object Name,PackageFullName | Format-List | Out-Host
                $Name=Read-Answer 'Exact app Name from the list (blank cancels)'
            }
        }
        if ([string]::IsNullOrWhiteSpace($Name)) { Write-Host 'Nothing removed.' }
        else {
            $Name=$Name.Trim()
            if ($Name -notin $allowed) { throw 'Use one exact supported app name. Wildcards and other apps are refused. Use -Help for names.' }
            $app=Get-SelectedApp $Name
            if ($null -eq $app) { Write-Host 'That app is not installed for this user. Nothing removed.' }
            else {
                Write-Host ('REMOVE current-user app: '+$app.Name)
                Write-Host ('Exact package: '+$app.PackageFullName)
                if ($Preview) { Write-Host 'PREVIEW ONLY: nothing removed.' }
                else {
                    $fresh=Get-SelectedApp $Name
                    if ($null -eq $fresh -or $fresh.PackageFullName -cne $app.PackageFullName) { throw 'Package changed before removal. Nothing removed; run again.' }
                    Remove-AppxPackage -Package $app.PackageFullName -Confirm:$false -ErrorAction Stop
                    if (@(Get-AppxPackage -ErrorAction Stop | Where-Object { $_.Name -eq $Name }).Count -ne 0) {
                        throw 'Removal returned but the app remains registered for this user. Inspect Windows; do not assume success.'
                    }
                    Write-Host 'Verified: app is no longer registered for this user. Other users and image provisioning unchanged.'
                }
            }
        }
    }
} catch {
    Write-Host ('FAILED: '+$_.Exception.Message)
    Write-Host 'Windows policy/permissions remain in force. No bypass or rollback; removal may have partially completed.'
    $code=2
}
if (-not $NoPause -and -not [Console]::IsInputRedirected -and -not [Console]::IsOutputRedirected) {
    [void](Read-Host 'Press Enter to close')
}
exit $code
