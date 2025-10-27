frappe.listview_settings['Delivery Shop'] = {
	add_fields: ["status", "active"],
	get_indicator: function(doc) {
		if (doc.status === 'Active' && doc.active) {
			return [__("Active"), "green", "status,=,Active|active,=,1"];
		} else if (doc.status === 'Inactive' || !doc.active) {
			return [__("Inactive"), "grey", "status,=,Inactive|active,=,0"];
		} else if (doc.status === 'Under Maintenance') {
			return [__("Under Maintenance"), "orange", "status,=,Under Maintenance"];
		}
	},
	formatters: {
		gps_latitude: function(value) {
			return value ? value.toFixed(6) : '';
		},
		gps_longitude: function(value) {
			return value ? value.toFixed(6) : '';
		}
	}
};
