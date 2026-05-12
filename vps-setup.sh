#!/bin/bash

# SharkDev Portfolio - Automated VPS Setup Script
# Run this script on your VPS: bash vps-setup.sh

set -e  # Exit on any error

echo "=========================================="
echo "SharkDev Portfolio - VPS Setup"
echo "=========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
DOMAIN="sharkdev.cloud"
REPO_URL="https://github.com/SharkDevSol/sharkdev.git"
WEB_DIR="/var/www/sharkdev"

echo -e "${YELLOW}Step 1: Updating system...${NC}"
apt update && apt upgrade -y

echo -e "${GREEN}✓ System updated${NC}"
echo ""

echo -e "${YELLOW}Step 2: Installing Nginx (if not already installed)...${NC}"
if ! command -v nginx &> /dev/null; then
    apt install nginx -y
    systemctl start nginx
    systemctl enable nginx
    echo -e "${GREEN}✓ Nginx installed${NC}"
else
    echo -e "${GREEN}✓ Nginx already installed${NC}"
fi
echo ""

echo -e "${YELLOW}Step 3: Installing Git (if not already installed)...${NC}"
if ! command -v git &> /dev/null; then
    apt install git -y
    echo -e "${GREEN}✓ Git installed${NC}"
else
    echo -e "${GREEN}✓ Git already installed${NC}"
fi
echo ""

echo -e "${YELLOW}Step 4: Installing Certbot for SSL (if not already installed)...${NC}"
if ! command -v certbot &> /dev/null; then
    apt install certbot python3-certbot-nginx -y
    echo -e "${GREEN}✓ Certbot installed${NC}"
else
    echo -e "${GREEN}✓ Certbot already installed${NC}"
fi
echo ""

echo -e "${YELLOW}Step 5: Cloning website from GitHub...${NC}"
cd /var/www

# Remove directory if it exists
if [ -d "$WEB_DIR" ]; then
    echo "Removing existing directory..."
    rm -rf "$WEB_DIR"
fi

git clone "$REPO_URL" sharkdev
chown -R www-data:www-data "$WEB_DIR"
chmod -R 755 "$WEB_DIR"

echo -e "${GREEN}✓ Website cloned${NC}"
echo ""

echo -e "${YELLOW}Step 6: Configuring Nginx...${NC}"

# Create Nginx configuration
cat > /etc/nginx/sites-available/$DOMAIN << 'EOF'
server {
    listen 80;
    listen [::]:80;
    
    server_name sharkdev.cloud www.sharkdev.cloud;
    
    root /var/www/sharkdev;
    index index.html;
    
    location / {
        try_files $uri $uri/ =404;
    }
    
    # Cache static assets
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
    
    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml+rss application/javascript application/json image/svg+xml;
}
EOF

# Enable site
ln -sf /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/

# DON'T remove default site if other projects exist
# Only remove if user confirms
if [ -f /etc/nginx/sites-enabled/default ]; then
    echo ""
    echo -e "${YELLOW}Note: Default Nginx site detected.${NC}"
    echo "If you have other projects, keep it. Otherwise, you can remove it."
    read -p "Remove default site? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -f /etc/nginx/sites-enabled/default
        echo "Default site removed"
    else
        echo "Default site kept"
    fi
fi

# Test configuration
nginx -t

# Restart Nginx
systemctl restart nginx

echo -e "${GREEN}✓ Nginx configured${NC}"
echo ""

echo -e "${YELLOW}Step 7: Configuring firewall...${NC}"

# Check if UFW is already enabled
if ufw status | grep -q "Status: active"; then
    echo "Firewall already active, adding rules..."
    ufw allow 'Nginx Full'
    ufw allow OpenSSH
    echo -e "${GREEN}✓ Firewall rules added${NC}"
else
    echo "Enabling firewall..."
    ufw allow 'Nginx Full'
    ufw allow OpenSSH
    echo "y" | ufw enable
    echo -e "${GREEN}✓ Firewall configured${NC}"
fi
echo ""

echo -e "${YELLOW}Step 8: Setting up SSL certificate...${NC}"
echo ""
echo "IMPORTANT: Make sure your DNS is pointing to this server before continuing!"
echo "A Record: @ -> 76.13.48.245"
echo "CNAME Record: www -> sharkdev.cloud"
echo ""
read -p "Press Enter when DNS is configured and propagated (or Ctrl+C to skip SSL for now)..."

# Get SSL certificate
certbot --nginx -d $DOMAIN -d www.$DOMAIN --non-interactive --agree-tos --register-unsafely-without-email --redirect

echo -e "${GREEN}✓ SSL certificate installed${NC}"
echo ""

echo "=========================================="
echo -e "${GREEN}✓ Deployment Complete!${NC}"
echo "=========================================="
echo ""
echo "Your website is now live at:"
echo "  https://$DOMAIN"
echo "  https://www.$DOMAIN"
echo ""
echo "To update your website in the future:"
echo "  cd $WEB_DIR"
echo "  git pull origin main"
echo ""
echo "Nginx status: systemctl status nginx"
echo "Nginx logs: tail -f /var/log/nginx/error.log"
echo ""
