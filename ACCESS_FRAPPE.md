# Access Frappe UI

## ✅ Correct URL
**http://localhost:8006** (or **http://127.0.0.1:8006**)

Your Frappe server is running on **port 8006**, not 8007!

---

## Quick Access

1. Open your browser
2. Go to: **http://localhost:8006**
3. Login with your Frappe credentials

---

## If You See "Not Found" Error

If you see the "testsite2.local does not exist" error:
- Make sure you're using port **8006**, not 8007
- The correct URL is: http://localhost:8006

---

## Navigation After Login

1. Click on **Apps** in the top menu
2. Select **Whatsapp Orders**
3. You'll see the doctypes we created:
   - Delivery Shop
   - Customer  
   - Customer Preference
   - Order Route Assignment

---

## Add Test Data

Follow the instructions in `DIRECT_DATA_ENTRY.md` to add:
- 3 Delivery Shops
- 2 Customers

---

## Troubleshooting

### Wrong port?
- Current active port: **8006**
- Don't use ports: 8007, 8000

### Can't access?
- Check server is running: `ps aux | grep "port 8006"`
- Restart if needed: `bench --site testsite2.localhost serve --port 8006`
