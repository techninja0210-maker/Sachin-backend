# NFT Admin Dashboard - Quick Start Guide

## ⚡ Get Started in 15 Minutes

This guide will get you up and running with the NFT Admin Dashboard as quickly as possible.

---

## 📋 Prerequisites Checklist

Before starting, make sure you have:
- [ ] Supabase account
- [ ] Stripe account
- [ ] Bubble.io account
- [ ] Node.js 16+ installed
- [ ] Git installed

---

## 🚀 Step 1: Database Setup (5 minutes)

### 1.1 Create Supabase Project
1. Go to https://app.supabase.com
2. Click "New Project"
3. Name: `nft-admin-dashboard`
4. Set password (save it!)
5. Wait ~2 minutes for creation

### 1.2 Get Your Credentials
1. Go to Project Settings → API
2. Copy these (you'll need them):
   ```
   Project URL: https://xxxxx.supabase.co
   Anon Key: eyJhbGc...
   Service Key: eyJhbGc...
   ```

### 1.3 Run Database Schema
1. Go to SQL Editor in Supabase
2. Click "New Query"
3. Copy entire contents of `database/schema.sql`
4. Paste and click "Run"
5. ✅ You should see success messages

---

## 💳 Step 2: Stripe Setup (5 minutes)

### 2.1 Get Stripe Keys
1. Go to https://dashboard.stripe.com
2. **Switch to Test Mode** (toggle in top right)
3. Go to Developers → API Keys
4. Copy:
   ```
   Publishable key: pk_test_xxxxx
   Secret key: sk_test_xxxxx (click "Reveal")
   ```

### 2.2 Create Subscription Product
1. Go to Products → Add Product
2. Fill in:
   ```
   Name: NFT Generator Weekly Subscription
   Price: 5.00 AUD
   Billing: Recurring - Weekly
   ```
3. Click "Save product"
4. Copy Price ID: `price_xxxxx`

### 2.3 Enable AfterPay (Optional)
1. Go to Settings → Payment Methods
2. Find "AfterPay / Clearpay"
3. Click "Enable"
4. Configure for Australia/AUD

---

## 🖥️ Step 3: Webhook Server (5 minutes)

### 3.1 Install Dependencies
```bash
cd webhooks
npm install
```

### 3.2 Configure Environment
```bash
cp env.example .env
```

Edit `.env` file:
```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_KEY=your-service-key
STRIPE_SECRET_KEY=sk_test_xxxxx
STRIPE_WEBHOOK_SECRET=whsec_xxxxx
PORT=4242
NODE_ENV=development
```

### 3.3 Start Server
```bash
npm start
```

You should see:
```
🚀 NFT Admin Webhook Server Started
📍 Port: 4242
✅ Ready to receive Stripe webhook events
```

### 3.4 Setup Stripe CLI (for testing)
```bash
# Install Stripe CLI (macOS)
brew install stripe/stripe-cli/stripe

# Login
stripe login

# Forward webhooks
stripe listen --forward-to localhost:4242/webhook
```

Copy the webhook secret (whsec_xxx) and update your `.env` file.

---

## 🎨 Step 4: Bubble.io Setup (Optional - 30 minutes)

### 4.1 Create App
1. Go to https://bubble.io
2. Click "Create an app"
3. Name: `nft-admin-dashboard`

### 4.2 Install Plugins
1. Go to Plugins tab
2. Install:
   - Stripe (Official)
   - API Connector

### 4.3 Configure Stripe Plugin
1. Open Stripe plugin settings
2. Add keys:
   ```
   Publishable Key: pk_test_xxxxx
   Secret Key: sk_test_xxxxx
   ```

### 4.4 Configure API Connector
1. Open API Connector
2. Add API: "Supabase_REST"
3. Base URL: `https://your-project.supabase.co/rest/v1`
4. Add headers:
   ```
   apikey: your-anon-key
   Authorization: Bearer your-anon-key
   Content-Type: application/json
   ```

For detailed Bubble setup, see `bubble/admin-ui-specs.md`

---

## 🧪 Step 5: Test Everything (5 minutes)

### 5.1 Test Database
In Supabase SQL Editor:
```sql
SELECT * FROM bnpl_transactions;
SELECT * FROM weekly_subscriptions;
SELECT * FROM nft_insurance_logs;
```

### 5.2 Test Webhook Server
```bash
curl http://localhost:4242/health
```

Expected:
```json
{"status": "healthy"}
```

### 5.3 Test Stripe Events
```bash
stripe trigger checkout.session.completed
```

Check webhook server logs - you should see event processed.

### 5.4 Test with Postman
1. Import `postman/nft-admin-dashboard.postman_collection.json`
2. Update environment variables
3. Run "Get All BNPL Transactions"

---

## ✅ Verification Checklist

- [ ] Supabase project created
- [ ] Database schema deployed
- [ ] Stripe account configured
- [ ] Webhook server running
- [ ] Stripe CLI forwarding events
- [ ] Test event processed successfully
- [ ] Postman collection working

---

## 🎉 You're Ready!

Your NFT Admin Dashboard is now set up and ready for development!

### What's Next?

1. **Add Sample Data:**
   ```bash
   # In Supabase SQL Editor
   # Run: database/seed-data.sql
   ```

2. **Build Bubble UI:**
   - Follow `bubble/admin-ui-specs.md`
   - Implement workflows from `bubble/workflow-guides.md`

3. **Test Complete Flows:**
   - BNPL purchase
   - Subscription creation
   - Insurance verification

4. **Deploy to Production:**
   - Follow `docs/DEPLOYMENT.md`

---

## 🆘 Quick Troubleshooting

### Webhook Server Won't Start
```bash
# Check if port is in use
lsof -i :4242

# Kill process if needed
kill -9 <PID>

# Try different port
PORT=4243 npm start
```

### Database Connection Error
- Verify Supabase URL is correct
- Check service key is valid
- Ensure project is not paused

### Stripe Events Not Received
- Check Stripe CLI is running
- Verify webhook secret matches
- Check server logs for errors

---

## 📚 Full Documentation

For detailed guides, see:
- **Setup:** `docs/SETUP.md`
- **Testing:** `docs/TESTING.md`
- **Deployment:** `docs/DEPLOYMENT.md`
- **API Reference:** `docs/API-REFERENCE.md`

---

## 💡 Pro Tips

1. **Use Test Mode:** Always test with Stripe test keys first
2. **Check Logs:** Webhook server logs show everything
3. **Test Cards:** Use `4242 4242 4242 4242` for success
4. **Verify Data:** Check Supabase tables after each test
5. **Read Docs:** Comprehensive guides available in `docs/`

---

## 🔗 Useful Commands

```bash
# Start webhook server
cd webhooks && npm start

# Start with auto-reload
cd webhooks && npm run dev

# Test webhook health
curl http://localhost:4242/health

# Forward Stripe events
stripe listen --forward-to localhost:4242/webhook

# Trigger test event
stripe trigger checkout.session.completed

# View Stripe events
stripe events list

# View webhook logs
stripe logs tail
```

---

## 📞 Need Help?

- **Setup Issues:** See `docs/SETUP.md` → Troubleshooting
- **Testing Issues:** See `docs/TESTING.md` → Common Issues
- **API Questions:** See `docs/API-REFERENCE.md`

---

**Happy Building! 🚀**

Your NFT Admin Dashboard is ready to track BNPL transactions, subscriptions, and insurance applications!

---

**Version:** 1.0.0  
**Last Updated:** October 2025

