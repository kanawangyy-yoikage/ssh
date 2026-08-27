# Konfigurasi Server Administrasi SSH - Debian

Script otomatisasi untuk studi kasus **Server Administrasi berbasis Debian** yang diakses oleh administrator jaringan melalui SSH dari ruang laboratorium.

Tugas: SMK Teknologi Nusantara

## 📋 Deskripsi Studi Kasus

Membangun Server Administrasi Debian dengan konfigurasi:

- **IP Server**: `200.100.50.1/24`
- **IP Client**: range `200.100.50.10/24` s.d. `200.100.50.100/24`
- User yang dibuat: `user5`, `user10`, `user100`
- File laporan: `laporan-praktik.txt`

## 🔒 Kebijakan Keamanan

| No | Kebijakan | Implementasi |
|----|-----------|--------------|
| 1 | SSH tidak menggunakan port default | Port diganti ke `2200` |
| 2 | Root tidak boleh login langsung | `PermitRootLogin no` |
| 3 | User yang diizinkan akses hanya user5 & user10 | `AllowUsers` |
| 4 | user100 login menggunakan SSH key | Generate keypair RSA 4096-bit |
| 5 | Hanya user dengan SSH key yang bisa login | `PasswordAuthentication no` |

## 📁 Struktur Repository

```
.
├── konfigurasi-server-ssh.sh   # Script utama konfigurasi server
├── laporan-praktik.txt         # Template laporan praktik
└── README.md                   # Dokumentasi ini
```

## 🚀 Cara Penggunaan

1. Clone repository ini ke server Debian:
   ```bash
   git clone https://github.com/USERNAME/konfigurasi-server-ssh.git
   cd konfigurasi-server-ssh
   ```

2. Beri izin eksekusi pada script:
   ```bash
   chmod +x konfigurasi-server-ssh.sh
   ```

3. Sesuaikan variabel berikut di dalam script sebelum menjalankan:
   - `INTERFACE` — nama interface jaringan server (cek dengan `ip a`)
   - `SSH_PORT` — port SSH baru yang diinginkan (default: `2200`)

4. Jalankan script sebagai root:
   ```bash
   sudo ./konfigurasi-server-ssh.sh
   ```

5. Set password untuk masing-masing user:
   ```bash
   sudo passwd user5
   sudo passwd user10
   ```

6. Salin private key `user100` ke komputer client untuk login SSH key-based:
   ```bash
   scp -P 2200 user100@200.100.50.1:/home/user100/.ssh/id_rsa ./user100_key
   chmod 600 user100_key
   ssh -i user100_key -p 2200 user100@200.100.50.1
   ```

## ⚠️ Catatan

- Setelah `PasswordAuthentication no` diterapkan, **hanya login via SSH key** yang berfungsi.
- Pastikan private key `user100` sudah disalin ke client **sebelum** menutup sesi akses root/console pertama kali, agar tidak terkunci dari server.
- Edit isi `laporan-praktik.txt` dengan nama kelompok dan nama siswa yang sesuai.

## 📄 Lisensi

Bebas digunakan untuk keperluan pembelajaran.
