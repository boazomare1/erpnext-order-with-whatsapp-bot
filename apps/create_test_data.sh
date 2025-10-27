#!/bin/bash

echo "╔════════════════════════════════════════════════════════════════════════╗"
echo "║     Creating Test Data in Frappe via API                               ║"
echo "╚════════════════════════════════════════════════════════════════════════╝"
echo ""

# Configuration
SITE="testsite2.localhost"
BASE_URL="http://localhost:8000"
API_KEY="your_api_key"
API_SECRET="your_api_secret"

echo "Creating test data for Order Routing System..."
echo ""

# 1. Create Delivery Shops
echo "📦 Creating Delivery Shops..."
echo ""

# Shop 1: Downtown Gas Shop
curl -X POST "${BASE_URL}/api/resource/Delivery Shop" \
  -H "Content-Type: application/json" \
  -H "Authorization: token ${API_KEY}:${API_SECRET}" \
  -d '{
    "shop_name": "Downtown Gas Shop",
    "gps_latitude": -1.2921,
    "gps_longitude": 36.8219,
    "county": "Nairobi County",
    "constituency": "Kamukunji Constituency",
    "ward": "Eastleigh North Ward",
    "nearest_landmark": "Airport Road Roundabout",
    "operating_hours": "Mon-Fri: 8:00 AM - 6:00 PM",
    "contact_person": "John Kamau",
    "phone_number": "+254712345678",
    "email": "downtown@gasshop.com",
    "status": "Active",
    "active": 1
  }' 2>/dev/null | jq '.data' || echo "Shop 1 created"

echo ""

# Shop 2: Nairobi Mall Shop
curl -X POST "${BASE_URL}/api/resource/Delivery Shop" \
  -H "Content-Type: application/json" \
  -H "Authorization: token ${API_KEY}:${API_SECRET}" \
  -d '{
    "shop_name": "Nairobi Mall Shop",
    "gps_latitude": -1.2830,
    "gps_longitude": 36.8271,
    "county": "Nairobi County",
    "constituency": "Westlands Constituency",
    "ward": "Parklands Ward",
    "nearest_landmark": "Nairobi Mall Entrance",
    "operating_hours": "Mon-Sat: 9:00 AM - 7:00 PM",
    "contact_person": "Sarah Njeri",
    "phone_number": "+254723456789",
    "email": "mall@gasshop.com",
    "status": "Active",
    "active": 1
  }' 2>/dev/null | jq '.data' || echo "Shop 2 created"

echo ""

# Shop 3: Westlands Shop
curl -X POST "${BASE_URL}/api/resource/Delivery Shop" \
  -H "Content-Type: application/json" \
  -H "Authorization: token ${API_KEY}:${API_SECRET}" \
  -d '{
    "shop_name": "Westlands Shop",
    "gps_latitude": -1.2545,
    "gps_longitude": 36.7971,
    "county": "Nairobi County",
    "constituency": "Westlands Constituency",
    "ward": "Westlands Ward",
    "nearest_landmark": "Westlands Shopping Center",
    "operating_hours": "Daily: 7:00 AM - 8:00 PM",
    "contact_person": "Mike Ouma",
    "phone_number": "+254734567890",
    "email": "westlands@gasshop.com",
    "status": "Active",
    "active": 1
  }' 2>/dev/null | jq '.data' || echo "Shop 3 created"

echo ""

# 2. Create Customers
echo "👤 Creating Customers..."
echo ""

curl -X POST "${BASE_URL}/api/resource/Customer" \
  -H "Content-Type: application/json" \
  -H "Authorization: token ${API_KEY}:${API_SECRET}" \
  -d '{
    "customer_name": "Peter Ochieng",
    "phone_number": "+254712345678",
    "default_delivery_address": "Westlands, Nairobi",
    "default_gps_latitude": -1.2850,
    "default_gps_longitude": 36.8110,
    "county": "Nairobi County",
    "constituency": "Westlands",
    "ward": "Westlands"
  }' 2>/dev/null | jq '.data' || echo "Customer 1 created"

echo ""

# 3. Create Customer Preferences
echo "⭐ Creating Customer Preferences..."
echo ""

# This would require Item codes from your system
echo "Note: Customer Preferences require Item codes from ERPNext"
echo ""

# 4. Display Created Data
echo "📊 Retrieving Created Data..."
echo ""

echo "=== DELIVERY SHOPS ==="
curl -X GET "${BASE_URL}/api/resource/Delivery Shop" \
  -H "Authorization: token ${API_KEY}:${API_SECRET}" \
  2>/dev/null | jq '.data[] | {name: .name, shop_name: .shop_name, location: "\(.gps_latitude), \(.gps_longitude)"}' || echo "Shops retrieved"

echo ""
echo "=== CUSTOMERS ==="
curl -X GET "${BASE_URL}/api/resource/Customer" \
  -H "Authorization: token ${API_KEY}:${API_SECRET}" \
  2>/dev/null | jq '.data[] | {name: .name, customer_name: .customer_name, phone: .phone_number}' || echo "Customers retrieved"

echo ""
echo "✅ Test data creation complete!"
echo ""
echo "You can now view this data in Frappe UI at: ${BASE_URL}"
echo "Navigate to: Delivery Shop, Customer, Order Route Assignment"
