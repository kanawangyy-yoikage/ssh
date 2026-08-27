#!/bin/bash
###############################################################################
# SCRIPT KONFIGURASI SERVER ADMINISTRASI - SMK TEKNOLOGI NUSANTARA
# Studi Kasus: Server Debian dengan akses SSH dari Lab Jaringan
#
# Jalankan sebagai root:
#   chmod +x konfigurasi-server-ssh.sh
#   sudo ./konfigurasi-server-ssh.sh
###############################################################################

set -e

echo "=== 1. KONFIGURASI IP ADDRESS SERVER ==="
# Sesuaikan nama interface dengan hasil "ip a" di server Anda (contoh: ens33/eth0)
INTERFACE="ens33"

cat > /etc/network/interfaces <<EOF
auto lo
iface lo inet loopback

auto $INTERFACE
iface $INTERFACE inet static
    address 200.100.50.1
    netmask 255.255.255.0
EOF

echo "-> File /etc/network/interfaces berhasil dikonfigurasi untuk IP 200.100.50.1/24"
echo "   (restart service networking / reboot agar berlaku: systemctl restart networking)"
echo

echo "=== 2. MEMBUAT USER user5, user10, user100 ==="
for USERNAME in user5 user10 user100; do
    if id "$USERNAME" &>/dev/null; then
        echo "-> User $USERNAME sudah ada, dilewati."
    else
        useradd -m -s /bin/bash "$USERNAME"
        echo "-> User $USERNAME berhasil dibuat."
        echo "   Silakan set password manual dengan: passwd $USERNAME"
    fi
done
echo

echo "=== 3. MEMBUAT FILE laporan-praktik.txt ==="
# Ganti "NAMA_KELOMPOK" dan "NAMA_SISWA" sesuai identitas Anda
cat > /root/laporan-praktik.txt <<EOF
Nama Kelompok : NAMA_KELOMPOK
Nama Siswa    : NAMA_SISWA
EOF
echo "-> File laporan-praktik.txt berhasil dibuat di /root/"
echo "   Edit isinya dengan: nano /root/laporan-praktik.txt"
echo

echo "=== 4. INSTALASI OPENSSH-SERVER (jika belum ada) ==="
if ! command -v sshd &>/dev/null; then
    apt update
    apt install -y openssh-server
fi
echo

echo "=== 5. BACKUP FILE KONFIGURASI SSH ==="
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak.$(date +%Y%m%d%H%M%S)
echo "-> Backup sshd_config berhasil dibuat."
echo

echo "=== 6. KONFIGURASI KEBIJAKAN KEAMANAN SSH ==="
SSHD_CONFIG="/etc/ssh/sshd_config"
SSH_PORT="2200"   # Port SSH baru, bukan port default 22 (bisa disesuaikan)

# Fungsi bantu untuk set/replace opsi di sshd_config
set_config() {
    local KEY="$1"
    local VALUE="$2"
    if grep -qE "^\s*#?\s*${KEY}\b" "$SSHD_CONFIG"; then
        sed -i "s|^\s*#\?\s*${KEY}.*|${KEY} ${VALUE}|" "$SSHD_CONFIG"
    else
        echo "${KEY} ${VALUE}" >> "$SSHD_CONFIG"
    fi
}

# a. Port SSH tidak boleh default (22)
set_config "Port" "$SSH_PORT"

# b. Root tidak boleh login langsung
set_config "PermitRootLogin" "no"

# c. Hanya user5 dan user10 yang diizinkan mengakses server via SSH
#    (user100 login lewat SSH key, jadi tetap dimasukkan agar bisa login key-based)
set_config "AllowUsers" "user5 user10 user100"

# d. Hanya user yang memiliki SSH key yang boleh login (nonaktifkan login password)
set_config "PubkeyAuthentication" "yes"
set_config "PasswordAuthentication" "no"
set_config "ChallengeResponseAuthentication" "no"

echo "-> Konfigurasi keamanan SSH selesai:"
echo "   Port              : $SSH_PORT"
echo "   PermitRootLogin   : no"
echo "   AllowUsers        : user5 user10 user100"
echo "   PasswordAuthentication : no (wajib pakai SSH key)"
echo

echo "=== 7. MEMBUAT SSH KEY (PRIVATE & PUBLIC) UNTUK user100 ==="
USER100_HOME="/home/user100"
SSH_DIR="$USER100_HOME/.ssh"

mkdir -p "$SSH_DIR"

# Generate keypair RSA 4096 bit tanpa passphrase (bisa diubah sesuai kebutuhan)
if [ ! -f "$SSH_DIR/id_rsa" ]; then
    sudo -u user100 ssh-keygen -t rsa -b 4096 -f "$SSH_DIR/id_rsa" -N "" -C "user100@server-admin"
fi

# Masukkan public key ke authorized_keys agar user100 bisa login pakai key tsb
cat "$SSH_DIR/id_rsa.pub" >> "$SSH_DIR/authorized_keys"

chown -R user100:user100 "$SSH_DIR"
chmod 700 "$SSH_DIR"
chmod 600 "$SSH_DIR/authorized_keys"
chmod 600 "$SSH_DIR/id_rsa"
chmod 644 "$SSH_DIR/id_rsa.pub"

echo "-> Key pair untuk user100 berhasil dibuat di $SSH_DIR"
echo "   Private key : $SSH_DIR/id_rsa   (COPY & SIMPAN INI ke komputer client, JANGAN dibagikan)"
echo "   Public key  : $SSH_DIR/id_rsa.pub (sudah otomatis ditambahkan ke authorized_keys)"
echo
echo "   Untuk login dari client, salin file id_rsa ke komputer client, contoh:"
echo "   scp -P $SSH_PORT user100@200.100.50.1:$SSH_DIR/id_rsa ./user100_key"
echo "   chmod 600 user100_key"
echo "   ssh -i user100_key -p $SSH_PORT user100@200.100.50.1"
echo

echo "=== 8. VALIDASI & RESTART SERVICE SSH ==="
sshd -t && echo "-> Konfigurasi sshd_config valid."
systemctl restart sshd
systemctl enable sshd
echo "-> Service SSH berhasil di-restart pada port $SSH_PORT."
echo

echo "=========================================================="
echo " SELESAI. Ringkasan konfigurasi:"
echo " - IP Server        : 200.100.50.1/24"
echo " - Port SSH baru     : $SSH_PORT"
echo " - Root login        : dinonaktifkan"
echo " - User diizinkan    : user5, user10 (password) & user100 (SSH key)"
echo " - Autentikasi       : hanya SSH key (password login dimatikan)"
echo "=========================================================="
