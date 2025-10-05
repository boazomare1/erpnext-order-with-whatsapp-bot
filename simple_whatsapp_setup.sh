#!/bin/bash

# Simple WhatsApp Setup Script
# Does exactly what you want: shows webhook URL, waits for verification, gets token, updates and restarts

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${WHITE}                WhatsApp Integration Setup                ${BLUE}║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️ $1${NC}"
}

# Configuration
BENCH_DIR="/home/boaz/my-new-bench"
WEBHOOK_SERVER="$BENCH_DIR/apps/frappe/frappe/custom/doctype/whatsapp_order/whatsapp_webhook_server.py"
PHONE_ID="853129267877967"  # This won't change

# Function to start ngrok and get URL
get_webhook_url() {
    print_info "Starting ngrok to create your webhook URL..."
    
    # Kill any existing ngrok processes
    pkill -f ngrok 2>/dev/null
    sleep 2
    
    # Start ngrok
    nohup ngrok http 5000 > /tmp/ngrok.log 2>&1 &
    
    # Wait for ngrok to start
    sleep 5
    
    # Get the ngrok URL
    NGROK_URL=$(curl -s http://localhost:4040/api/tunnels | grep -o '"public_url":"[^"]*' | grep -o 'https://[^"]*' | head -1)
    
    if [ -z "$NGROK_URL" ]; then
        print_error "Failed to get ngrok URL"
        exit 1
    fi
    
    WEBHOOK_URL="${NGROK_URL}/webhook"
    echo "$WEBHOOK_URL"
}

# Function to update webhook server with new token
update_webhook_token() {
    local token="$1"
    
    print_info "Updating webhook server with your new access token..."
    
    # Update the webhook server file
    sed -i "s/WHATSAPP_TOKEN = \".*\"/WHATSAPP_TOKEN = \"$token\"/" "$WEBHOOK_SERVER"
    
    print_success "Webhook server updated with new access token"
}

# Function to restart webhook server
restart_webhook() {
    print_info "Restarting webhook server..."
    
    # Kill existing webhook processes
    pkill -f whatsapp_webhook_server.py 2>/dev/null
    sleep 2
    
    # Start webhook server
    cd "$BENCH_DIR/apps/frappe/frappe/custom/doctype/whatsapp_order"
    source webhook_env/bin/activate
    nohup python3 whatsapp_webhook_server.py > webhook_debug.log 2>&1 &
    
    # Wait for webhook to start
    sleep 3
    
    # Test webhook
    if curl -s http://localhost:5000/health >/dev/null 2>&1; then
        print_success "Webhook server restarted successfully!"
        return 0
    else
        print_error "Failed to restart webhook server"
        return 1
    fi
}

# Main setup function
setup_whatsapp() {
    print_header
    
    # Step 1: Get webhook URL
    print_info "Step 1: Creating your webhook URL..."
    WEBHOOK_URL=$(get_webhook_url)
    
    print_success "Your webhook URL is ready!"
    echo
    
    # Step 2: Show Meta Dashboard instructions
    print_info "Step 2: Configure Meta Dashboard"
    echo -e "${WHITE}📱 GO TO YOUR META DASHBOARD AND DO THIS:${NC}"
    echo
    echo -e "${YELLOW}1. Go to: https://developers.facebook.com/${NC}"
    echo -e "${YELLOW}2. Select your WhatsApp app${NC}"
    echo -e "${YELLOW}3. Go to WhatsApp > Configuration${NC}"
    echo -e "${YELLOW}4. Set Webhook URL to: ${GREEN}$WEBHOOK_URL${NC}"
    echo -e "${YELLOW}5. Set Verify Token to: ${GREEN}frappe_verify_token${NC}"
    echo -e "${YELLOW}6. Subscribe to 'messages' events${NC}"
    echo -e "${YELLOW}7. Click 'Verify and Save'${NC}"
    echo
    
    read -p "Press Enter when you have successfully verified the webhook in Meta Dashboard..."
    
    # Step 3: Get access token
    print_info "Step 3: Get your access token"
    echo -e "${WHITE}🔑 NOW GET YOUR ACCESS TOKEN:${NC}"
    echo
    echo -e "${YELLOW}1. In Meta Dashboard > WhatsApp > Getting Started${NC}"
    echo -e "${YELLOW}2. Copy your Access Token${NC}"
    echo
    
    read -p "Enter your WhatsApp Access Token: " ACCESS_TOKEN
    
    # Step 4: Update system configuration
    print_info "Step 4: Updating system configuration..."
    update_webhook_token "$ACCESS_TOKEN"
    
    # Step 5: Restart webhook server
    print_info "Step 5: Restarting webhook server..."
    if restart_webhook; then
        print_success "Webhook server restarted successfully!"
    else
        print_error "Failed to restart webhook server"
        exit 1
    fi
    
    # Step 6: Test integration
    print_info "Step 6: Testing WhatsApp integration..."
    if curl -s http://localhost:5000/health >/dev/null 2>&1; then
        print_success "Webhook server is responding"
    else
        print_error "Webhook server is not responding"
        exit 1
    fi
    
    if curl -s http://localhost:8001 >/dev/null 2>&1; then
        print_success "ERPNext server is responding"
    else
        print_error "ERPNext server is not responding"
        exit 1
    fi
    
    print_success "🎉 WhatsApp Integration Setup Complete!"
    echo
    echo -e "${WHITE}📱 What you can do now:${NC}"
    echo "• Send 'menu' to your WhatsApp number"
    echo "• Follow the ordering flow"
    echo "• Check orders in ERPNext: http://localhost:8001"
    echo "• Monitor logs: tail -f $BENCH_DIR/apps/frappe/frappe/custom/doctype/whatsapp_order/webhook_debug.log"
    echo
    echo -e "${WHITE}📱 Available WhatsApp commands:${NC}"
    echo "• 'menu' - Show main menu"
    echo "• 'My Orders' - View your orders"
    echo "• 'Status [Order ID]' - Check order status"
    echo "• 'Cancel [Order ID]' - Cancel an order"
    echo
    echo -e "${YELLOW}⚠️ Keep this terminal open to maintain the ngrok tunnel!${NC}"
    echo -e "${YELLOW}⚠️ Press Ctrl+C to stop the setup and ngrok${NC}"
    
    # Keep the script running to maintain ngrok
    print_info "Maintaining ngrok tunnel... Press Ctrl+C to stop"
    while true; do
        sleep 10
        if ! curl -s http://localhost:4040/api/tunnels >/dev/null 2>&1; then
            print_error "ngrok tunnel lost. Restarting..."
            get_webhook_url
        fi
    done
}

# Run the setup
setup_whatsapp
