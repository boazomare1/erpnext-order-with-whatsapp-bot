# Business Requirements - WhatsApp Order Management System

## Part 1: Core Requirements (✅ COMPLETED)
- WhatsApp integration for receiving orders
- ERPNext integration for order logging
- Basic order management

## Part 2: Order Fulfillment & Routing System (🚧 IN PROGRESS)

### Business Process Flow:
1. Customer places order via WhatsApp
   - Provides product (cylinder type)
   - Provides delivery location (text input OR map selection)
   - System captures GPS coordinates

2. Order Processing & Routing
   - Central system receives order
   - System searches for nearest shop/agent with available inventory
   - Considers:
     - ✅ Proximity to customer (GPS-based distance calculation)
     - ✅ Inventory availability (shop must have product in stock)
     - ✅ Customer preference (if specified)
   - Automatically routes order to selected shop/agent

3. Shop/Agent Management
   - Multiple authorized sales agents across different locations
   - Each shop has: GPS coordinates, inventory levels, operating hours
   - Real-time inventory tracking

4. Delivery Execution
   - Shop/agent receives order notification
   - Driver/agent assigned to delivery
   - Delivery tracking and status updates
   - Minimal human intervention needed

### Key Questions for Confirmation:
1. How to handle inventory - ERPNext Items or separate system?
2. What happens when no nearby shop has inventory?
3. How to store customer preferences?
4. Order assignment - automatic or agent selection?
