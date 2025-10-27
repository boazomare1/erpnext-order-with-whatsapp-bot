# WhatsApp Order Management API Documentation

## Overview
This API provides comprehensive order management functionality for WhatsApp orders in ERPNext. All endpoints require authentication via ERPNext login.

## Base URL
```
http://localhost:8001
```

## Authentication
All API calls require ERPNext authentication. First, login to get session cookies:

### Login
```bash
curl -X POST "http://localhost:8001/api/method/login" \
  -d "usr=Administrator&pwd=admin" \
  -c cookies.txt
```

## API Endpoints

### 1. Create Order
**Endpoint:** `POST /api/method/frappe.custom.doctype.whatsapp_order.api.create_order`

**Description:** Create a new WhatsApp order with items.

**Request Body:**
```json
{
  "customer_name": "John Doe",
  "customer_phone": "254770534365",
  "delivery_address": "123 Test Street, Nairobi",
  "payment_method": "Cash on Delivery",
  "items": [
    {
      "item_name": "LPG Cylinder 6kg",
      "description": "6kg LPG Cylinder",
      "quantity": 2,
      "unit_price": 1200
    },
    {
      "item_name": "LPG Regulator",
      "description": "LPG Pressure Regulator",
      "quantity": 1,
      "unit_price": 500
    }
  ]
}
```

**Response:**
```json
{
  "message": {
    "success": true,
    "message": "Order created successfully",
    "order": {
      "name": "WOR-2025-00021",
      "customer_name": "John Doe",
      "customer_phone": "254770534365",
      "status": "New",
      "total_amount": 2400.0,
      "order_date": "2025-10-06 10:57:17.613999"
    }
  }
}
```

### 2. Get Order
**Endpoint:** `POST /api/method/frappe.custom.doctype.whatsapp_order.api.get_order`

**Description:** Get order details by ID.

**Request Body:**
```json
{
  "order_id": "WOR-2025-00021"
}
```

**Response:**
```json
{
  "message": {
    "success": true,
    "order": {
      "name": "WOR-2025-00021",
      "customer_name": "John Doe",
      "customer_phone": "254770534365",
      "order_date": "2025-10-06 10:57:17.613999",
      "status": "New",
      "delivery_address": "123 Test Street, Nairobi",
      "payment_method": "Cash on Delivery",
      "total_amount": 2400.0,
      "items": [
        {
          "item_name": "LPG Cylinder 6kg",
          "description": "6kg LPG Cylinder",
          "quantity": 2,
          "unit_price": 1200.0,
          "amount": 2400.0
        }
      ]
    }
  }
}
```

### 3. List Orders
**Endpoint:** `POST /api/method/frappe.custom.doctype.whatsapp_order.api.list_orders`

**Description:** List orders with optional filtering.

**Request Body:**
```json
{
  "status": "New",
  "customer_phone": "254770534365",
  "limit": 10,
  "offset": 0
}
```

**Parameters:**
- `status` (optional): Filter by status (New, Confirmed, Processing, Shipped, Delivered, Cancelled)
- `customer_name` (optional): Filter by customer name (partial match)
- `customer_phone` (optional): Filter by exact phone number
- `limit` (optional): Number of records to return (default: 20)
- `offset` (optional): Number of records to skip (default: 0)

**Response:**
```json
{
  "message": {
    "success": true,
    "orders": [
      {
        "name": "WOR-2025-00021",
        "customer_name": "John Doe",
        "customer_phone": "254770534365",
        "status": "New",
        "total_amount": 2400.0,
        "order_date": "2025-10-06 10:57:17.613999"
      }
    ],
    "count": 1
  }
}
```

### 4. Update Order Status
**Endpoint:** `POST /api/method/frappe.custom.doctype.whatsapp_order.api.update_order_status`

**Description:** Update order status.

**Request Body:**
```json
{
  "order_id": "WOR-2025-00021",
  "status": "Confirmed"
}
```

**Valid Status Values:**
- `New`
- `Confirmed`
- `Processing`
- `Shipped`
- `Delivered`
- `Cancelled`

**Response:**
```json
{
  "message": {
    "success": true,
    "message": "Order status updated to Confirmed",
    "order": {
      "name": "WOR-2025-00021",
      "status": "Confirmed"
    }
  }
}
```

### 5. Cancel Order
**Endpoint:** `POST /api/method/frappe.custom.doctype.whatsapp_order.api.cancel_order`

**Description:** Cancel an order with reason.

**Request Body:**
```json
{
  "order_id": "WOR-2025-00021",
  "reason": "Customer requested cancellation"
}
```

**Response:**
```json
{
  "message": {
    "success": true,
    "message": "Order WOR-2025-00021 cancelled successfully",
    "order": {
      "name": "WOR-2025-00021",
      "status": "Cancelled",
      "cancellation_reason": "Customer requested cancellation"
    }
  }
}
```

### 6. Duplicate Order
**Endpoint:** `POST /api/method/frappe.custom.doctype.whatsapp_order.api.duplicate_order`

**Description:** Duplicate an existing order (reorder).

**Request Body:**
```json
{
  "order_id": "WOR-2025-00021"
}
```

**Response:**
```json
{
  "message": {
    "success": true,
    "message": "Order duplicated successfully",
    "original_order": "WOR-2025-00021",
    "new_order": {
      "name": "WOR-2025-00022",
      "customer_name": "John Doe",
      "customer_phone": "254770534365",
      "status": "New",
      "total_amount": 2400.0,
      "order_date": "2025-10-06 10:57:47.118358"
    }
  }
}
```

### 7. Search Orders
**Endpoint:** `POST /api/method/frappe.custom.doctype.whatsapp_order.api.search_orders`

**Description:** Search orders by customer name, phone, or order ID.

**Request Body:**
```json
{
  "query": "John",
  "limit": 10
}
```

**Response:**
```json
{
  "message": {
    "success": true,
    "orders": [
      {
        "name": "WOR-2025-00021",
        "customer_name": "John Doe",
        "customer_phone": "254770534365",
        "status": "New",
        "total_amount": 2400.0,
        "order_date": "2025-10-06 10:57:17.613999"
      }
    ],
    "count": 1,
    "query": "John"
  }
}
```

### 8. Add Item to Order
**Endpoint:** `POST /api/method/frappe.custom.doctype.whatsapp_order.api.add_item_to_order`

**Description:** Add item to existing order.

**Request Body:**
```json
{
  "order_id": "WOR-2025-00021",
  "item_name": "LPG Accessory",
  "quantity": 1,
  "unit_price": 500,
  "description": "LPG Regulator"
}
```

**Response:**
```json
{
  "message": {
    "success": true,
    "message": "Item added to order",
    "order": {
      "name": "WOR-2025-00021",
      "total_amount": 2900.0
    }
  }
}
```

### 9. Remove Item from Order
**Endpoint:** `POST /api/method/frappe.custom.doctype.whatsapp_order.api.remove_item_from_order`

**Description:** Remove item from order by index.

**Request Body:**
```json
{
  "order_id": "WOR-2025-00021",
  "item_index": 0
}
```

**Response:**
```json
{
  "message": {
    "success": true,
    "message": "Item removed from order",
    "order": {
      "name": "WOR-2025-00021",
      "total_amount": 2400.0
    }
  }
}
```

### 10. Get Order Statistics
**Endpoint:** `POST /api/method/frappe.custom.doctype.whatsapp_order.api.get_order_statistics`

**Description:** Get order statistics and analytics.

**Request Body:**
```json
{}
```

**Response:**
```json
{
  "message": {
    "success": true,
    "statistics": {
      "total_orders": 20,
      "total_revenue": 45392.5,
      "recent_orders": 20,
      "status_breakdown": [
        {
          "status": "Confirmed",
          "count": 3
        },
        {
          "status": "New",
          "count": 14
        },
        {
          "status": "Processing",
          "count": 1
        },
        {
          "status": "Shipped",
          "count": 2
        }
      ]
    }
  }
}
```

## Error Responses

All endpoints return error responses in the following format:

```json
{
  "success": false,
  "message": "Error description"
}
```

Common error scenarios:
- **Order not found**: When trying to access a non-existent order
- **Invalid parameters**: When required parameters are missing or invalid
- **Authentication required**: When not logged in to ERPNext

## Testing with cURL

### Complete Test Sequence
```bash
# 1. Login
curl -X POST "http://localhost:8001/api/method/login" \
  -d "usr=Administrator&pwd=admin" \
  -c cookies.txt

# 2. Create Order
curl -b cookies.txt -X POST "http://localhost:8001/api/method/frappe.custom.doctype.whatsapp_order.api.create_order" \
  -H "Content-Type: application/json" \
  -d '{"customer_name": "Test Customer", "customer_phone": "254770534365", "delivery_address": "Test Address", "items": [{"item_name": "Test Item", "quantity": 1, "unit_price": 100, "description": "Test"}]}'

# 3. Get Order
curl -b cookies.txt -X POST "http://localhost:8001/api/method/frappe.custom.doctype.whatsapp_order.api.get_order" \
  -H "Content-Type: application/json" \
  -d '{"order_id": "WOR-2025-00021"}'

# 4. List Orders
curl -b cookies.txt -X POST "http://localhost:8001/api/method/frappe.custom.doctype.whatsapp_order.api.list_orders" \
  -H "Content-Type: application/json" \
  -d '{"limit": 5}'

# 5. Update Status
curl -b cookies.txt -X POST "http://localhost:8001/api/method/frappe.custom.doctype.whatsapp_order.api.update_order_status" \
  -H "Content-Type: application/json" \
  -d '{"order_id": "WOR-2025-00021", "status": "Confirmed"}'

# 6. Get Statistics
curl -b cookies.txt -X POST "http://localhost:8001/api/method/frappe.custom.doctype.whatsapp_order.api.get_order_statistics" \
  -H "Content-Type: application/json"
```

## Postman Collection

Import the provided Postman collection file: `WhatsApp_Order_Management_API.postman_collection.json`

The collection includes:
- Pre-configured requests for all endpoints
- Example request bodies
- Environment variables for base URL
- Authentication setup

## Notes

1. **Authentication**: All API calls require ERPNext login session cookies
2. **Order IDs**: Follow the format `WOR-YYYY-NNNNN` (e.g., `WOR-2025-00021`)
3. **Status Values**: Use exact status names as specified
4. **Phone Numbers**: Use international format (e.g., `254770534365`)
5. **Amounts**: All monetary values are in the system's base currency
6. **WhatsApp Notifications**: Currently disabled due to token expiry (can be re-enabled with valid token)

## Support

For issues or questions about the API, check the ERPNext error logs or contact the system administrator.







