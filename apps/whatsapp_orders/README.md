# WhatsApp Orders

A Frappe application for managing WhatsApp orders with status tracking and customer management.

## Features

- WhatsApp Order management
- Order status tracking (New, Confirmed, Processing, Shipped, Delivered, Cancelled)
- Customer information management
- Order priority system
- Assignment to users
- Custom order ID generation

## Installation

1. Install the app in your Frappe bench:
```bash
bench get-app whatsapp_orders
bench install-app whatsapp_orders
```

2. Migrate the database:
```bash
bench migrate
```

## Usage

1. Navigate to the WhatsApp Orders module in your ERPNext instance
2. Create new orders or manage existing ones
3. Update order status as orders progress through the workflow
4. Assign orders to specific users for better management

## DocType

### WhatsApp Order

Fields:
- Order ID (auto-generated)
- Customer Name
- Customer Phone
- Order Date
- Status (dropdown with predefined options)
- Total Amount
- Notes
- WhatsApp Message ID
- Delivery Address
- Payment Method
- Priority
- Assigned To

## License

MIT



