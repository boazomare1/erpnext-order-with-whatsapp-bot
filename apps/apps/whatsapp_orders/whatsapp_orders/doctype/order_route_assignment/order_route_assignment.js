frappe.listview_settings['Order Route Assignment'] = {
	add_fields: ["assignment_status", "tier_distance"],
	
	get_indicator: function(doc) {
		if (doc.assignment_status === 'Confirmed') {
			return [__("Confirmed"), "green", "assignment_status,=,Confirmed"];
		} else if (doc.assignment_status === 'Pending Confirmation') {
			return [__("Pending"), "orange", "assignment_status,=,Pending Confirmation"];
		} else if (doc.assignment_status === 'Rejected') {
			return [__("Rejected"), "red", "assignment_status,=,Rejected"];
		} else if (doc.assignment_status === 'Expired') {
			return [__("Expired"), "grey", "assignment_status,=,Expired"];
		}
	},
	
	formatters: {
		tier_distance: function(value) {
			return value ? value + 'm' : '';
		}
	},
	
	onload: function(listview) {
		// Add custom button to check expired assignments
		listview.page.add_inner_button(__("Check Expired Assignments"), function() {
			frappe.call({
				method: 'whatsapp_orders.doctype.order_route_assignment.order_route_assignment.OrderRouteAssignment.check_and_expire_assignments',
				callback: function(r) {
					if (r.message) {
						frappe.show_alert({
							message: __('Processed ' + r.message + ' expired assignments'),
							indicator: 'green'
						});
						listview.refresh();
					}
				}
			});
		});
	}
};

// Form hooks
frappe.ui.form.on('Order Route Assignment', {
	refresh: function(frm) {
		// Show timer countdown
		if (frm.doc.assignment_status === 'Pending Confirmation' && frm.doc.timer_expires_at) {
			frm.dashboard.add_indicator(__("Timer Active - Check remaining seconds"), "orange");
		}
		
		// Add confirm/reject buttons for shops
		if (frm.doc.assignment_status === 'Pending Confirmation') {
			frm.add_custom_button(__('Confirm'), function() {
				frappe.confirm(
					__('Are you sure you want to confirm this assignment?'),
					function() {
						frappe.call({
							method: 'whatsapp_orders.doctype.order_route_assignment.order_route_assignment.OrderRouteAssignment.confirm_assignment',
							args: {
								assignment_name: frm.doc.name
							},
							callback: function(r) {
								if (r.message) {
									frappe.show_alert({
										message: __('Assignment confirmed successfully'),
										indicator: 'green'
									});
									frm.reload_doc();
								}
							}
						});
					}
				);
			}, __('Actions'));
			
			frm.add_custom_button(__('Reject'), function() {
				frappe.prompt({
					label: __('Rejection Reason'),
					fieldname: 'reason',
					fieldtype: 'Small Text',
					default: ''
				}, function(values) {
					frappe.call({
						method: 'whatsapp_orders.doctype.order_route_assignment.order_route_assignment.OrderRouteAssignment.reject_assignment',
						args: {
							assignment_name: frm.doc.name,
							reason: values.reason
						},
						callback: function(r) {
							if (r.message) {
								frappe.show_alert({
									message: __('Assignment rejected'),
									indicator: 'orange'
								});
								frm.reload_doc();
							}
						}
					});
				}, __('Reject Assignment'), __('Reject'));
			}, __('Actions'));
		}
		
		// Show assignment info
		if (frm.doc.assigned_shop) {
			frm.dashboard.add_indicator(__("Shop: " + frm.doc.assigned_shop), "blue");
		}
		
		if (frm.doc.tier_distance) {
			frm.dashboard.add_indicator(__("Distance: ~" + frm.doc.tier_distance + "m"), "blue");
		}
	}
});
