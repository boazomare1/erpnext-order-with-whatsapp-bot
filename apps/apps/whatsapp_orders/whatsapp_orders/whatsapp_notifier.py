"""
WhatsApp Notification System
Handles sending order notifications to shops and processing confirmations
"""

import frappe
from frappe.utils import now_datetime


class WhatsAppNotifier:
	"""
	Handles WhatsApp notifications for order routing
	"""
	
	def __init__(self):
		self.webhook_url = frappe.conf.get('whatsapp_webhook_url')
	
	def send_assignment_notification(self, assignment_doc, shop_doc, order_doc):
		"""
		Send notification to shop about new order assignment
		
		Args:
			assignment_doc: Order Route Assignment document
			shop_doc: Delivery Shop document
			order_doc: WhatsApp Order document
		
		Returns:
			True if sent successfully
		"""
		try:
			# Get shop phone number
			shop_phone = shop_doc.get('phone_number')
			if not shop_phone:
				frappe.log_error("Shop has no phone number", "WhatsApp Notification Failed")
				return False
			
			# Create message
			message = self._create_assignment_message(assignment_doc, shop_doc, order_doc)
			
			# Send WhatsApp message
			success = self._send_whatsapp_message(shop_phone, message)
			
			if success:
				# Log notification
				self._log_notification(assignment_doc.name, shop_phone, 'sent')
			
			return success
		
		except Exception as e:
			frappe.log_error(f"Error sending notification: {str(e)}")
			return False
	
	def _create_assignment_message(self, assignment_doc, shop_doc, order_doc):
		"""
		Create assignment notification message
		
		Args:
			assignment_doc: Order Route Assignment
			shop_doc: Delivery Shop
			order_doc: Order
		
		Returns:
			Formatted message string
		"""
		customer_phone = order_doc.get('customer_phone', 'N/A')
		item_name = order_doc.get('item_name', 'N/A')
		quantity = order_doc.get('quantity', 1)
		tier = assignment_doc.tier_distance
		
		# Get remaining time
		timer_status = assignment_doc.get_timer_status()
		remaining_time = timer_status.get('remaining_seconds', 0)
		minutes = remaining_time // 60
		seconds = remaining_time % 60
		
		message = f"""
🆕 *New Order Assignment*

📦 *Order:* #{order_doc.name}
👤 *Customer:* {customer_phone}
📱 *Item:* {item_name}
🔢 *Quantity:* {quantity}
📍 *Distance:* ~{tier}m from customer

⏰ *Action Required:* 
You have *{minutes} min {seconds} sec* to confirm this order.

*Reply with:*
✅ "CONFIRM" or "YES" to accept
❌ "REJECT" or "NO" to decline

_This assignment will expire automatically if not confirmed._
"""
		return message.strip()
	
	def send_confirmation_notification(self, assignment_doc, status, customer_phone):
		"""
		Send confirmation notification to customer
		
		Args:
			assignment_doc: Order Route Assignment
			status: 'confirmed' or 'rejected'
			customer_phone: Customer phone number
		
		Returns:
			True if sent successfully
		"""
		try:
			if status == 'confirmed':
				message = self._create_confirmed_message(assignment_doc)
			else:
				message = self._create_rejected_message(assignment_doc)
			
			# Send to customer
			success = self._send_whatsapp_message(customer_phone, message)
			
			return success
		
		except Exception as e:
			frappe.log_error(f"Error sending confirmation: {str(e)}")
			return False
	
	def _create_confirmed_message(self, assignment_doc):
		"""Create confirmed order message"""
		shop = frappe.get_doc('Delivery Shop', assignment_doc.assigned_shop)
		
		message = f"""
✅ *Order Confirmed!*

Your order has been confirmed and is being prepared for delivery.

🏪 *Shop:* {shop.shop_name}
📍 *Location:* {shop.county}, {shop.constituency}
🆕 *Order ID:* #{assignment_doc.whatsapp_order}

We'll update you once your order is ready for pickup or delivery.

Thank you for your order! 🙏
"""
		return message.strip()
	
	def _create_rejected_message(self, assignment_doc):
		"""Create rejected order message"""
		message = f"""
⏳ *Finding Alternative Shop*

The assigned shop is unable to fulfill your order at this time.

We're automatically finding the next nearest shop with available inventory.

🔄 *Status:* Searching...
📦 *Order ID:* #{assignment_doc.whatsapp_order}

We'll notify you as soon as we find an available shop.

Thank you for your patience! 🙏
"""
		return message.strip()
	
	def _send_whatsapp_message(self, phone_number, message):
		"""
		Send WhatsApp message via webhook
		
		Args:
			phone_number: Recipient phone number
			message: Message text
		
		Returns:
			True if sent successfully
		"""
		# TODO: Implement actual WhatsApp API integration
		# For now, log the message
		frappe.logger().info(f"WhatsApp notification to {phone_number}: {message[:100]}...")
		
		# Placeholder for actual WhatsApp API call
		# import requests
		# response = requests.post(self.webhook_url, json={
		#     'to': phone_number,
		#     'message': message
		# })
		# return response.status_code == 200
		
		return True
	
	def _log_notification(self, assignment_name, recipient, status):
		"""Log notification to database"""
		try:
			frappe.get_doc({
				'doctype': 'Notification Log',
				'reference_doctype': 'Order Route Assignment',
				'reference_name': assignment_name,
				'recipient': recipient,
				'status': status,
				'sent_at': now_datetime()
			}).insert(ignore_permissions=True)
		except:
			pass  # Log silently if doctype doesn't exist
	
	def process_shop_response(self, phone_number, message):
		"""
		Process shop response (confirm/reject) from WhatsApp
		
		Args:
			phone_number: Shop phone number
			message: Received message
		
		Returns:
			Response processing result
		"""
		# Normalize message
		message = message.strip().upper()
		
		# Get shop
		shop = frappe.db.exists('Delivery Shop', {'phone_number': phone_number})
		if not shop:
			return {'success': False, 'message': 'Shop not found'}
		
		# Get pending assignments for this shop
		assignments = frappe.get_all(
			'Order Route Assignment',
			filters={
				'assigned_shop': shop,
				'assignment_status': 'Pending Confirmation'
			},
			order_by='assigned_datetime desc',
			limit=1
		)
		
		if not assignments:
			return {'success': False, 'message': 'No pending assignments'}
		
		assignment_name = assignments[0].name
		assignment_doc = frappe.get_doc('Order Route Assignment', assignment_name)
		
		# Check for confirmation keywords
		if any(keyword in message for keyword in ['CONFIRM', 'YES', 'ACCEPT', 'OK']):
			# Confirm assignment
			try:
				assignment_doc.confirm_assignment()
				
				# Notify customer
				order_doc = frappe.get_doc('Whatsapp Order', assignment_doc.whatsapp_order)
				self.send_confirmation_notification(
					assignment_doc,
					'confirmed',
					order_doc.customer_phone
				)
				
				return {
					'success': True,
					'message': 'Order confirmed successfully!',
					'order_id': assignment_doc.whatsapp_order
				}
			except Exception as e:
				return {'success': False, 'message': str(e)}
		
		elif any(keyword in message for keyword in ['REJECT', 'NO', 'DECLINE']):
			# Reject assignment
			try:
				assignment_doc.reject_assignment()
				
				return {
					'success': True,
					'message': 'Order rejected. Finding alternative shop...'
				}
			except Exception as e:
				return {'success': False, 'message': str(e)}
		
		else:
			return {
				'success': False,
				'message': 'Please reply with CONFIRM or REJECT'
			}
