#!/bin/bash

# Simple script that shows webhook URL and waits for access token

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
WHITE='\033[1;37m'
NC='\033[0m'

# Configuration
BENCH_DIR="/home/boaz/my-new-bench"
WEBHOOK_SERVER="$BENCH_DIR/apps/frappe/frappe/custom/doctype/whatsapp_order/whatsapp_webhook_server.py"
PHONE_ID="853129267877967"

# Function to start ngrok and get URL
get_webhook_url() {
    echo -e "${BLUE}ℹ️ Starting ngrok to create your webhook URL...${NC}"
    
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
        echo -e "${RED}❌ Failed to get ngrok URL${NC}"
        exit 1
    fi
    
    WEBHOOK_URL="${NGROK_URL}/webhook"
    echo "$WEBHOOK_URL"
}

# Function to update webhook server with new token
update_webhook_token() {
    local token="$1"
    
    echo -e "${BLUE}ℹ️ Updating webhook server with your new access token...${NC}"
    
    # Update the webhook server file
    sed -i "s/WHATSAPP_TOKEN = \".*\"/WHATSAPP_TOKEN = \"$token\"/" "$WEBHOOK_SERVER"
    
    echo -e "${GREEN}✅ Webhook server updated with new access token${NC}"
}

# Function to restart webhook server
restart_webhook() {
    echo -e "${BLUE}ℹ️ Restarting webhook server...${NC}"
    
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
        echo -e "${GREEN}✅ Webhook server restarted successfully!${NC}"
        return 0
    else
        echo -e "${RED}❌ Failed to restart webhook server${NC}"
        return 1
    fi
}

# Main function
main() {
    echo -e "${WHITE}🚀 WhatsApp Integration Setup${NC}"
    echo
    
    # Step 1: Get webhook URL
    WEBHOOK_URL=$(get_webhook_url)
    
    echo -e "${GREEN}✅ Your webhook URL is ready!${NC}"
    echo
    
    # Step 2: Show Meta Dashboard instructions
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
    echo -e "${WHITE}🔑 NOW GET YOUR ACCESS TOKEN:${NC}"
    echo
    echo -e "${YELLOW}1. In Meta Dashboard > WhatsApp > Getting Started${NC}"
    echo -e "${YELLOW}2. Copy your Access Token${NC}"
    echo
    
    read -p "Enter your WhatsApp Access Token: " ACCESS_TOKEN
    
    # Step 4: Update system configuration
    update_webhook_token "$ACCESS_TOKEN"
    
    # Step 5: Restart webhook server
    if restart_webhook; then
        echo -e "${GREEN}✅ Webhook server restarted successfully!${NC}"
    else
        echo -e "${RED}❌ Failed to restart webhook server${NC}"
        exit 1
    fi
    
    # Step 6: Test integration
    echo -e "${BLUE}ℹ️ Testing WhatsApp integration...${NC}"
    if curl -s http://localhost:5000/health >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Webhook server is responding${NC}"
    else
        echo -e "${RED}❌ Webhook server is not responding${NC}"
        exit 1
    fi
    
    if curl -s http://localhost:8001 >/dev/null 2>&1; then
        echo -e "${GREEN}✅ ERPNext server is responding${NC}"
    else
        echo -e "${RED}❌ ERPNext server is not responding${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}🎉 WhatsApp Integration Setup Complete!${NC}"
    echo
    echo -e "${WHITE}📱 What you can do now:${NC}"
    echo "• Send 'menu' to your WhatsApp number"
    echo "• Follow the ordering flow"
    echo "• Check orders in ERPNext: http://localhost:8001"
    echo "• Monitor logs: tail -f $BENCH_DIR/apps/frappe/frappe/custom/doctype/whatsapp_order/webhook_debug.log"
    echo
    echo -e "${YELLOW}⚠️ Keep this terminal open to maintain the ngrok tunnel!${NC}"
    echo -e "${YELLOW}⚠️ Press Ctrl+C to stop the setup and ngrok${NC}"
    
    # Keep the script running to maintain ngrok
    echo -e "${BLUE}ℹ️ Maintaining ngrok tunnel... Press Ctrl+C to stop${NC}"
    while true; do
        sleep 10
        if ! curl -s http://localhost:4040/api/tunnels >/dev/null 2>&1; then
            echo -e "${RED}❌ ngrok tunnel lost. Restarting...${NC}"
            get_webhook_url
        fi
    done
}

# Run the main function
main
