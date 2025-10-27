#!/usr/bin/env python3
"""
Order Routing System - Simulation Test
Tests the complete order routing flow
"""

import sys
import os

# Add Frappe path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'apps'))

# Simulate Frappe environment
class FakeFrappe:
    def get_all(self, doctype, filters=None, fields=None):
        if doctype == 'Delivery Shop':
            # Simulate shops
            return [
                {
                    'name': 'Shop001',
                    'shop_name': 'Downtown Gas Shop',
                    'gps_latitude': -1.2921,
                    'gps_longitude': 36.8219,
                    'erpnext_warehouse': 'Main Warehouse'
                },
                {
                    'name': 'Shop002',
                    'shop_name': 'Nairobi Mall Shop',
                    'gps_latitude': -1.2830,
                    'gps_longitude': 36.8271,
                    'erpnext_warehouse': 'Mall Warehouse'
                },
                {
                    'name': 'Shop003',
                    'shop_name': 'Westlands Shop',
                    'gps_latitude': -1.2545,
                    'gps_longitude': 36.7971,
                    'erpnext_warehouse': 'Westlands Warehouse'
                }
            ]
        return []
    
    def exists(self, doctype, filters):
        return None
    
    def get_doc(self, doctype, name):
        class FakeDoc:
            def __init__(self, doc_type, name):
                self.doctype = doc_type
                self.name = name
                self.customer_phone = '+254712345678'
                self.item_name = 'Gas Cylinder 13kg'
                self.quantity = 1
        return FakeDoc(doctype, name)

# Import our utilities (without Frappe dependency)
import math

def calculate_distance(lat1, lon1, lat2, lon2):
    """Calculate distance using Haversine formula"""
    R = 6371000  # Earth radius in meters
    phi1 = math.radians(lat1)
    phi2 = math.radians(lat2)
    delta_phi = math.radians(lat2 - lat1)
    delta_lambda = math.radians(lon2 - lon1)
    
    a = (math.sin(delta_phi / 2) ** 2 +
         math.cos(phi1) * math.cos(phi2) * math.sin(delta_lambda / 2) ** 2)
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    
    return R * c

def find_nearest_shops(customer_lat, customer_lon, shops, tier_distances=[50, 100, 500, 1000]):
    """Find shops within distance tiers"""
    shops_by_tier = {tier: [] for tier in tier_distances}
    
    for shop in shops:
        # Calculate distance
        distance = calculate_distance(
            customer_lat, customer_lon,
            shop['gps_latitude'], shop['gps_longitude']
        )
        
        # Assign to appropriate tier
        for tier in sorted(tier_distances):
            if distance <= tier:
                shops_by_tier[tier].append({
                    **shop,
                    'distance': distance
                })
                break
    
    return shops_by_tier

def simulate_order_routing():
    """Simulate the complete order routing flow"""
    
    print("=" * 70)
    print("ORDER ROUTING SYSTEM - SIMULATION")
    print("=" * 70)
    print()
    
    # Simulate customer order
    print("📦 CUSTOMER ORDER RECEIVED")
    print("-" * 70)
    customer_lat = -1.2850  # Nairobi Westlands
    customer_lon = 36.8110
    customer_phone = "+254712345678"
    item_code = "GAS_CYLINDER_13KG"
    quantity = 1
    
    print(f"Customer: {customer_phone}")
    print(f"Location: {customer_lat}, {customer_lon}")
    print(f"Item: {item_code}")
    print(f"Quantity: {quantity}")
    print()
    
    # Get shops
    print("🔍 SEARCHING FOR SHOPS WITH INVENTORY")
    print("-" * 70)
    shops = [
        {
            'name': 'Shop001',
            'shop_name': 'Downtown Gas Shop',
            'gps_latitude': -1.2921,
            'gps_longitude': 36.8219,
            'active': True,
            'inventory': 10
        },
        {
            'name': 'Shop002',
            'shop_name': 'Nairobi Mall Shop',
            'gps_latitude': -1.2830,
            'gps_longitude': 36.8271,
            'active': True,
            'inventory': 5
        },
        {
            'name': 'Shop003',
            'shop_name': 'Westlands Shop',
            'gps_latitude': -1.2545,
            'gps_longitude': 36.7971,
            'active': True,
            'inventory': 8
        }
    ]
    
    print(f"Found {len(shops)} shops with inventory")
    for shop in shops:
        print(f"  ✓ {shop['shop_name']} - {shop['inventory']} units in stock")
    print()
    
    # Calculate distances and tiers
    print("📏 CALCULATING DISTANCES")
    print("-" * 70)
    tier_distances = [50, 100, 500, 1000, 5000]
    shops_by_tier = find_nearest_shops(
        customer_lat, customer_lon,
        shops, tier_distances
    )
    
    # Display distances
    for shop in shops:
        distance = calculate_distance(
            customer_lat, customer_lon,
            shop['gps_latitude'], shop['gps_longitude']
        )
        print(f"{shop['shop_name']}: {distance:.0f}m from customer")
    print()
    
    # Show tiered assignment
    print("🎯 TIERED ASSIGNMENT STRATEGY")
    print("-" * 70)
    for tier in sorted(tier_distances):
        if shops_by_tier[tier]:
            print(f"Tier {tier}m: {len(shops_by_tier[tier])} shop(s)")
            for shop in shops_by_tier[tier]:
                print(f"  → {shop['shop_name']} ({shop['distance']:.0f}m)")
    
    print()
    
    # Assignment process
    print("✅ ORDER ASSIGNMENT")
    print("-" * 70)
    
    # Find nearest shop in closest tier
    assigned = False
    for tier in sorted(tier_distances):
        if shops_by_tier[tier] and not assigned:
            nearest_shop = shops_by_tier[tier][0]
            
            print(f"📍 Assigning to nearest shop in {tier}m tier...")
            print(f"   Shop: {nearest_shop['shop_name']}")
            print(f"   Distance: {nearest_shop['distance']:.0f}m")
            print()
            print(f"📱 WhatsApp notification sent to shop")
            print(f"⏰ 3-minute timer started")
            print()
            print("Waiting for shop response...")
            print("   (Simulating 10 seconds)")
            import time
            time.sleep(2)
            print()
            print("✅ Shop CONFIRMED assignment")
            print()
            print("📧 Customer notification sent")
            print("   'Your order has been confirmed and is being prepared for delivery'")
            print()
            print("=" * 70)
            print("ORDER ROUTED SUCCESSFULLY!")
            print("=" * 70)
            print()
            print(f"Assigned Shop: {nearest_shop['shop_name']}")
            print(f"Distance: {nearest_shop['distance']:.0f}m")
            print(f"Tier: {tier}m")
            print(f"Status: CONFIRMED")
            print(f"Timer: Confirmed before expiration")
            
            assigned = True
            break
    
    if not assigned:
        print("❌ No shops available to assign order")
    
    print()
    print("=" * 70)

if __name__ == "__main__":
    simulate_order_routing()
