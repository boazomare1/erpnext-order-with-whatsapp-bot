# Order Routing System - Implementation Roadmap

## Development Branch: feature/order-routing-system
**Branch created**: Safe development environment without affecting main

## PHASE 1: Foundation Setup ✅ (START HERE)

### Tasks:
1. ✅ Create development branch
2. Create GPS distance calculation utilities
3. Create core doctypes:
   - Delivery Shop
   - Customer
   - Customer Preferences
   - Delivery Zone
4. Set up basic location management

### Delivery Shop Doctype
- shop_name
- gps_latitude
- gps_longitude
- county
- constituency
- ward
- nearest_landmark
- operating_hours
- erpnext_warehouse (link)

### Customer Doctype
- customer_name
- phone_number (unique)
- default_delivery_address
- default_gps_latitude
- default_gps_longitude

### Customer Preferences Doctype
- customer (link)
- preferred_sku (link to Item)
- preferred_fulfiller (link to Delivery Shop)
- preference_score

## PHASE 2: Routing Engine Core
- GPS distance calculator
- Shop finder by proximity + inventory
- Tiered assignment logic (50m, 100m, etc.)
- 3-minute timer mechanism

## PHASE 3: Order Assignment System
- Order Route Assignment doctype
- Notification system
- Shop confirmation interface

## PHASE 4: Integration
- ERPNext inventory check
- WhatsApp notifications
- Map integration

## PHASE 5: Testing & Deployment
- Unit tests
- Integration tests
- Performance testing
- Documentation

