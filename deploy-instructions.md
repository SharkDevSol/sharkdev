# SharkDev Portfolio Deployment Guide

## Prerequisites
- VPS IP: 76.13.48.245
- Domain: sharkdev.cloud
- GitHub Repo: https://github.com/SharkDevSol/sharkdev.git

## Step 1: Connect to Your VPS

```bash
ssh root@76.13.48.245
```

## Step 2: Install Required Software

```bash
# Update system
apt update && apt upgrade -y

# Install Nginx web server
apt install nginx -y

# Install Git
apt install git -y

# Install Certbot for SSL (HTTPS)
apt install certbot python3-certbot-nginx -y
```

## Step 3: Clone Your Website from GitHub

```bash
# Navigate to web directory
cd /var/www

# Clone your repository
git clone https://github.com/SharkDevSol/sharkdev.git

# Set proper permissions
chown -R www-data:www-data /var/www/sharkdev
chmod -R 755 /var/www/sharkdev
```

## Step 4: Configure Nginx for Your Domain

```bash
# Create Nginx configuration file
nano /etc/nginx/sites-available/sharkdev.cloud
```

Paste this configuration:

```nginx
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
```

Save and exit (Ctrl+X, then Y, then Enter)

## Step 5: Enable the Site

```bash
# Create symbolic link to enable site
ln -s /etc/nginx/sites-available/sharkdev.cloud /etc/nginx/sites-enabled/

# Remove default site (optional)
rm /etc/nginx/sites-enabled/default

# Test Nginx configuration
nginx -t

# Restart Nginx
systemctl restart nginx

# Enable Nginx to start on boot
systemctl enable nginx
```

## Step 6: Configure Firewall

```bash
# Allow HTTP and HTTPS traffic
ufw allow 'Nginx Full'
ufw allow OpenSSH
ufw enable
```

## Step 7: Install SSL Certificate (HTTPS)

```bash
# Get free SSL certificate from Let's Encrypt
certbot --nginx -d sharkdev.cloud -d www.sharkdev.cloud
```

Follow the prompts:
- Enter your email address
- Agree to terms of service
- Choose whether to redirect HTTP to HTTPS (recommended: Yes)

## Step 8: Verify DNS Settings

Make sure your domain DNS is configured correctly:

**A Records:**
- Type: A
- Name: @ (or leave blank)
- Value: 76.13.48.245
- TTL: 14400 (or auto)

**CNAME Record:**
- Type: CNAME
- Name: www
- Value: sharkdev.cloud
- TTL: 300

## Step 9: Test Your Website

Visit: https://sharkdev.cloud

Your portfolio should now be live! 🎉

## Future Updates

To update your website after making changes:

```bash
# SSH into VPS
ssh root@76.13.48.245

# Navigate to website directory
cd /var/www/sharkdev

# Pull latest changes from GitHub
git pull origin main

# No need to restart Nginx for static files
```

## Troubleshooting

### Check Nginx Status
```bash
systemctl status nginx
```

### Check Nginx Error Logs
```bash
tail -f /var/log/nginx/error.log
```

### Check SSL Certificate Status
```bash
certbot certificates
```

### Renew SSL Certificate (auto-renewal is enabled by default)
```bash
certbot renew --dry-run
```

### Restart Nginx
```bash
systemctl restart nginx
```

## Security Recommendations

1. **Change SSH Port** (optional but recommended)
2. **Disable Root Login** and create a sudo user
3. **Set up automatic security updates**
4. **Configure fail2ban** to prevent brute force attacks

Would you like me to add these security configurations?
