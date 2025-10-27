#!/usr/bin/env python3
"""
Populate Frappe with test data for Order Routing System
This script creates shops, customers, and test orders
"""

import sys
import os

# Add Frappe paths
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'apps', 'frappe'))

def create_test_data():
    """Create test data in Frappe"""
    
    print("╔════════════════════════════════════════════════════════════════════════╗")
    print("║         Populating Frappe with Test Data                              ║")
    print("╚════════════════════════════════════════════════════════════════════════╝")
    print("")
    
    # Try to import Frappe
    try:
        import frappe
        frappe.init(site='testsite2.localhost')
        frappe.connect()
    except Exception as e:
        print(f"Note: Cannot connect to Frappe directly: {e}")
        print("Creating a simple test data generator instead...")
        print()
        create_sample_output()
        return
    
    print("Creating Delivery Shops...")
    print()
    
    # Create shops
    shops = [
        {
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
        },
        {
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
        },
        {
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
        }
    ]
    
    for shop in shops:
        print(f"  Creating: {shop['shop_name']}")
        try:
            doc = frappe.get_doc({
                'doctype': 'Delivery Shop',
                **shop
            })
            doc.insert()
            print(f"    ✓ Created (ID: {doc.name})")
        except Exception as e:
            print(f"    ⚠ Error: {e}")
    
    print()
    print("Creating Customers...")
    print()
    
    customers = [
        {
            "customer_name": "Peter Ochieng",
            "phone_number": "+254712345678",
            "default_delivery_address": "Westlands, Nairobi",
            "default_gps_latitude": -1.2850,
            "default_gps_longitude": 36.8110,
            "county": "Nairobi County",
            "constituency": "Westlands",
            "ward": "Westlands"
        },
        {
            "customer_name": "Mary Wanjiru",
            "phone_number": "+254723456789",
            "default_delivery_address": "Parklands, Nairobi",
            "default_gps_latitude": -1.2700,
            "default_gps_longitude": 36.8200,
            "county": "Nairobi County",
            "constituency": "Westlands",
            "ward": "Parklands"
        }
    ]
    
    for customer in customers:
        print(f"  Creating: {customer['customer_name']}")
        try:
            doc = frappe.get_doc({
                'doctype': 'Customer',
                **customer
            })
            doc.insert()
            print(f"    ✓ Created (ID: {doc.name})")
        except Exception as e:
            print(f"    ⚠ Error: {e}")
    
    print()
    print("✅ Test data creation complete!")
    print()
    print("View your data in Frappe UI:")
    print("  - Delivery Shop: List view")
    print("  - Customer: List view")
    print()

def create_sample_output():
    """Create sample output showing what data should look like"""
    
    print("╔════════════════════════════════════════════════════════════════════════╗")
    print("║              SAMPLE DATA TO MANUALLY ADD TO FRAPPE                    ║")
    print("╚════════════════════════════════════════════════════════════════════════╝")
    print()
    
    print("📍 DELIVERY SHOPS (3 shops)")
    print("─" * 70)
    shops = [
        {"name": "Downtown Gas Shop", "lat": -1.2921, "lon": 36.8219, "phone": "+254712345678"},
        {"name": "Nairobi Mall Shop", "lat": -1.2830, "lon": 36.8271, "phone": "+254723456789"},
        {"name": "Westlands Shop", "lat": -1.2545, "lon": 36.7971, "phone": "+254734567890"}
    ]
    
    for i, shop in enumerate(shops, 1):
        print(f"{i}. {shop['name']}")
        print(f"   GPS: {shop['lat']}, {shop['lon']}")
        print(f"   Phone: {shop['phone']}")
        print(f"   Status: Active")
        print()
    
    print("👤 CUSTOMERS (2 customers)")
    print("─" * 70)
    customers = [
        {"name": "Peter Ochieng", "phone": "+254712345678", "lat": -1.2850, "lon": 36.8110},
        {"name": "Mary Wanjiru", "phone": "+254723456789", "lat": -1.2700, "lon": 36.8200}
    ]
    
    for i, customer in enumerate(customers, 1):
        print(f"{i}. {customer['name']}")
        print(f"   Phone: {customer['phone']}")
        print(f"   Location: {customer['lat']}, {customer['lon']}")
        print()
    
    print("═════════════════════════════════════════════════════════════════════════")
    print()
    print("TO ADD THIS DATA IN FRAPPE:")
    print()
    print("1. Go to Frappe UI: http://localhost:8000")
    print("2. Navigate to: Apps > Whatsapp Orders")
    print("3. Create Delivery Shop records with the data above")
    print("4. Create Customer records with the data above")
    print("5. Test the order routing system")
    print()

if __name__ == "__main__":
    create_test_data()

