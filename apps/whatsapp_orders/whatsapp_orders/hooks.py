from . import __version__ as app_version

app_name = "whatsapp_orders"
app_title = "WhatsApp Orders"
app_publisher = "Your Name"
app_description = "WhatsApp Order Management System"
app_icon = "octicon octicon-file-directory"
app_color = "grey"
app_email = "your.email@example.com"
app_license = "MIT"

# DocType to be automatically created
fixtures = [
	{"dt": "Custom Field", "filters": [["name", "in", ["WhatsApp Order"]]]},
]

# Includes in <head>
# ------------------

# include js, css files in header of desk.html
# app_include_css = "/assets/whatsapp_orders/css/whatsapp_orders.css"
# app_include_js = "/assets/whatsapp_orders/js/whatsapp_orders.js"

# include js, css files in header of web template
# web_include_css = "/assets/whatsapp_orders/css/whatsapp_orders.css"
# web_include_js = "/assets/whatsapp_orders/js/whatsapp_orders.js"

# include custom scss in every website theme (without file extension ".scss")
# website_theme_scss = "whatsapp_orders/public/scss/website"

# include js, css files in header of web form
# webform_include_js = {"doctype": "public/js/doctype.js"}
# webform_include_css = {"doctype": "public/css/doctype.css"}

# include js in page
# page_js = {"page" : "public/js/file.js"}

# include js in doctype views
# doctype_js = {"doctype" : "public/js/doctype.js"}
# doctype_list_js = {"doctype" : "public/js/doctype_list.js"}
# doctype_tree_js = {"doctype" : "public/js/doctype_tree.js"}
# doctype_calendar_js = {"doctype" : "public/js/doctype_calendar.js"}

# Home Pages
# ----------

# application home page (will override Website Settings)
# home_page = "login"

# website user home page (by Role)
# role_home_page = {
#	"Role": "home_page"
# }

# Generators
# ----------

# automatically create page for each record of this doctype
# website_generators = ["Web Page"]

# Jinja
# ----------

# add methods and filters to jinja environment
# jinja = {
#	"methods": "whatsapp_orders.utils.jinja_methods",
#	"filters": "whatsapp_orders.utils.jinja_filters"
# }

# Installation
# ------------

# before_install = "whatsapp_orders.install.before_install"
# after_install = "whatsapp_orders.install.after_install"

# Uninstallation
# ------------

# before_uninstall = "whatsapp_orders.uninstall.before_uninstall"
# after_uninstall = "whatsapp_orders.uninstall.after_uninstall"

# Desk Notifications
# ------------------
# See frappe.core.notifications.get_notification_config

# notification_config = "whatsapp_orders.notifications.get_notification_config"

# Permissions
# -----------
# Permissions evaluated in scripted ways

# permission_query_conditions = {
#	"Event": "frappe.desk.doctype.event.event.get_permission_query_conditions",
# }
#
# has_permission = {
#	"Event": "frappe.desk.doctype.event.event.has_permission",
# }

# DocType Class
# ---------------
# Override standard doctype classes

# override_doctype_class = {
#	"ToDo": "custom_app.overrides.CustomToDo"
# }

# Document Events
# ---------------
# Hook on document methods and events

# doc_events = {
#	"*": {
#		"on_update": "method",
#		"on_cancel": "method",
#		"on_trash": "method"
#	}
# }

# Scheduled Tasks
# ---------------

# scheduler_events = {
#	"all": [
#		"whatsapp_orders.tasks.all"
#	],
#	"daily": [
#		"whatsapp_orders.tasks.daily"
#	],
#	"hourly": [
#		"whatsapp_orders.tasks.hourly"
#	],
#	"weekly": [
#		"whatsapp_orders.tasks.weekly"
#	],
#	"monthly": [
#		"whatsapp_orders.tasks.monthly"
#	],
# }

# Testing
# -------

# before_tests = "whatsapp_orders.install.before_tests"

# Overriding Methods
# ------------------------------
#
# override_whitelisted_methods = {
#	"frappe.desk.doctype.event.event.get_events": "whatsapp_orders.event.get_events"
# }
#
# each overriding function accepts a `data` argument;
# generated from the base function, along with a `data` argument,
# the original function name is appended as `_original`
#
# override_whitelisted_methods = {
#	"frappe.desk.doctype.event.event.get_events": "whatsapp_orders.event.get_events"
# }

# exempt linked doctypes from being automatically cancelled
#
# auto_cancel_exempted_doctypes = ["Auto Repeat"]


# User Data Protection
# --------------------

# user_data_fields = [
#	{
#		"doctype": "{doctype_1}",
#		"filter_by": "{filter_by}",
#		"redact_fields": ["{field_1}", "{field_2}"],
#		"partial": 1,
#	},
#	{
#		"doctype": "{doctype_2}",
#		"filter_by": "{filter_by}",
#		"partial": 1,
#	},
#	{
#		"doctype": "{doctype_3}",
#		"strict": False,
#	},
#	{
#		"doctype": "{doctype_4}"
#	}
# ]

# Authentication and authorization
# --------------------------------

# auth_hooks = [
#	"whatsapp_orders.auth.validate"
# ]

# Translation
# --------------------------------

# Make link fields search translated document names for these DocTypes
# Recommended only for DocTypes which have limited documents with untranslated names
# For example: Role, Gender, etc.
# translated_search_doctypes = []



