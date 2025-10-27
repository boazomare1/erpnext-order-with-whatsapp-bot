#!/bin/bash

# WhatsApp Order Management System - Monitoring Dashboard
# Real-time monitoring of system health and activity

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# Configuration
ERP_PORT="8001"
WEBHOOK_PORT="5000"
ADMIN_USER="Administrator"
ADMIN_PASS="admin"

# Function to check port
check_port() {
    local port=$1
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Function to get system status
get_status() {
    local status=""
    
    # Check ERPNext
    if check_port $ERP_PORT; then
        if curl -s http://localhost:$ERP_PORT >/dev/null 2>&1; then
            status+="${GREEN}✅ ERPNext${NC} "
        else
            status+="${YELLOW}⚠️ ERPNext${NC} "
        fi
    else
        status+="${RED}❌ ERPNext${NC} "
    fi
    
    # Check Webhook
    if check_port $WEBHOOK_PORT; then
        if curl -s http://localhost:$WEBHOOK_PORT/health >/dev/null 2>&1; then
            status+="${GREEN}✅ Webhook${NC} "
        else
            status+="${YELLOW}⚠️ Webhook${NC} "
        fi
    else
        status+="${RED}❌ Webhook${NC} "
    fi
    
    echo "$status"
}

# Function to get recent orders count
get_orders_count() {
    local count=0
    if check_port $ERP_PORT; then
        # Try to get orders count via API
        SESSION=$(curl -s -c - -X POST "http://localhost:$ERP_PORT/api/method/login" \
            -d "usr=$ADMIN_USER&pwd=$ADMIN_PASS" 2>/dev/null | grep -o 'sid=[^;]*' | cut -d'=' -f2)
        
        if [ ! -z "$SESSION" ]; then
            count=$(curl -s -b "sid=$SESSION" \
                "http://localhost:$ERP_PORT/api/method/frappe.custom.doctype.whatsapp_order.api.list_orders" \
                2>/dev/null | grep -o '"count":[0-9]*' | cut -d':' -f2)
        fi
    fi
    
    echo "${count:-0}"
}

# Function to get system load
get_system_load() {
    local load=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//')
    echo "$load"
}

# Function to get memory usage
get_memory_usage() {
    local mem=$(free | grep Mem | awk '{printf "%.1f", $3/$2 * 100.0}')
    echo "$mem%"
}

# Function to get disk usage
get_disk_usage() {
    local disk=$(df -h / | awk 'NR==2{print $5}')
    echo "$disk"
}

# Function to get uptime
get_uptime() {
    local uptime=$(uptime -p | sed 's/up //')
    echo "$uptime"
}

# Function to get recent activity
get_recent_activity() {
    local activity=""
    
    # Check for recent webhook activity
    if [ -f "/home/boaz/my-new-bench/apps/frappe/frappe/custom/doctype/whatsapp_order/webhook_debug.log" ]; then
        local recent_requests=$(tail -20 "/home/boaz/my-new-bench/apps/frappe/frappe/custom/doctype/whatsapp_order/webhook_debug.log" | grep -c "POST /webhook")
        if [ "$recent_requests" -gt 0 ]; then
            activity+="${GREEN}📱 $recent_requests recent WhatsApp requests${NC}\n"
        fi
    fi
    
    # Check for recent ERPNext activity
    if [ -f "/home/boaz/my-new-bench/erpnext.log" ]; then
        local recent_orders=$(tail -50 "/home/boaz/my-new-bench/erpnext.log" | grep -c "WhatsApp Order")
        if [ "$recent_orders" -gt 0 ]; then
            activity+="${GREEN}📋 $recent_orders recent order activities${NC}\n"
        fi
    fi
    
    if [ -z "$activity" ]; then
        activity="${YELLOW}📊 No recent activity${NC}\n"
    fi
    
    echo -e "$activity"
}

# Function to clear screen and show dashboard
show_dashboard() {
    clear
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${WHITE}                WhatsApp Order Management System                ${BLUE}║${NC}"
    echo -e "${BLUE}║${WHITE}                      Monitoring Dashboard                    ${BLUE}║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo
    
    # System Status
    echo -e "${CYAN}🔧 System Status:${NC} $(get_status)"
    echo
    
    # Services
    echo -e "${CYAN}🌐 Services:${NC}"
    echo -e "  ERPNext:  http://localhost:$ERP_PORT"
    echo -e "  Webhook:  http://localhost:$WEBHOOK_PORT/webhook"
    echo -e "  Health:   http://localhost:$WEBHOOK_PORT/health"
    echo
    
    # Statistics
    echo -e "${CYAN}📊 Statistics:${NC}"
    echo -e "  Total Orders: $(get_orders_count)"
    echo -e "  System Load: $(get_system_load)"
    echo -e "  Memory Usage: $(get_memory_usage)"
    echo -e "  Disk Usage: $(get_disk_usage)"
    echo -e "  Uptime: $(get_uptime)"
    echo
    
    # Recent Activity
    echo -e "${CYAN}📈 Recent Activity:${NC}"
    get_recent_activity
    echo
    
    # Quick Actions
    echo -e "${CYAN}⚡ Quick Actions:${NC}"
    echo -e "  ${GREEN}1.${NC} Open ERPNext: http://localhost:$ERP_PORT"
    echo -e "  ${GREEN}2.${NC} Test Webhook: curl http://localhost:$WEBHOOK_PORT/health"
    echo -e "  ${GREEN}3.${NC} View Logs: ./start_whatsapp_system.sh logs"
    echo -e "  ${GREEN}4.${NC} Restart: ./start_whatsapp_system.sh restart"
    echo
    
    # Footer
    echo -e "${BLUE}──────────────────────────────────────────────────────────────${NC}"
    echo -e "${YELLOW}Press Ctrl+C to exit | Auto-refresh every 5 seconds${NC}"
}

# Main monitoring loop
monitor_loop() {
    while true; do
        show_dashboard
        sleep 5
    done
}

# Function to show help
show_help() {
    echo -e "${WHITE}WhatsApp Order Management System - Monitoring Dashboard${NC}"
    echo
    echo -e "${CYAN}Usage:${NC} $0 [OPTIONS]"
    echo
    echo -e "${CYAN}Options:${NC}"
    echo "  dashboard  - Show real-time monitoring dashboard (default)"
    echo "  status     - Show one-time system status"
    echo "  help       - Show this help message"
    echo
    echo -e "${CYAN}Examples:${NC}"
    echo "  $0                    # Start monitoring dashboard"
    echo "  $0 dashboard         # Start monitoring dashboard"
    echo "  $0 status            # Show current status"
}

# Main script logic
case "${1:-dashboard}" in
    dashboard)
        print_status "Starting monitoring dashboard..."
        print_status "Press Ctrl+C to exit"
        monitor_loop
        ;;
    
    status)
        show_dashboard
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













