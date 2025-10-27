import frappe
from frappe.model.document import Document
from frappe.utils import now_datetime, time_diff_in_seconds

class OrderRouteAssignment(Document):
	def validate(self):
		"""Validate assignment"""
		# Update remaining seconds if timer is active
		if self.assignment_status == 'Pending Confirmation' and self.timer_expires_at:
			self._update_remaining_seconds()
	
	def _update_remaining_seconds(self):
		"""Calculate and update remaining seconds"""
		if self.timer_expires_at:
			remaining = time_diff_in_seconds(self.timer_expires_at, now_datetime())
			self.remaining_seconds = max(0, remaining)
	
	def confirm_assignment(self, notes=None):
		"""
		Confirm the order assignment
		
		Args:
			notes: Optional notes
		
		Returns:
			True if confirmed successfully
		"""
		if self.assignment_status != 'Pending Confirmation':
			frappe.throw(f"Cannot confirm assignment. Current status: {self.assignment_status}")
		
		# Check if timer has expired
		if self.timer_expires_at and now_datetime() > self.timer_expires_at:
			frappe.throw("Assignment timer has expired. Please retry assignment.")
		
		self.assignment_status = 'Confirmed'
		self.confirmed_datetime = now_datetime()
		
		if notes:
			self.notes = notes
		
		self.save()
		
		# Update related order if needed
		self._update_order_status()
		
		return True
	
	def reject_assignment(self, reason=None):
		"""
		Reject the order assignment
		
		Args:
			reason: Rejection reason
		
		Returns:
			True if rejected successfully
		"""
		if self.assignment_status not in ['Pending Confirmation', 'Expired']:
			frappe.throw(f"Cannot reject assignment. Current status: {self.assignment_status}")
		
		self.assignment_status = 'Rejected'
		self.rejected_datetime = now_datetime()
		
		if reason:
			self.notes = reason
		
		self.save()
		
		# Trigger retry logic
		self._trigger_retry()
		
		return True
	
	def is_expired(self):
		"""
		Check if assignment timer has expired
		
		Returns:
			True if expired
		"""
		if not self.timer_expires_at:
			return False
		return now_datetime() > self.timer_expires_at
	
	def get_timer_status(self):
		"""
		Get timer status information
		
		Returns:
			Dict with timer status
		"""
		if not self.timer_expires_at:
			return {
				'status': 'no_timer',
				'remaining_seconds': 0
			}
		
		self._update_remaining_seconds()
		
		if self.is_expired():
			return {
				'status': 'expired',
				'remaining_seconds': 0
			}
		
		return {
			'status': 'active',
			'remaining_seconds': self.remaining_seconds,
			'expires_at': self.timer_expires_at
		}
	
	def _update_order_status(self):
		"""Update related WhatsApp order status"""
		try:
			order = frappe.get_doc('Whatsapp Order', self.whatsapp_order)
			# Add any order status update logic here
			# order.status = 'Assigned'
			# order.save()
		except:
			pass
	
	def _trigger_retry(self):
		"""Trigger retry assignment logic"""
		try:
			from ..routing_engine import OrderRoutingEngine
			engine = OrderRoutingEngine()
			engine._retry_assignment(self.whatsapp_order)
		except Exception as e:
			frappe.log_error(f"Error triggering retry: {str(e)}")
	
	@staticmethod
	def get_pending_assignments_for_shop(shop_name):
		"""
		Get pending assignments for a specific shop
		
		Args:
			shop_name: Shop name
		
		Returns:
			List of pending assignments
		"""
		return frappe.get_all(
			'Order Route Assignment',
			filters={
				'assigned_shop': shop_name,
				'assignment_status': 'Pending Confirmation'
			},
			fields=['name', 'whatsapp_order', 'assigned_datetime', 'tier_distance', 'timer_expires_at'],
			order_by='assigned_datetime desc'
		)
	
	@staticmethod
	def check_and_expire_assignments():
		"""
		Check for expired assignments and mark them as expired
		Should be called by a scheduled job
		
		Returns:
			Number of expired assignments
		"""
		from ..routing_engine import OrderRoutingEngine
		engine = OrderRoutingEngine()
		return engine.check_expired_assignments()
