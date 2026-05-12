# Hosting Multiple Websites on the Same VPS

## How It Works

Your VPS can host **unlimited websites** on the same server. Nginx uses **virtual hosts** (called "server blocks") to route traffic to the correct website based on the domain name.

## Current Setup

```
VPS (76.13.48.245)
├── Your existing project(s)
└── SharkDev Portfolio (sharkdev.cloud) ← NEW
```

## How Nginx Routes Traffic

When someone visits a domain, Nginx checks the domain name and serves the correct website:

```
User visits: sharkdev.cloud
    ↓
Nginx checks domain name
    ↓
Serves files from: /var/www/sharkdev/

User visits: yourotherdomain.com
    ↓
Nginx checks domain name
    ↓
Serves files from: /var/www/yourotherdomain/
```

## File Structure on Your VPS

```
/var/www/
├── sharkdev/              ← Your new portfolio
│   ├── index.html
│   ├── sharkdev-logo.png
│   └── favicon.ico
│
├── your-other-project/    ← Your existing project
│   └── ...
│
└── another-project/       ← Another project (if any)
    └── ...
```

## Nginx Configuration Files

Each website has its own configuration file:

```
/etc/nginx/sites-available/
├── sharkdev.cloud         ← New config for your portfolio
├── yourotherdomain.com    ← Existing project config
└── anotherdomain.com      ← Another project config
```

## What the Script Does (Safe for Existing Projects)

✅ **SAFE - Won't affect other projects:**
- Installs software only if not already installed
- Creates a NEW directory: `/var/www/sharkdev`
- Creates a NEW Nginx config: `/etc/nginx/sites-available/sharkdev.cloud`
- Asks before removing default site
- Only restarts Nginx (all sites reload together, but independently)

❌ **Won't touch:**
- Your existing project files
- Your existing Nginx configurations
- Your existing SSL certificates
- Your existing domains

## Checking Your Existing Projects

Before running the script, you can check what's already on your VPS:

```bash
# Connect to VPS
ssh root@76.13.48.245

# Check existing websites
ls -la /var/www/

# Check existing Nginx configurations
ls -la /etc/nginx/sites-enabled/

# Check which domains have SSL certificates
certbot certificates
```

## After Deployment

All your websites will work independently:

- **sharkdev.cloud** → Your new portfolio
- **yourotherdomain.com** → Your existing project (unchanged)
- **anotherdomain.com** → Another project (unchanged)

## Port Usage

All websites share the same ports:
- **Port 80** (HTTP) - Nginx routes to correct site
- **Port 443** (HTTPS) - Nginx routes to correct site

You don't need different ports for different websites!

## SSL Certificates

Each domain gets its own SSL certificate:

```bash
# Your new portfolio
certbot --nginx -d sharkdev.cloud -d www.sharkdev.cloud

# Your existing projects (already have their own certificates)
# No changes needed
```

## Updating Individual Sites

Each site can be updated independently:

```bash
# Update SharkDev portfolio
cd /var/www/sharkdev
git pull origin main

# Update another project
cd /var/www/your-other-project
git pull origin main
```

## Resource Usage

Multiple websites on one VPS share:
- ✅ CPU
- ✅ RAM
- ✅ Disk space
- ✅ Bandwidth

Your portfolio is a static HTML site (very lightweight), so it will use minimal resources.

## Common Questions

### Q: Will this slow down my other websites?
**A:** No. Static HTML sites like your portfolio use almost no resources. Your existing projects won't be affected.

### Q: Can I use different PHP/Node.js versions for different sites?
**A:** Yes! Each site can have its own configuration and runtime environment.

### Q: What if I want to remove the portfolio later?
**A:** Simply:
```bash
rm -rf /var/www/sharkdev
rm /etc/nginx/sites-enabled/sharkdev.cloud
rm /etc/nginx/sites-available/sharkdev.cloud
systemctl restart nginx
```

### Q: Do I need to configure DNS for each domain?
**A:** Yes, each domain needs its own DNS A record pointing to your VPS IP (76.13.48.245).

## Best Practices

1. **Organize by domain:**
   ```
   /var/www/domain1.com/
   /var/www/domain2.com/
   /var/www/domain3.com/
   ```

2. **Name Nginx configs after domains:**
   ```
   /etc/nginx/sites-available/domain1.com
   /etc/nginx/sites-available/domain2.com
   ```

3. **Keep separate Git repositories** for each project

4. **Monitor resource usage:**
   ```bash
   htop              # CPU and RAM usage
   df -h             # Disk space
   ```

## Summary

✅ **Safe to run** - Won't affect existing projects
✅ **Independent** - Each site works separately  
✅ **Scalable** - Add as many sites as you want
✅ **Efficient** - Share server resources smartly

Your existing projects will continue working exactly as they are now!
