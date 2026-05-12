#!/bin/bash

# Quick update script for SharkDev Portfolio
# Run this on your VPS when you push changes to GitHub

echo "Updating SharkDev Portfolio..."

cd /var/www/sharkdev

# Pull latest changes
git pull origin main

# Set permissions
chown -R www-data:www-data /var/www/sharkdev
chmod -R 755 /var/www/sharkdev

echo "✓ Website updated successfully!"
echo "Visit: https://sharkdev.cloud"
