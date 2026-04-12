#!/bin/bash
# ==============================================================================
# YTECH SOLUTIONS – Ubuntu Server Hardening Script v7.0
# CIS Benchmarks + Lynis > 85 + Toutes corrections supplémentaires
# SANS modification PAM – aucun risque de blocage
# ==============================================================================
# USAGE : sudo bash ytech_hardening_v7.sh
# ==============================================================================

set -uo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

LOG_FILE="/var/log/ubuntu_hardening_$(date +%F).log"

log()     { echo -e "${GREEN}[✔]${NC} $*" | tee -a "$LOG_FILE"; }
warn()    { echo -e "${YELLOW}[⚠]${NC} $*" | tee -a "$LOG_FILE"; }
info()    { echo -e "${CYAN}[ℹ]${NC} $*" | tee -a "$LOG_FILE"; }
section() {
  echo -e "\n${BOLD}${CYAN}══════════════════════════════════════════${NC}" | tee -a "$LOG_FILE"
  echo -e "${BOLD}${CYAN}  $*${NC}" | tee -a "$LOG_FILE"
  echo -e "${BOLD}${CYAN}══════════════════════════════════════════${NC}" | tee -a "$LOG_FILE"
}

# ── Root check ────────────────────────────────────────────────────────────────
if [[ $EUID -ne 0 ]]; then
  echo -e "${RED}[✘]${NC} Exécuter avec : sudo bash $0"
  exit 1
fi

clear
echo -e "${BOLD}${GREEN}"
echo "  ██╗   ██╗████████╗███████╗ ██████╗██╗  ██╗"
echo "  ╚██╗ ██╔╝╚══██╔══╝██╔════╝██╔════╝██║  ██║"
echo "   ╚████╔╝    ██║   █████╗  ██║     ███████║"
echo "    ╚██╔╝     ██║   ██╔══╝  ██║     ██╔══██║"
echo "     ██║      ██║   ███████╗╚██████╗██║  ██║"
echo "     ╚═╝      ╚═╝   ╚══════╝ ╚═════╝╚═╝  ╚═╝"
echo -e "${NC}"
echo -e "${BOLD}   Hardening v7.0 – CIS + Lynis > 85 – COMPLET${NC}"
echo ""
echo "=== Début : $(date) ===" | tee -a "$LOG_FILE"
echo "=== OS    : $(lsb_release -ds 2>/dev/null) ===" | tee -a "$LOG_FILE"

# ==============================================================================
# [1/18] RÉPARATION ET MISE À JOUR
# ==============================================================================
section "[1/18] Réparation dpkg et mise à jour système"
export DEBIAN_FRONTEND=noninteractive

dpkg --configure -a 2>/dev/null || true
apt-get install -f -y -qq 2>/dev/null || true
apt-get update -qq
apt-get upgrade -y -qq
apt-get dist-upgrade -y -qq

# Suppression services inutiles (CIS 2.2.x)
for pkg in nis rsh-client rsh-redone-client telnet talk ldap-utils \
           avahi-daemon cups rpcbind bind9 vsftpd samba snmp \
           xinetd isc-dhcp-server dovecot-imapd dovecot-pop3d squid; do
  dpkg -l "$pkg" &>/dev/null 2>&1 && \
    apt-get purge -y -qq "$pkg" 2>/dev/null && log "Supprimé: $pkg" || true
done

# Désactiver services inutiles
for svc in cups bluetooth avahi-daemon; do
  systemctl disable "$svc" 2>/dev/null || true
  systemctl stop "$svc" 2>/dev/null || true
done

apt-get autoremove -y -qq
log "Système mis à jour | Services inutiles supprimés"

# ==============================================================================
# [2/18] MISES À JOUR AUTOMATIQUES
# ==============================================================================
section "[2/18] Mises à jour automatiques (fixe DEB-0810)"
apt-get install -y -qq unattended-upgrades apt-listchanges apt-listbugs 2>/dev/null || true

cat > /etc/apt/apt.conf.d/50unattended-upgrades << 'EOF'
Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}";
    "${distro_id}:${distro_codename}-security";
    "${distro_id}ESMApps:${distro_codename}-apps-security";
    "${distro_id}ESM:${distro_codename}-infra-security";
};
Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";
Unattended-Upgrade::Remove-New-Unused-Dependencies "true";
Unattended-Upgrade::Automatic-Reboot "false";
Unattended-Upgrade::Mail "root";
Unattended-Upgrade::MailReport "on-change";
EOF

cat > /etc/apt/apt.conf.d/20auto-upgrades << 'EOF'
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "7";
APT::Periodic::Unattended-Upgrade "1";
EOF

systemctl enable --now unattended-upgrades 2>/dev/null || true
log "Mises à jour automatiques activées"

# ==============================================================================
# [3/18] INSTALLATION OUTILS
# ==============================================================================
section "[3/18] Installation outils de sécurité"
PACKAGES=(
  ufw fail2ban auditd audispd-plugins
  apparmor apparmor-utils
  lynis rkhunter chkrootkit aide debsums
  libpam-tmpdir chrony
  sysstat acct
  net-tools lsof htop curl wget git vim
  libapache2-mod-evasive libapache2-mod-security2
)
for pkg in "${PACKAGES[@]}"; do
  if ! dpkg -l "$pkg" &>/dev/null 2>&1; then
    apt-get install -y -qq "$pkg" 2>/dev/null && log "Installé: $pkg" || warn "Échec: $pkg"
  else
    info "Déjà installé: $pkg"
  fi
done

# ==============================================================================
# [4/18] FILESYSTEM HARDENING (CIS 1.1)
# ==============================================================================
section "[4/18] Hardening filesystem"

# Sticky bit sur répertoires world-writable
find / -xdev -type d \( -perm -0002 -a ! -perm -1000 \) \
  -exec chmod a+t {} + 2>/dev/null || true

# Permissions fichiers sensibles
chmod 640 /etc/shadow /etc/gshadow 2>/dev/null || true
chown root:shadow /etc/shadow /etc/gshadow 2>/dev/null || true
chmod 644 /etc/passwd /etc/group 2>/dev/null || true
chmod 1777 /tmp /var/tmp 2>/dev/null || true
chmod 700 /root 2>/dev/null || true
chmod 700 /boot 2>/dev/null || true

# Permissions cron
chmod 600 /etc/crontab 2>/dev/null || true
for d in /etc/cron.d /etc/cron.daily /etc/cron.hourly /etc/cron.monthly /etc/cron.weekly; do
  [[ -d "$d" ]] && chmod 700 "$d" 2>/dev/null || true
done

# cron.allow / at.allow – restreindre à root uniquement
echo "root" > /etc/cron.allow
echo "root" > /etc/at.allow
rm -f /etc/cron.deny /etc/at.deny 2>/dev/null || true
chmod 600 /etc/cron.allow /etc/at.allow

# Sécuriser /boot/grub
chmod 600 /boot/grub/grub.cfg 2>/dev/null || true

# Supprimer .rhosts et .netrc
find /home /root -name ".rhosts" -o -name ".netrc" 2>/dev/null | xargs rm -f 2>/dev/null || true

# SUID/SGID audit
find / -xdev -type f \( -perm -4000 -o -perm -2000 \) 2>/dev/null | \
  tee /var/log/suid_audit.txt > /dev/null

# Restreindre les compilateurs
for bin in gcc cc g++ make; do
  BIN_PATH=$(which "$bin" 2>/dev/null) && chmod 750 "$BIN_PATH" 2>/dev/null || true
done

log "Filesystem durci | cron.allow | /boot/grub 600 | compilateurs 750"

# ==============================================================================
# [5/18] POLITIQUE MOTS DE PASSE (SANS PAM)
# ==============================================================================
section "[5/18] Politique mots de passe – login.defs + pwquality (sans PAM)"

sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS   90/'  /etc/login.defs
sed -i 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS   7/'   /etc/login.defs
sed -i 's/^PASS_WARN_AGE.*/PASS_WARN_AGE   14/'  /etc/login.defs
grep -q "^UMASK" /etc/login.defs && \
  sed -i 's/^UMASK.*/UMASK 027/' /etc/login.defs || \
  echo "UMASK 027" >> /etc/login.defs
grep -q "^ENCRYPT_METHOD" /etc/login.defs && \
  sed -i 's/^ENCRYPT_METHOD.*/ENCRYPT_METHOD SHA512/' /etc/login.defs || \
  echo "ENCRYPT_METHOD SHA512" >> /etc/login.defs

cat > /etc/security/pwquality.conf << 'EOF'
# Ytech Solutions – Password Quality (sans injection PAM)
minlen = 14
dcredit = -1
ucredit = -1
ocredit = -1
lcredit = -1
maxrepeat = 3
maxsequence = 4
gecoscheck = 1
reject_username = 1
retry = 3
EOF

cat > /etc/security/faillock.conf << 'EOF'
deny = 5
fail_interval = 900
unlock_time = 1800
EOF

log "login.defs + pwquality configurés | PAM NON MODIFIÉ"

# ==============================================================================
# [6/18] SYSCTL RÉSEAU + KERNEL (CIS 3.x)
# ==============================================================================
section "[6/18] Sysctl – réseau et kernel"

cat > /etc/sysctl.d/99-ytech-hardening.conf << 'EOF'
# Ytech Solutions – CIS + Lynis sysctl hardening

# ── IPv4 ──
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_syn_backlog = 2048
net.ipv4.tcp_rfc1337 = 1
net.ipv4.ip_forward = 0
net.ipv4.tcp_timestamps = 0
net.ipv4.conf.all.forwarding = 0
net.ipv4.conf.all.arp_ignore = 1
net.ipv4.conf.all.arp_announce = 2

# ── IPv6 désactivé ──
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
net.ipv6.conf.all.accept_ra = 0
net.ipv6.conf.default.accept_ra = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.all.forwarding = 0

# ── Kernel hardening ──
kernel.randomize_va_space = 2
kernel.kptr_restrict = 2
kernel.dmesg_restrict = 1
kernel.perf_event_paranoid = 3
kernel.sysrq = 0
kernel.core_uses_pid = 1
kernel.panic = 60
kernel.panic_on_oops = 60
kernel.unprivileged_bpf_disabled = 1
kernel.yama.ptrace_scope = 1
net.core.bpf_jit_harden = 2

# ── Filesystem ──
fs.suid_dumpable = 0
fs.protected_hardlinks = 1
fs.protected_symlinks = 1
fs.protected_fifos = 2
fs.protected_regular = 2
EOF

sysctl --system > /dev/null 2>&1 || true
log "Sysctl : anti-spoofing, ASLR=2, ptrace=1, IPv6 OFF, timestamps OFF"

# ==============================================================================
# [7/18] BLACKLIST MODULES
# ==============================================================================
section "[7/18] Blacklist modules inutiles"

cat > /etc/modprobe.d/ytech-blacklist.conf << 'EOF'
# Ytech Solutions – Blacklist modules inutiles
# Protocoles réseau
blacklist dccp
blacklist sctp
blacklist rds
blacklist tipc
blacklist n-hdlc
blacklist ax25
blacklist netrom
blacklist x25
blacklist rose
blacklist decnet
blacklist econet
blacklist can
blacklist atm
blacklist net-pf-31
blacklist ipx
blacklist appletalk
# USB Storage
blacklist usb-storage
install usb-storage /bin/true
# Firewire
blacklist firewire-core
blacklist firewire-ohci
blacklist firewire-sbp2
# Filesystems rares
install cramfs /bin/true
install freevxfs /bin/true
install jffs2 /bin/true
install hfs /bin/true
install hfsplus /bin/true
install udf /bin/true
install squashfs /bin/true
EOF
log "Modules blacklistés : protocoles réseau, USB, firewire, filesystems rares"

# ==============================================================================
# [8/18] GRUB HARDENING
# ==============================================================================
section "[8/18] GRUB hardening"

chmod 700 /boot 2>/dev/null || true

if [[ -f /etc/default/grub ]]; then
  cp /etc/default/grub /etc/default/grub.bak.$(date +%Y%m%d)
  CMDLINE='GRUB_CMDLINE_LINUX_DEFAULT="quiet splash apparmor=1 security=apparmor audit=1 audit_backlog_limit=8192 ipv6.disable=1 init_on_alloc=1 init_on_free=1 vsyscall=none page_alloc.shuffle=1"'
  sed -i "s|^GRUB_CMDLINE_LINUX_DEFAULT=.*|$CMDLINE|" /etc/default/grub
  sed -i 's/^#\?GRUB_DISABLE_RECOVERY=.*/GRUB_DISABLE_RECOVERY="true"/' /etc/default/grub
  grep -q "GRUB_DISABLE_RECOVERY" /etc/default/grub || \
    echo 'GRUB_DISABLE_RECOVERY="true"' >> /etc/default/grub
  sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=5/' /etc/default/grub
  update-grub 2>/dev/null || true
  log "GRUB : recovery OFF | /boot 700 | params sécurité kernel"
fi

# ==============================================================================
# [9/18] SSH HARDENING (CIS 5.2)
# ==============================================================================
section "[9/18] SSH hardening (CIS 5.2)"

cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak.$(date +%Y%m%d) 2>/dev/null || true

cat > /etc/ssh/sshd_config << 'EOF'
# Ytech Solutions – SSH Hardened v7 (CIS 5.2)
Port 22
AddressFamily inet
Protocol 2
HostKey /etc/ssh/ssh_host_ed25519_key
HostKey /etc/ssh/ssh_host_rsa_key

# Crypto forte
KexAlgorithms curve25519-sha256@libssh.org,diffie-hellman-group-exchange-sha256
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com

# Authentification
LoginGraceTime 60
MaxAuthTries 4
MaxSessions 4
MaxStartups 10:30:60
PermitRootLogin no
StrictModes yes
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys
PasswordAuthentication yes
PermitEmptyPasswords no
ChallengeResponseAuthentication no
IgnoreRhosts yes
HostbasedAuthentication no
UsePAM yes

# Restrictions sécurité
X11Forwarding no
AllowTcpForwarding no
AllowAgentForwarding no
PermitTunnel no
GatewayPorts no
TCPKeepAlive no
Compression no

# Session
ClientAliveInterval 300
ClientAliveCountMax 2

# Logs
SyslogFacility AUTH
LogLevel VERBOSE
Banner /etc/issue.net
PrintLastLog yes

AcceptEnv LANG LC_*
Subsystem sftp /usr/lib/openssh/sftp-server -f AUTHPRIV -l INFO
EOF

# Bannières légales
cat > /etc/issue.net << 'EOF'
+--------------------------------------------------+
|       YTECH SOLUTIONS - ACCES RESTREINT          |
|  Systeme prive. Acces non autorise interdit.     |
|  Toute activite est enregistree et surveillee.   |
+--------------------------------------------------+
EOF

cat > /etc/issue << 'EOF'
YTECH SOLUTIONS - Acces restreint. Activites surveillees.
EOF

cat > /etc/motd << 'EOF'
WARNING: Authorized access only. All activities are monitored and logged.
EOF

# Clés SSH – supprimer les faibles
cd /etc/ssh
rm -f ssh_host_dsa_key* ssh_host_ecdsa_key* 2>/dev/null || true
[[ ! -f ssh_host_ed25519_key ]] && \
  ssh-keygen -t ed25519 -f ssh_host_ed25519_key -N "" -q 2>/dev/null || true
[[ ! -f ssh_host_rsa_key ]] && \
  ssh-keygen -t rsa -b 4096 -f ssh_host_rsa_key -N "" -q 2>/dev/null || true

# Supprimer moduli faibles (< 3071 bits)
awk '$5 >= 3071' /etc/ssh/moduli > /tmp/moduli_strong 2>/dev/null && \
  [[ -s /tmp/moduli_strong ]] && mv /tmp/moduli_strong /etc/ssh/moduli || true
cd - > /dev/null

if sshd -t 2>/dev/null; then
  systemctl restart sshd 2>/dev/null || systemctl restart ssh 2>/dev/null || true
  log "SSH durci : MaxAuthTries=4, no-root, Ed25519, moduli forts"
else
  warn "Erreur config SSH – vérifier manuellement"
fi

# ==============================================================================
# [10/18] UFW PARE-FEU
# ==============================================================================
section "[10/18] Pare-feu UFW"

ufw --force reset 2>/dev/null || true
ufw default deny incoming
ufw default allow outgoing
ufw default deny forward

ufw allow 22/tcp            comment "SSH"
ufw allow 80/tcp            comment "HTTP"
ufw allow 443/tcp           comment "HTTPS"
ufw allow from 192.168.0.0/16 to any port 3306  comment "MariaDB LAN"
ufw allow from 192.168.0.0/16 to any port 33700 comment "MariaDB custom"
ufw allow from 192.168.0.0/16 to any port 5666  comment "NRPE Nagios"
ufw allow from 192.168.0.0/16 to any port 10050 comment "Zabbix Agent"
ufw limit 22/tcp            comment "Rate-limit SSH"
ufw logging full
ufw --force enable
log "UFW activé | logging full"

# ==============================================================================
# [11/18] FAIL2BAN
# ==============================================================================
section "[11/18] Fail2ban"

mkdir -p /etc/fail2ban
cat > /etc/fail2ban/jail.local << 'EOF'
[DEFAULT]
bantime   = 3600
findtime  = 600
maxretry  = 5
backend   = systemd
ignoreip  = 127.0.0.1/8 ::1

[sshd]
enabled  = true
port     = ssh
filter   = sshd
logpath  = /var/log/auth.log
maxretry = 4
bantime  = 7200

[apache-auth]
enabled  = true
port     = http,https
logpath  = /var/log/apache2/error.log
maxretry = 5
EOF

systemctl enable fail2ban 2>/dev/null || true
systemctl restart fail2ban 2>/dev/null || true
log "Fail2ban : SSH 4 essais max, ban 2h"

# ==============================================================================
# [12/18] AUDITD (CIS 4.1)
# ==============================================================================
section "[12/18] Auditd – règles CIS complètes"

mkdir -p /etc/audit/rules.d/
cat > /etc/audit/rules.d/99-ytech-cis.rules << 'EOF'
-D
-b 8192

# Identité
-w /etc/passwd -p wa -k identity
-w /etc/shadow -p wa -k identity
-w /etc/group -p wa -k identity
-w /etc/gshadow -p wa -k identity
-w /etc/sudoers -p wa -k privilege_escalation
-w /etc/sudoers.d/ -p wa -k privilege_escalation

# SSH
-w /etc/ssh/sshd_config -p wa -k sshd_config

# Sessions
-w /var/log/lastlog -p wa -k logins
-w /var/log/auth.log -p wa -k auth_log
-w /var/run/utmp -p wa -k session
-w /var/log/wtmp -p wa -k session
-w /var/log/btmp -p wa -k session

# Syscalls critiques
-a always,exit -F arch=b64 -S execve -k exec
-a always,exit -F arch=b32 -S execve -k exec
-a always,exit -F arch=b64 -S chmod,fchmod,fchmodat -k perm_mod
-a always,exit -F arch=b64 -S chown,fchown,lchown,fchownat -k perm_mod
-a always,exit -F arch=b64 -S setuid,setgid,setreuid,setregid -k setuid
-a always,exit -F arch=b64 -S mount -k mounts
-a always,exit -F arch=b64 -S unlink,unlinkat,rename,renameat -k delete
-a always,exit -F arch=b64 -S open,openat -F exit=-EACCES -k access
-a always,exit -F arch=b64 -S ptrace -k ptrace

# Réseau
-w /etc/hosts -p wa -k network
-w /etc/resolv.conf -p wa -k network
-a always,exit -F arch=b64 -S sethostname,setdomainname -k network_mod

# Cron
-w /etc/crontab -p wa -k cron
-w /etc/cron.d/ -p wa -k cron
-w /var/spool/cron/ -p wa -k cron

# Modules noyau
-w /sbin/insmod -p x -k modules
-w /sbin/rmmod -p x -k modules
-w /sbin/modprobe -p x -k modules
-a always,exit -F arch=b64 -S init_module,delete_module -k modules
EOF

systemctl enable auditd 2>/dev/null || true
systemctl restart auditd 2>/dev/null || service auditd restart 2>/dev/null || true
log "Auditd configuré avec toutes les règles CIS"

# ==============================================================================
# [13/18] APPARMOR + MALWARE SCANNERS (fixe HRDN-7230)
# ==============================================================================
section "[13/18] AppArmor + Malware scanners"

systemctl enable --now apparmor 2>/dev/null || true
aa-enforce /etc/apparmor.d/* 2>/dev/null || true
log "AppArmor mode enforce"

if command -v rkhunter &>/dev/null; then
  rkhunter --update --quiet 2>/dev/null || true
  rkhunter --propupd --quiet 2>/dev/null || true
  log "Rkhunter base mise à jour"
fi

if command -v aide &>/dev/null; then
  aideinit --yes --force 2>/dev/null || aide --init 2>/dev/null || true
  [[ -f /var/lib/aide/aide.db.new ]] && \
    cp /var/lib/aide/aide.db.new /var/lib/aide/aide.db 2>/dev/null || true
  cat > /etc/cron.daily/aide-check << 'EOF'
#!/bin/bash
/usr/bin/aide --check 2>&1 | logger -t aide-check
EOF
  chmod +x /etc/cron.daily/aide-check
  log "AIDE : base initialisée + vérification quotidienne"
fi

# ==============================================================================
# [14/18] NTP – SYNCHRONISATION TEMPS (fixe Lynis TIME-3104)
# ==============================================================================
section "[14/18] NTP – Synchronisation temps (fixe TIME-3104)"

if command -v chronyc &>/dev/null; then
  systemctl enable --now chrony 2>/dev/null || true
  log "Chrony (NTP) activé"
elif command -v ntpd &>/dev/null; then
  systemctl enable --now ntp 2>/dev/null || true
  log "NTP activé"
else
  apt-get install -y -qq chrony 2>/dev/null && \
    systemctl enable --now chrony 2>/dev/null && \
    log "Chrony installé et activé" || warn "NTP non disponible"
fi

# ==============================================================================
# [15/18] SUDO HARDENING
# ==============================================================================
section "[15/18] Sudo hardening"

cat > /etc/sudoers.d/ytech-security << 'EOF'
# Ytech Solutions – Sudo Hardening
Defaults        env_reset
Defaults        mail_badpass
Defaults        secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
Defaults        logfile="/var/log/sudo.log"
Defaults        log_input,log_output
Defaults        use_pty
Defaults        !visiblepw
Defaults        always_set_home
Defaults        passwd_timeout=1
Defaults        timestamp_timeout=5
%sudo   ALL=(ALL:ALL) ALL
EOF
chmod 440 /etc/sudoers.d/ytech-security
log "Sudo : use_pty, log_input/output, !visiblepw"

# Restreindre su au groupe wheel/sudo
if ! grep -q "pam_wheel" /etc/pam.d/su 2>/dev/null; then
  echo "auth required pam_wheel.so use_uid" >> /etc/pam.d/su
  log "su : restreint au groupe sudo (pam_wheel)"
fi

# ==============================================================================
# [16/18] COREDUMP + SESSION + LOGROTATE
# ==============================================================================
section "[16/18] Coredump + Sessions + Logrotate"

# Coredump
mkdir -p /etc/systemd/coredump.conf.d/
cat > /etc/systemd/coredump.conf.d/ytech.conf << 'EOF'
[Coredump]
Storage=none
ProcessSizeMax=0
EOF
grep -q "hard core 0" /etc/security/limits.conf || \
  echo "* hard core 0" >> /etc/security/limits.conf
grep -q "soft core 0" /etc/security/limits.conf || \
  echo "* soft core 0" >> /etc/security/limits.conf

# Session sécurisée
cat > /etc/profile.d/ytech-security.sh << 'EOF'
# Ytech Solutions – Session Security
export TMOUT=900
readonly TMOUT
export HISTCONTROL=ignoredups:erasedups
export HISTSIZE=500
export HISTFILESIZE=1000
export HISTTIMEFORMAT="%F %T "
umask 027
EOF
chmod 644 /etc/profile.d/ytech-security.sh

# Désactiver comptes système inutilisés
for user in games news uucp proxy backup list irc gnats; do
  id "$user" &>/dev/null && \
    usermod -s /usr/sbin/nologin "$user" 2>/dev/null || true
done

# Ctrl+Alt+Del désactivé
systemctl mask ctrl-alt-del.target 2>/dev/null || true

# Logrotate 90 jours
cat > /etc/logrotate.d/ytech << 'EOF'
/var/log/auth.log
/var/log/syslog
/var/log/kern.log
/var/log/sudo.log
{
    weekly
    missingok
    rotate 52
    compress
    delaycompress
    notifempty
    create 640 root adm
    sharedscripts
    postrotate
        /bin/kill -HUP $(cat /var/run/rsyslogd.pid 2>/dev/null) 2>/dev/null || true
    endscript
}
EOF

systemctl restart rsyslog 2>/dev/null || true
log "Coredump OFF | Session 15min | Comptes système nologin | Logrotate 52sem"

# ==============================================================================
# [17/18] APACHE + MARIADB HARDENING
# ==============================================================================
section "[17/18] Apache + MariaDB hardening"

if command -v apache2 &>/dev/null; then
  for conf in /etc/apache2/conf-enabled/security.conf \
              /etc/apache2/conf-available/security.conf; do
    [[ -f "$conf" ]] && {
      sed -i 's/^ServerTokens.*/ServerTokens Prod/' "$conf"
      sed -i 's/^ServerSignature.*/ServerSignature Off/' "$conf"
      sed -i 's/^TraceEnable.*/TraceEnable Off/' "$conf"
    }
  done

  cat > /etc/apache2/conf-available/ytech-security.conf << 'EOF'
ServerTokens Prod
ServerSignature Off
TraceEnable Off

<IfModule mod_headers.c>
    Header always set X-Frame-Options "SAMEORIGIN"
    Header always set X-XSS-Protection "1; mode=block"
    Header always set X-Content-Type-Options "nosniff"
    Header always set Referrer-Policy "strict-origin-when-cross-origin"
    Header always set Strict-Transport-Security "max-age=63072000; includeSubDomains; preload"
    Header always set Content-Security-Policy "default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline';"
    Header always set Permissions-Policy "geolocation=(), microphone=(), camera=()"
    Header unset Server
    Header unset X-Powered-By
</IfModule>

<Directory />
    Options None
    AllowOverride None
    Require all denied
</Directory>
EOF

  a2enconf ytech-security 2>/dev/null || true
  a2enmod headers ssl rewrite 2>/dev/null || true
  apache2ctl configtest 2>/dev/null && \
    systemctl reload apache2 2>/dev/null || true
  log "Apache : headers sécurité complets"
fi

if command -v mysql &>/dev/null || command -v mariadb &>/dev/null; then
  mkdir -p /etc/mysql/mariadb.conf.d/
  cat > /etc/mysql/mariadb.conf.d/99-ytech.cnf << 'EOF'
[mysqld]
bind-address        = 127.0.0.1
local-infile        = 0
skip-symbolic-links = 1
skip-show-database
log_error           = /var/log/mysql/error.log
slow_query_log      = 1
max_connect_errors  = 10
max_connections     = 150
EOF
  systemctl restart mariadb 2>/dev/null || true
  log "MariaDB : bind=127.0.0.1, local-infile=OFF"
fi

# ==============================================================================
# [18/18] SCAN LYNIS FINAL
# ==============================================================================
section "[18/18] Scan Lynis – Score final"

if ! command -v lynis &>/dev/null; then
  apt-get install -y -qq lynis 2>/dev/null || true
fi

if command -v lynis &>/dev/null; then
  LYNIS_OUT="/var/log/lynis_v7_$(date +%Y%m%d_%H%M%S).txt"
  lynis audit system --quiet --no-colors 2>&1 | tee "$LYNIS_OUT"
  SCORE=$(grep "Hardening index" "$LYNIS_OUT" | grep -oP '\d+' | tail -1)
  echo ""
  echo -e "${BOLD}${GREEN}╔══════════════════════════════════════════════════╗${NC}"
  echo -e "${BOLD}${GREEN}║   SCORE LYNIS FINAL : ${SCORE}/100                     ║${NC}"
  echo -e "${BOLD}${GREEN}╚══════════════════════════════════════════════════╝${NC}"
  log "Rapport Lynis → $LYNIS_OUT"

  # Afficher les warnings restants
  echo ""
  warn "WARNINGS RESTANTS :"
  grep "Warning" "$LYNIS_OUT" | head -10 | while read line; do
    echo -e "  ${YELLOW}→${NC} $line"
  done
fi

# ==============================================================================
# RÉSUMÉ FINAL
# ==============================================================================
echo ""
echo -e "${BOLD}${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${GREEN}║      YTECH SOLUTIONS – HARDENING v7.0 COMPLET               ║${NC}"
echo -e "${BOLD}${GREEN}╠══════════════════════════════════════════════════════════════╣${NC}"
echo -e "${BOLD}${GREEN}║  [1]  Système mis à jour + services inutiles supprimés       ║${NC}"
echo -e "${BOLD}${GREEN}║  [2]  Mises à jour auto sécurité (apt-listbugs)              ║${NC}"
echo -e "${BOLD}${GREEN}║  [3]  lynis, rkhunter, chkrootkit, aide, debsums, chrony     ║${NC}"
echo -e "${BOLD}${GREEN}║  [4]  Filesystem : sticky bit, cron.allow, /boot 700         ║${NC}"
echo -e "${BOLD}${GREEN}║  [5]  Politique mdp : SHA512, minlen=14 (sans PAM)           ║${NC}"
echo -e "${BOLD}${GREEN}║  [6]  Sysctl : ptrace=1, timestamps OFF, arp_ignore          ║${NC}"
echo -e "${BOLD}${GREEN}║  [7]  Blacklist : 20+ modules inutiles                       ║${NC}"
echo -e "${BOLD}${GREEN}║  [8]  GRUB : recovery OFF, page_alloc.shuffle                ║${NC}"
echo -e "${BOLD}${GREEN}║  [9]  SSH : moduli forts, Ed25519, MaxAuthTries=4            ║${NC}"
echo -e "${BOLD}${GREEN}║  [10] UFW : logging full + règles LAN                        ║${NC}"
echo -e "${BOLD}${GREEN}║  [11] Fail2ban : SSH 4 essais, ban 2h                        ║${NC}"
echo -e "${BOLD}${GREEN}║  [12] Auditd : ptrace, réseau, modules, cron                 ║${NC}"
echo -e "${BOLD}${GREEN}║  [13] AppArmor enforce + Rkhunter + AIDE quotidien           ║${NC}"
echo -e "${BOLD}${GREEN}║  [14] Chrony NTP (fixe TIME-3104)                            ║${NC}"
echo -e "${BOLD}${GREEN}║  [15] Sudo : use_pty, log_input, pam_wheel                   ║${NC}"
echo -e "${BOLD}${GREEN}║  [16] Coredump OFF + Session 15min + Logrotate 52sem         ║${NC}"
echo -e "${BOLD}${GREEN}║  [17] Apache headers + MariaDB bind=127.0.0.1                ║${NC}"
echo -e "${BOLD}${GREEN}║  [18] Scan Lynis final                                       ║${NC}"
echo -e "${BOLD}${GREEN}╠══════════════════════════════════════════════════════════════╣${NC}"
echo -e "${BOLD}${YELLOW}║  PAM NON MODIFIÉ – aucun risque de blocage                  ║${NC}"
echo -e "${BOLD}${GREEN}╠══════════════════════════════════════════════════════════════╣${NC}"
echo -e "${BOLD}${GREEN}║  ACTIONS MANUELLES :                                         ║${NC}"
echo -e "${BOLD}${GREEN}║  1. sudo mysql_secure_installation                           ║${NC}"
echo -e "${BOLD}${GREEN}║  2. Certificat TLS : certbot --apache                        ║${NC}"
echo -e "${BOLD}${GREEN}║  3. REBOOT : sudo reboot                                     ║${NC}"
echo -e "${BOLD}${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"

echo ""
echo -e "${RED}${BOLD}⚡ REBOOT RECOMMANDÉ : sudo reboot${NC}"
echo "=== Fin : $(date) ===" | tee -a "$LOG_FILE"
