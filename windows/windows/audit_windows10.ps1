########################################################################
#  audit_windows10_fixed.ps1
#  Audit de securite Windows 10 - Score avant/apres hardening
#  Usage : .\audit_windows10_fixed.ps1
#  - Premiere execution  => sauvegarde le score AVANT
#  - Deuxieme execution  => affiche le score APRES + comparaison
########################################################################

#Requires -RunAsAdministrator

$ScoreFile = "C:\audit_score_avant.xml"

# -----------------------------------------------------------------------
# FONCTIONS D'AFFICHAGE
# -----------------------------------------------------------------------
function Banner {
    Clear-Host
    Write-Host ""
    Write-Host "  ██╗    ██╗██╗███╗   ██╗ ██╗ ██████╗      █████╗ ██╗   ██╗██████╗ ██╗████████╗" -ForegroundColor Cyan
    Write-Host "  ██║    ██║██║████╗  ██║███║██╔═████╗    ██╔══██╗██║   ██║██╔══██╗██║╚══██╔══╝" -ForegroundColor Cyan
    Write-Host "  ██║ █╗ ██║██║██╔██╗ ██║╚██║██║██╔██║    ███████║██║   ██║██║  ██║██║   ██║   " -ForegroundColor Cyan
    Write-Host "  ██║███╗██║██║██║╚██╗██║ ██║████╔╝██║    ██╔══██║██║   ██║██║  ██║██║   ██║   " -ForegroundColor Cyan
    Write-Host "  ╚███╔███╔╝██║██║ ╚████║ ██║╚██████╔╝    ██║  ██║╚██████╔╝██████╔╝██║   ██║   " -ForegroundColor Cyan
    Write-Host "   ╚══╝╚══╝ ╚═╝╚═╝  ╚═══╝ ╚═╝ ╚═════╝     ╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚═╝   ╚═╝   " -ForegroundColor Cyan
    Write-Host "                    Windows 10 Security Audit - PowerShell                      " -ForegroundColor DarkCyan
    Write-Host ""
}

function Section {
    param(
        [string]$title
    )

    Write-Host ""
    Write-Host "  ┌─────────────────────────────────────────────────┐" -ForegroundColor DarkGray
    Write-Host "  │  $title" -ForegroundColor White
    Write-Host "  └─────────────────────────────────────────────────┘" -ForegroundColor DarkGray
}

function CheckLine {
    param(
        [string]$label,
        [bool]$passed,
        [string]$detail = ""
    )

    $icon   = if ($passed) { "  +" } else { "  -" }
    $color  = if ($passed) { "Green" } else { "Red" }
    $status = if ($passed) { "PASS" } else { "FAIL" }

    Write-Host "$icon  " -ForegroundColor $color -NoNewline
    Write-Host ("{0,-45}" -f $label) -NoNewline
    Write-Host "[$status]" -ForegroundColor $color -NoNewline

    if ($detail) {
        Write-Host "  $detail" -ForegroundColor DarkGray
    }
    else {
        Write-Host ""
    }
}

# -----------------------------------------------------------------------
# TOUTES LES VERIFICATIONS
# -----------------------------------------------------------------------
function Run-Audit {
    $results = [ordered]@{}

    # === PARE-FEU ===
    $fw = Get-NetFirewallProfile -ErrorAction SilentlyContinue
    $results["Firewall - Profil Domain actif"]  = (($fw | Where-Object Name -eq "Domain").Enabled  -eq $true)
    $results["Firewall - Profil Private actif"] = (($fw | Where-Object Name -eq "Private").Enabled -eq $true)
    $results["Firewall - Profil Public actif"]  = (($fw | Where-Object Name -eq "Public").Enabled  -eq $true)

    # === SMB ===
    $smb = Get-SmbServerConfiguration -ErrorAction SilentlyContinue
    $results["SMBv1 desactive"] = ($smb.EnableSMB1Protocol -eq $false)
    $results["SMBv2/3 active"]  = ($smb.EnableSMB2Protocol -eq $true)

    # === UAC ===
    $uacKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
    $uac = Get-ItemProperty -Path $uacKey -ErrorAction SilentlyContinue
    $results["UAC active (EnableLUA)"] = ($uac.EnableLUA -eq 1)
    $results["UAC niveau max (ConsentPromptAdmin=2)"] = ($uac.ConsentPromptBehaviorAdmin -eq 2)

    # === RDP ===
    $rdp = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" -ErrorAction SilentlyContinue
    $results["RDP desactive"] = ($rdp.fDenyTSConnections -eq 1)

    # === TELEMETRIE ===
    $tele = Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -ErrorAction SilentlyContinue
    $results["Telemetrie desactivee (AllowTelemetry=0)"] = ($tele.AllowTelemetry -eq 0)

    # === CORTANA ===
    $cort = Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -ErrorAction SilentlyContinue
    $results["Cortana desactivee"] = ($cort.AllowCortana -eq 0)

    # === AUTORUN ===
    $ar = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -ErrorAction SilentlyContinue
    $results["Autorun/Autoplay desactive (=255)"] = ($ar.NoDriveTypeAutoRun -eq 255)

    # === WINDOWS DEFENDER ===
    $def = Get-MpPreference -ErrorAction SilentlyContinue
    $results["Defender - Protection temps reel"] = ($def.DisableRealtimeMonitoring -eq $false)
    $results["Defender - Surveillance comportement"] = ($def.DisableBehaviorMonitoring -eq $false)
    $results["Defender - MAPS active"] = ($def.MAPSReporting -gt 0)

    # === MISE A JOUR AUTO ===
    $wuKey = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
    $wu = Get-ItemProperty -Path $wuKey -ErrorAction SilentlyContinue
    $results["Mises a jour automatiques activees"] = ($wu.NoAutoUpdate -eq 0)

    # === SERVICES DESACTIVES ===
    foreach ($svcName in @("RemoteRegistry", "DiagTrack", "XblGameSave", "wsearch")) {
        $svc = Get-Service -Name $svcName -ErrorAction SilentlyContinue
        $results["Service desactive : $svcName"] = ($null -eq $svc -or $svc.StartType -eq "Disabled")
    }

    # === POWERSHELL LOGGING ===
    $psLog = Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" -ErrorAction SilentlyContinue
    $results["PowerShell ScriptBlock Logging actif"] = ($psLog.EnableScriptBlockLogging -eq 1)

    # === PUBLICITE ===
    $adv = Get-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -ErrorAction SilentlyContinue
    $results["Publicite ciblee desactivee"] = ($adv.Enabled -eq 0)

    # === POWERSHELL V2 ===
    $psv2 = Get-WindowsOptionalFeature -Online -FeatureName MicrosoftWindowsPowerShellV2Root -ErrorAction SilentlyContinue
    $results["PowerShell v2 desactive"] = ($null -eq $psv2 -or $psv2.State -eq "Disabled")

    return $results
}

# -----------------------------------------------------------------------
# AFFICHAGE DU RAPPORT
# -----------------------------------------------------------------------
function Show-Report {
    param(
        $results,
        [string]$title
    )

    $categories = [ordered]@{
        "Pare-feu"         = @("Firewall - Profil Domain actif", "Firewall - Profil Private actif", "Firewall - Profil Public actif")
        "SMB"              = @("SMBv1 desactive", "SMBv2/3 active")
        "UAC"              = @("UAC active (EnableLUA)", "UAC niveau max (ConsentPromptAdmin=2)")
        "Acces distant"    = @("RDP desactive")
        "Vie privee"       = @("Telemetrie desactivee (AllowTelemetry=0)", "Cortana desactivee", "Publicite ciblee desactivee")
        "Systeme"          = @("Autorun/Autoplay desactive (=255)", "Mises a jour automatiques activees", "PowerShell ScriptBlock Logging actif", "PowerShell v2 desactive")
        "Windows Defender" = @("Defender - Protection temps reel", "Defender - Surveillance comportement", "Defender - MAPS active")
        "Services"         = @("Service desactive : RemoteRegistry", "Service desactive : DiagTrack", "Service desactive : XblGameSave", "Service desactive : wsearch")
    }

    Write-Host ""
    Write-Host "  ════════════════════════════════════════════════════════" -ForegroundColor DarkCyan
    Write-Host "   $title" -ForegroundColor White
    Write-Host "  ════════════════════════════════════════════════════════" -ForegroundColor DarkCyan

    foreach ($cat in $categories.Keys) {
        Section $cat
        foreach ($check in $categories[$cat]) {
            if ($results.Contains($check)) {
                CheckLine -label $check -passed ([bool]$results[$check])
            }
        }
    }
}

# -----------------------------------------------------------------------
# SCORE FINAL
# -----------------------------------------------------------------------
function Show-Score {
    param(
        $results,
        [string]$label,
        [int]$prevScore = -1
    )

    $total  = $results.Count
    $passed = ($results.Values | Where-Object { $_ -eq $true }).Count
    $pct    = [math]::Round(($passed / $total) * 100)

    $color = if ($pct -ge 80) { "Green" } elseif ($pct -ge 50) { "Yellow" } else { "Red" }

    Write-Host ""
    Write-Host "  ┌──────────────────────────────────────────────────────┐" -ForegroundColor DarkGray
    Write-Host ("  │  {0,-52}│" -f " SCORE $label") -ForegroundColor White
    Write-Host ("  │  {0,-52}│" -f "  $passed / $total checks passed ($pct%)") -ForegroundColor $color

    if ($prevScore -ge 0) {
        $diff = $pct - $prevScore
        $diffColor = if ($diff -gt 0) { "Green" } elseif ($diff -eq 0) { "Yellow" } else { "Red" }
        $sign = if ($diff -ge 0) { "+" } else { "" }
        Write-Host ("  │  {0,-52}│" -f "  Evolution : $sign$diff% par rapport au scan AVANT") -ForegroundColor $diffColor
    }

    Write-Host "  └──────────────────────────────────────────────────────┘" -ForegroundColor DarkGray
    Write-Host ""

    return $pct
}

# -----------------------------------------------------------------------
# BARRE DE PROGRESSION VISUELLE
# -----------------------------------------------------------------------
function Show-Bar {
    param(
        [int]$pct
    )

    $filled = [math]::Round($pct / 5)
    $empty  = 20 - $filled
    $bar    = ("█" * $filled) + ("░" * $empty)
    $color  = if ($pct -ge 80) { "Green" } elseif ($pct -ge 50) { "Yellow" } else { "Red" }

    Write-Host "  Securite  [" -NoNewline
    Write-Host $bar -ForegroundColor $color -NoNewline
    Write-Host "] $pct%"
    Write-Host ""
}

# -----------------------------------------------------------------------
# MAIN
# -----------------------------------------------------------------------
Banner

$results = Run-Audit

if (-not (Test-Path $ScoreFile)) {
    # ── PREMIERE EXECUTION : scan AVANT ──
    Write-Host "  [i] Aucun scan precedent detecte => SCAN AVANT HARDENING" -ForegroundColor Yellow
    Show-Report -results $results -title "AUDIT AVANT HARDENING"
    $score = Show-Score -results $results -label "AVANT"
    Show-Bar -pct $score

    # Sauvegarder pour comparaison future
    $results | Export-Clixml -Path $ScoreFile
    Write-Host "  [+] Score sauvegarde dans $ScoreFile" -ForegroundColor DarkGreen
    Write-Host "  [i] Lance ce script apres le hardening pour voir l'evolution." -ForegroundColor Cyan
}
else {
    # ── DEUXIEME EXECUTION : scan APRES + comparaison ──
    Write-Host "  [i] Scan precedent detecte => SCAN APRES HARDENING + COMPARAISON" -ForegroundColor Cyan

    $avant = Import-Clixml -Path $ScoreFile
    $totalA  = $avant.Count
    $passedA = ($avant.Values | Where-Object { $_ -eq $true }).Count
    $scoreA  = [math]::Round(($passedA / $totalA) * 100)

    Show-Report -results $results -title "AUDIT APRES HARDENING"
    $scoreB = Show-Score -results $results -label "APRES" -prevScore $scoreA

    # ── TABLEAU COMPARATIF ──
    Write-Host ""
    Write-Host "  ════════════════════════════════════════════════════════" -ForegroundColor DarkCyan
    Write-Host "   COMPARAISON AVANT / APRES" -ForegroundColor White
    Write-Host "  ════════════════════════════════════════════════════════" -ForegroundColor DarkCyan
    Write-Host ""
    Write-Host ("  {0,-45} {1,-8} {2,-8}" -f "CHECK", "AVANT", "APRES") -ForegroundColor DarkGray
    Write-Host "  $(("─" * 62))" -ForegroundColor DarkGray

    foreach ($key in $results.Keys) {
        $valAvant = if ($avant.Contains($key)) { $avant[$key] } else { $null }
        $valApres = $results[$key]

        $iconA = if ($valAvant -eq $true) { "+" } elseif ($valAvant -eq $false) { "-" } else { "?" }
        $iconB = if ($valApres -eq $true) { "+" } else { "-" }
        $colorA = if ($valAvant -eq $true) { "Green" } else { "Red" }
        $colorB = if ($valApres -eq $true) { "Green" } else { "Red" }

        $improved  = ($valAvant -eq $false -and $valApres -eq $true)
        $regressed = ($valAvant -eq $true -and $valApres -eq $false)

        Write-Host ("  {0,-45} " -f $key) -NoNewline
        Write-Host (" [$iconA]    ") -ForegroundColor $colorA -NoNewline
        Write-Host (" [$iconB]") -ForegroundColor $colorB -NoNewline

        if ($improved) {
            Write-Host "  <- ameliore" -ForegroundColor Green
        }
        elseif ($regressed) {
            Write-Host "  <- regression !" -ForegroundColor Red
        }
        else {
            Write-Host ""
        }
    }

    Write-Host ""
    Write-Host "  AVANT  : " -NoNewline
    Show-Bar -pct $scoreA
    Write-Host "  APRES  : " -NoNewline
    Show-Bar -pct $scoreB

    # Nettoyer le fichier de sauvegarde pour permettre un nouveau cycle
    $reset = Read-Host "  Reinitialiser pour un nouveau cycle avant/apres ? (o/N)"
    if ($reset -match "^[oO]$") {
        Remove-Item -Path $ScoreFile -Force
        Write-Host "  [+] Reinitialise. Prochain lancement = nouveau scan AVANT." -ForegroundColor Yellow
    }
}
