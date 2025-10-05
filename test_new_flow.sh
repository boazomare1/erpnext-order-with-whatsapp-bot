#!/bin/bash

# Test script to show the new automated WhatsApp integration flow

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

# Simulate the new automated flow
simulate_new_flow() {
    print_header
    
    print_step "1" "Starting ngrok to get your callback URL"
    print_info "The script will:"
    echo "• Start ngrok automatically"
    echo "• Get a new callback URL like: https://abc123.ngrok.io/webhook"
    echo "• Show you the exact URL to use"
    echo
    
    print_step "2" "Meta Dashboard Configuration"
    echo -e "${WHITE}📱 THE SCRIPT WILL TELL YOU EXACTLY WHAT TO DO:${NC}"
    echo
    echo -e "${YELLOW}1. Go to: https://developers.facebook.com/${NC}"
    echo -e "${YELLOW}2. Select your WhatsApp app${NC}"
    echo -e "${YELLOW}3. Go to WhatsApp > Configuration${NC}"
    echo -e "${YELLOW}4. Set Webhook URL to: ${GREEN}https://abc123.ngrok.io/webhook${NC}"
    echo -e "${YELLOW}5. Set Verify Token to: ${GREEN}frappe_verify_token${NC}"
    echo -e "${YELLOW}6. Subscribe to 'messages' events${NC}"
    echo -e "${YELLOW}7. Click 'Verify and Save'${NC}"
    echo
    print_info "The script will wait for you to press Enter when done"
    echo
    
    print_step "3" "Add Your Phone as Tester"
    echo -e "${WHITE}📱 THE SCRIPT WILL TELL YOU EXACTLY WHAT TO DO:${NC}"
    echo
    echo -e "${YELLOW}1. In Meta Dashboard > WhatsApp > Getting Started${NC}"
    echo -e "${YELLOW}2. Add your phone number as a tester${NC}"
    echo -e "${YELLOW}3. Accept the invitation on your WhatsApp${NC}"
    echo
    print_info "The script will wait for you to press Enter when done"
    echo
    
    print_step "4" "Get Your Access Token"
    echo -e "${WHITE}🔑 THE SCRIPT WILL ASK YOU FOR:${NC}"
    echo
    echo -e "${YELLOW}1. In Meta Dashboard > WhatsApp > Getting Started${NC}"
    echo -e "${YELLOW}2. Copy your Access Token${NC}"
    echo -e "${YELLOW}3. Copy your Phone Number ID${NC}"
    echo
    print_info "The script will prompt you to enter these values"
    echo
    
    print_step "5" "Updating System Configuration"
    print_info "The script will automatically:"
    echo "• Update webhook server with your new access token"
    echo "• Update webhook server with your phone number ID"
    echo "• Restart webhook server with new configuration"
    echo "• Test the webhook connectivity"
    echo
    
    print_step "6" "Testing WhatsApp Integration"
    print_info "The script will automatically:"
    echo "• Test webhook server health"
    echo "• Test ERPNext API connectivity"
    echo "• Verify WhatsApp integration is working"
    echo "• Start logging all WhatsApp interactions"
    echo
    
    print_step "7" "Starting Interaction Logging"
    print_info "After setup, you can:"
    echo "• Send 'menu' to your WhatsApp number"
    echo "• Follow the ordering flow"
    echo "• All interactions will be logged"
    echo "• Monitor logs in real-time"
    echo
    
    print_success "🎉 WhatsApp Integration Setup Complete!"
    echo
    echo -e "${WHITE}📱 What you can do after setup:${NC}"
    echo "• Send 'menu' to your WhatsApp number"
    echo "• Follow the ordering flow"
    echo "• Check orders in ERPNext: http://localhost:8001"
    echo "• Monitor logs: tail -f webhook_debug.log"
    echo
    echo -e "${WHITE}📱 Available WhatsApp commands:${NC}"
    echo "• 'menu' - Show main menu"
    echo "• 'My Orders' - View your orders"
    echo "• 'Status [Order ID]' - Check order status"
    echo "• 'Cancel [Order ID]' - Cancel an order"
    echo
    echo -e "${YELLOW}⚠️ The script will keep ngrok running to maintain the callback URL${NC}"
    echo -e "${YELLOW}⚠️ Press Ctrl+C to stop the setup and ngrok${NC}"
}

# Main execution
simulate_new_flow
