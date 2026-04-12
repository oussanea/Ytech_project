########################################################################
#  hardening_windows10.ps1
#  Durcissement d'une machine Windows 10 - A executer en tant qu'Administrateur
#  Usage : .\hardening_windows10.ps1
########################################################################

#Requires -RunAsAdministrator

$LogFile = "C:\hardening_log_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"

function Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "[$timestamp] [$Level] $Message"
    Write-Host $line -ForegroundColor $(if ($Level -eq "ERROR") {"Red"} elseif ($Level -eq "WARN") {"Yellow"} else {"Green"})
    Add-Content -Path $LogFile -Value $line
}

Log "=== DEBUT DU HARDENING WINDOWS 10 ==="

# -----------------------------------------------------------------------
# 1. DESACTIVER LES SERVICES INUTILES / A RISQUE
# -----------------------------------------------------------------------
Log "--- [1/9] Desactivation des services inutiles ---"

$servicesToDisable = @(
    @{Name="wsearch";       Desc="Windows Search"},
    @{Name="XblGameSave";   Desc="Xbox Live Game Save"},
    @{Name="XboxNetApiSvc"; Desc="Xbox Live Networking"},
    @{Name="DiagTrack";     Desc="Telemetrie Windows"},
    @{Name="dmwappushservice"; Desc="WAP Push Message Routing"},
    @{Name="RemoteRegistry";Desc="Remote Registry"},
    @{Name="Fax";           Desc="Service Fax"},
    @{Name="WMPNetworkSvc"; Desc="Windows Media Player Sharing"},
    @{Name="lfsvc";         Desc="Geolocalisation"},
    @{Name="MapsBroker";    Desc="Telechargement cartes hors-ligne"}
)

foreach ($svc in $servicesToDisable) {
    try {
        $s = Get-Service -Name $svc.Name -ErrorAction SilentlyContinue
        if ($s) {
            Stop-Service -Name $svc.Name -Force -ErrorAction SilentlyContinue
            Set-Service -Name $svc.Name -StartupType Disabled
            Log "Service desactive : $($svc.Desc) ($($svc.Name))"
        } else {
            Log "Service introuvable (ignore) : $($svc.Name)" "WARN"
        }
    } catch {
        Log "Erreur sur le service $($svc.Name) : $_" "ERROR"
    }
}

# -----------------------------------------------------------------------
# 2. PARE-FEU WINDOWS
# -----------------------------------------------------------------------
Log "--- [2/9] Configuration du pare-feu Windows ---"

Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True
Set-NetFirewallProfile -Profile Public -DefaultInboundAction Block -DefaultOutboundAction Allow
Set-NetFirewallProfile -Profile Private -DefaultInboundAction Block -DefaultOutboundAction Allow
Log "Pare-feu active sur tous les profils"

# Bloquer les connexions entrantes non sollicitees
netsh advfirewall set allprofiles firewallpolicy blockinbound,allowoutbound | Out-Null
Log "Politique pare-feu : bloquer entrant, autoriser sortant"

# -----------------------------------------------------------------------
# 3. MISES A JOUR AUTOMATIQUES
# -----------------------------------------------------------------------
Log "--- [3/9] Activation des mises a jour automatiques ---"

$wuPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
if (-not (Test-Path $wuPath)) { New-Item -Path $wuPath -Force | Out-Null }

Set-ItemProperty -Path $wuPath -Name "NoAutoUpdate"       -Value 0
Set-ItemProperty -Path $wuPath -Name "AUOptions"          -Value 4   # Telecharger et installer automatiquement
Set-ItemProperty -Path $wuPath -Name "ScheduledInstallDay" -Value 0  # Tous les jours
Set-ItemProperty -Path $wuPath -Name "ScheduledInstallTime" -Value 3 # 3h du matin
Log "Mises a jour automatiques configurees (installation a 3h)"

# -----------------------------------------------------------------------
# 4. POLITIQUE DE MOT DE PASSE
# -----------------------------------------------------------------------
Log "--- [4/9] Durcissement de la politique de mot de passe ---"

$secpolCfg = "C:\secpol_hardening.cfg"
secedit /export /cfg $secpolCfg /quiet

if (Test-Path $secpolCfg) {
    $content = Get-Content $secpolCfg
    $content = $content -replace "MinimumPasswordLength\s*=\s*\d+", "MinimumPasswordLength = 14"
    $content = $content -replace "PasswordComplexity\s*=\s*\d+",    "PasswordComplexity = 1"
    $content = $content -replace "MaximumPasswordAge\s*=\s*\d+",    "MaximumPasswordAge = 90"
    $content = $content -replace "MinimumPasswordAge\s*=\s*\d+",    "MinimumPasswordAge = 1"
    $content = $content -replace "PasswordHistorySize\s*=\s*\d+",   "PasswordHistorySize = 10"
    $content = $content -replace "LockoutBadCount\s*=\s*\d+",       "LockoutBadCount = 5"
    $content = $content -replace "ResetLockoutCount\s*=\s*\d+",     "ResetLockoutCount = 30"
    $content = $content -replace "LockoutDuration\s*=\s*\d+",       "LockoutDuration = 30"
    $content | Set-Content $secpolCfg
    secedit /configure /db "$env:windir\Security\Database\secedit.sdb" /cfg $secpolCfg /areas SECURITYPOLICY /quiet
    Remove-Item $secpolCfg -Force
    Log "Politique de mot de passe : longueur min 14, complexite, historique 10, verrouillage apres 5 echecs"
} else {
    Log "Impossible d'exporter la politique de securite" "ERROR"
}

# -----------------------------------------------------------------------
# 5. DESACTIVER SMBv1
# -----------------------------------------------------------------------
Log "--- [5/9] Desactivation de SMBv1 ---"

Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force
Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -NoRestart -ErrorAction SilentlyContinue
Log "SMBv1 desactive (vulnerabilite WannaCry/EternalBlue)"

# -----------------------------------------------------------------------
# 6. BITLOCKER (si TPM disponible)
# -----------------------------------------------------------------------
Log "--- [6/9] Verification BitLocker ---"

try {
    $tpm = Get-WmiObject -Namespace root\cimv2\security\microsofttpm -Class win32_tpm -ErrorAction Stop
    if ($tpm.IsEnabled_InitialValue -eq $true) {
        $blStatus = Get-BitLockerVolume -MountPoint "C:" -ErrorAction SilentlyContinue
        if ($blStatus.VolumeStatus -eq "FullyDecrypted") {
            Enable-BitLocker -MountPoint "C:" -EncryptionMethod XtsAes256 -TpmProtector -UsedSpaceOnly
            Log "BitLocker active sur C: (XTS-AES 256)"
        } else {
            Log "BitLocker deja actif ou en cours sur C:" "WARN"
        }
    } else {
        Log "TPM non disponible ou non active, BitLocker ignore" "WARN"
    }
} catch {
    Log "BitLocker : impossible de verifier le TPM ($_)" "WARN"
}

# -----------------------------------------------------------------------
# 7. DESACTIVER TELEMETRIE ET COLLECTE DE DONNEES
# -----------------------------------------------------------------------
Log "--- [7/9] Reduction de la telemetrie ---"

$telemetryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
if (-not (Test-Path $telemetryPath)) { New-Item -Path $telemetryPath -Force | Out-Null }
Set-ItemProperty -Path $telemetryPath -Name "AllowTelemetry" -Value 0

# Desactiver la publicite cibiee
$adPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo"
if (-not (Test-Path $adPath)) { New-Item -Path $adPath -Force | Out-Null }
Set-ItemProperty -Path $adPath -Name "Enabled" -Value 0

# Desactiver Cortana
$cortanaPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
if (-not (Test-Path $cortanaPath)) { New-Item -Path $cortanaPath -Force | Out-Null }
Set-ItemProperty -Path $cortanaPath -Name "AllowCortana" -Value 0

Log "Telemetrie desactivee, publicite ciblee desactivee, Cortana desactivee"

# -----------------------------------------------------------------------
# 8. DURCISSEMENT DES PARAMETRES SYSTEME
# -----------------------------------------------------------------------
Log "--- [8/9] Durcissements supplementaires ---"

# Desactiver Autorun/Autoplay sur tous les lecteurs
$autorunPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer"
Set-ItemProperty -Path $autorunPath -Name "NoDriveTypeAutoRun" -Value 255
Log "Autorun/Autoplay desactive"

# Activer UAC au niveau maximum
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" `
    -Name "ConsentPromptBehaviorAdmin" -Value 2
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" `
    -Name "EnableLUA" -Value 1
Log "UAC active au niveau maximum"

# Desactiver Remote Desktop si non necessaire
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" `
    -Name "fDenyTSConnections" -Value 1
Log "Bureau a distance (RDP) desactive"

# Desactiver PowerShell v2 (ancienne version moins securisee)
Disable-WindowsOptionalFeature -Online -FeatureName MicrosoftWindowsPowerShellV2Root -NoRestart -ErrorAction SilentlyContinue
Log "PowerShell v2 desactive"

# Activer la journalisation PowerShell
$psLogPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging"
if (-not (Test-Path $psLogPath)) { New-Item -Path $psLogPath -Force | Out-Null }
Set-ItemProperty -Path $psLogPath -Name "EnableScriptBlockLogging" -Value 1
Log "Journalisation PowerShell (ScriptBlock) activee"

# -----------------------------------------------------------------------
# 9. ACTIVER WINDOWS DEFENDER
# -----------------------------------------------------------------------
Log "--- [9/9] Configuration Windows Defender ---"

Set-MpPreference -DisableRealtimeMonitoring $false
Set-MpPreference -DisableBehaviorMonitoring $false
Set-MpPreference -DisableBlockAtFirstSeen $false
Set-MpPreference -MAPSReporting Advanced
Set-MpPreference -SubmitSamplesConsent SendSafeSamples
Update-MpSignature -ErrorAction SilentlyContinue
Log "Windows Defender active avec protection en temps reel"

# -----------------------------------------------------------------------
# FIN
# -----------------------------------------------------------------------
Log "=== HARDENING WINDOWS 10 TERMINE ==="
Log "Journal complet : $LogFile"
Write-Host "`nUn redemarrage est recommande pour appliquer tous les changements." -ForegroundColor Cyan
