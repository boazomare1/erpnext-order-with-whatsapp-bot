// Copyright (c) 2025, Your Name and contributors
// For license information, please see license.txt

frappe.ui.form.on('WhatsApp Order', {
	refresh: function(frm) {
		// Add custom buttons or actions here
		if (frm.doc.status === 'New') {
			frm.add_custom_button(__('Confirm Order'), function() {
				frm.set_value('status', 'Confirmed');
				frm.save();
			});
		}
		
		if (frm.doc.status === 'Confirmed') {
			frm.add_custom_button(__('Start Processing'), function() {
				frm.set_value('status', 'Processing');
				frm.save();
			});
		}
		
		if (frm.doc.status === 'Processing') {
			frm.add_custom_button(__('Mark as Shipped'), function() {
				frm.set_value('status', 'Shipped');
				frm.save();
			});
		}
	},
	
	order_date: function(frm) {
		// Auto-fill order date if not set
		if (!frm.doc.order_date) {
			frm.set_value('order_date', frappe.datetime.now_datetime());
		}
	},
	
	customer_phone: function(frm) {
		// Format phone number
		if (frm.doc.customer_phone) {
			let phone = frm.doc.customer_phone.replace(/\D/g, '');
			if (phone.startsWith('254')) {
				frm.set_value('customer_phone', '+' + phone);
			} else if (phone.startsWith('0')) {
				frm.set_value('customer_phone', '+254' + phone.substring(1));
			}
		}
	}
});




