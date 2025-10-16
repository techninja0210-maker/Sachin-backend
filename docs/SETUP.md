# NFT Admin Dashboard - Complete Setup Guide

## 🎯 Overview

This guide will walk you through setting up the complete NFT Admin Dashboard system from scratch.

**Estimated Setup Time:** 2-3 hours

---

## 📋 Prerequisites

Before starting, ensure you have:

- [ ] Supabase account ([Sign up here](https://supabase.com))
- [ ] Stripe account ([Sign up here](https://stripe.com))
- [ ] Bubble.io account ([Sign up here](https://bubble.io))
- [ ] Node.js 16+ installed ([Download here](https://nodejs.org))
- [ ] Git installed
- [ ] Code editor (VS Code recommended)
- [ ] Terminal/Command Prompt

---

## 🗄️ Part 1: Supabase Database Setup

### Step 1: Create Supabase Project

1. Log in to [Supabase Dashboard](https://app.supabase.com)
2. Click "New Project"
3. Fill in details:
   - **Name:** nft-admin-dashboard
   - **Database Password:** (Save this securely!)
   - **Region:** Choose closest to Australia
   - **Plan:** Free tier is sufficient for development
4. Wait for project to be created (~2 minutes)

### Step 2: Get Supabase Credentials

1. Go to Project Settings → API
2. Copy and save:
   - **Project URL:** `https://xxxxxxxxxxxxx.supabase.co`
   - **Anon/Public Key:** `eyJhbGc...` (starts with eyJ)
   - **Service Role Key:** `eyJhbGc...` (different from anon key)

⚠️ **Important:** Keep service role key secret! Never commit to git.

### Step 3: Create Database Schema

1. In Supabase Dashboard, go to **SQL Editor**
2. Click "New Query"
3. Copy entire contents of `database/schema.sql`
4. Paste into SQL Editor
5. Click "Run" (or press Ctrl+Enter)
6. Verify success messages appear
7. Check Tables section to confirm 3 new tables:
   - `bnpl_transactions`
   - `weekly_subscriptions`
   - `nft_insurance_logs`

### Step 4: Insert Sample Data (Optional)

1. Create new query in SQL Editor
2. Copy contents of `database/seed-data.sql`
3. **Important:** Replace sample UUIDs with real user IDs:
   ```sql
   -- Before running, update user_id values:
   -- Replace '00000000-0000-0000-0000-000000000001' with actual user IDs
   ```
4. Run query
5. Verify data inserted:
   ```sql
   SELECT count(*) FROM bnpl_transactions;
   SELECT count(*) FROM weekly_subscriptions;
   SELECT count(*) FROM nft_insurance_logs;
   ```

### Step 5: Verify Database Views

Run these queries to test views:

```sql
-- Test BNPL view
SELECT * FROM vw_recent_bnpl_transactions LIMIT 5;

-- Test subscriptions view
SELECT * FROM vw_active_subscriptions;

-- Test insurance view
SELECT * FROM vw_insurance_applications LIMIT 5;
```

✅ **Checkpoint:** You should see sample data returned from views.

---

## 💳 Part 2: Stripe Configuration

### Step 1: Access Stripe Dashboard

1. Log in to [Stripe Dashboard](https://dashboard.stripe.com)
2. **Important:** Make sure you're in **Test Mode** (toggle in top right)

### Step 2: Get API Keys

1. Go to **Developers → API Keys**
2. Copy and save:
   - **Publishable key:** `pk_test_xxxxx`
   - **Secret key:** `sk_test_xxxxx` (click "Reveal test key")

### Step 3: Create Subscription Product

1. Go to **Products → Add Product**
2. Fill in details:
   ```
   Name: NFT Generator Weekly Subscription
   Description: Weekly access to NFT Generator tools
   ```
3. Add Price:
   ```
   Type: Recurring
   Amount: 5.00
   Currency: AUD (Australian Dollar)
   Billing period: Weekly
   ```
4. Click "Save product"
5. **Copy Price ID:** `price_xxxxxxxxxxxxx`

### Step 4: Enable AfterPay/ClearPay

1. Go to **Settings → Payment Methods**
2. Find **AfterPay / Clearpay**
3. Click "Enable"
4. Configure:
   ```
   Country: Australia
   Currency: AUD
   Business type: [Your business type]
   ```
5. Complete verification (may require business details)

⚠️ **Note:** AfterPay may require manual approval. Use card payments for testing if not yet approved.

### Step 5: Create Webhook Endpoint (After deploying webhook server)

**Skip this step for now.** Return after deploying webhook server in Part 3.

1. Go to **Developers → Webhooks**
2. Click "Add endpoint"
3. Enter webhook URL: `https://your-server-url.com/webhook`
4. Select events to listen for:
   - `checkout.session.completed`
   - `invoice.payment_succeeded`
   - `invoice.payment_failed`
   - `customer.subscription.created`
   - `customer.subscription.updated`
   - `customer.subscription.deleted`
   - `payment_intent.succeeded`
   - `payment_intent.payment_failed`
5. Click "Add endpoint"
6. **Copy Signing Secret:** `whsec_xxxxxxxxxxxxx`

✅ **Checkpoint:** You have Stripe keys and subscription product ID.

---

## 🖥️ Part 3: Webhook Server Setup

### Step 1: Clone/Download Repository

```bash
# If using git
git clone <repository-url>
cd nft-admin-dashboard

# Or download and extract ZIP
cd nft-admin-dashboard
```

### Step 2: Install Dependencies

```bash
cd webhooks
npm install
```

Expected output:
```
added 150 packages
```

### Step 3: Configure Environment Variables

1. Copy example environment file:
   ```bash
   cp env.example .env
   ```

2. Edit `.env` file with your credentials:
   ```env
   # Supabase
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=your-anon-key
   SUPABASE_SERVICE_KEY=your-service-key

   # Stripe
   STRIPE_SECRET_KEY=sk_test_xxxxxxxxxxxxx
   STRIPE_PUBLISHABLE_KEY=pk_test_xxxxxxxxxxxxx
   STRIPE_WEBHOOK_SECRET=whsec_xxxxxxxxxxxxx

   # Server
   PORT=4242
   NODE_ENV=development
   ```

3. Save file

### Step 4: Test Webhook Server Locally

```bash
npm run dev
```

Expected output:
```
🚀 NFT Admin Webhook Server Started
📍 Port: 4242
🌍 Environment: development
🔗 Webhook URL: http://localhost:4242/webhook
💚 Health check: http://localhost:4242/health

✅ Ready to receive Stripe webhook events
```

### Step 5: Test Health Endpoint

Open browser or use curl:
```bash
curl http://localhost:4242/health
```

Expected response:
```json
{
  "status": "healthy",
  "service": "nft-admin-webhook",
  "version": "1.0.0",
  "timestamp": "2025-10-10T12:00:00.000Z"
}
```

### Step 6: Setup Stripe CLI for Local Testing

1. Install Stripe CLI:
   ```bash
   # macOS
   brew install stripe/stripe-cli/stripe
   
   # Windows (using Scoop)
   scoop bucket add stripe https://github.com/stripe/scoop-stripe-cli.git
   scoop install stripe
   
   # Linux
   # See: https://stripe.com/docs/stripe-cli#install
   ```

2. Login to Stripe:
   ```bash
   stripe login
   ```
   
3. Forward webhooks to local server:
   ```bash
   stripe listen --forward-to localhost:4242/webhook
   ```
   
4. **Copy webhook signing secret** from output (starts with `whsec_`)
5. Update `.env` with this secret

### Step 7: Test Webhook Events

In a new terminal:

```bash
# Test checkout completed
stripe trigger checkout.session.completed

# Test subscription created
stripe trigger customer.subscription.created

# Test invoice payment succeeded
stripe trigger invoice.payment_succeeded
```

Check webhook server logs for processing messages.

✅ **Checkpoint:** Webhook server receives and processes events.

---

## 🎨 Part 4: Bubble.io Setup

### Step 1: Create New Bubble App

1. Log in to [Bubble.io](https://bubble.io)
2. Click "Create an app"
3. Name: `nft-admin-dashboard`
4. Template: Start with blank

### Step 2: Install Required Plugins

1. Go to **Plugins** tab
2. Search and install:
   - **Stripe** (Official Stripe plugin)
   - **API Connector**

### Step 3: Configure Stripe Plugin

1. Open **Stripe** plugin settings
2. Add Stripe keys:
   ```
   Publishable Key (test): pk_test_xxxxxxxxxxxxx
   Secret Key (test): sk_test_xxxxxxxxxxxxx
   ```
3. Save

### Step 4: Configure Supabase REST API

1. Open **API Connector** plugin
2. Click "Add another API"
3. Name: `Supabase_REST`
4. Authentication: **Private key in header**
5. Add shared headers:
   ```
   apikey: [paste your Supabase anon key]
   Authorization: Bearer [paste your Supabase anon key]
   Content-Type: application/json
   Prefer: return=representation
   ```

### Step 5: Add Supabase API Calls

**Important:** Replace `YOUR_PROJECT` with your actual Supabase project ID.

#### Call 1: Get BNPL Transactions

```
Name: Get_BNPL_Transactions
Use as: Data
Data type: [Create new type] BNPL_Transaction

Method: GET
URL: https://YOUR_PROJECT.supabase.co/rest/v1/bnpl_transactions

Parameters (all query strings):
- select (optional): *
- order (optional): created_at.desc
- user_id (optional): eq.[user_id]
- limit (optional): 100

Click "Initialize call"
```

Bubble will detect the response structure. Map fields:
- id → text
- user_id → text
- order_id → text
- payment_id → text
- payment_method → text
- amount_paid → number
- bnpl_status → text
- created_at → date

#### Call 2: Get Weekly Subscriptions

```
Name: Get_Weekly_Subscriptions
Use as: Data
Data type: [Create new type] Weekly_Subscription

Method: GET
URL: https://YOUR_PROJECT.supabase.co/rest/v1/weekly_subscriptions

Parameters:
- select (optional): *
- order (optional): created_at.desc
- status (optional): eq.[status]

Initialize and map fields similar to above.
```

#### Call 3: Get NFT Insurance Logs

```
Name: Get_NFT_Insurance_Logs
Use as: Data
Data type: [Create new type] NFT_Insurance_Log

Method: GET
URL: https://YOUR_PROJECT.supabase.co/rest/v1/nft_insurance_logs

Parameters:
- select (optional): *
- order (optional): created_at.desc
- insurance_status (optional): eq.[status]

Initialize and map fields.
```

#### Call 4: Get BNPL Statistics (RPC Function)

```
Name: Get_BNPL_Statistics
Use as: Data
Data type: [Create new type] BNPL_Stats

Method: POST
URL: https://YOUR_PROJECT.supabase.co/rest/v1/rpc/get_bnpl_statistics

Body type: JSON
Body: {}

Initialize call.
```

### Step 6: Configure Mock Insurance API

**Option A: Local Mock Insurance Server (Recommended)**
1. **Start the Mock Insurance API Server:**
   ```bash
   cd webhooks
   npm run start:insurance
   ```
   Server will run on: `http://localhost:3001`

2. **API Connector Configuration:**
   - In API Connector, click "Add another API"
   - Name: `Mock_Insurance_API`
   - Authentication: None
   - Add call:
     ```
     Name: Verify_Insurance
     Use as: Action
     
     Method: POST
     URL: http://localhost:3001/insurance/verify

**Option B: External Mock API (Alternative)**
1. **API Connector Configuration:**
   - In API Connector, click "Add another API"
   - Name: `Mock_Insurance_API`
   - Authentication: None
   - Add call:
     ```
     Name: Verify_Insurance
     Use as: Action
     
     Method: POST
     URL: https://mock-insurance-api.free.beeceptor.com/insurance/verify
   
   Body type: JSON
   Body:
   {
     "user_id": "[user_id]",
     "nft_id": "[nft_id]",
     "plan": "standard"
   }
   
   Initialize call
   ```

✅ **Checkpoint:** All API calls initialized successfully.

### Step 7: Build Admin Dashboard Pages

Follow detailed instructions in `bubble/admin-ui-specs.md` to build:
- Admin Dashboard page
- BNPL Transactions view
- Subscriptions view
- Insurance Logs view

**Quick Start:**
1. Create page: `/admin-dashboard`
2. Add repeating group for BNPL transactions
3. Data source: Get data from external API → Supabase_REST - Get_BNPL_Transactions
4. Display fields in cells

✅ **Checkpoint:** Basic admin page displays data from Supabase.

---

## 🧪 Part 5: Testing

### Test 1: BNPL Transaction via Postman

1. Import `postman/nft-admin-dashboard.postman_collection.json`
2. Update environment variables in Postman
3. Run: "Test BNPL Transaction (Dev Only)"
4. Verify in Supabase: Check `bnpl_transactions` table
5. Verify in Bubble: Check admin dashboard displays new transaction

### Test 2: Create Subscription via Stripe

1. In Bubble, create a subscribe button
2. Workflow: Create Stripe Checkout Session (mode: subscription)
3. Use test card: 4242 4242 4242 4242
4. Complete checkout
5. Verify webhook processes event
6. Check `weekly_subscriptions` table in Supabase

### Test 3: Insurance API

1. In Bubble, call Mock Insurance API
2. Pass test user_id and nft_id
3. Verify mock response
4. Log result in `nft_insurance_logs` table

---

## 🚀 Part 6: Deployment (Optional)

### Deploy Webhook Server to Railway

1. Install Railway CLI:
   ```bash
   npm install -g @railway/cli
   ```

2. Login:
   ```bash
   railway login
   ```

3. Deploy:
   ```bash
   cd webhooks
   railway init
   railway up
   ```

4. Set environment variables in Railway dashboard
5. Get deployment URL
6. Update Stripe webhook endpoint with new URL

### Make Bubble App Live

1. Click "Deploy to live" in Bubble editor
2. Update API calls to use production Supabase keys (if different)
3. Test all workflows in live environment

---

## ✅ Setup Verification Checklist

- [ ] Supabase project created
- [ ] Database schema deployed successfully
- [ ] Sample data inserted (optional)
- [ ] Stripe account configured
- [ ] Subscription product created
- [ ] AfterPay enabled (or using card fallback)
- [ ] Webhook server running locally
- [ ] Stripe CLI forwarding webhooks
- [ ] Webhook events being processed
- [ ] Bubble app created
- [ ] Stripe plugin configured
- [ ] API Connector configured with Supabase
- [ ] All API calls initialized
- [ ] Admin dashboard page created
- [ ] Data displaying in repeating groups
- [ ] Postman collection tested
- [ ] All test scenarios passed

---

## 🆘 Troubleshooting

### Supabase Connection Issues

**Problem:** API calls returning 401 Unauthorized

**Solution:**
- Verify anon key is correct
- Check `Authorization` header format: `Bearer <key>`
- Ensure RLS policies allow access

### Webhook Not Receiving Events

**Problem:** Stripe events not appearing in webhook logs

**Solution:**
- Check Stripe CLI is running: `stripe listen`
- Verify webhook secret in `.env` matches CLI output
- Check server is running on correct port
- Test health endpoint first

### Bubble API Calls Failing

**Problem:** Repeating group shows "API call error"

**Solution:**
- Re-initialize API call
- Check Supabase URL is correct
- Verify headers are set correctly
- Test API call in Postman first

### AfterPay Not Available

**Problem:** AfterPay option not showing in checkout

**Solution:**
- Verify AfterPay enabled in Stripe dashboard
- Check your Stripe account region supports AfterPay
- Use regular card payments as fallback

---

## 📚 Next Steps

After successful setup:

1. Review `bubble/workflow-guides.md` for detailed workflow implementations
2. Customize admin UI following `bubble/admin-ui-specs.md`
3. Test all payment scenarios
4. Deploy to production when ready
5. Monitor webhook logs and Supabase tables

---

## 🔗 Useful Links

- [Supabase Documentation](https://supabase.com/docs)
- [Stripe API Reference](https://stripe.com/docs/api)
- [Stripe AfterPay Guide](https://stripe.com/docs/payments/afterpay-clearpay)
- [Bubble Manual](https://manual.bubble.io)
- [Stripe CLI Documentation](https://stripe.com/docs/stripe-cli)

---

**Need Help?** Check the troubleshooting section or review the detailed docs in the `docs/` folder.

**Version:** 1.0.0  
**Last Updated:** October 2025

