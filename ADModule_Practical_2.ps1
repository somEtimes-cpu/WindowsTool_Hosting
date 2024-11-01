﻿# Rename the PowerShell window to "ADModule"
$Host.UI.RawUI.WindowTitle = "ADModule"

# Define credentials
$securePassword_regular = ConvertTo-SecureString "sexywolfy" -AsPlainText -Force
$credential_regular = New-Object System.Management.Automation.PSCredential("robb.stark", $securePassword_regular)

$securePassword_admin = ConvertTo-SecureString "iamthekingoftheworld" -AsPlainText -Force
$credential_admin = New-Object System.Management.Automation.PSCredential("robert.baratheon", $securePassword_admin)

# Set Execution Policy to unrestricted
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted -ErrorAction Stop

# Unblock and import AD modules
Unblock-File ./ADModule/Microsoft.ActiveDirectory.Management.dll -ErrorAction Stop
Unblock-File ./ADModule/ActiveDirectory/ActiveDirectory.psd1 -ErrorAction Stop
Import-Module ./ADModule/Microsoft.ActiveDirectory.Management.dll -Verbose -ErrorAction Stop
Import-Module ./ADModule/ActiveDirectory/ActiveDirectory.psd1 -Verbose -ErrorAction Stop

# Verify AD Module installation with Get-ADDomain
try {
    Write-Output "Verifying AD module installation with Get-ADDomain..."
    Get-ADDomain -ErrorAction Stop
} catch {
    Write-Output "AD Module verification failed. Get-ADDomain could not be run: $_"
}

# Run Get-ADDefaultDomainPasswordPolicy as `robb.stark`
Read-Host "Press Enter to run Get-ADDefaultDomainPasswordPolicy for ADModule as robb.stark"
try {
    Get-ADDefaultDomainPasswordPolicy -Credential $credential_regular -ErrorAction Stop
} catch {
    $_  # Output the error message directly
}

# Run Get-ADDefaultDomainPasswordPolicy as `robert.baratheon`
Read-Host "Press Enter to run Get-ADDefaultDomainPasswordPolicy for ADModule as robert.baratheon"
try {
    Get-ADDefaultDomainPasswordPolicy -Credential $credential_admin -ErrorAction Stop
} catch {
    $_  # Output the error message directly
}
