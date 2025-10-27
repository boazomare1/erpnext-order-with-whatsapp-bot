# How to Add Test Data to Frappe UI

Since your Frappe is running on port **8006**, access it at:
**http://localhost:8006**

---

## Quick Steps to Add Data

### 1. Access Frappe UI
- Open browser: `http://localhost:8006`
- Login with your credentials

### 2. Navigate to Whatsapp Orders App
- Click on **Apps** menu
- Select **Whatsapp Orders**

### 3. Create Delivery Shops

Go to **Delivery Shop** doctype and create these 3 shops:

#### Shop 1: Downtown Gas Shop
```
Shop Name: Downtown Gas Shop
GPS Latitude: -1.2921
GPS Longitude: 36.8219
County: Nairobi County
Constituency: Kamukunji Constituency
Ward: Eastleigh North Ward
Nearest Landmark: Airport Road Roundabout
Operating Hours: Mon-Fri: 8:00 AM - 6:00 PM
Contact Person: John Kamau
Phone Number: +254712345678
Email: downtown@gasshop.com
Status: Active
Active: ✓ (checked)
```

#### Shop 2: Nairobi Mall Shop
```
Shop Name: Nairobi Mall Shop
GPS Latitude: -1.2830
GPS Longitude: 36.8271
County: Nairobi County
Constituency: Westlands Constituency
Ward: Parklands Ward
Nearest Landmark: Nairobi Mall Entrance
Operating Hours: Mon-Sat: 9:00 AM - 7:00 PM
Contact Person: Sarah Njeri
Phone Number: +254723456789
Email: mall@gasshop.com
Status: Active
Active: ✓ (checked)
```

#### Shop 3: Westlands Shop
```
Shop Name: Westlands Shop
GPS Latitude: -1.2545
GPS Longitude: 36.7971
County: Nairobi County
Constituency: Westlands Constituency
Ward: Westlands Ward
Nearest Landmark: Westlands Shopping Center
Operating Hours: Daily: 7:00 AM - 8:00 PM
Contact Person: Mike Ouma
Phone Number: +254734567890
Email: westlands@gasshop.com
Status: Active
Active: ✓ (checked)
```

### 4. Create Customers

Go to **Customer** doctype and create these 2 customers:

#### Customer 1: Peter Ochieng
```
Customer Name: Peter Ochieng
Phone Number: +254712345678
Default Delivery Address: Westlands, Nairobi
Default GPS Latitude: -1.2850
Default GPS Longitude: 36.8110
County: Nairobi County
Constituency: Westlands
Ward: Westlands
```

#### Customer 2: Mary Wanjiru
```
Customer Name: Mary Wanjiru
Phone Number: +254723456789
Default Delivery Address: Parklands, Nairobi
Default GPS Latitude: -1.2700
Default GPS Longitude: 36.8200
County: Nairobi County
Constituency: Westlands
Ward: Parklands
```

---

## Verify Data

After creating the data:
1. Go to **Delivery Shop List** - you should see 3 shops
2. Go to **Customer List** - you should see 2 customers
3. Click on each record to verify all data is correct

---

## Expected Results

After adding this data:
- ✅ 3 Delivery Shops with GPS coordinates
- ✅ 2 Customers with GPS coordinates
- ✅ All shops marked as Active
- ✅ Contact information for each shop

---

## Next Steps

Once data is added:
1. Test the order routing by creating a test order
2. View the Order Route Assignment to see which shop gets assigned
3. Test the distance calculation
4. Verify the tiered assignment logic

**Your system will be ready for testing!** 🚀
