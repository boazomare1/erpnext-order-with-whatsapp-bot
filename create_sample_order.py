#!/usr/bin/env python3

import frappe
from frappe.utils import now

def create_sample_order():
    # Initialize Frappe
    frappe.init(site='testsite2.localhost')
    frappe.connect()
    
    try:
        # Create a sample WhatsApp Order
        order = frappe.new_doc('WhatsApp Order')
        order.naming_series = 'WOR-2025-.#####'
        order.customer_name = 'John Doe'
        order.customer_phone = '+254712345678'
        order.order_date = now()
        order.status = 'New'
        order.delivery_address = '123 Main Street, Nairobi, Kenya'
        order.payment_method = 'Cash on Delivery'

        # Add items to the order
        order.append('items', {
            'item_name': 'Pizza Margherita',
            'description': 'Large pizza with tomato sauce and mozzarella cheese',
            'quantity': 2,
            'unit_price': 15.00
        })

        order.append('items', {
            'item_name': 'Coca Cola',
            'description': '500ml bottle',
            'quantity': 3,
            'unit_price': 2.50
        })

        order.append('items', {
            'item_name': 'French Fries',
            'description': 'Large portion of crispy fries',
            'quantity': 1,
            'unit_price': 8.00
        })

        # Save the order
        order.insert()
        frappe.db.commit()
        
        print(f"✅ Successfully created WhatsApp Order: {order.name}")
        print(f"📋 Customer: {order.customer_name}")
        print(f"📞 Phone: {order.customer_phone}")
        print(f"📅 Order Date: {order.order_date}")
        print(f"📦 Status: {order.status}")
        print(f"🏠 Delivery Address: {order.delivery_address}")
        print(f"💳 Payment Method: {order.payment_method}")
        print(f"📝 Items: {len(order.items)} items")
        
        for i, item in enumerate(order.items, 1):
            print(f"   {i}. {item.item_name} - Qty: {item.quantity} x ${item.unit_price} = ${item.amount}")
        
        return order.name
        
    except Exception as e:
        print(f"❌ Error creating order: {str(e)}")
        return None
    finally:
        frappe.destroy()

if __name__ == "__main__":
    create_sample_order()


