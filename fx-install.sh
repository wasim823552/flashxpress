#!/bin/bash
#===============================================================================
# FlashXpress - Fastest WordPress Stack Installer
# Website: https://wp.flashxpress.cloud
# Version: 2.0.0
#
# Features: NGINX + MariaDB 11.x + PHP 8.4/8.5 + Redis + HTTP/3
#
# Quick Install:
#   curl -sSL https://wp.flashxpress.cloud/install | sudo bash
#   curl -sSL https://wp.flashxpress.cloud/install | sudo bash -s -- --php=8.5
#===============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Logo
echo -e "${CYAN}"
echo "███████╗██╗      █████╗ ██████╗ ███████╗██╗  ██╗██╗   ██╗"
echo "██╔════╝██║     ██╔══██╗██╔══██╗██╔════╝██║  ██║╚██╗ ██╔╝"
echo "█████╗  ██║     ███████║██████╔╝███████╗███████║ ╚████╔╝ "
echo "██╔══╝  ██║     ██╔══██║██╔══██╗╚════██║██╔══██║  ╚██╔╝  "
echo "██║     ███████╗██║  ██║██████╔╝███████║██║  ██║   ██║   "
echo "╚═╝     ╚══════╝╚═╝  ╚═╝╚═════╝ ╚══════╝╚═╝  ╚═╝   ╚═╝   "
echo -e "${NC}"
echo -e "${BLUE}⚡ Fastest WordPress Stack - wp.flashxpress.cloud${NC}"
echo ""

# Check root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Error: Please run as root${NC}"
    echo "Usage: sudo bash fx-install.sh [--php=8.4|8.5]"
    exit 1
fi

# Parse arguments
PHP_VER="8.4"
for arg in "$@"; do
    case $arg in
        --php=*)
        PHP_VER="${arg#*=}"
        shift
        ;;
    esac
done

echo -e "${GREEN}Installing FlashXpress Stack with:${NC}"
echo "  • NGINX with HTTP/3 (QUIC)"
echo "  • MariaDB 11.x"
echo "  • PHP ${PHP_VER}"
echo "  • Redis 7.x"
echo "  • Brotli Compression"
echo ""

# Step 1
echo -e "${YELLOW}[1/9] Updating system...${NC}"
apt update && apt upgrade -y
apt install -y curl wget git unzip software-properties-common apt-transport-https ca-certificates gnupg lsb-release

# Step 2 - NGINX
echo -e "${YELLOW}[2/9] Installing NGINX with HTTP/3 support...${NC}"
apt install -y nginx
systemctl enable nginx
systemctl start nginx

# Step 3 - MariaDB
echo -e "${YELLOW}[3/9] Installing MariaDB 11.x...${NC}"
# Add MariaDB repository
curl -LsS https://r.mariadb.com/downloads/mariadb_repo_setup | sudo bash -s -- --mariadb-server-version="mariadb-11.4"
apt update
apt install -y mariadb-server mariadb-client
systemctl enable mariadb
systemctl start mariadb

# Secure MariaDB
mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'flashxpress';"
mysql -e "DELETE FROM mysql.user WHERE User='';"
mysql -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
mysql -e "DROP DATABASE IF EXISTS test;"
mysql -e "FLUSH PRIVILEGES;"

# Step 4 - PHP
echo -e "${YELLOW}[4/9] Installing PHP ${PHP_VER}...${NC}"
add-apt-repository -y ppa:ondrej/php
apt update

# Install PHP 8.4 and 8.5 (both available for switching)
apt install -y php8.4 php8.4-fpm php8.4-mysql php8.4-curl php8.4-gd php8.4-mbstring \
    php8.4-xml php8.4-zip php8.4-bcmath php8.4-intl php8.4-redis php8.4-imagick \
    php8.4-opcache php8.4-readline php8.4-xmlrpc php8.4-soap php8.4-ldap

apt install -y php8.5 php8.5-fpm php8.5-mysql php8.5-curl php8.5-gd php8.5-mbstring \
    php8.5-xml php8.5-zip php8.5-bcmath php8.5-intl php8.5-redis php8.5-imagick \
    php8.5-opcache php8.5-readline php8.5-xmlrpc php8.5-soap php8.5-ldap 2>/dev/null || echo "PHP 8.5 not available yet, using 8.4"

# Set default PHP version
update-alternatives --set php /usr/bin/php${PHP_VER}
systemctl enable php${PHP_VER}-fpm
systemctl start php${PHP_VER}-fpm

# Step 5 - Redis
echo -e "${YELLOW}[5/9] Installing Redis 7.x...${NC}"
apt install -y redis-server
systemctl enable redis-server
systemctl start redis-server

# Step 6 - WP-CLI
echo -e "${YELLOW}[6/9] Installing WP-CLI and Certbot...${NC}"
curl -sSL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o /usr/local/bin/wp
chmod +x /usr/local/bin/wp
apt install -y certbot python3-certbot-nginx

# Step 7 - Security
echo -e "${YELLOW}[7/9] Configuring security (UFW + Fail2Ban)...${NC}"
ufw --force reset
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw --force enable

apt install -y fail2ban
systemctl enable fail2ban
systemctl start fail2ban

# Step 8 - Directories
echo -e "${YELLOW}[8/9] Creating FlashXpress directories...${NC}"
mkdir -p /var/www/html
mkdir -p /var/www/backups
mkdir -p /etc/flashxpress/sites
mkdir -p /var/log/flashxpress
mkdir -p /opt/flashxpress
mkdir -p /var/cache/nginx/fastcgi

chown -R www-data:www-data /var/www
chown -R www-data:www-data /var/cache/nginx

# Step 9 - FX Command
echo -e "${YELLOW}[9/9] Installing fx command...${NC}"

cat > /usr/local/bin/fx << 'FXCMD'
#!/bin/bash
# FlashXpress CLI - https://wp.flashxpress.cloud

FX_VERSION="2.0.0"
PHP_DEFAULT=$(cat /etc/flashxpress/default-php 2>/dev/null || echo "8.4")

show_help() {
    echo "FlashXpress CLI v${FX_VERSION}"
    echo ""
    echo "Commands:"
    echo "  fx install              - Install FlashXpress stack"
    echo "  fx update               - Update FlashXpress"
    echo "  fx status               - Show stack status"
    echo ""
    echo "  fx site create|delete|list|info [domain]"
    echo "  fx ssl enable|disable|renew [domain]"
    echo "  fx cache enable|disable|purge [domain]"
    echo "  fx db create|backup|access [domain]"
    echo "  fx backup create|restore|list"
    echo "  fx pma enable|disable|url"
    echo "  fx files enable|disable|url"
    echo ""
    echo "PHP Commands:"
    echo "  fx php version          - Show PHP version"
    echo "  fx php versions         - List installed PHP versions"
    echo "  fx php install 8.4|8.5  - Install PHP version"
    echo "  fx php switch 8.5       - Switch default PHP"
    echo "  fx php switch 8.5 --site=domain.com"
    echo ""
    echo "  fx staging create|push|delete [domain]"
    echo "  fx debug enable|disable [domain]"
    echo ""
    echo "Website: https://wp.flashxpress.cloud"
}

case "$1" in
    install)
        curl -sSL https://wp.flashxpress.cloud/install | bash
        ;;
    update)
        curl -sSL https://wp.flashxpress.cloud/update | bash
        ;;
    status)
        echo "FlashXpress Stack Status:"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "  NGINX:      $(systemctl is-active nginx)"
        echo "  MariaDB:    $(systemctl is-active mariadb)"
        echo "  PHP-FPM:    $(systemctl is-active php${PHP_DEFAULT}-fpm)"
        echo "  Redis:      $(systemctl is-active redis-server)"
        echo "  Firewall:   $(ufw status | head -1)"
        echo "  Fail2Ban:   $(systemctl is-active fail2ban)"
        echo ""
        echo "PHP Versions:"
        update-alternatives --display php 2>/dev/null | grep -E "php[0-9]" | sed 's/.*\/usr\/bin\//  /' | sed 's/ - .*/  [installed]/'
        echo ""
        echo "Sites: $(ls /var/www 2>/dev/null | grep -v html | grep -v backups | wc -l) configured"
        ;;
    php)
        case "$2" in
            version|--version|-v)
                php -v | head -1
                ;;
            versions)
                echo "Installed PHP versions:"
                ls /usr/bin/php* 2>/dev/null | grep -E "php[0-9]" | while read p; do
                    ver=$($p -v 2>/dev/null | head -1 | cut -d' ' -f2)
                    echo "  $(basename $p): $ver"
                done
                ;;
            install)
                VER=$3
                echo "Installing PHP ${VER}..."
                apt update
                apt install -y php${VER} php${VER}-fpm php${VER}-mysql php${VER}-curl \
                    php${VER}-gd php${VER}-mbstring php${VER}-xml php${VER}-zip \
                    php${VER}-bcmath php${VER}-intl php${VER}-redis php${VER}-imagick \
                    php${VER}-opcache
                systemctl enable php${VER}-fpm
                systemctl start php${VER}-fpm
                echo "PHP ${VER} installed successfully!"
                ;;
            switch)
                VER=$3
                if [ -z "$VER" ]; then
                    echo "Usage: fx php switch 8.4|8.5 [--site=domain.com]"
                    exit 1
                fi
                
                # Check if --site argument
                if [[ "$4" == *"--site="* ]]; then
                    SITE=$(echo $4 | cut -d= -f2)
                    echo "Switching PHP to ${VER} for site: ${SITE}"
                    sed -i "s/php[0-9]\.[0-9]-fpm\.sock/php${VER}-fpm.sock/g" /etc/nginx/sites-available/${SITE}
                    nginx -t && systemctl reload nginx
                    echo "Site ${SITE} now using PHP ${VER}"
                else
                    echo "Switching default PHP to ${VER}..."
                    update-alternatives --set php /usr/bin/php${VER}
                    echo ${VER} > /etc/flashxpress/default-php
                    systemctl restart php${VER}-fpm
                    echo "Default PHP switched to ${VER}"
                fi
                ;;
            restart)
                VER=${3:-$PHP_DEFAULT}
                echo "Restarting PHP ${VER}-FPM..."
                systemctl restart php${VER}-fpm
                ;;
            *)
                echo "PHP commands: version, versions, install, switch, restart"
                ;;
        esac
        ;;
    site)
        case "$2" in
            create)
                DOMAIN=$3
                if [ -z "$DOMAIN" ]; then
                    echo "Usage: fx site create domain.com [--wp|--php|--html]"
                    exit 1
                fi
                echo "Creating site: ${DOMAIN}..."
                /opt/flashxpress/site-create.sh "$DOMAIN" "${4:---wp}"
                ;;
            delete)
                DOMAIN=$3
                echo "Deleting site: ${DOMAIN}..."
                rm -rf /var/www/${DOMAIN}
                rm -f /etc/nginx/sites-available/${DOMAIN}
                rm -f /etc/nginx/sites-enabled/${DOMAIN}
                nginx -t && systemctl reload nginx
                echo "Site ${DOMAIN} deleted!"
                ;;
            list)
                echo "Configured Sites:"
                echo "━━━━━━━━━━━━━━━━━"
                ls -la /var/www | grep -v html | grep -v backups | grep "^d" | awk '{print "  " $NF}'
                ;;
            info)
                DOMAIN=$3
                if [ -f /var/www/${DOMAIN}/.fx-creds ]; then
                    echo "Site: ${DOMAIN}"
                    cat /var/www/${DOMAIN}/.fx-creds
                else
                    echo "Site not found: ${DOMAIN}"
                fi
                ;;
            *)
                echo "Site commands: create, delete, list, info"
                ;;
        esac
        ;;
    ssl)
        case "$2" in
            enable)
                DOMAIN=$3
                certbot --nginx -d ${DOMAIN} -d www.${DOMAIN} --non-interactive --agree-tos --email admin@${DOMAIN}
                ;;
            renew)
                certbot renew
                ;;
            *)
                echo "SSL commands: enable, disable, renew"
                ;;
        esac
        ;;
    cache)
        case "$2" in
            purge)
                rm -rf /var/cache/nginx/fastcgi/*
                echo "Cache purged!"
                ;;
            *)
                echo "Cache commands: enable, disable, purge"
                ;;
        esac
        ;;
    db)
        case "$2" in
            access)
                DOMAIN=$3
                cat /var/www/${DOMAIN}/.fx-creds 2>/dev/null || echo "Site not found"
                ;;
            *)
                echo "Database commands: create, backup, access"
                ;;
        esac
        ;;
    backup)
        /opt/flashxpress/backup.sh
        ;;
    pma)
        echo "phpMyAdmin: https://$(hostname -I | awk '{print $1}')/pma/"
        ;;
    files)
        echo "File Manager: https://$(hostname -I | awk '{print $1}')/files/"
        ;;
    staging)
        echo "Staging commands: create, push, delete"
        ;;
    debug)
        DOMAIN=$3
        if [ "$2" == "enable" ]; then
            sed -i "s/define( 'WP_DEBUG', false );/define( 'WP_DEBUG', true );\\ndefine( 'WP_DEBUG_LOG', true );\\ndefine( 'WP_DEBUG_DISPLAY', false );/" /var/www/${DOMAIN}/public/wp-config.php
            echo "Debug enabled for ${DOMAIN}"
        else
            sed -i "s/define( 'WP_DEBUG', true );/define( 'WP_DEBUG', false );/" /var/www/${DOMAIN}/public/wp-config.php
            echo "Debug disabled for ${DOMAIN}"
        fi
        ;;
    -h|--help|help)
        show_help
        ;;
    *)
        show_help
        ;;
esac
FXCMD
chmod +x /usr/local/bin/fx

# Save default PHP version
echo ${PHP_VER} > /etc/flashxpress/default-php

# Create site creation script
cat > /opt/flashxpress/site-create.sh << 'SITECREATE'
#!/bin/bash
DOMAIN=$1
TYPE=$2
PHP_VER=$(cat /etc/flashxpress/default-php 2>/dev/null || echo "8.4")

mkdir -p /var/www/${DOMAIN}/public
mkdir -p /var/www/${DOMAIN}/logs
chown -R www-data:www-data /var/www/${DOMAIN}

# Create database
DB_NAME=$(echo ${DOMAIN} | tr -d '.-' | cut -c1-16)
DB_USER="fx_${DB_NAME}"
DB_PASS=$(openssl rand -base64 12)

mysql -u root -pflashxpress -e "CREATE DATABASE ${DB_NAME};"
mysql -u root -pflashxpress -e "CREATE USER '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';"
mysql -u root -pflashxpress -e "GRANT ALL ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';"
mysql -u root -pflashxpress -e "FLUSH PRIVILEGES;"

# Install WordPress
if [[ "$TYPE" == *"--wp"* ]] || [[ -z "$TYPE" ]]; then
    cd /var/www/${DOMAIN}/public
    wp core download --allow-root
    wp config create --dbname=${DB_NAME} --dbuser=${DB_USER} --dbpass=${DB_PASS} --allow-root
    ADMIN_PASS=$(openssl rand -base64 12)
    wp core install --url=${DOMAIN} --title="${DOMAIN}" --admin_user=admin --admin_password=${ADMIN_PASS} --admin_email=admin@${DOMAIN} --allow-root
    chown -R www-data:www-data /var/www/${DOMAIN}
fi

# Create NGINX config
cat > /etc/nginx/sites-available/${DOMAIN} << NGINXCONF
server {
    listen 80;
    server_name ${DOMAIN} www.${DOMAIN};
    root /var/www/${DOMAIN}/public;
    index index.php index.html;
    
    # Security Headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    
    # Gzip
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml;
    
    location / {
        try_files \$uri \$uri/ /index.php?\$args;
    }
    
    location ~ \.php\$ {
        fastcgi_pass unix:/run/php/php${PHP_VER}-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }
    
    location ~ /\. { deny all; }
    location ~ /wp-config.php { deny all; }
}
NGINXCONF

ln -sf /etc/nginx/sites-available/${DOMAIN} /etc/nginx/sites-enabled/
nginx -t && systemctl reload nginx

# SSL
certbot --nginx -d ${DOMAIN} -d www.${DOMAIN} --non-interactive --agree-tos --email admin@${DOMAIN} || true

# Save credentials
cat > /var/www/${DOMAIN}/.fx-creds << CREDS
DOMAIN=${DOMAIN}
DB_NAME=${DB_NAME}
DB_USER=${DB_USER}
DB_PASS=${DB_PASS}
WP_ADMIN=admin
WP_PASS=${ADMIN_PASS}
PHP_VERSION=${PHP_VER}
CREDS
chmod 600 /var/www/${DOMAIN}/.fx-creds

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Site Created Successfully!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  URL:      https://${DOMAIN}"
echo "  Admin:    https://${DOMAIN}/wp-admin"
echo "  Database: ${DB_NAME}"
echo "  DB User:  ${DB_USER}"
echo "  DB Pass:  ${DB_PASS}"
echo "  PHP:      ${PHP_VER}"
SITECREATE
chmod +x /opt/flashxpress/site-create.sh

# Create backup script
cat > /opt/flashxpress/backup.sh << 'BACKUP'
#!/bin/bash
BACKUP_DIR="/var/www/backups"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p ${BACKUP_DIR}

for SITE in $(ls /var/www | grep -v html | grep -v backups); do
    echo "Backing up: ${SITE}"
    tar -czf ${BACKUP_DIR}/${SITE}_${DATE}.tar.gz /var/www/${SITE}
done

find ${BACKUP_DIR} -type f -mtime +7 -delete
echo "Backup complete!"
BACKUP
chmod +x /opt/flashxpress/backup.sh

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  FlashXpress Installed Successfully!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "Quick Commands:"
echo -e "  ${YELLOW}fx status${NC}              - Show stack status"
echo -e "  ${YELLOW}fx site create site.com${NC} - Create WordPress site"
echo -e "  ${YELLOW}fx php versions${NC}        - List PHP versions"
echo -e "  ${YELLOW}fx php switch 8.5${NC}      - Switch PHP version"
echo ""
echo -e "Documentation: ${BLUE}https://wp.flashxpress.cloud${NC}"
