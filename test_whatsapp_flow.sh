#!/bin/bash

# Test script to show the WhatsApp integration flow
# This demonstrates what the setup script will do for you

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

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

# Simulate the WhatsApp integration flow
simulate_whatsapp_flow() {
    print_header
    
    print_step "1" "Meta WhatsApp Business API Setup"
    echo -e "${WHITE}The script will guide you through:${NC}"
    echo "1. Go to https://developers.facebook.com/"
    echo "2. Create a new app and add WhatsApp Business API"
    echo "3. Go to WhatsApp > Getting Started"
    echo "4. Copy your Access Token and Phone Number ID"
    echo
    
    print_info "The script will ask you for:"
    echo "• WhatsApp Access Token (from Meta Dashboard)"
    echo "• WhatsApp Phone Number ID (from Meta Dashboard)"
    echo "• Webhook Verify Token (default: frappe_verify_token)"
    echo
    
    print_step "2" "ngrok Setup for Webhook URL"
    print_info "The script will:"
    echo "• Check if ngrok is installed (install if needed)"
    echo "• Start ngrok to expose your webhook on port 5000"
    echo "• Generate a new callback URL like: https://abc123.ngrok.io/webhook"
    echo "• Keep ngrok running in the background"
    echo
    
    print_step "3" "Meta Webhook Configuration"
    print_info "The script will show you:"
    echo "1. Your new webhook URL: https://abc123.ngrok.io/webhook"
    echo "2. Go to your Meta app > WhatsApp > Configuration"
    echo "3. Set Webhook URL to: https://abc123.ngrok.io/webhook"
    echo "4. Set Verify Token to: frappe_verify_token"
    echo "5. Subscribe to 'messages' events"
    echo "6. Click 'Verify and Save'"
    echo
    
    print_step "4" "Add Your Phone as Tester"
    print_info "The script will guide you to:"
    echo "1. In Meta Dashboard > WhatsApp > Getting Started"
    echo "2. Add your phone number as a tester"
    echo "3. Accept the invitation on your WhatsApp"
    echo
    
    print_step "5" "Update System Configuration"
    print_info "The script will automatically:"
    echo "• Update webhook server with your new access token"
    echo "• Update webhook server with your phone number ID"
    echo "• Restart webhook server with new configuration"
    echo "• Test the webhook connectivity"
    echo
    
    print_step "6" "Test WhatsApp Integration"
    print_info "The script will:"
    echo "• Test webhook server health"
    echo "• Test ERPNext API connectivity"
    echo "• Verify WhatsApp integration is working"
    echo "• Start logging all WhatsApp interactions"
    echo
    
    print_step "7" "Start Logging Interactions"
    print_info "After setup, you can:"
    echo "• Send 'menu' to your WhatsApp number"
    echo "• Follow the ordering flow"
    echo "• All interactions will be logged"
    echo "• Monitor logs in real-time"
    echo
    
    print_success "🎉 WhatsApp Integration Setup Complete!"
    echo
    echo -e "${WHITE}What you can do after setup:${NC}"
    echo "• Send 'menu' to your WhatsApp number"
    echo "• Follow the ordering flow"
    echo "• Check orders in ERPNext: http://localhost:8001"
    echo "• Monitor logs: tail -f webhook_debug.log"
    echo
    echo -e "${WHITE}Available WhatsApp commands:${NC}"
    echo "• 'menu' - Show main menu"
    echo "• 'My Orders' - View your orders"
    echo "• 'Status [Order ID]' - Check order status"
    echo "• 'Cancel [Order ID]' - Cancel an order"
    echo
    echo -e "${YELLOW}The script will keep ngrok running to maintain the callback URL${NC}"
    echo -e "${YELLOW}Press Ctrl+C to stop the setup and ngrok${NC}"
}

# Main execution
simulate_whatsapp_flow











