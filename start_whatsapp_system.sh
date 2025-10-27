#!/bin/bash

# WhatsApp Order Management System - Startup & Monitoring Script
# Created for: Boaz
# Purpose: Start and monitor the complete WhatsApp Order Management system

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Configuration
BENCH_DIR="/home/boaz/my-new-bench"
SITE_NAME="testsite2.localhost"
WEBHOOK_DIR="$BENCH_DIR/apps/frappe/frappe/custom/doctype/whatsapp_order"
ERP_PORT="8001"
WEBHOOK_PORT="5000"
ADMIN_USER="Administrator"
ADMIN_PASS="admin"

# Log files
ERP_LOG="$BENCH_DIR/erpnext.log"
WEBHOOK_LOG="$WEBHOOK_DIR/webhook_debug.log"
SYSTEM_LOG="$BENCH_DIR/system.log"

# PID files
ERP_PID="$BENCH_DIR/erpnext.pid"
WEBHOOK_PID="$BENCH_DIR/webhook.pid"

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${WHITE}$1${NC}"
    echo -e "${BLUE}================================${NC}"
}

# Function to check if a port is in use
check_port() {
    local port=$1
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
        return 0  # Port is in use
    else
        return 1  # Port is free
    fi
}

# Function to kill processes on specific ports
kill_port() {
    local port=$1
    local process_name=$2
    
    if check_port $port; then
        print_warning "Port $port is in use. Killing existing processes..."
        lsof -ti:$port | xargs kill -9 2>/dev/null
        sleep 2
        if check_port $port; then
            print_error "Failed to kill processes on port $port"
            return 1
        else
            print_success "Successfully freed port $port"
        fi
    fi
}

# Function to start ERPNext server
start_erpnext() {
    print_header "🚀 Starting ERPNext Server"
    
    cd $BENCH_DIR
    
    # Kill any existing ERPNext processes
    kill_port $ERP_PORT "ERPNext"
    
    print_status "Starting ERPNext server on port $ERP_PORT..."
    export PATH="$HOME/.local/bin:$PATH"
    
    # Start ERPNext in background
    nohup bench --site $SITE_NAME serve --port $ERP_PORT > $ERP_LOG 2>&1 &
    ERP_PID_VALUE=$!
    echo $ERP_PID_VALUE > $ERP_PID
    
    # Wait for server to start
    print_status "Waiting for ERPNext server to start..."
    for i in {1..30}; do
        if curl -s http://localhost:$ERP_PORT >/dev/null 2>&1; then
            print_success "ERPNext server is running on http://localhost:$ERP_PORT"
            return 0
        fi
        sleep 2
        echo -n "."
    done
    
    print_error "ERPNext server failed to start"
    return 1
}

# Function to start WhatsApp webhook server
start_webhook() {
    print_header "📱 Starting WhatsApp Webhook Server"
    
    cd $WEBHOOK_DIR
    
    # Kill any existing webhook processes
    kill_port $WEBHOOK_PORT "Webhook"
    
    print_status "Starting WhatsApp webhook server on port $WEBHOOK_PORT..."
    
    # Activate virtual environment and start webhook
    nohup bash -c "source webhook_env/bin/activate && python3 whatsapp_webhook_server.py" > $WEBHOOK_LOG 2>&1 &
    WEBHOOK_PID_VALUE=$!
    echo $WEBHOOK_PID_VALUE > $WEBHOOK_PID
    
    # Wait for webhook to start
    print_status "Waiting for webhook server to start..."
    for i in {1..15}; do
        if curl -s http://localhost:$WEBHOOK_PORT/health >/dev/null 2>&1; then
            print_success "WhatsApp webhook server is running on http://localhost:$WEBHOOK_PORT"
            return 0
        fi
        sleep 2
        echo -n "."
    done
    
    print_error "Webhook server failed to start"
    return 1
}

# Function to test system connectivity
test_system() {
    print_header "🧪 Testing System Connectivity"
    
    # Test ERPNext
    print_status "Testing ERPNext API..."
    if curl -s -X POST "http://localhost:$ERP_PORT/api/method/login" \
        -d "usr=$ADMIN_USER&pwd=$ADMIN_PASS" >/dev/null 2>&1; then
        print_success "ERPNext API is responding"
    else
        print_error "ERPNext API is not responding"
        return 1
    fi
    
    # Test webhook
    print_status "Testing webhook server..."
    if curl -s http://localhost:$WEBHOOK_PORT/health >/dev/null 2>&1; then
        print_success "Webhook server is responding"
    else
        print_error "Webhook server is not responding"
        return 1
    fi
    
    # Test WhatsApp Order API
    print_status "Testing WhatsApp Order API..."
    SESSION=$(curl -s -c - -X POST "http://localhost:$ERP_PORT/api/method/login" \
        -d "usr=$ADMIN_USER&pwd=$ADMIN_PASS" | grep -o 'sid=[^;]*' | cut -d'=' -f2)
    
    if curl -s -b "sid=$SESSION" "http://localhost:$ERP_PORT/api/method/frappe.custom.doctype.whatsapp_order.api.list_orders" >/dev/null 2>&1; then
        print_success "WhatsApp Order API is working"
    else
        print_warning "WhatsApp Order API test failed"
    fi
    
    return 0
}

# Function to show system status
show_status() {
    print_header "📊 System Status"
    
    echo -e "${CYAN}ERPNext Server:${NC}"
    if check_port $ERP_PORT; then
        print_success "Running on port $ERP_PORT"
        echo "  🌐 URL: http://localhost:$ERP_PORT"
        echo "  👤 Login: $ADMIN_USER / $ADMIN_PASS"
    else
        print_error "Not running"
    fi
    
    echo -e "\n${CYAN}WhatsApp Webhook:${NC}"
    if check_port $WEBHOOK_PORT; then
        print_success "Running on port $WEBHOOK_PORT"
        echo "  📡 Webhook URL: http://localhost:$WEBHOOK_PORT/webhook"
        echo "  🔍 Health: http://localhost:$WEBHOOK_PORT/health"
    else
        print_error "Not running"
    fi
    
    echo -e "\n${CYAN}Recent Orders:${NC}"
    if [ -f "$BENCH_DIR/erpnext.log" ]; then
        echo "  📋 Check ERPNext UI for orders"
    fi
    
    echo -e "\n${CYAN}Log Files:${NC}"
    echo "  📄 ERPNext: $ERP_LOG"
    echo "  📄 Webhook: $WEBHOOK_LOG"
    echo "  📄 System: $SYSTEM_LOG"
}

# Function to monitor logs
monitor_logs() {
    print_header "📋 Monitoring System Logs"
    
    echo -e "${YELLOW}Press Ctrl+C to stop monitoring${NC}\n"
    
    # Monitor both logs simultaneously
    tail -f $ERP_LOG $WEBHOOK_LOG 2>/dev/null | while read line; do
        timestamp=$(date '+%H:%M:%S')
        echo "[$timestamp] $line"
    done
}

# Function to stop all services
stop_all() {
    print_header "🛑 Stopping All Services"
    
    # Stop ERPNext
    if [ -f $ERP_PID ]; then
        ERP_PID_VALUE=$(cat $ERP_PID)
        if kill -0 $ERP_PID_VALUE 2>/dev/null; then
            print_status "Stopping ERPNext server (PID: $ERP_PID_VALUE)..."
            kill $ERP_PID_VALUE
            rm -f $ERP_PID
        fi
    fi
    
    # Stop webhook
    if [ -f $WEBHOOK_PID ]; then
        WEBHOOK_PID_VALUE=$(cat $WEBHOOK_PID)
        if kill -0 $WEBHOOK_PID_VALUE 2>/dev/null; then
            print_status "Stopping webhook server (PID: $WEBHOOK_PID_VALUE)..."
            kill $WEBHOOK_PID_VALUE
            rm -f $WEBHOOK_PID
        fi
    fi
    
    # Kill any remaining processes
    kill_port $ERP_PORT "ERPNext"
    kill_port $WEBHOOK_PORT "Webhook"
    
    print_success "All services stopped"
}

# Function to show help
show_help() {
    print_header "📖 WhatsApp Order Management System"
    
    echo -e "${WHITE}Usage: $0 [COMMAND]${NC}\n"
    
    echo -e "${CYAN}Commands:${NC}"
    echo "  start     - Start all services (ERPNext + Webhook)"
    echo "  stop      - Stop all services"
    echo "  restart   - Restart all services"
    echo "  status    - Show system status"
    echo "  test      - Test system connectivity"
    echo "  monitor   - Monitor system logs"
    echo "  webhook   - Start only webhook server"
    echo "  erpnext   - Start only ERPNext server"
    echo "  logs      - Show recent logs"
    echo "  help      - Show this help message"
    
    echo -e "\n${CYAN}Quick Start:${NC}"
    echo "  1. Run: $0 start"
    echo "  2. Open: http://localhost:8001"
    echo "  3. Login with: Administrator / admin"
    echo "  4. Go to: WhatsApp Order list"
    echo "  5. Test with: $0 test"
    
    echo -e "\n${CYAN}Monitoring:${NC}"
    echo "  - System status: $0 status"
    echo "  - Live logs: $0 monitor"
    echo "  - Recent logs: $0 logs"
}

# Function to show recent logs
show_logs() {
    print_header "📋 Recent System Logs"
    
    echo -e "${CYAN}ERPNext Logs (last 20 lines):${NC}"
    if [ -f "$ERP_LOG" ]; then
        tail -20 "$ERP_LOG"
    else
        echo "No ERPNext log file found"
    fi
    
    echo -e "\n${CYAN}Webhook Logs (last 20 lines):${NC}"
    if [ -f "$WEBHOOK_LOG" ]; then
        tail -20 "$WEBHOOK_LOG"
    else
        echo "No webhook log file found"
    fi
}

# Main script logic
case "${1:-help}" in
    start)
        print_header "🚀 Starting WhatsApp Order Management System"
        
        # Create log directory if it doesn't exist
        mkdir -p $(dirname $ERP_LOG)
        
        # Start ERPNext
        if start_erpnext; then
            # Start webhook
            if start_webhook; then
                # Test system
                sleep 5
                if test_system; then
                    print_success "🎉 System started successfully!"
                    echo -e "\n${WHITE}Next Steps:${NC}"
                    echo "1. Open ERPNext: http://localhost:$ERP_PORT"
                    echo "2. Login: $ADMIN_USER / $ADMIN_PASS"
                    echo "3. Go to: WhatsApp Order list"
                    echo "4. Test webhook: $0 test"
                    echo "5. Monitor: $0 monitor"
                else
                    print_error "System test failed"
                    exit 1
                fi
            else
                print_error "Failed to start webhook server"
                exit 1
            fi
        else
            print_error "Failed to start ERPNext server"
            exit 1
        fi
        ;;
    
    stop)
        stop_all
        ;;
    
    restart)
        print_header "🔄 Restarting System"
        stop_all
        sleep 3
        $0 start
        ;;
    
    status)
        show_status
        ;;
    
    test)
        test_system
        ;;
    
    monitor)
        monitor_logs
        ;;
    
    webhook)
        start_webhook
        ;;
    
    erpnext)
        start_erpnext
        ;;
    
    logs)
        show_logs
        ;;
    
    help|--help|-h)
        show_help
        ;;
    
    *)
        print_error "Unknown command: $1"
        show_help
        exit 1
        ;;
esac













