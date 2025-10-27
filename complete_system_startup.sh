#!/bin/bash

# Complete WhatsApp Order Management System Startup
# This script will guide you through the entire setup process

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
    echo -e "${BLUE}║${WHITE}            WhatsApp Order Management System            ${BLUE}║${NC}"
    echo -e "${BLUE}║${WHITE}                Complete Startup Guide                ${BLUE}║${NC}"
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

# Function to check if services are running
check_services() {
    local erpnext_running=false
    local webhook_running=false
    
    if curl -s http://localhost:8001 >/dev/null 2>&1; then
        erpnext_running=true
    fi
    
    if curl -s http://localhost:5000/health >/dev/null 2>&1; then
        webhook_running=true
    fi
    
    echo "$erpnext_running $webhook_running"
}

# Function to start basic system
start_basic_system() {
    print_step "1" "Starting Basic System (ERPNext + Webhook)"
    
    # Start the basic system
    if ./start_whatsapp_system.sh start; then
        print_success "Basic system started successfully!"
        return 0
    else
        print_error "Failed to start basic system"
        return 1
    fi
}

# Function to setup WhatsApp integration
setup_whatsapp_integration() {
    print_step "2" "Setting up WhatsApp Business API Integration"
    
    print_info "This will guide you through the Meta WhatsApp Business API setup"
    print_info "You will need:"
    echo "• Meta Developer account"
    echo "• WhatsApp Business API access"
    echo "• Your phone number for testing"
    echo
    
    read -p "Do you want to proceed with WhatsApp integration setup? (y/n): " proceed
    
    if [[ $proceed =~ ^[Yy]$ ]]; then
        if ./setup_whatsapp_integration.sh setup; then
            print_success "WhatsApp integration setup completed!"
            return 0
        else
            print_error "WhatsApp integration setup failed"
            return 1
        fi
    else
        print_warning "Skipping WhatsApp integration setup"
        print_info "You can run it later with: ./setup_whatsapp_integration.sh setup"
        return 0
    fi
}

# Function to show final instructions
show_final_instructions() {
    print_step "3" "System Ready!"
    
    echo -e "${WHITE}🎉 Your WhatsApp Order Management System is ready!${NC}"
    echo
    
    echo -e "${CYAN}🌐 Access Points:${NC}"
    echo "• ERPNext UI: http://localhost:8001"
    echo "• Webhook Health: http://localhost:5000/health"
    echo "• Webhook URL: http://localhost:5000/webhook"
    echo
    
    echo -e "${CYAN}📱 WhatsApp Commands:${NC}"
    echo "• 'menu' - Show main menu"
    echo "• 'My Orders' - View your orders"
    echo "• 'Status [Order ID]' - Check order status"
    echo "• 'Cancel [Order ID]' - Cancel an order"
    echo "• 'Reorder [Order ID]' - Reorder previous order"
    echo
    
    echo -e "${CYAN}🛠️ Management Commands:${NC}"
    echo "• Check status: ./start_whatsapp_system.sh status"
    echo "• Monitor logs: ./start_whatsapp_system.sh monitor"
    echo "• Test system: ./start_whatsapp_system.sh test"
    echo "• Restart: ./start_whatsapp_system.sh restart"
    echo "• Stop: ./start_whatsapp_system.sh stop"
    echo
    
    echo -e "${CYAN}📊 Monitoring:${NC}"
    echo "• Real-time dashboard: ./monitor_dashboard.sh"
    echo "• Live logs: ./start_whatsapp_system.sh monitor"
    echo "• Recent logs: ./start_whatsapp_system.sh logs"
    echo
    
    echo -e "${CYAN}🔧 WhatsApp Integration:${NC}"
    echo "• Setup: ./setup_whatsapp_integration.sh setup"
    echo "• Test: ./setup_whatsapp_integration.sh test"
    echo "• Status: ./setup_whatsapp_integration.sh status"
    echo "• Restart: ./setup_whatsapp_integration.sh restart"
    echo
    
    echo -e "${YELLOW}📋 Next Steps:${NC}"
    echo "1. Open ERPNext: http://localhost:8001"
    echo "2. Login with: Administrator / admin"
    echo "3. Go to: WhatsApp Order list"
    echo "4. Test WhatsApp bot by sending 'menu' to your number"
    echo "5. Monitor the system with: ./monitor_dashboard.sh"
    echo
    
    echo -e "${GREEN}🎊 Congratulations! Your system is ready to use!${NC}"
}

# Function to show help
show_help() {
    print_header
    
    echo -e "${WHITE}Complete WhatsApp Order Management System Startup${NC}"
    echo
    echo -e "${CYAN}Usage:${NC} $0 [OPTIONS]"
    echo
    echo -e "${CYAN}Options:${NC}"
    echo "  start     - Complete system startup (default)"
    echo "  basic     - Start only basic system (ERPNext + Webhook)"
    echo "  whatsapp  - Setup WhatsApp integration only"
    echo "  status    - Show system status"
    echo "  help      - Show this help message"
    echo
    echo -e "${CYAN}What this script does:${NC}"
    echo "1. Starts ERPNext server on port 8001"
    echo "2. Starts WhatsApp webhook server on port 5000"
    echo "3. Guides you through Meta WhatsApp Business API setup"
    echo "4. Configures webhook URLs and access tokens"
    echo "5. Tests the complete system"
    echo "6. Provides monitoring and management tools"
    echo
    echo -e "${CYAN}Prerequisites:${NC}"
    echo "• Meta WhatsApp Business API account"
    echo "• Your phone number for testing"
    echo "• Internet connection for ngrok"
    echo
    echo -e "${CYAN}Quick Start:${NC}"
    echo "  $0 start    # Complete setup with WhatsApp integration"
    echo "  $0 basic    # Start basic system only"
    echo "  $0 whatsapp # Setup WhatsApp integration only"
}

# Function to show system status
show_system_status() {
    print_header
    
    echo -e "${CYAN}System Status:${NC}"
    echo
    
    # Check basic services
    local services=$(check_services)
    local erpnext_running=$(echo $services | cut -d' ' -f1)
    local webhook_running=$(echo $services | cut -d' ' -f2)
    
    if [ "$erpnext_running" = "true" ]; then
        print_success "ERPNext server is running on port 8001"
    else
        print_error "ERPNext server is not running"
    fi
    
    if [ "$webhook_running" = "true" ]; then
        print_success "Webhook server is running on port 5000"
    else
        print_error "Webhook server is not running"
    fi
    
    # Check WhatsApp integration
    echo
    echo -e "${CYAN}WhatsApp Integration Status:${NC}"
    if ./setup_whatsapp_integration.sh status >/dev/null 2>&1; then
        print_success "WhatsApp integration is configured"
    else
        print_warning "WhatsApp integration not configured"
    fi
    
    # Check ngrok
    if curl -s http://localhost:4040/api/tunnels >/dev/null 2>&1; then
        print_success "ngrok is running"
        local ngrok_url=$(curl -s http://localhost:4040/api/tunnels | grep -o '"public_url":"[^"]*' | grep -o 'https://[^"]*' | head -1)
        echo "ngrok URL: $ngrok_url"
    else
        print_warning "ngrok is not running"
    fi
    
    echo
    echo -e "${CYAN}Quick Actions:${NC}"
    echo "• Start system: $0 start"
    echo "• Setup WhatsApp: $0 whatsapp"
    echo "• Monitor: ./monitor_dashboard.sh"
    echo "• Test: ./start_whatsapp_system.sh test"
}

# Main startup function
complete_startup() {
    print_header
    
    echo -e "${WHITE}Welcome to the WhatsApp Order Management System!${NC}"
    echo
    echo "This script will guide you through the complete setup process:"
    echo "1. Start ERPNext server and webhook server"
    echo "2. Set up Meta WhatsApp Business API integration"
    echo "3. Configure webhook URLs and access tokens"
    echo "4. Test the complete system"
    echo "5. Provide monitoring and management tools"
    echo
    
    read -p "Press Enter to continue..."
    
    # Start basic system
    if start_basic_system; then
        print_success "Basic system started successfully!"
    else
        print_error "Failed to start basic system"
        exit 1
    fi
    
    # Setup WhatsApp integration
    if setup_whatsapp_integration; then
        print_success "WhatsApp integration setup completed!"
    else
        print_warning "WhatsApp integration setup failed or skipped"
    fi
    
    # Show final instructions
    show_final_instructions
}

# Main script logic
case "${1:-start}" in
    start)
        complete_startup
        ;;
    
    basic)
        print_header
        print_info "Starting basic system only..."
        start_basic_system
        ;;
    
    whatsapp)
        print_header
        print_info "Setting up WhatsApp integration only..."
        setup_whatsapp_integration
        ;;
    
    status)
        show_system_status
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













