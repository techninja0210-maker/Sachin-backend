# NFT Admin Dashboard - BNPL, Subscriptions & Insurance Module

## 🎯 Overview

This is a **modular admin dashboard** for managing:
- **BNPL Transactions** (Buy Now Pay Later via Stripe AfterPay/ClearPay)
- **Weekly Subscriptions** (Recurring payments via Stripe)
- **NFT Insurance Logs** (Insurance coverage tracking)

Built for integration with the main NFT marketplace platform.

---

## 🛠 Tech Stack

- **Frontend/UI:** Bubble.io
- **Database:** Supabase (PostgreSQL)
- **Backend/Webhooks:** Node.js + Express
- **Payment Processing:** Stripe (Australia/AUD)
- **API Integration:** Bubble API Connector (mock Insurance API)

---

## 📁 Project Structure

```
nft-admin-dashboard/
├── README.md                           # This file
├── database/
│   ├── schema.sql                      # Complete Supabase schema
│   ├── migrations/                     # Future migrations
│   └── seed-data.sql                   # Sample test data
├── webhooks/
│   ├── stripe-webhook.js               # Stripe event handler
│   ├── package.json                    # Node.js dependencies
│   ├── .env.example                    # Environment variables template
│   └── README.md                       # Webhook setup guide
├── bubble/
│   ├── api-connector-config.json       # Bubble API Connector settings
│   ├── admin-ui-specs.md               # Admin repeating group specifications
│   └── workflow-guides.md              # Bubble workflow documentation
├── postman/
│   └── nft-admin-dashboard.postman_collection.json
├── docs/
│   ├── SETUP.md                        # Complete setup instructions
│   ├── DEPLOYMENT.md                   # Deployment guide
│   ├── TESTING.md                      # Testing checklist
│   └── API-REFERENCE.md                # API endpoints reference
└── .gitignore

```

---

## 🚀 Quick Start

### Prerequisites
- Supabase account with project created
- Stripe account (Australia/AUD)
- Bubble.io account
- Node.js 16+ installed (for webhooks)
- Git installed

### 1. Clone Repository
```bash
git clone <repository-url>
cd nft-admin-dashboard
```

### 2. Setup Supabase Database
```bash
# Connect to your Supabase project and run:
psql -h <your-supabase-host> -U postgres -d postgres -f database/schema.sql
```

### 3. Setup Webhook Server
```bash
cd webhooks
npm install
cp .env.example .env
# Edit .env with your credentials
node stripe-webhook.js
```

### 4. Configure Bubble.io
- Import API Connector configuration from `bubble/api-connector-config.json`
- Follow setup guide in `bubble/admin-ui-specs.md`
- Connect Supabase using REST API

### 5. Test with Postman
- Import `postman/nft-admin-dashboard.postman_collection.json`
- Run test scenarios

---

## 📊 Database Tables

### 1. `bnpl_transactions`
Tracks BNPL purchases via Stripe AfterPay/ClearPay
- **Fields:** user_id, order_id, payment_id, payment_method, amount_paid, bnpl_status

### 2. `weekly_subscriptions`
Manages weekly recurring subscriptions
- **Fields:** user_id, subscription_id, stripe_customer_id, status, start_date, next_billing_date

### 3. `nft_insurance_logs`
Logs NFT insurance applications
- **Fields:** user_id, nft_id, insurance_status, insurance_policy_id

---

## 🔐 Environment Variables

Create `.env` file in `webhooks/` directory:

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

---

## 📝 Admin Dashboard Features

### BNPL Transactions View
- ✅ View all BNPL transactions
- ✅ Filter by user ID
- ✅ Sort by date (newest first)
- ✅ Export to CSV
- ✅ View payment method and status

### Weekly Subscriptions View
- ✅ View all subscriptions
- ✅ Filter by status (active/paused/canceled)
- ✅ Sort by start date
- ✅ View next billing date
- ✅ Export to CSV

### NFT Insurance Logs View
- ✅ View all insurance applications
- ✅ Filter by status (applied/approved/rejected)
- ✅ Sort by date
- ✅ Export to CSV

---

## 🧪 Testing

### Test Mode (Sandbox)
All development uses Stripe test keys and Supabase test project.

### Test Cards
- **Success:** 4242 4242 4242 4242
- **Decline:** 4000 0000 0000 0002
- **AfterPay:** Use Stripe test mode AfterPay

### Webhook Testing
```bash
# Install Stripe CLI
stripe listen --forward-to localhost:4242/webhook

# Trigger test events
stripe trigger invoice.payment_succeeded
stripe trigger checkout.session.completed
```

---

## 📦 Deliverables Checklist

- [x] Supabase schema with triggers
- [x] Node.js webhook handler
- [x] Mock Insurance API configuration
- [x] Bubble.io admin UI specifications
- [x] Complete documentation
- [x] Postman collection for testing
- [x] Environment setup guide
- [x] Testing checklist

---

## 🔄 Integration Notes

This module is **standalone and modular** for easy integration:
- Uses consistent naming conventions (snake_case)
- Foreign keys reference existing `users` and `nfts` tables
- All tables include `metadata` JSONB for flexibility
- Automatic `updated_at` triggers
- Ready to merge with main admin panel

---

## 📞 Support & Handover

### What You'll Receive
1. Complete GitHub repository (private)
2. Supabase SQL schema ready to import
3. Node.js webhook server (tested)
4. Bubble.io configuration files
5. Postman collection with test scenarios
6. Full documentation

### What You Need to Provide
- Supabase project URL and keys
- Stripe test keys (sk_test_xxx, pk_test_xxx)
- GitHub repository access

---

## 🔒 Security Notes

- ✅ Never commit `.env` files
- ✅ Use Stripe test keys for development
- ✅ Use Supabase Row Level Security (RLS)
- ✅ Validate webhook signatures
- ✅ Use HTTPS in production

---

## 📚 Additional Resources

- [Stripe AfterPay Documentation](https://stripe.com/docs/payments/afterpay-clearpay)
- [Supabase REST API](https://supabase.com/docs/guides/api)
- [Bubble API Connector](https://manual.bubble.io/help-guides/integrations/api-connector)

---

## 📄 License

Proprietary - NFT Marketplace Admin Dashboard Module

---

**Built by:** Marco (NFT Admin Dashboard Developer)  
**Version:** 1.0.0  
**Last Updated:** October 2025  
**Stack:** Bubble.io + Supabase + Stripe + Node.js

