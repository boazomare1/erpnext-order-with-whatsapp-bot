import frappe
from frappe.model.document import Document
from frappe.utils import now_datetime

class CustomerPreference(Document):
	def validate(self):
		"""Validate preference data"""
		# Ensure either SKU or Fulfiller is set based on type
		if self.preference_type == 'Preferred SKU' and not self.preferred_sku:
			frappe.throw("Please select a Preferred SKU")
		
		if self.preference_type == 'Preferred Fulfiller' and not self.preferred_fulfiller:
			frappe.throw("Please select a Preferred Fulfiller (Shop)")
		
		# Validate preference score range
		if self.preference_score and not (0 <= self.preference_score <= 100):
			frappe.throw("Preference Score must be between 0 and 100")
	
	def record_usage(self):
		"""Record that this preference was used"""
		self.usage_count = (self.usage_count or 0) + 1
		self.last_used = now_datetime()
		
		# Increase preference score (capped at 100)
		self.preference_score = min(100, (self.preference_score or 0) + 5)
		self.save()
	
	@staticmethod
	def get_customer_preferences(customer_phone):
		"""
		Get all preferences for a customer
		
		Args:
			customer_phone: Customer phone number
		
		Returns:
			Dict with 'sku_preferences' and 'fulfiller_preferences' lists
		"""
		customer = frappe.db.exists('Customer', {'phone_number': customer_phone})
		if not customer:
			return {'sku_preferences': [], 'fulfiller_preferences': []}
		
		sku_prefs = frappe.get_all(
			'Customer Preference',
			filters={
				'customer': customer,
				'preference_type': 'Preferred SKU',
				'preferred_sku': ['!=', '']
			},
			fields=['preferred_sku', 'preference_score', 'usage_count'],
			order_by='preference_score desc'
		)
		
		fulfiller_prefs = frappe.get_all(
			'Customer Preference',
			filters={
				'customer': customer,
				'preference_type': 'Preferred Fulfiller',
				'preferred_fulfiller': ['!=', '']
			},
			fields=['preferred_fulfiller', 'preference_score', 'usage_count'],
			order_by='preference_score desc'
		)
		
		return {
			'sku_preferences': sku_prefs,
			'fulfiller_preferences': fulfiller_prefs
		}
	
	@staticmethod
	def update_or_create_preference(customer_phone, preference_type, item_or_shop, score_increment=10):
		"""
		Update existing preference or create new one
		
		Args:
			customer_phone: Customer phone number
			preference_type: 'Preferred SKU' or 'Preferred Fulfiller'
			item_or_shop: Item code or Shop name
			score_increment: How much to increase the score
		
		Returns:
			Customer Preference document
		"""
		customer = frappe.db.exists('Customer', {'phone_number': customer_phone})
		if not customer:
			return None
		
		# Determine which field to search
		filter_field = 'preferred_sku' if preference_type == 'Preferred SKU' else 'preferred_fulfiller'
		
		# Check if preference already exists
		existing = frappe.get_all(
			'Customer Preference',
			filters={
				'customer': customer,
				'preference_type': preference_type,
				filter_field: item_or_shop
			},
			limit=1
		)
		
		if existing:
			# Update existing preference
			pref = frappe.get_doc('Customer Preference', existing[0].name)
			pref.preference_score = min(100, (pref.preference_score or 0) + score_increment)
			pref.usage_count = (pref.usage_count or 0) + 1
			pref.last_used = now_datetime()
		else:
			# Create new preference
			pref_data = {
				'doctype': 'Customer Preference',
				'customer': customer,
				'preference_type': preference_type,
				'preference_score': score_increment
			}
			pref_data[filter_field] = item_or_shop
			
			pref = frappe.get_doc(pref_data)
		
		pref.save()
		return pref
