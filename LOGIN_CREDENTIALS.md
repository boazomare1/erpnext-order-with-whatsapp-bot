# Frappe Login Credentials

## Access Your Frappe UI

### URL
**http://localhost:8014** (since you started server on port 8014)

### Login Credentials
- **Username**: Administrator (or Admin)
- **Password**: admin

---

## Quick Access Steps

1. Open your browser
2. Go to: **http://localhost:8014**
3. Login with:
   - Username: `Administrator`
   - Password: `admin`
4. Click Login

---

## Alternative URLs
- http://127.0.0.1:8014
- http://192.168.200.45:8014

---

## After Login

1. Navigate to **Apps** menu
2. Select **Whatsapp Orders**
3. You'll see all the doctypes we created:
   - Delivery Shop
   - Customer
   - Customer Preference
   - Order Route Assignment

---

## Change Password Later

If you want to change the password later, run:
```bash
bench --site testsite2.localhost set-admin-password YOUR_NEW_PASSWORD
```

---

## Troubleshooting

### Forgot username?
- Default username is usually `Administrator` or `admin`

### Can't login?
- Make sure server is running on port 8014
- Check server status: `ps aux | grep "port 8014"`

### Need to reset password again?
```bash
bench --site testsite2.localhost set-admin-password your_new_password
```
