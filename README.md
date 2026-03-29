# FlashXpress WordPress Stack Installer

<p align="center">
  <img src="https://img.shields.io/badge/version-3.2.0-blue?style=for-the-badge" alt="Version 3.2.0">
  <img src="https://img.shields.io/badge/license-MIT-green?style=for-the-badge" alt="MIT License">
  <img src="https://img.shields.io/badge/OS-Ubuntu%2020.04%20%7C%2022.04%20%7C%2024.04-orange?style=for-the-badge" alt="Ubuntu">
  <img src="https://img.shields.io/badge/NGINX-FastCGI_Cache-brightgreen?style=for-the-badge" alt="NGINX">
  <img src="https://img.shields.io/badge/PHP-8.4%20%2B%208.3%20%2B%208.2%20%2B%208.1-purple?style=for-the-badge" alt="PHP">
</p>

<p align="center">
  <strong>FlashXpress</strong> is a blazing-fast WordPress stack installer that sets up a complete, production-ready hosting environment in minutes.
</p>

<p align="center">
  <a href="https://wp.flashxpress.cloud">Website</a> •
  <a href="https://buymeacoffee.com/wasimb">Support</a> •
  <a href="#features">Features</a> •
  <a href="#installation">Installation</a> •
  <a href="#commands">Commands</a>
</p>

---

## Features

- **Lightning Fast** — NGINX with FlashXPRESS FastCGI Cache for page-level caching
- **Latest Stack** — MariaDB 11.4, PHP 8.4 (with fallback to 8.3/8.2/8.1)
- **Redis Object Cache** — Pre-configured for WordPress Redis caching
- **SSL Made Easy** — One-command Let's Encrypt SSL with auto-renewal
- **Secure by Default** — UFW Firewall, Fail2Ban, disabled PHP functions
- **Site Management** — Create, delete, backup WordPress sites with one command
- **Database Tools** — Create, export, import, and manage databases
- **phpMyAdmin & Adminer** — Install database management tools instantly
- **File Manager** — TinyFileManager for web-based file management
- **PHP Version Switching** — Switch between PHP 8.4, 8.3, 8.2, 8.1
- **CLI Tool** — Full-featured `fx` command for managing everything
- **Clean Uninstall** — Remove everything cleanly when needed

## What Gets Installed

| Component | Version | Description |
|-----------|---------|-------------|
| NGINX | Latest | Web server with FastCGI cache |
| MariaDB | 11.4 | MySQL-compatible database server |
| PHP | 8.4 / 8.3 / 8.2 / 8.1 | PHP-FPM with essential extensions |
| Redis | Latest | In-memory object cache |
| WP-CLI | Latest | WordPress command-line tool |
| Certbot | Latest | Let's Encrypt SSL certificates |
| UFW | System | Firewall (ports 22, 80, 443) |
| Fail2Ban | System | Intrusion prevention |

## Installation

### Quick Install (One Command)

```bash
wget -O install https://wp.flashxpress.cloud/install && sudo bash install
```

Or with curl:

```bash
curl -fsSL https://wp.flashxpress.cloud/install | sudo bash
```

### From This Repository

```bash
git clone https://github.com/wasimakram/flashxpress.git
cd flashxpress
chmod +x install fx uninstall
sudo bash install
```

### Requirements

- **Ubuntu** 20.04, 22.04, or 24.04 (LTS)
- **Root** or **sudo** access
- **2 GB+ RAM** recommended
- Clean server (no existing NGINX/Apache/MySQL)

### Uninstall

```bash
sudo bash uninstall
```

## Commands

### System

```bash
fx status              # Show system status
fx version             # Show FlashXpress version
fx update              # Update FlashXpress
fx help                # Show help
```

### SSL Management

```bash
fx ssl install <domain>        # Install SSL certificate
fx ssl renew <domain>          # Renew SSL certificate
fx ssl remove <domain>         # Remove SSL certificate
```

### Authentication

```bash
fx auth on <domain>            # Enable basic auth
fx auth off <domain>           # Disable basic auth
fx auth add <domain> <user>    # Add auth user
fx auth remove <domain> <user> # Remove auth user
```

### Site Management

```bash
fx site create <domain>        # Create WordPress site
fx site delete <domain>        # Delete WordPress site
fx site list                   # List all sites
fx site info <domain>          # Show site details
```

### Database Management

```bash
fx db password <domain>        # Change site DB password
fx db create <name>            # Create new database
fx db delete <name>            # Delete database
fx db list                     # List all databases
fx db export <database> [file] # Export database
fx db import <database> <file> # Import database
```

### Tools

```bash
fx pma install                 # Install phpMyAdmin
fx pma remove                  # Remove phpMyAdmin
fx adminer install             # Install Adminer
fx adminer remove              # Remove Adminer
fx files install               # Install File Manager
fx files remove                # Remove File Manager
```

### Cache

```bash
fx cache clear                 # Clear FastCGI cache
fx cache status                # Show cache status
```

### PHP

```bash
fx php version                 # Show current PHP version
fx php list                    # List installed PHP versions
fx php switch <version>        # Switch PHP version
fx php restart                 # Restart PHP-FPM
```

### Backup

```bash
fx backup create <domain>      # Create site backup
fx backup list                 # List backups
fx backup restore <file>       # Restore from backup
```

## Quick Start

After installation, create your first WordPress site:

```bash
fx site create example.com
```

This single command will:
1. Create the NGINX server block
2. Create a MariaDB database
3. Download and configure WordPress
4. Install an SSL certificate
5. Configure FastCGI caching
6. Set up Redis object cache

Then visit `https://example.com/wp-admin` to complete the WordPress setup.

## Project Structure

```
flashxpress/
├── install                        # Main installer script
├── fx                             # fx CLI tool
├── uninstall                      # Uninstaller script
├── conf/
│   ├── nginx/
│   │   ├── fastcgi-cache.conf     # FastCGI cache configuration
│   │   ├── wordpress.conf         # WordPress server block template
│   │   └── fastcgi-params         # Custom FastCGI parameters
│   ├── php/
│   │   └── disabled-functions.ini # PHP security hardening
│   ├── redis/
│   │   └── redis.conf             # Redis WordPress cache config
│   ├── fail2ban/
│   │   └── nginx-limit-req.conf  # Fail2Ban rate limit filter
│   └── ufw/
│       └── applications.ini       # UFW firewall profiles
├── LICENSE                        # MIT License
└── README.md                      # This file
```

## Support

- **Website:** [wp.flashxpress.cloud](https://wp.flashxpress.cloud)
- **Support:** [buymeacoffee.com/wasimb](https://buymeacoffee.com/wasimb)
- **Issues:** [GitHub Issues](https://github.com/wasimakram/flashxpress/issues)

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

<p align="center">
  Made with ❤️ by <strong>Wasim Akram</strong>
</p>
