# Copyright (c) 2025, Your Name and contributors
# For license information, please see license.txt

import frappe
from frappe.model.document import Document


class WhatsAppOrderNew(Document):
	# this will auto-save on creation
	def autoname(self):
		if not self.order_id:
			self.order_id = self.generate_order_id()
	
	def generate_order_id(self):
		# Generate a unique order ID
		import random
		import string
		
		# Create a prefix based on date
		from datetime import datetime
		date_prefix = datetime.now().strftime("%Y%m%d")
		
		# Generate random suffix
		suffix = ''.join(random.choices(string.ascii_uppercase + string.digits, k=6))
		
		order_id = f"WON{date_prefix}{suffix}"
		
		# Check if this order ID already exists
		if frappe.db.exists("WhatsApp Order New", order_id):
			return self.generate_order_id()  # Recursive call if exists
		
		return order_id
	
	def before_save(self):
		# Set created_by and modified_by
		if not self.created_by:
			self.created_by = frappe.session.user
		self.modified_by = frappe.session.user
	
	def validate(self):
		# Add any validation logic here
		if self.total_amount and self.total_amount < 0:
			frappe.throw("Total amount cannot be negative")
	
	def on_update(self):
		# This method is called after the document is updated
		# You can add logic here to send notifications, update other records, etc.
		pass

