# Frappe Test Data - Ready to Insert

## 📦 Test Data Summary

Use this data to test the Order Routing System in Frappe UI.

---

## 🏪 DELIVERY SHOPS

### Shop 1: Downtown Gas Shop
- **Shop Name**: Downtown Gas Shop
- **GPS Latitude**: -1.2921
- **GPS Longitude**: 36.8219
- **County**: Nairobi County
- **Constituency**: Kamukunji Constituency
- **Ward**: Eastleigh North Ward
- **Nearest Landmark**: Airport Road Roundabout
- **Operating Hours**: Mon-Fri: 8:00 AM - 6:00 PM
- **Contact Person**: John Kamau
- **Phone**: +254712345678
- **Email**: downtown@gasshop.com
- **Status**: Active

### Shop 2: Nairobi Mall Shop
- **Shop Name**: Nairobi Mall Shop
- **GPS Latitude**: -1.2830
- **GPS Longitude**: 36.8271
- **County**: Nairobi County
- **Constituency**: Westlands Constituency
- **Ward**: Parklands Ward
- **Nearest Landmark**: Nairobi Mall Entrance
- **Operating Hours**: Mon-Sat: 9:00 AM - 7:00 PM
- **Contact Person**: Sarah Njeri
- **Phone**: +254723456789
- **Email**: mall@gasshop.com
- **Status**: Active

### Shop 3: Westlands Shop
- **Shop Name**: Westlands Shop
- **GPS Latitude**: -1.2545
- **GPS Longitude**: 36.7971
- **County**: Nairobi County
- **Constituency**: Westlands Constituency
- **Ward**: Westlands Ward
- **Nearest Landmark**: Westlands Shopping Center
- **Operating Hours**: Daily: 7:00 AM - 8:00 PM
- **Contact Person**: Mike Ouma
- **Phone**: +254734567890
- **Email**: westlands@gasshop.com
- **Status**: Active

---

## 👤 CUSTOMERS

### Customer 1: Peter Ochieng
- **Customer Name**: Peter Ochieng
- **Phone Number**: +254712345678
- **Email**: (optional)
- **Default Delivery Address**: Westlands, Nairobi
- **GPS Latitude**: -1.2850
- **GPS Longitude**: 36.8110
- **County**: Nairobi County
- **Constituency**: Westlands
- **Ward**: Westlands

### Customer 2: Mary Wanjiru
- **Customer Name**: Mary Wanjiru
- **Phone Number**: +254723456789
- **Email**: (optional)
- **Default Delivery Address**: Parklands, Nairobi
- **GPS Latitude**: -1.2700
- **GPS Longitude**: 36.8200
- **County**: Nairobi County
- **Constituency**: Westlands
- **Ward**: Parklands

---

## 📋 How to Add This Data

### Option 1: Via Frappe UI
1. Start Frappe server (if not running): `bench start`
2. Go to: `http://localhost:8000`
3. Login with your credentials
4. Navigate to **Apps > Whatsapp Orders**
5. Create new records for:
   - Delivery Shop (3 shops)
   - Customer (2 customers)

### Option 2: Via Bench Console
```bash
bench --site testsite2.localhost console
```

Then in Python console:
```python
# Create shops
for shop_data in shops:  # Use data from above
    doc = frappe.get_doc({
        'doctype': 'Delivery Shop',
        **shop_data
    })
    doc.insert()

# Create customers
for customer_data in customers:  # Use data from above
    doc = frappe.get_doc({
        'doctype': 'Customer',
        **customer_data
    })
    doc.insert()
```

### Option 3: Via API
```bash
# Using curl (update API_KEY and API_SECRET)
curl -X POST "http://localhost:8000/api/resource/Delivery Shop" \
  -H "Content-Type: application/json" \
  -H "Authorization: token API_KEY:API_SECRET" \
  -d '{
    "shop_name": "Downtown Gas Shop",
    "gps_latitude": -1.2921,
    "gps_longitude": 36.8219,
    ...
  }'
```

---

## 🧪 Testing the System

Once data is added:

1. **View Shops**: Navigate to Delivery Shop list
2. **View Customers**: Navigate to Customer list
3. **Test Routing**: Create a test order and see it route to nearest shop
4. **Test Inventory**: Ensure shops have inventory in ERPNext
5. **Test Preferences**: Add customer preferences

---

## 📊 Expected Distance Calculations

**From Customer 1 (Peter Ochieng): -1.2850, 36.8110**
- Downtown Gas Shop: ~1,446m
- Nairobi Mall Shop: ~1,804m
- Westlands Shop: ~3,727m

**From Customer 2 (Mary Wanjiru): -1.2700, 36.8200**
- Downtown Gas Shop: ~3,125m
- Nairobi Mall Shop: ~1,415m
- Westlands Shop: ~982m

---

## 🎯 Next Steps

1. Add this data to Frappe
2. Create ERPNext Items for gas cylinders
3. Add inventory to shops
4. Test order routing
5. Monitor assignment flow

**System is ready for production testing!** 🚀
