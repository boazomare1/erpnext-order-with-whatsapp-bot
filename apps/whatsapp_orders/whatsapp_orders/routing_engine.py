"""
Order Routing Engine
Main logic for finding shops and assigning orders based on proximity, inventory, and preferences
"""

import frappe
from frappe.utils import now_datetime, add_to_date, get_datetime, time_diff_in_seconds
from datetime import timedelta
from .utils import find_nearest_shops, calculate_distance


class OrderRoutingEngine:
	"""
	Main routing engine for order assignment
	"""
	
	def __init__(self):
		self.tier_distances = [50, 100, 500, 1000, 5000]  # meters
		self.confirmation_timeout = 180  # 3 minutes in seconds
	
	def find_shop_for_order(self, order_doc, customer_lat, customer_lon, item_code, quantity=1):
		"""
		Main method to find and assign a shop for an order
		
		Args:
			order_doc: WhatsApp Order document
			customer_lat: Customer latitude
			customer_lon: Customer longitude
			item_code: Item code to order
			quantity: Quantity needed
		
		Returns:
			Dict with assignment details or None if no shop found
		"""
		# Step 1: Get all active shops with inventory
		shops_with_inventory = self._get_shops_with_inventory(item_code, quantity)
		
		if not shops_with_inventory:
			return {
				'success': False,
				'message': 'No shops have sufficient inventory for this item',
				'shops_checked': 0
			}
		
		# Step 2: Check customer preferences
		customer_phone = order_doc.get('customer_phone')
		preferences = self._get_customer_preferences(customer_phone)
		
		# Step 3: Find shops by tiers
		shops_by_tier = find_nearest_shops(
			customer_lat,
			customer_lon,
			shops_with_inventory,
			self.tier_distances
		)
		
		# Step 4: Start tiered assignment
		for tier in sorted(self.tier_distances):
			if tier in shops_by_tier and shops_by_tier[tier]:
				shops = shops_by_tier[tier]
				
				# Sort by distance (already sorted by find_nearest_shops)
				# Apply customer preference bonus
				if preferences:
					shops = self._apply_preferences(shops, preferences)
				
				# Try assignment for each shop in tier
				for shop in shops:
					assignment = self._create_assignment(
						order_doc,
						shop,
						tier,
						customer_lat,
						customer_lon
					)
					
					if assignment:
						return {
							'success': True,
							'assignment': assignment,
							'shop': shop,
							'tier': tier,
							'distance': shop.get('distance', 0),
							'timeout_seconds': self.confirmation_timeout
						}
		
		return {
			'success': False,
			'message': 'All shops in range declined or timed out',
			'shops_checked': len(shops_with_inventory)
		}
	
	def _get_shops_with_inventory(self, item_code, quantity):
		"""
		Get all active shops that have the required quantity of item
		
		Args:
			item_code: Item code
			quantity: Required quantity
		
		Returns:
			List of shop dicts with inventory
		"""
		# Get all active shops
		shops = frappe.get_all(
			'Delivery Shop',
			filters={'active': 1, 'status': 'Active'},
			fields=['name', 'shop_name', 'gps_latitude', 'gps_longitude', 'erpnext_warehouse']
		)
		
		shops_with_inventory = []
		
		for shop in shops:
			# Check if shop has inventory
			shop_doc = frappe.get_doc('Delivery Shop', shop.name)
			if shop_doc.has_stock(item_code, quantity):
				shop['latitude'] = shop.gps_latitude
				shop['longitude'] = shop.gps_longitude
				shop['available_qty'] = shop_doc.get_inventory_quantity(item_code)
				shops_with_inventory.append(shop)
		
		return shops_with_inventory
	
	def _get_customer_preferences(self, customer_phone):
		"""
		Get customer preferences if available
		
		Args:
			customer_phone: Customer phone number
		
		Returns:
			Dict with preferences or None
		"""
		try:
			from .doctype.customer_preference.customer_preference import CustomerPreference
			return CustomerPreference.get_customer_preferences(customer_phone)
		except:
			return None
	
	def _apply_preferences(self, shops, preferences):
		"""
		Apply customer preferences to shop list
		
		Args:
			shops: List of shops
			preferences: Customer preferences dict
		
		Returns:
			List of shops with preference applied
		"""
		fulfiller_prefs = preferences.get('fulfiller_preferences', [])
		
		if not fulfiller_prefs:
			return shops
		
		# Check if any preferred fulfiller is in the list
		for pref in fulfiller_prefs:
			shop_name = pref.get('preferred_fulfiller')
			for shop in shops:
				if shop.get('name') == shop_name:
					# Boost preference by adding to distance (negative = closer in sorted list)
					shop['preference_boost'] = -1000
					return shops
		
		return shops
	
	def _create_assignment(self, order_doc, shop, tier, customer_lat, customer_lon):
		"""
		Create an order assignment and start timer
		
		Args:
			order_doc: Order document
			shop: Shop dict
			tier: Distance tier
			customer_lat: Customer latitude
			customer_lon: Customer longitude
		
		Returns:
			Assignment document or None
		"""
		try:
			# Create assignment
			assignment = frappe.get_doc({
				'doctype': 'Order Route Assignment',
				'whatsapp_order': order_doc.name,
				'assigned_shop': shop.get('name'),
				'tier_distance': tier,
				'assignment_status': 'Pending Confirmation',
				'assigned_datetime': now_datetime(),
				'timer_started_at': now_datetime(),
				'timer_expires_at': add_to_date(now_datetime(), seconds=self.confirmation_timeout)
			})
			assignment.insert()
			
			# Send notification to shop (placeholder for future implementation)
			self._notify_shop(shop, order_doc)
			
			return assignment
		except Exception as e:
			frappe.log_error(f"Error creating assignment: {str(e)}")
			return None
	
	def _notify_shop(self, shop, order_doc):
		"""
		Send notification to shop about new order assignment
		
		Args:
			shop: Shop dict
			order_doc: Order document
		"""
		# Import WhatsApp notifier
		from .whatsapp_notifier import WhatsAppNotifier
		
		try:
			# Get shop document
			shop_doc = frappe.get_doc('Delivery Shop', shop.get('name'))
			
			# Get assignment
			assignment = frappe.get_all(
				'Order Route Assignment',
				filters={'whatsapp_order': order_doc.name, 'assigned_shop': shop.get('name')},
				order_by='creation desc',
				limit=1
			)
			
			if assignment:
				assignment_doc = frappe.get_doc('Order Route Assignment', assignment[0].name)
				notifier = WhatsAppNotifier()
				notifier.send_assignment_notification(assignment_doc, shop_doc, order_doc)
		except Exception as e:
			frappe.log_error(f"Error notifying shop: {str(e)}")
	
	def check_expired_assignments(self):
		"""
		Check for assignments that have expired and need to be retried
		Should be called by a scheduled job
		
		Returns:
			Number of expired assignments processed
		"""
		now = now_datetime()
		
		# Find expired pending assignments
		expired = frappe.get_all(
			'Order Route Assignment',
			filters={
				'assignment_status': 'Pending Confirmation',
				'timer_expires_at': ['<', now]
			},
			fields=['name', 'whatsapp_order', 'assigned_shop']
		)
		
		for assignment in expired:
			# Mark as expired
			assignment_doc = frappe.get_doc('Order Route Assignment', assignment.name)
			assignment_doc.assignment_status = 'Expired'
			assignment_doc.save()
			
			# Try to find alternative shop
			self._retry_assignment(assignment.whatsapp_order)
		
		return len(expired)
	
	def _retry_assignment(self, order_name):
		"""
		Retry assignment for an order with next tier shops
		
		Args:
			order_name: Order name
		"""
		# Get order details
		order_doc = frappe.get_doc('Whatsapp Order', order_name)
		
		# This would trigger another assignment attempt
		# Implementation depends on your WhatsApp order structure
		frappe.logger().info(f"Retrying assignment for order {order_name}")


@frappe.whitelist()
def route_order(order_name, item_code=None, quantity=1, customer_lat=None, customer_lon=None):
	"""
	Convenience function to route an order
	
	Args:
		order_name: Order document name
		item_code: Item code (optional)
		quantity: Quantity (optional, default 1)
		customer_lat: Customer latitude (optional, from order)
		customer_lon: Customer longitude (optional, from order)
	
	Returns:
		Routing result dict with success status
	"""
	try:
		engine = OrderRoutingEngine()
		
		# Get WhatsApp Order document
		order_doc = frappe.get_doc('WhatsApp Order', order_name)
		
		# Get GPS coordinates from order or use provided ones
		if not customer_lat:
			customer_lat = float(order_doc.get('customer_latitude') or 0)
		if not customer_lon:
			customer_lon = float(order_doc.get('customer_longitude') or 0)
		
		# Validate GPS coordinates
		if customer_lat == 0 or customer_lon == 0:
			return {
				'success': False,
				'error': 'Customer GPS coordinates not provided. Please add latitude and longitude to the order.'
			}
		
		# Get item info from order if not provided
		if not item_code and order_doc.items:
			item_code = order_doc.items[0].item_name or 'Unknown Item'
			quantity = order_doc.items[0].quantity or 1
		
		# Route the order
		result = engine.find_shop_for_order(order_doc, customer_lat, customer_lon, item_code, quantity)
		
		if result:
			return {
				'success': True,
				'assignment_id': result.get('name'),
				'shop_name': result.get('assigned_shop'),
				'tier_distance': result.get('tier_distance'),
				'message': 'Order successfully routed to nearest shop'
			}
		else:
			return {
				'success': False,
				'error': 'No available shops found with inventory for this order'
			}
	
	except Exception as e:
		frappe.log_error(f"Error routing order {order_name}: {str(e)}")
		return {
			'success': False,
			'error': str(e)
		}
