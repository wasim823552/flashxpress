# ⚡ FlashXpress - World's Fastest WordPress Stack

<div align="center">

![FlashXpress](https://img.shields.io/badge/FlashXpress-wp.flashxpress.cloud-orange)
![License](https://img.shields.io/badge/License-MIT-green)
![PHP](https://img.shields.io/badge/PHP-8.4%20%7C%208.5-blue)
![MariaDB](https://img.shields.io/badge/MariaDB-11.x-purple)

**Deploy WordPress in seconds with NGINX, MariaDB, PHP 8.4/8.5, Redis, FastCGI, Brotli & HTTP/3**

[Documentation](https://wp.flashxpress.cloud) • [Installation](#installation) • [Commands](#commands) • [Features](#features)

</div>

---

## 🚀 Quick Start

Install FlashXpress on a fresh Ubuntu 22.04/24.04 server with a single command:

```bash
curl -sSL https://wp.flashxpress.cloud/install | sudo bash
```

Create your first WordPress site:

```bash
sudo fx site create example.com --wp --php=8.5 --ssl --cache
```

---

## ✨ Features

### 🏎️ Performance
- **HTTP/3 (QUIC)** - Latest protocol for fastest connections
- **Brotli Compression** - 20-30% better than GZIP
- **Redis Object Cache** - Built-in Redis 7.x
- **FastCGI Page Cache** - 100x faster page loads
- **OPcache** - PHP bytecode caching

### 🔒 Security
- **UFW Firewall** - Configured with rate limiting
- **Fail2Ban** - Brute-force protection for SSH, WordPress, XML-RPC
- **Malware Scanner** - Real-time file scanning
- **Security Headers** - HSTS, CSP, X-Frame-Options
- **Let's Encrypt SSL** - Auto-renewal with wildcard support

### 🛠️ Developer Tools
- **PHP Version Management** - Run PHP 8.1-8.5, switch per site
- **Staging Sites** - One-click staging environment
- **Git Deployment** - Push-to-deploy workflow
- **WP-CLI** - Pre-installed and configured
- **File Manager** - Web-based file management
- **phpMyAdmin** - Database management UI

### 💾 Data Management
- **MariaDB 11.x** - MySQL drop-in replacement, faster
- **Automated Backups** - Daily backups with retention
- **Easy Restore** - One-command restore
- **Cloud Storage** - S3, GCS, SFTP support

---

## 📋 Requirements

| Minimum | Recommended |
|---------|-------------|
| Ubuntu 22.04/24.04 | Ubuntu 24.04 LTS |
| 1 GB RAM | 4+ GB RAM |
| 20 GB SSD | 50+ GB SSD |
| 1 CPU Core | 2+ CPU Cores |
| Root access | Dedicated IP |

**Supported Providers:** DigitalOcean, Linode, Vultr, AWS EC2, Google Cloud, Azure, Hetzner, OVH, UpCloud, and any KVM VPS.

---

## 🔧 Installation

### One-Command Install

```bash
# Default installation (PHP 8.4)
curl -sSL https://wp.flashxpress.cloud/install | sudo bash

# With PHP 8.5
curl -sSL https://wp.flashxpress.cloud/install | sudo bash -s -- --php=8.5
```

### Manual Installation

1. Update your system:
```bash
apt update && apt upgrade -y
```

2. Download and run the installer:
```bash
wget https://wp.flashxpress.cloud/scripts/fx-install.sh
chmod +x fx-install.sh
sudo ./fx-install.sh --php=8.5
```

---

## 📝 Commands

### Stack Management

| Command | Description |
|---------|-------------|
| `fx status` | Show complete stack status |
| `fx update` | Update FlashXpress |
| `fx uninstall` | Remove FlashXpress |

### Site Management

| Command | Description |
|---------|-------------|
| `fx site create domain.com --wp` | Create WordPress site |
| `fx site create domain.com --php` | Create PHP site |
| `fx site create domain.com --html` | Create HTML site |
| `fx site delete domain.com` | Delete a site |
| `fx site list` | List all sites |
| `fx site info domain.com` | Show site details |

### PHP Management

| Command | Description |
|---------|-------------|
| `fx php version` | Show current PHP version |
| `fx php versions` | List installed PHP versions |
| `fx php install 8.5` | Install PHP version |
| `fx php switch 8.5` | Switch default PHP |
| `fx php switch 8.5 --site=domain.com` | Switch PHP for site |
| `fx php restart` | Restart PHP-FPM |

### SSL & Security

| Command | Description |
|---------|-------------|
| `fx ssl enable domain.com` | Enable Let's Encrypt SSL |
| `fx ssl enable domain.com --wildcard` | Enable wildcard SSL |
| `fx ssl renew` | Renew all certificates |
| `fx firewall enable` | Enable UFW firewall |
| `fx security fail2ban enable` | Enable Fail2Ban |
| `fx security scan domain.com` | Scan for malware |

### Performance

| Command | Description |
|---------|-------------|
| `fx cache enable domain.com` | Enable FastCGI cache |
| `fx cache purge domain.com` | Clear page cache |
| `fx redis enable` | Enable Redis object cache |
| `fx redis flush` | Clear Redis cache |
| `fx http3 enable` | Enable HTTP/3 (QUIC) |
| `fx compress brotli enable` | Enable Brotli compression |

### Database

| Command | Description |
|---------|-------------|
| `fx db access domain.com` | Show database credentials |
| `fx db backup domain.com` | Backup database |
| `fx db import domain.com file.sql` | Import database |
| `fx pma enable` | Enable phpMyAdmin |
| `fx pma url` | Get phpMyAdmin URL |

### Backup & Restore

| Command | Description |
|---------|-------------|
| `fx backup create domain.com` | Full site backup |
| `fx backup create --all` | Backup all sites |
| `fx backup list` | List all backups |
| `fx backup restore domain.com` | Restore from backup |

---

## 📁 Scripts in this Repository

| Script | Description |
|--------|-------------|
| `fx-install.sh` | Main installation script |
| `fx-site-create.sh` | WordPress site creator |
| `fx-security.sh` | Security hardening script |
| `fx-backup.sh` | Backup automation script |
| `fx-performance.sh` | Performance optimization |
| `fx-php-manager.sh` | PHP version management |
| `fx-pma-install.sh` | phpMyAdmin installer |
| `fx-filemanager-install.sh` | File manager installer |

---

## 🔄 Comparison with Other Tools

| Feature | FlashXpress | EasyEngine | GridPane | Cloudways |
|---------|:-----------:|:----------:|:--------:|:---------:|
| Free & Open Source | ✅ | ✅ | ❌ | ❌ |
| PHP 8.4/8.5 | ✅ | ❌ | ✅ | ✅ |
| HTTP/3 (QUIC) | ✅ | ❌ | ❌ | ❌ |
| Brotli Compression | ✅ | ❌ | ❌ | ✅ |
| File Manager | ✅ | ❌ | ❌ | ✅ |
| phpMyAdmin | ✅ | ❌ | ✅ | ✅ |
| Staging Sites | ✅ | ❌ | ✅ | ✅ |
| Git Deployment | ✅ | ❌ | ✅ | ✅ |
| Malware Scanner | ✅ | ❌ | ❌ | ❌ |

---

## 🤝 Contributing

We welcome contributions! Please see our Contributing Guide for details.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

FlashXpress is open-source software licensed under the MIT License.

---

## 🆘 Support

- **Documentation:** [wp.flashxpress.cloud](https://wp.flashxpress.cloud)
- **Issues:** GitHub Issues
- **Community:** GitHub Discussions

---

<div align="center">

Made with ❤️ by the FlashXpress Team

</div>
