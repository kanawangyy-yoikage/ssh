#!/bin/bash
#
# install-ssh.sh
# Script untuk install & konfigurasi OpenSSH Server di Debian
# agar VM Debian bisa diremote dari Windows host.
#
# Cara pakai:
#   chmod +x install-ssh.sh
#   sudo ./install-ssh.sh
#
# Author: -
# License: MIT

set -e  # Hentikan script jika ada error

# Warna untuk output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Cek apakah dijalankan sebagai root/sudo
if [ "$EUID" -ne 0 ]; then
    echo "Script ini harus dijalankan dengan sudo."
    echo "Contoh: sudo ./install-ssh.sh"
    exit 1
fi

info "Update package list..."
apt update -y

info "Install OpenSSH Server..."
apt install -y openssh-server

info "Mengaktifkan SSH agar auto-start saat boot..."
systemctl enable ssh

info "Menjalankan service SSH..."
systemctl start ssh

info "Cek status service SSH:"
systemctl status ssh --no-pager || true

# Buka firewall jika ufw terpasang & aktif
if command -v ufw &> /dev/null; then
    if ufw status | grep -q "Status: active"; then
        info "Membuka port SSH (22) di ufw..."
        ufw allow ssh
        ufw reload
    else
        warn "ufw terpasang tapi tidak aktif, lewati konfigurasi firewall."
    fi
else
    warn "ufw tidak ditemukan, lewati konfigurasi firewall."
fi

echo ""
info "Instalasi selesai!"
echo ""
echo "=== Informasi Koneksi ==="
echo "IP address VM ini:"
ip addr show | grep "inet " | grep -v "127.0.0.1" | awk '{print "  - " $2}'

echo ""
echo "User yang bisa dipakai login:"
echo "  - $(logname 2>/dev/null || echo "<user_anda>")"

echo ""
echo "Dari Windows (PowerShell/CMD/PuTTY), remote dengan:"
echo "  ssh <username>@<IP_VM_DI_ATAS>"
echo ""
echo "Lihat README.md untuk catatan konfigurasi jaringan VM (NAT/Bridged/WSL2)."
