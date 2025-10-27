import frappe
from frappe.model.document import Document

class DeliveryShop(Document):
	def validate(self):
		"""Validate GPS coordinates and warehouse link"""
		# Validate GPS coordinates range
		if self.gps_latitude:
			if not (-90 <= self.gps_latitude <= 90):
				frappe.throw("GPS Latitude must be between -90 and 90 degrees")
		
		if self.gps_longitude:
			if not (-180 <= self.gps_longitude <= 180):
				frappe.throw("GPS Longitude must be between -180 and 180 degrees")
		
		# Auto-generate shop code if not provided
		if not self.shop_code:
			self.shop_code = self.generate_shop_code()
		
		# Ensure warehouse is linked for inventory tracking
		if not self.erpnext_warehouse:
			frappe.throw("ERPNext Warehouse is required for inventory tracking")
	
	def generate_shop_code(self):
		"""Generate unique shop code"""
		# Use shop name initials + number
		shop_name = self.shop_name or "SHOP"
		initials = ''.join([word[0].upper() for word in shop_name.split()])
		
		# Get the next number
		count = frappe.db.count('Delivery Shop')
		return f"{initials}{count + 1:03d}"
	
	def get_inventory_quantity(self, item_code):
		"""
		Get inventory quantity for a specific item from ERPNext
		
		Args:
			item_code: Item code to check
		
		Returns:
			Available quantity in warehouse
		"""
		if not self.erpnext_warehouse:
			return 0
		
		try:
			from erpnext.stock.utils import get_stock_balance
			quantity = get_stock_balance(
				item_code, 
				self.erpnext_warehouse
			)
			return quantity or 0
		except Exception as e:
			frappe.log_error(f"Error getting inventory for {item_code}: {str(e)}")
			return 0
	
	def has_stock(self, item_code, required_qty=1):
		"""
		Check if shop has required quantity of item in stock
		
		Args:
			item_code: Item code to check
			required_qty: Required quantity
		
		Returns:
			True if shop has sufficient stock
		"""
		available_qty = self.get_inventory_quantity(item_code)
		return available_qty >= required_qty
	
	def distance_to_customer(self, customer_lat, customer_lon):
		"""
		Calculate distance from shop to customer
		
		Args:
			customer_lat: Customer latitude
			customer_lon: Customer longitude
		
		Returns:
			Distance in meters
		"""
		from ..utils import calculate_distance
		return calculate_distance(
			self.gps_latitude,
			self.gps_longitude,
			customer_lat,
			customer_lon
		)
