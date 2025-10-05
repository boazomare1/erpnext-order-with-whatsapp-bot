#!/bin/bash

# WhatsApp Business API Integration Setup Script
# Interactive setup for Meta WhatsApp Business API

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# Configuration files
BENCH_DIR="/home/boaz/my-new-bench"
SITE_CONFIG="$BENCH_DIR/sites/testsite2.localhost/site_config.json"
WEBHOOK_SERVER="$BENCH_DIR/apps/frappe/frappe/custom/doctype/whatsapp_order/whatsapp_webhook_server.py"

print_header() {
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${WHITE}                WhatsApp Business API Setup                ${BLUE}║${NC}"
    echo -e "${BLUE}║${WHITE}              Interactive Configuration Guide              ${BLUE}║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo
}

print_step() {
    echo -e "${CYAN}Step $1:${NC} $2"
    echo
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️ $1${NC}"
}

# Function to check if ngrok is installed
check_ngrok() {
    if command -v ngrok &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# Function to install ngrok
install_ngrok() {
    print_info "Installing ngrok..."
    if command -v snap &> /dev/null; then
        sudo snap install ngrok
    else
        print_error "Snap not available. Please install ngrok manually:"
        echo "1. Go to https://ngrok.com/download"
        echo "2. Download and install ngrok"
        echo "3. Add ngrok to your PATH"
        return 1
    fi
}

# Function to start ngrok and get URL
start_ngrok() {
    print_info "Starting ngrok to expose your webhook..."
    print_warning "This will open ngrok in the background. Keep this terminal open!"
    
    # Kill any existing ngrok processes
    pkill -f ngrok 2>/dev/null
    
    # Start ngrok
    nohup ngrok http 5000 > /tmp/ngrok.log 2>&1 &
    NGROK_PID=$!
    
    # Wait for ngrok to start
    print_info "Waiting for ngrok to start..."
    sleep 5
    
    # Get the ngrok URL
    NGROK_URL=$(curl -s http://localhost:4040/api/tunnels | grep -o '"public_url":"[^"]*' | grep -o 'https://[^"]*' | head -1)
    
    if [ -z "$NGROK_URL" ]; then
        print_error "Failed to get ngrok URL. Please check if ngrok is running."
        return 1
    fi
    
    print_success "ngrok is running!"
    print_info "Your webhook URL: ${NGROK_URL}/webhook"
    echo "$NGROK_URL"
}

# Function to get user input
get_input() {
    local prompt="$1"
    local var_name="$2"
    local default="$3"
    
    if [ ! -z "$default" ]; then
        read -p "$prompt [$default]: " input
        if [ -z "$input" ]; then
            input="$default"
        fi
    else
        read -p "$prompt: " input
    fi
    
    eval "$var_name='$input'"
}

# Function to wait for user confirmation
wait_for_user() {
    local message="$1"
    echo -e "${YELLOW}$message${NC}"
    read -p "Press Enter when you have completed this step..."
}

# Function to update webhook server with new token
update_webhook_token() {
    local token="$1"
    local phone_id="$2"
    
    print_info "Updating webhook server with new credentials..."
    
    # Update the webhook server file
    sed -i "s/WHATSAPP_TOKEN = \".*\"/WHATSAPP_TOKEN = \"$token\"/" "$WEBHOOK_SERVER"
    sed -i "s/WHATSAPP_PHONE_ID = \".*\"/WHATSAPP_PHONE_ID = \"$phone_id\"/" "$WEBHOOK_SERVER"
    
    print_success "Webhook server updated with new credentials"
}

# Function to restart webhook server
restart_webhook() {
    print_info "Restarting webhook server with new configuration..."
    
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

# Function to test WhatsApp integration
test_whatsapp() {
    print_info "Testing WhatsApp integration..."
    
    # Test webhook health
    if curl -s http://localhost:5000/health >/dev/null 2>&1; then
        print_success "Webhook server is responding"
    else
        print_error "Webhook server is not responding"
        return 1
    fi
    
    # Test ERPNext API
    if curl -s http://localhost:8001 >/dev/null 2>&1; then
        print_success "ERPNext server is responding"
    else
        print_error "ERPNext server is not responding"
        return 1
    fi
    
    print_success "WhatsApp integration is ready!"
    print_info "You can now send 'menu' to your WhatsApp number to test the bot"
}

# Main setup function
setup_whatsapp() {
    print_header
    
    print_step "1" "Starting ngrok to get your callback URL"
    
    # Check if ngrok is installed
    if ! check_ngrok; then
        print_warning "ngrok is not installed. Installing now..."
        if ! install_ngrok; then
            print_error "Failed to install ngrok. Please install it manually and run this script again."
            exit 1
        fi
    fi
    
    # Start ngrok and get URL
    print_info "Starting ngrok to expose your webhook..."
    NGROK_URL=$(start_ngrok)
    
    if [ -z "$NGROK_URL" ]; then
        print_error "Failed to start ngrok. Please check your ngrok installation."
        exit 1
    fi
    
    WEBHOOK_URL="${NGROK_URL}/webhook"
    print_success "Your webhook URL is: $WEBHOOK_URL"
    
    print_step "2" "Meta Dashboard Configuration"
    echo -e "${WHITE}📱 NOW GO TO YOUR META DASHBOARD AND DO THIS:${NC}"
    echo
    echo -e "${YELLOW}1. Go to: https://developers.facebook.com/${NC}"
    echo -e "${YELLOW}2. Select your WhatsApp app${NC}"
    echo -e "${YELLOW}3. Go to WhatsApp > Configuration${NC}"
    echo -e "${YELLOW}4. Set Webhook URL to: ${GREEN}$WEBHOOK_URL${NC}"
    echo -e "${YELLOW}5. Set Verify Token to: ${GREEN}frappe_verify_token${NC}"
    echo -e "${YELLOW}6. Subscribe to 'messages' events${NC}"
    echo -e "${YELLOW}7. Click 'Verify and Save'${NC}"
    echo
    
    wait_for_user "Press Enter when you have configured the webhook in Meta Dashboard"
    
    print_step "3" "Add Your Phone as Tester"
    echo -e "${WHITE}📱 NOW ADD YOUR PHONE AS A TESTER:${NC}"
    echo
    echo -e "${YELLOW}1. In Meta Dashboard > WhatsApp > Getting Started${NC}"
    echo -e "${YELLOW}2. Add your phone number as a tester${NC}"
    echo -e "${YELLOW}3. Accept the invitation on your WhatsApp${NC}"
    echo
    
    wait_for_user "Press Enter when you have added your phone as a tester"
    
    print_step "4" "Get Your Access Token"
    echo -e "${WHITE}🔑 NOW GET YOUR ACCESS TOKEN:${NC}"
    echo
    echo -e "${YELLOW}1. In Meta Dashboard > WhatsApp > Getting Started${NC}"
    echo -e "${YELLOW}2. Copy your Access Token${NC}"
    echo -e "${YELLOW}3. Copy your Phone Number ID${NC}"
    echo
    
    # Get access token
    get_input "Enter your WhatsApp Access Token" ACCESS_TOKEN
    
    # Get phone number ID
    get_input "Enter your WhatsApp Phone Number ID" PHONE_ID
    
    print_step "5" "Updating System Configuration"
    print_info "Updating webhook server with your new credentials..."
    
    # Update webhook server with new credentials
    update_webhook_token "$ACCESS_TOKEN" "$PHONE_ID"
    
    # Restart webhook server
    if restart_webhook; then
        print_success "Webhook server restarted with new configuration"
    else
        print_error "Failed to restart webhook server"
        exit 1
    fi
    
    print_step "6" "Testing WhatsApp Integration"
    print_info "Testing the complete integration..."
    
    # Test the integration
    if test_whatsapp; then
        print_success "WhatsApp integration is working!"
    else
        print_error "WhatsApp integration test failed"
        exit 1
    fi
    
    print_step "7" "Starting Interaction Logging"
    print_info "Starting interaction logging..."
    print_info "All interactions will be logged to: $BENCH_DIR/apps/frappe/frappe/custom/doctype/whatsapp_order/webhook_debug.log"
    
    echo
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
            start_ngrok
        fi
    done
}

# Function to show help
show_help() {
    echo -e "${WHITE}WhatsApp Business API Integration Setup${NC}"
    echo
    echo -e "${CYAN}Usage:${NC} $0 [OPTIONS]"
    echo
    echo -e "${CYAN}Options:${NC}"
    echo "  setup     - Run the interactive setup (default)"
    echo "  test      - Test existing configuration"
    echo "  restart   - Restart webhook server"
    echo "  status    - Show current configuration"
    echo "  help      - Show this help message"
    echo
    echo -e "${CYAN}Prerequisites:${NC}"
    echo "• Meta WhatsApp Business API account"
    echo "• ngrok installed (will be installed automatically)"
    echo "• ERPNext server running on port 8001"
    echo "• Webhook server running on port 5000"
}

# Function to show current status
show_status() {
    print_header
    
    echo -e "${CYAN}Current Configuration:${NC}"
    echo
    
    # Check webhook server
    if [ -f "$WEBHOOK_SERVER" ]; then
        TOKEN=$(grep "WHATSAPP_TOKEN" "$WEBHOOK_SERVER" | cut -d'"' -f2)
        PHONE_ID=$(grep "WHATSAPP_PHONE_ID" "$WEBHOOK_SERVER" | cut -d'"' -f2)
        
        echo "WhatsApp Token: ${TOKEN:0:20}..."
        echo "Phone ID: $PHONE_ID"
    else
        echo "Webhook server file not found"
    fi
    
    echo
    
    # Check services
    echo -e "${CYAN}Service Status:${NC}"
    
    if curl -s http://localhost:8001 >/dev/null 2>&1; then
        print_success "ERPNext server is running"
    else
        print_error "ERPNext server is not running"
    fi
    
    if curl -s http://localhost:5000/health >/dev/null 2>&1; then
        print_success "Webhook server is running"
    else
        print_error "Webhook server is not running"
    fi
    
    if curl -s http://localhost:4040/api/tunnels >/dev/null 2>&1; then
        print_success "ngrok is running"
        NGROK_URL=$(curl -s http://localhost:4040/api/tunnels | grep -o '"public_url":"[^"]*' | grep -o 'https://[^"]*' | head -1)
        echo "ngrok URL: $NGROK_URL"
    else
        print_warning "ngrok is not running"
    fi
}

# Main script logic
case "${1:-setup}" in
    setup)
        setup_whatsapp
        ;;
    
    test)
        test_whatsapp
        ;;
    
    restart)
        restart_webhook
        ;;
    
    status)
        show_status
        ;;
    
    help|--help|-h)
        show_help
        ;;
    
    *)
        echo -e "${RED}Unknown option: $1${NC}"
        show_help
        exit 1
        ;;
esac


