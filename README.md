# Debian SSH Installer

Script Bash sederhana untuk meng-install dan mengaktifkan **OpenSSH Server** di Debian, sehingga VM Debian bisa diremote (SSH) dari Windows host.

## Fitur

- Install `openssh-server`
- Aktifkan service SSH agar auto-start saat boot
- Buka port 22 di `ufw` (jika terpasang & aktif)
- Menampilkan IP address VM setelah instalasi selesai

## Cara Pakai

```bash
git clone https://github.com/<username>/<nama-repo>.git
cd <nama-repo>
chmod +x install-ssh.sh
sudo ./install-ssh.sh
```

Setelah selesai, script akan menampilkan IP address VM dan contoh perintah untuk connect dari Windows:

```bash
ssh <username>@<IP_VM>
```

## Koneksi dari Windows

Windows 10/11 sudah memiliki OpenSSH Client bawaan, jadi cukup buka **PowerShell** atau **CMD** lalu jalankan perintah `ssh` di atas. Alternatif lain bisa pakai [PuTTY](https://www.putty.org/).

## Catatan Konfigurasi Jaringan VM

Cara VM diakses dari Windows tergantung jenis network adapter yang dipakai:

| Mode Jaringan | Cara Akses dari Windows |
|---|---|
| **NAT** (VirtualBox/VMware) | Tambahkan *port forwarding* (misal host `2222` → guest `22`), lalu `ssh user@127.0.0.1 -p 2222` |
| **Bridged Adapter** | VM mendapat IP sendiri di jaringan yang sama, langsung `ssh user@<IP_VM>` |
| **Hyper-V (Default Switch)** | Biasanya bridged secara otomatis, cek IP dengan `ip addr` di dalam VM |
| **WSL2** | Berbeda dari VM biasa — WSL2 punya mekanisme jaringan sendiri, umumnya sudah bisa diakses lewat `localhost` tanpa perlu setup manual seperti ini |

## Requirement

- Debian (10/11/12) atau turunannya
- Akses `sudo`/root
- Koneksi internet untuk `apt install`

## Lisensi

MIT
