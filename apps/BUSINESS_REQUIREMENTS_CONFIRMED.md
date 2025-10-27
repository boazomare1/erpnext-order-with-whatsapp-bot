# Business Requirements - CONFIRMED

## Part 1: Core Requirements (✅ COMPLETED)
- WhatsApp integration for receiving orders
- ERPNext integration for order logging
- Basic order management

## Part 2: Order Fulfillment & Routing System (📋 SPECIFICATIONS)

### 1. INVENTORY MANAGEMENT
- **Source**: ERPNext Items/Stock Ledger
- **Shop Creation Flow**:
  - When creating a shop, automatically create inventory in ERPNext
  - Track SKUs and quantities per shop
  - Include all relevant properties
- **Inventory Check**: Real-time stock levels from ERPNext

### 2. ORDER ROUTING LOGIC
**Priority Order** (not radius-based, but distance-based):
1. Find ALL shops with available inventory for the SKU
2. Calculate distance to customer (GPS-based)
3. **Tiered Assignment Approach**:
   - First offer to shops within ~50m
   - Wait 3 minutes for confirmation
   - If no confirmation, move to next tier (~100m)
   - Continue expanding search until shop accepts
   - **No maximum distance limit** - if a shop is 500km away and matches conditions, it gets the order

**Key Concept**: "Nearest" = geographically closest shop with inventory, regardless of distance

### 3. CUSTOMER PREFERENCES MANAGEMENT
**Data Capture**:
- Create Customer doctype for first-time orders
- Store customer phone number, location, order history

**Preference Tracking**:
- Create Preferences doctype linked to Customer
- Track:
  - Preferred SKU (e.g., always orders specific cylinder type)
  - Preferred Fulfiller (specific shop/agent customer likes)
  - Delivery location patterns

**UI/UX**:
- Show preferred options to customer when placing order
- If they choose preferred option → auto-apply
- If they don't select preference → proceed manually

### 4. ORDER ASSIGNMENT PROCESS
**Progressive Offer System**:
1. System finds nearest shop with inventory
2. **First Tier**: Offer to shops within 50m
   - Send notification/alert to shop
   - **3-minute wait timer**
   - If shop confirms → Order assigned
3. **Second Tier**: If no confirmation after 3 minutes
   - Expand to next distance tier (100m)
   - Repeat notification and 3-minute timer
4. Continue until shop confirms

**Automation Level**: 
- Automatic offer based on proximity + inventory
- Human confirmation required from shop
- System handles retries if no response

## REQUIRED DOCTYPES

### 1. **Delivery Shop**
- Shop name, location details
- GPS coordinates (latitude, longitude)
- County, Constituency, Ward
- Nearest landmark
- Operating hours
- Link to ERPNext inventory/bin

### 2. **Customer**
- Phone number (from WhatsApp)
- Name
- Default delivery location
- GPS coordinates
- Order history

### 3. **Customer Preferences**
- Link to Customer
- Preferred SKU
- Preferred Fulfiller (shop)
- Preference score/priority

### 4. **Delivery Zone**
- County, Constituency, Ward structure
- Boundaries and GPS data
- For reporting and analytics

### 5. **Order Route Assignment** (or Order Fulfillment)
- Link to WhatsApp Order
- Assigned Shop
- Assigned Date/Time
- Status (Pending, Confirmed, Rejected)
- Confirmation timer tracking
- Priority tier applied

### 6. **Delivery Driver/Agent**
- Driver name, contact
- Link to Shop
- Status (available, on delivery)
- GPS tracking capability

### 7. **Location** (Enhanced)
- Customer delivery location
- GPS coordinates
- Text address OR map selection
- Linked to orders

## IMPLEMENTATION ROADMAP

### Phase 1: Foundation Setup
1. Create all required doctypes
2. Set up ERPNext inventory integration for shops
3. Create location management system
4. Build GPS distance calculation utilities

### Phase 2: Customer Management
1. Create Customer doctype
2. Create Customer Preferences doctype
3. Build preference detection logic
4. Create preference-based UI

### Phase 3: Routing Engine
1. Build shop search by proximity
2. Implement inventory check integration
3. Create tiered assignment system
4. Build 3-minute timer mechanism
5. Handle fallback logic

### Phase 4: Shop Assignment
1. Create Order Route Assignment doctype
2. Build notification system
3. Create shop confirmation interface
4. Implement retry logic

### Phase 5: Delivery Management
1. Create Delivery Driver/Agent doctype
2. Build driver assignment logic
3. Create tracking system

### Phase 6: Maps Integration
1. Integrate map API (Google Maps/OpenStreetMap)
2. Build location selector
3. Create map-based routing visualization

## OPEN QUESTIONS FOR CONFIRMATION
1. Which map service? (Google Maps, OpenStreetMap, etc.)
2. Notification method for shops? (WhatsApp, SMS, In-app, Email)
3. Should we store GPS history for customer delivery patterns?
4. Do we need a separate UI for shop agents to manage orders?
5. Should the system support bulk orders (multiple SKUs in one order)?
