// Copyright (c) 2025, Your Name and contributors
// For license information, please see license.txt

frappe.listview_settings['WhatsApp Order New'] = {
	// add_fields: ["customer_name", "status", "total_amount"],
	// filters: [["status", "!=", "Cancelled"]],
	
	onload: function(listview) {
		// Add custom filters
		listview.page.add_inner_button(__("Export Orders"), function() {
			frappe.route_options = {
				"status": listview.filter_area.get("status")
			};
			frappe.set_route("query-report", "WhatsApp Orders Report");
		});
	},
	
	refresh: function(listview) {
		// Add custom buttons
		listview.page.add_inner_button(__("Bulk Update Status"), function() {
			frappe.msgprint("Bulk update functionality can be added here");
		});
	},
	
	get_indicator: function(doc) {
		const status_colors = {
			"New": "red",
			"Confirmed": "orange", 
			"Processing": "blue",
			"Shipped": "purple",
			"Delivered": "green",
			"Cancelled": "grey"
		};
		return [__(doc.status), status_colors[doc.status], "status,=," + doc.status];
	}
};

