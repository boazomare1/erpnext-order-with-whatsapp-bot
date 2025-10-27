import frappe
from frappe.model.document import Document
from frappe.utils import nowdate

class Customer(Document):
	def validate(self):
		"""Validate GPS coordinates"""
		# Validate GPS coordinates range
		if self.default_gps_latitude:
			if not (-90 <= self.default_gps_latitude <= 90):
				frappe.throw("GPS Latitude must be between -90 and 90 degrees")
		
		if self.default_gps_longitude:
			if not (-180 <= self.default_gps_longitude <= 180):
				frappe.throw("GPS Longitude must be between -180 and 180 degrees")
	
	def update_order_stats(self):
		"""Update order statistics from order history"""
		# Count total orders
		total_orders = frappe.db.count('Whatsapp Order', {'customer_phone': self.phone_number})
		
		# Get last order date
		last_order = frappe.db.sql("""
			SELECT MAX(creation) as last_date
			FROM `tabWhatsapp Order`
			WHERE customer_phone = %s
		""", (self.phone_number,), as_dict=True)
		
		self.total_orders = total_orders
		self.last_order_date = last_order[0].last_date if last_order and last_order[0].last_date else None
		self.save()
	
	def get_default_location(self):
		"""
		Get default delivery location as dict
		
		Returns:
			Dict with address, latitude, longitude
		"""
		if not self.default_gps_latitude or not self.default_gps_longitude:
			return None
		
		return {
			'address': self.default_delivery_address,
			'latitude': self.default_gps_latitude,
			'longitude': self.default_gps_longitude,
			'county': self.county,
			'constituency': self.constituency,
			'ward': self.ward
		}
	
	@staticmethod
	def get_or_create(phone_number, customer_name=None):
		"""
		Get existing customer or create new one
		
		Args:
			phone_number: Customer phone number
			customer_name: Customer name (optional)
		
		Returns:
			Customer document
		"""
		customer = frappe.db.exists('Customer', {'phone_number': phone_number})
		
		if customer:
			return frappe.get_doc('Customer', customer)
		else:
			# Create new customer
			new_customer = frappe.get_doc({
				'doctype': 'Customer',
				'phone_number': phone_number,
				'customer_name': customer_name or phone_number,
				'total_orders': 0
			})
			new_customer.insert()
			return new_customer
