#!/bin/bash
########################################################################
#  hardening_kali_safe.sh
#  Durcissement Kali Linux — SANS changement/blocage de mot de passe
#  Sans faillock (pas de verrouillage de compte)
#  Compatible pentest — haut score Lynis
#  Usage : sudo bash hardening_kali_safe.sh
########################################################################

set -euo pipefail

RED='\033[0;31m'; YELLOW='\033[1;33m'; GREEN='\033[0;32m'; CYAN='\033[0;36m'; NC='\033[0m'

LOG_FILE="/var/log/hardening_kali_$(date +%Y%m%d_%H%M%S).log"

log()  { echo -e "${GREEN}[INFO]${NC}  $1" | tee -a "$LOG_FILE"; }
warn() { echo -e "${YELLOW}[WARN]${NC}  $1" | tee -a "$LOG_FILE"; }
err()  { echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"; }
step() { echo -e "\n${CYAN}==============================${NC}" | tee -a "$LOG_FILE"
         echo -e "${CYAN} $1${NC}" | tee -a "$LOG_FILE"
         echo -e "${CYAN}==============================${NC}" | tee -a "$LOG_FILE"; }

if [[ $EUID -ne 0 ]]; then
    err "Ce script doit etre execute en root : sudo bash $0"
    exit 1
fi

log "=== DEBUT DU HARDENING KALI LINUX (version safe — sans blocage MDP) ==="
log "Journal : $LOG_FILE"

########################################################################
# 1. MISE A JOUR DU SYSTEME
########################################################################
step "[1/10] Mise a jour du systeme"

apt-get update -y >> "$LOG_FILE" 2>&1
apt-get upgrade -y >> "$LOG_FILE" 2>&1
apt-get dist-upgrade -y >> "$LOG_FILE" 2>&1
apt-get autoremove -y >> "$LOG_FILE" 2>&1
log "Systeme mis a jour"

########################################################################
# 2. PARE-FEU UFW
########################################################################
step "[2/10] Configuration UFW"

apt-get install -y ufw >> "$LOG_FILE" 2>&1

ufw --force reset >> "$LOG_FILE" 2>&1
ufw default deny incoming
ufw default allow outgoing
ufw default deny forward

# SSH avec rate limiting (anti brute-force sans bloquer le compte)
ufw limit 22/tcp comment 'SSH rate-limit anti brute-force'

# Journalisation activee
ufw logging on

ufw --force enable
log "UFW : deny incoming, allow outgoing, SSH rate-limited"

########################################################################
# 3. DURCISSEMENT SSH
# NOTE : PasswordAuthentication reste sur YES pour ne pas te bloquer
#        si tu n'as pas encore de cle SSH configuree.
#        Change-le en "no" manuellement une fois tes cles en place.
########################################################################
step "[3/10] Durcissement SSH"

SSHD_CONF="/etc/ssh/sshd_config"
cp "$SSHD_CONF" "${SSHD_CONF}.bak_$(date +%Y%m%d)"
log "Sauvegarde sshd_config creee"

sshd_set() {
    local key="$1"; local val="$2"
    if grep -qE "^#?[[:space:]]*${key}[[:space:]]" "$SSHD_CONF"; then
        sed -i "s|^#\?[[:space:]]*${key}[[:space:]].*|${key} ${val}|" "$SSHD_CONF"
    else
        echo "${key} ${val}" >> "$SSHD_CONF"
    fi
}

sshd_set "PermitRootLogin"            "no"
sshd_set "PasswordAuthentication"     "yes"       # ← garde yes pour ne pas te bloquer
sshd_set "PubkeyAuthentication"       "yes"
sshd_set "PermitEmptyPasswords"       "no"
sshd_set "MaxAuthTries"               "3"
sshd_set "MaxSessions"                "3"
sshd_set "LoginGraceTime"             "30"
sshd_set "ClientAliveInterval"        "300"
sshd_set "ClientAliveCountMax"        "2"
sshd_set "X11Forwarding"              "no"
sshd_set "AllowAgentForwarding"       "no"
sshd_set "AllowTcpForwarding"         "no"
sshd_set "UseDNS"                     "no"
sshd_set "LogLevel"                   "VERBOSE"
sshd_set "Banner"                     "/etc/ssh/banner"
sshd_set "Ciphers"                    "chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com"
sshd_set "MACs"                       "hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com"
sshd_set "KexAlgorithms"              "curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group18-sha512"

# Banniere SSH
cat > /etc/ssh/banner << 'EOF'
*************************************************************
*  Systeme Ytech Solutions — Acces restreint                *
*  Toute connexion non autorisee sera enregistree.          *
*************************************************************
EOF

if sshd -t >> "$LOG_FILE" 2>&1; then
    systemctl restart sshd
    log "SSH durci et redemarre"
else
    err "Erreur syntaxe sshd_config — restauration sauvegarde"
    cp "${SSHD_CONF}.bak_$(date +%Y%m%d)" "$SSHD_CONF"
    systemctl restart sshd
fi

########################################################################
# 4. AUDITD — JOURNALISATION AVANCEE
########################################################################
step "[4/10] Configuration auditd"

apt-get install -y auditd audispd-plugins >> "$LOG_FILE" 2>&1

AUDIT_RULES="/etc/audit/rules.d/hardening.rules"
cat > "$AUDIT_RULES" << 'EOF'
# Effacer les regles existantes
-D

# Buffer size
-b 8192

# Surveiller connexions/deconnexions
-w /var/log/wtmp    -p wa -k logins
-w /var/log/btmp    -p wa -k logins
-w /var/log/lastlog -p wa -k logins

# Fichiers d'identite sensibles
-w /etc/passwd      -p wa -k identity
-w /etc/shadow      -p wa -k identity
-w /etc/group       -p wa -k identity
-w /etc/gshadow     -p wa -k identity
-w /etc/sudoers     -p wa -k sudoers
-w /etc/sudoers.d/  -p wa -k sudoers

# Configuration SSH
-w /etc/ssh/sshd_config -p wa -k sshd_config

# Modules noyau
-w /sbin/insmod   -p x -k modules
-w /sbin/rmmod    -p x -k modules
-w /sbin/modprobe -p x -k modules
-a always,exit -F arch=b64 -S init_module -S delete_module -k modules

# Appels systeme critiques
-a always,exit -F arch=b64 -S execve -k exec_log
-a always,exit -F arch=b64 -S open,creat,truncate,ftruncate,openat -F exit=-EACCES -k access_denied
-a always,exit -F arch=b64 -S open,creat,truncate,ftruncate,openat -F exit=-EPERM  -k access_denied

# Surveillance /tmp (souvent utilise pour escalade)
-w /tmp  -p x -k tmp_exec
-w /var/tmp -p x -k tmp_exec

# Surveillance crontab
-w /etc/cron.d/       -p wa -k cron
-w /etc/crontab       -p wa -k cron
-w /var/spool/cron/   -p wa -k cron

# Immuable — necessite reboot pour modifier les regles
-e 2
EOF

augenrules --load >> "$LOG_FILE" 2>&1 || auditctl -R "$AUDIT_RULES" >> "$LOG_FILE" 2>&1 || true
systemctl enable auditd >> "$LOG_FILE" 2>&1
systemctl restart auditd >> "$LOG_FILE" 2>&1
log "auditd configure avec regles etendues"

########################################################################
# 5. PARAMETRES NOYAU (SYSCTL)
########################################################################
step "[5/10] Durcissement noyau sysctl"

SYSCTL_CONF="/etc/sysctl.d/99-hardening.conf"
cat > "$SYSCTL_CONF" << 'EOF'
# ── Reseau IPv4 ──────────────────────────────────────────────────────
net.ipv4.ip_forward = 0
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1

# ── Protection SYN flood ─────────────────────────────────────────────
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_syn_backlog = 2048
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_syn_retries = 5

# ── Reseau IPv6 ──────────────────────────────────────────────────────
net.ipv6.conf.all.forwarding = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0
net.ipv6.conf.all.accept_source_route = 0

# ── Noyau ────────────────────────────────────────────────────────────
kernel.randomize_va_space = 2
kernel.kptr_restrict = 2
kernel.dmesg_restrict = 1
kernel.sysrq = 0
fs.suid_dumpable = 0

# ── Protection memoire ───────────────────────────────────────────────
kernel.perf_event_paranoid = 3
vm.mmap_min_addr = 65536

# ── Fichiers core dump ───────────────────────────────────────────────
fs.core_uses_pid = 1
kernel.core_pattern = |/bin/false
EOF

sysctl -p "$SYSCTL_CONF" >> "$LOG_FILE" 2>&1
log "Parametres sysctl appliques"

########################################################################
# 6. DESACTIVER SERVICES INUTILES
########################################################################
step "[6/10] Desactivation services inutiles"

SERVICES_TO_DISABLE=(
    "avahi-daemon"
    "cups"
    "bluetooth"
    "rpcbind"
    "nfs-server"
    "rsync"
)

for svc in "${SERVICES_TO_DISABLE[@]}"; do
    if systemctl list-unit-files 2>/dev/null | grep -q "^${svc}"; then
        systemctl stop "$svc"    >> "$LOG_FILE" 2>&1 || true
        systemctl disable "$svc" >> "$LOG_FILE" 2>&1 || true
        systemctl mask "$svc"    >> "$LOG_FILE" 2>&1 || true
        log "Service desactive + masque : $svc"
    else
        warn "Service introuvable (ignore) : $svc"
    fi
done

########################################################################
# 7. DESACTIVER PROTOCOLES ET FS INUTILES
########################################################################
step "[7/10] Desactivation protocoles reseau / systemes de fichiers rares"

cat > /etc/modprobe.d/disable-protocols.conf << 'EOF'
# Protocoles reseau inutiles
install dccp    /bin/false
install sctp    /bin/false
install rds     /bin/false
install tipc    /bin/false

# Systemes de fichiers rares (reduit surface d'attaque)
install cramfs   /bin/false
install freevxfs /bin/false
install jffs2    /bin/false
install hfs      /bin/false
install hfsplus  /bin/false
install udf      /bin/false
EOF

# Blacklist dans initramfs aussi
cat > /etc/modprobe.d/blacklist-rare-net.conf << 'EOF'
blacklist dccp
blacklist sctp
blacklist rds
blacklist tipc
EOF

log "Protocoles et FS rares desactives"

########################################################################
# 8. PERMISSIONS FICHIERS SENSIBLES
########################################################################
step "[8/10] Permissions fichiers sensibles"

chmod 640  /etc/shadow   2>/dev/null && log "chmod 640 /etc/shadow"
chmod 600  /etc/gshadow  2>/dev/null && log "chmod 600 /etc/gshadow"
chmod 644  /etc/passwd   2>/dev/null && log "chmod 644 /etc/passwd"
chmod 644  /etc/group    2>/dev/null && log "chmod 644 /etc/group"
chmod 600  /boot/grub/grub.cfg 2>/dev/null && log "chmod 600 /boot/grub/grub.cfg" || warn "grub.cfg introuvable"

# Securiser le repertoire /home
chmod 750 /root
log "chmod 750 /root"

# Trouver et corriger les fichiers world-writable (hors /proc /sys /dev)
log "Recherche fichiers world-writable (peut prendre quelques secondes)..."
find / -xdev -type f -perm -0002 \
    ! -path "/proc/*" ! -path "/sys/*" ! -path "/dev/*" ! -path "/run/*" \
    2>/dev/null | while read -r f; do
    chmod o-w "$f"
    warn "Corrige world-writable : $f"
done

# Trouver les fichiers SUID/SGID suspects (affichage seulement)
log "Liste SUID/SGID (informatif) :"
find / -xdev \( -perm -4000 -o -perm -2000 \) -type f \
    ! -path "/proc/*" ! -path "/sys/*" 2>/dev/null \
    | tee -a "$LOG_FILE" || true

########################################################################
# 9. MISES A JOUR AUTOMATIQUES
########################################################################
step "[9/10] Mises a jour automatiques de securite"

apt-get install -y unattended-upgrades >> "$LOG_FILE" 2>&1

cat > /etc/apt/apt.conf.d/50unattended-upgrades << 'EOF'
Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}";
    "${distro_id}:${distro_codename}-security";
    "${distro_id}:${distro_codename}-updates";
};
Unattended-Upgrade::AutoFixInterruptedDpkg "true";
Unattended-Upgrade::MinimalSteps "true";
Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";
Unattended-Upgrade::Remove-Unused-Dependencies "true";
Unattended-Upgrade::Automatic-Reboot "false";
Unattended-Upgrade::Mail "root";
EOF

cat > /etc/apt/apt.conf.d/20auto-upgrades << 'EOF'
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
APT::Periodic::AutocleanInterval "7";
EOF

systemctl enable unattended-upgrades >> "$LOG_FILE" 2>&1
log "Mises a jour automatiques activees"

########################################################################
# 10. LYNIS — INSTALLATION ET SCAN
########################################################################
step "[10/10] Installation de Lynis (scanner de securite)"

apt-get install -y lynis >> "$LOG_FILE" 2>&1

LYNIS_VERSION=$(lynis show version 2>/dev/null || echo "installee")
log "Lynis $LYNIS_VERSION installe"

log ""
log "=== LYNIS PRET — Lance le scan avec la commande suivante ==="
log ""
log "  sudo lynis audit system"
log ""
log "Pour un rapport complet vers un fichier :"
log "  sudo lynis audit system --report-file /tmp/lynis_report.dat 2>&1 | tee /tmp/lynis_output.txt"
log ""
log "Pour voir uniquement les suggestions :"
log "  sudo lynis audit system | grep -A2 'Suggestion'"
log ""
log "Pour voir le score :"
log "  sudo lynis audit system | grep -i 'hardening index'"

########################################################################
# FIN
########################################################################
echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}  HARDENING TERMINE AVEC SUCCES             ${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo -e "${CYAN}CE QUI A ETE FAIT :${NC}"
echo "  ✅ Systeme mis a jour"
echo "  ✅ UFW firewall configure (deny incoming, SSH rate-limited)"
echo "  ✅ SSH durci (no root, MaxAuthTries 3, ciphers forts)"
echo "  ✅ auditd avec regles etendues"
echo "  ✅ sysctl noyau durci (anti-spoofing, SYN flood, ASLR)"
echo "  ✅ Services inutiles desactives et masques"
echo "  ✅ Protocoles reseau rares desactives"
echo "  ✅ Permissions fichiers sensibles corrigees"
echo "  ✅ Mises a jour automatiques activees"
echo "  ✅ Lynis installe"
echo ""
echo -e "${YELLOW}CE QUI N'A PAS ETE TOUCHE (intentionnel) :${NC}"
echo "  ⚠️  Mots de passe : AUCUN changement (pas de PAM pwquality)"
echo "  ⚠️  Verrouillage de compte : DESACTIVE (pas de faillock)"
echo "  ⚠️  PasswordAuthentication SSH : reste sur YES"
echo ""
echo -e "${CYAN}PROCHAINE ETAPE — Scanner avec Lynis :${NC}"
echo ""
echo "  sudo lynis audit system"
echo ""
echo -e "${YELLOW}Journal complet : $LOG_FILE${NC}"
echo -e "${YELLOW}Un redemarrage est recommande apres le scan.${NC}"
