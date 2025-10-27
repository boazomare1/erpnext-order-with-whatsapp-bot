#!/bin/bash

echo "╔════════════════════════════════════════════════════════════════════════╗"
echo "║     Create Test Data Directly via Bench Console                        ║"
echo "╚════════════════════════════════════════════════════════════════════════╝"
echo ""

# Note: You need to run this in a separate terminal or through bench console
cat << 'PYTHON_DATA' > /tmp/insert_data.py
import frappe
frappe.init(site='testsite2.localhost')
frappe.connect()

# Create Delivery Shops
shops_data = [
    {
        'doctype': 'Delivery Shop',
        'shop_name': 'Downtown Gas Shop',
        'gps_latitude': -1.2921,
        'gps_longitude': 36.8219,
        'county': 'Nairobi County',
        'constituency': 'Kamukunji Constituency',
        'ward': 'Eastleigh North Ward',
        'nearest_landmark': 'Airport Road Roundabout',
        'operating_hours': 'Mon-Fri: 8:00 AM - 6:00 PM',
        'contact_person': 'John Kamau',
        'phone_number': '+254712345678',
        'email': 'downtown@gasshop.com',
        'status': 'Active',
        'active': 1
    },
    {
        'doctype': 'Delivery Shop',
        'shop_name': 'Nairobi Mall Shop',
        'gps_latitude': -1.2830,
        'gps_longitude': 36.8271,
        'county': 'Nairobi County',
        'constituency': 'Westlands Constituency',
        'ward': 'Parklands Ward',
        'nearest_landmark': 'Nairobi Mall Entrance',
        'operating_hours': 'Mon-Sat: 9:00 AM - 7:00 PM',
        'contact_person': 'Sarah Njeri',
        'phone_number': '+254723456789',
        'email': 'mall@gasshop.com',
        'status': 'Active',
        'active': 1
    },
    {
        'doctype': 'Delivery Shop',
        'shop_name': 'Westlands Shop',
        'gps_latitude': -1.2545,
        'gps_longitude': 36.7971,
        'county': 'Nairobi County',
        'constituency': 'Westlands Constituency',
        'ward': 'Westlands Ward',
        'nearest_landmark': 'Westlands Shopping Center',
        'operating_hours': 'Daily: 7:00 AM - 8:00 PM',
        'contact_person': 'Mike Ouma',
        'phone_number': '+254734567890',
        'email': 'westlands@gasshop.com',
        'status': 'Active',
        'active': 1
    }
]

print("Creating Delivery Shops...")
for shop_data in shops_data:
    try:
        doc = frappe.get_doc(shop_data)
        doc.insert()
        print(f"✓ Created: {doc.shop_name}")
    except Exception as e:
        print(f"✗ Error creating {shop_data['shop_name']}: {e}")

# Create Customers
customers_data = [
    {
        'doctype': 'Customer',
        'customer_name': 'Peter Ochieng',
        'phone_number': '+254712345678',
        'default_delivery_address': 'Westlands, Nairobi',
        'default_gps_latitude': -1.2850,
        'default_gps_longitude': 36.8110,
        'county': 'Nairobi County',
        'constituency': 'Westlands',
        'ward': 'Westlands'
    },
    {
        'doctype': 'Customer',
        'customer_name': 'Mary Wanjiru',
        'phone_number': '+254723456789',
        'default_delivery_address': 'Parklands, Nairobi',
        'default_gps_latitude': -1.2700,
        'default_gps_longitude': 36.8200,
        'county': 'Nairobi County',
        'constituency': 'Westlands',
        'ward': 'Parklands'
    }
]

print("\nCreating Customers...")
for customer_data in customers_data:
    try:
        doc = frappe.get_doc(customer_data)
        doc.insert()
        print(f"✓ Created: {doc.customer_name}")
    except Exception as e:
        print(f"✗ Error creating {customer_data['customer_name']}: {e}")

print("\n✅ Test data creation complete!")
frappe.db.commit()
PYTHON_DATA

echo "Python script created at: /tmp/insert_data.py"
echo ""
echo "To insert this data, run:"
echo "  bench --site testsite2.localhost console"
echo ""
echo "Then in the console, type:"
echo "  exec(open('/tmp/insert_data.py').read())"
echo ""
echo "Or copy the Python code from the file above and paste it directly in the console"
