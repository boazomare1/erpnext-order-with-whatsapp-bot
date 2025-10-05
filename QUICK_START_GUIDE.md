# 🚀 Quick Start Guide - WhatsApp Order Management System

## Current Status ✅
- ✅ ERPNext server is running on port 8001
- ✅ WhatsApp webhook server is running on port 5000
- ✅ ngrok is installed and ready
- ✅ All scripts are tested and working

## What You Need to Do Now

### Option 1: Complete Setup (Recommended)
```bash
cd /home/boaz/my-new-bench
./complete_system_startup.sh start
```
This will:
1. Start the basic system (already running)
2. Guide you through Meta WhatsApp Business API setup
3. Get a new callback URL via ngrok
4. Update your access token
5. Configure everything automatically

### Option 2: WhatsApp Integration Only
```bash
cd /home/boaz/my-new-bench
./setup_whatsapp_integration.sh setup
```
This will:
1. Start ngrok and get a new callback URL
2. Ask for your new access token
3. Update the webhook server configuration
4. Test the integration

## What the Scripts Will Do For You

### 1. Get New Callback URL
- Start ngrok to expose your webhook
- Generate a new URL like: `https://abc123.ngrok.io/webhook`
- Keep ngrok running in the background

### 2. Guide You Through Meta Setup
- Ask for your new WhatsApp Access Token
- Ask for your Phone Number ID
- Show you exactly where to configure the webhook URL in Meta Dashboard

### 3. Update Configuration
- Automatically update the webhook server with your new token
- Restart the webhook server
- Test the connection

### 4. Start Logging
- Begin logging all WhatsApp interactions
- Monitor the system in real-time

## Available Commands

### System Management
```bash
# Complete startup with WhatsApp integration
./complete_system_startup.sh start

# Start basic system only
./complete_system_startup.sh basic

# Setup WhatsApp integration only
./complete_system_startup.sh whatsapp

# Check system status
./complete_system_startup.sh status
```

### WhatsApp Integration
```bash
# Interactive WhatsApp setup
./setup_whatsapp_integration.sh setup

# Test existing configuration
./setup_whatsapp_integration.sh test

# Restart webhook server
./setup_whatsapp_integration.sh restart

# Check WhatsApp status
./setup_whatsapp_integration.sh status
```

### System Monitoring
```bash
# Check system status
./start_whatsapp_system.sh status

# Test system connectivity
./start_whatsapp_system.sh test

# Monitor live logs
./start_whatsapp_system.sh monitor

# Show recent logs
./start_whatsapp_system.sh logs
```

## What Happens During Setup

1. **Script starts ngrok** → Gets new callback URL
2. **Script asks for your access token** → You provide it
3. **Script shows you the Meta Dashboard steps** → You configure webhook
4. **Script updates webhook server** → Restarts with new token
5. **Script tests everything** → Verifies it's working
6. **Script starts logging** → Monitors all interactions

## After Setup

### WhatsApp Commands
- Send `menu` to your WhatsApp number
- Follow the ordering flow
- Use `My Orders` to view your orders
- Use `Status [Order ID]` to check order status

### Monitoring
- **ERPNext UI**: http://localhost:8001
- **Webhook Health**: http://localhost:5000/health
- **Live Logs**: `./start_whatsapp_system.sh monitor`
- **System Status**: `./complete_system_startup.sh status`

## Troubleshooting

### If Something Goes Wrong
```bash
# Check system status
./complete_system_startup.sh status

# Restart everything
./start_whatsapp_system.sh restart

# Test connectivity
./start_whatsapp_system.sh test

# Check logs
./start_whatsapp_system.sh logs
```

### If WhatsApp Integration Fails
```bash
# Restart WhatsApp setup
./setup_whatsapp_integration.sh setup

# Test WhatsApp integration
./setup_whatsapp_integration.sh test

# Check WhatsApp status
./setup_whatsapp_integration.sh status
```

## Ready to Start? 🎯

**Just run this command:**
```bash
cd /home/boaz/my-new-bench
./complete_system_startup.sh start
```

The script will guide you through everything step by step, including:
- Getting a new callback URL
- Updating your access token
- Configuring Meta Dashboard
- Testing the complete system
- Starting interaction logging

**Ready? Let's go! 🚀**