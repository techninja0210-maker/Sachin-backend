# 🚀 NFT Admin Dashboard - Production Ready

> **Complete Admin Dashboard for NFT Project with BNPL, Subscriptions, and Insurance Tracking**

[![Production Ready](https://img.shields.io/badge/Status-Production%20Ready-green.svg)](https://github.com/your-repo/nft-admin-dashboard)
[![Security](https://img.shields.io/badge/Security-Secure-blue.svg)](SECURITY-CHECKLIST.md)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

## 📋 Project Overview

A modular, production-ready admin dashboard for tracking BNPL transactions, weekly subscriptions, and NFT insurance logs. Built with **Supabase**, **Stripe**, **Node.js**, and **Bubble.io** for the MFH Project.

### ✨ Key Features

- 🔄 **Real-time BNPL Transaction Tracking** via Stripe AfterPay/ClearPay
- 📅 **Weekly Subscription Management** ($5.00 AUD/week)
- 🛡️ **NFT Insurance Logs** with approval/rejection workflow
- 📊 **Admin Dashboard** with filtering, sorting, and analytics
- 🔐 **Production Security** with RLS, webhook verification, and rate limiting
- 📤 **CSV Export Functionality** with audit logging
- 🌐 **Modular Design** for easy integration with main NFT platform

---

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Bubble.io     │    │   Node.js       │    │   Supabase      │
│   Frontend      │◄──►│   Webhook       │◄──►│   Database      │
│   (Admin UI)    │    │   Server        │    │   (PostgreSQL)  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Stripe API    │    │   Stripe CLI    │    │   API Views     │
│   (Payments)    │    │   (Webhooks)    │    │   (Analytics)   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

---

## 🚀 Quick Start

### Prerequisites
- **Supabase Account** with project created
- **Stripe Account** with test/live keys
- **Node.js** 16+ installed
- **Bubble.io Account** for frontend

### 1. Database Setup (5 minutes)
```bash
# 1. Go to Supabase SQL Editor
https://supabase.com/dashboard/project/YOUR_PROJECT/editor

# 2. Run production schema
Copy database/schema-production.sql → Paste → Run

# 3. Add test data (optional)
Copy database/seed-data.sql → Paste → Run
```

### 2. Backend Setup (5 minutes)
```bash
# 1. Navigate to webhooks folder
cd webhooks

# 2. Install dependencies
npm install

# 3. Configure environment
cp env.production.example .env
# Edit .env with your API keys

# 4. Start server
npm start
```

### 3. Frontend Setup (10 minutes)
```bash
# 1. Import Bubble configuration
Use bubble/api-connector-production.json

# 2. Follow UI specs
See bubble/admin-ui-production-specs.md

# 3. Test integration
Use postman/nft-admin-dashboard-production.postman_collection.json
```

---

## 📁 Project Structure

```
nft-admin-dashboard/
│
├── 📊 database/
│   ├── schema-production.sql          # Production database schema
│   ├── seed-data.sql                  # Test data
│   └── csv-export-functions.sql       # CSV export functions
│
├── 🔧 webhooks/
│   ├── stripe-webhook-production.js   # Production webhook server
│   ├── package.json                   # Dependencies
│   └── env.production.example         # Environment template
│
├── 🎨 bubble/
│   ├── api-connector-production.json  # Production API config
│   ├── admin-ui-production-specs.md   # UI specifications
│   └── csv-export-workflow.md         # Export functionality
│
├── 🧪 postman/
│   └── nft-admin-dashboard-production.postman_collection.json
│
├── 📚 docs/
│   ├── SETUP.md                       # Detailed setup guide
│   ├── TESTING.md                     # Testing procedures
│   ├── DEPLOYMENT.md                  # Production deployment
│   └── API-REFERENCE.md               # API documentation
│
├── 🔒 SECURITY-CHECKLIST.md           # Security verification
├── 🚀 HOW-TO-RUN.md                   # Quick start guide
├── ⚡ QUICK-START.md                   # 15-minute setup
└── 📄 README.md                       # This file
```

---

## 🔑 Environment Variables

### Required Variables
```env
# Supabase Configuration
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_SERVICE_KEY=your_service_role_key_here
SUPABASE_ANON_KEY=your_anon_key_here

# Stripe Configuration
STRIPE_SECRET_KEY=sk_live_your_live_secret_key_here
STRIPE_PUBLISHABLE_KEY=pk_live_your_live_publishable_key_here
STRIPE_WEBHOOK_SECRET=whsec_your_webhook_secret_here

# Server Configuration
PORT=3000
NODE_ENV=production
```

### Getting Your API Keys

#### Supabase Keys
1. Go to: `https://supabase.com/dashboard/project/YOUR_PROJECT/settings/api`
2. Copy **Project URL** → `SUPABASE_URL`
3. Copy **anon public** key → `SUPABASE_ANON_KEY`
4. Copy **service_role** key → `SUPABASE_SERVICE_KEY`

#### Stripe Keys
1. Go to: `https://dashboard.stripe.com/apikeys`
2. Copy **Secret key** → `STRIPE_SECRET_KEY`
3. Copy **Publishable key** → `STRIPE_PUBLISHABLE_KEY`
4. Create webhook endpoint → Copy **Signing secret** → `STRIPE_WEBHOOK_SECRET`

---

## 🗄️ Database Schema

### Core Tables
```sql
-- BNPL Transactions
bnpl_transactions (id, user_id, order_id, payment_id, payment_method, 
                   amount_paid, bnpl_status, metadata, created_at, updated_at)

-- Weekly Subscriptions  
weekly_subscriptions (id, user_id, subscription_id, stripe_customer_id,
                     status, start_date, next_billing_date, amount, 
                     currency, metadata, created_at, updated_at)

-- NFT Insurance Logs
nft_insurance_logs (id, user_id, nft_id, insurance_status, 
                   insurance_policy_id, coverage_amount, premium_paid,
                   expiry_date, metadata, created_at, updated_at)

-- Global Transactions (BONUS)
transactions (id, transaction_type, source_table, source_id,
             user_id, amount, status, metadata, created_at, updated_at)
```

### Key Features
- ✅ **Foreign key constraints** to `auth.users` table
- ✅ **Row Level Security (RLS)** enabled
- ✅ **Auto-updating timestamps** with triggers
- ✅ **Metadata JSONB columns** for extensibility
- ✅ **Optimized views** for admin dashboard
- ✅ **Analytics functions** for statistics
- ✅ **CSV export functions** with filtering

---

## 🔧 API Endpoints

### Webhook Server
```bash
# Health Check
GET /health

# Stripe Webhooks
POST /webhook

# Test Endpoints (Development)
POST /test/bnpl
POST /test/subscription  
POST /test/insurance
```

### Supabase REST API
```bash
# BNPL Transactions
GET /rest/v1/bnpl_transactions
GET /rest/v1/vw_recent_bnpl_transactions

# Weekly Subscriptions
GET /rest/v1/weekly_subscriptions
GET /rest/v1/vw_active_subscriptions

# NFT Insurance Logs
GET /rest/v1/nft_insurance_logs
GET /rest/v1/vw_insurance_applications

# Global Transactions
GET /rest/v1/transactions
GET /rest/v1/vw_transactions_summary

# Statistics Functions
POST /rest/v1/rpc/get_bnpl_statistics
POST /rest/v1/rpc/get_subscription_statistics
POST /rest/v1/rpc/get_transaction_statistics
```

---

## 🎨 Frontend Features

### Admin Dashboard
- **📊 3 Main Tabs**: BNPL, Subscriptions, Insurance
- **🔍 Advanced Filtering**: By user ID, status, date range
- **📈 Real-time Statistics**: Revenue, success rates, analytics
- **📤 CSV Export**: Filtered data export with audit logging
- **📱 Responsive Design**: Works on desktop, tablet, mobile

### UI Components
- **Status Badges**: Color-coded status indicators
- **Data Tables**: Sortable, filterable repeating groups
- **Loading States**: Spinners and skeleton loaders
- **Error Handling**: User-friendly error messages
- **Success Notifications**: Action confirmation messages

---

## 🔒 Security Features

### Production Security
- ✅ **Environment Variables**: No hardcoded secrets
- ✅ **Webhook Verification**: Stripe signature validation
- ✅ **Rate Limiting**: Express rate limiting (1000 req/15min)
- ✅ **Security Headers**: Helmet.js protection
- ✅ **Row Level Security**: Database-level access control
- ✅ **Error Handling**: No sensitive data in error messages
- ✅ **Audit Logging**: All exports and actions logged

### Access Control
- **Admin Only**: Dashboard restricted to authenticated admins
- **Read-only Frontend**: Supabase anon key (read-only)
- **Service Role Backend**: Full access for webhook operations
- **Data Masking**: Partial IDs for privacy protection

---

## 🚀 Deployment

### Local Development
```bash
# 1. Clone repository
git clone https://github.com/your-repo/nft-admin-dashboard.git
cd nft-admin-dashboard

# 2. Setup database
# Run database/schema-production.sql in Supabase

# 3. Setup webhook server
cd webhooks
npm install
cp env.production.example .env
# Edit .env with your keys
npm start

# 4. Setup frontend
# Follow bubble/admin-ui-production-specs.md
```

### Production Deployment

#### Railway (Recommended)
```bash
# 1. Connect GitHub repository
# 2. Set environment variables
# 3. Deploy automatically
```

#### Heroku
```bash
# 1. Create Heroku app
heroku create your-app-name

# 2. Set environment variables
heroku config:set SUPABASE_URL=your_url
heroku config:set STRIPE_SECRET_KEY=your_key
# ... set all required variables

# 3. Deploy
git push heroku main
```

#### Vercel
```bash
# 1. Connect repository
# 2. Set environment variables in dashboard
# 3. Deploy automatically
```

---

## 🧪 Testing

### API Testing
```bash
# Import Postman collection
postman/nft-admin-dashboard-production.postman_collection.json

# Test endpoints
GET /health
POST /webhook (with Stripe test events)
GET /rest/v1/bnpl_transactions
```

### Stripe Testing
```bash
# Install Stripe CLI
stripe login

# Forward webhooks
stripe listen --forward-to localhost:3000/webhook

# Trigger test events
stripe trigger payment_intent.succeeded
stripe trigger invoice.payment_succeeded
stripe trigger customer.subscription.deleted
```

### Database Testing
```sql
-- Test data insertion
INSERT INTO bnpl_transactions (user_id, order_id, payment_method, amount_paid, bnpl_status)
VALUES ('00000000-0000-0000-0000-000000000001', 'TEST-001', 'afterpay_clearpay', 150.00, 'success');

-- Test views
SELECT * FROM vw_recent_bnpl_transactions LIMIT 10;

-- Test statistics
SELECT * FROM get_bnpl_statistics();
```

---

## 📊 Monitoring & Analytics

### Health Checks
- **Webhook Server**: `GET /health` endpoint
- **Database Connectivity**: Supabase connection status
- **Stripe Integration**: Webhook processing status
- **API Response Times**: Performance monitoring

### Analytics Dashboard
- **BNPL Statistics**: Total transactions, success rates, revenue
- **Subscription Metrics**: Active subscriptions, churn rate, MRR
- **Insurance Analytics**: Approval rates, coverage amounts
- **Global Overview**: Combined transaction statistics

---

## 🔄 Integration with Main NFT Platform

### Modular Design
This dashboard is designed to be easily integrated with your main NFT platform:

1. **Database Integration**: Add foreign key constraints to your existing `users` and `nfts` tables
2. **API Integration**: Use existing webhook server for real-time updates
3. **UI Integration**: Import Bubble.io components into your main app
4. **Authentication**: Connect to your existing user authentication system

### Migration Path
```sql
-- 1. Add foreign key constraints (when ready)
ALTER TABLE bnpl_transactions 
ADD CONSTRAINT fk_bnpl_users 
FOREIGN KEY (user_id) REFERENCES auth.users(id);

-- 2. Update RLS policies for your user roles
-- 3. Integrate with your existing admin panel
-- 4. Connect to your main application workflow
```

---

## 📈 Performance & Scalability

### Optimizations
- **Database Indexes**: Optimized for common queries
- **API Views**: Pre-computed views for dashboard
- **Rate Limiting**: Prevents abuse and ensures stability
- **Caching**: Statistics cached for 5 minutes
- **Pagination**: Large datasets handled efficiently

### Scalability
- **Horizontal Scaling**: Webhook server can be replicated
- **Database Scaling**: Supabase handles scaling automatically
- **CDN Ready**: Static assets can be served via CDN
- **Load Balancing**: Multiple webhook instances supported

---

## 🛠️ Troubleshooting

### Common Issues

#### Webhook Server Won't Start
```bash
# Check environment variables
cat .env

# Check port availability
netstat -ano | findstr :3000

# Check dependencies
npm install
```

#### Database Connection Issues
```sql
-- Test Supabase connection
SELECT version();

-- Check table permissions
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public';
```

#### Frontend Data Not Loading
1. Check Supabase API key configuration
2. Verify API Connector setup in Bubble
3. Check browser console for errors
4. Verify RLS policies allow access

### Error Codes
- **400**: Bad request (check webhook signature)
- **401**: Unauthorized (check API keys)
- **403**: Forbidden (check RLS policies)
- **500**: Server error (check logs)

---

## 📚 Documentation

### Complete Guides
- **[Setup Guide](docs/SETUP.md)** - Detailed setup instructions
- **[Testing Guide](docs/TESTING.md)** - Comprehensive testing procedures
- **[Deployment Guide](docs/DEPLOYMENT.md)** - Production deployment
- **[API Reference](docs/API-REFERENCE.md)** - Complete API documentation
- **[Security Checklist](SECURITY-CHECKLIST.md)** - Security verification
- **[Quick Start](QUICK-START.md)** - 15-minute setup guide

### Bubble.io Guides
- **[Admin UI Specs](bubble/admin-ui-production-specs.md)** - Complete UI specifications
- **[API Connector Config](bubble/api-connector-production.json)** - API configuration
- **[CSV Export Workflow](bubble/csv-export-workflow.md)** - Export functionality

---

## 🤝 Contributing

### Development Setup
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

### Code Standards
- **ESLint**: JavaScript linting
- **Prettier**: Code formatting
- **Security**: No hardcoded secrets
- **Documentation**: Update docs for changes
- **Testing**: Include tests for new features

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🆘 Support

### Getting Help
1. **Documentation**: Check the comprehensive guides in `docs/`
2. **Issues**: Create GitHub issues for bugs or feature requests
3. **Security**: Report security issues privately
4. **Community**: Join discussions in GitHub Discussions

### Contact
- **GitHub Issues**: For bugs and feature requests
- **Documentation**: Complete guides in `docs/` folder
- **Security**: See [SECURITY-CHECKLIST.md](SECURITY-CHECKLIST.md)

---

## 🎯 Roadmap

### Completed ✅
- [x] Production-ready database schema
- [x] Secure webhook server with retry logic
- [x] Complete admin dashboard UI
- [x] CSV export functionality
- [x] Comprehensive security measures
- [x] Full documentation and testing guides

### Future Enhancements 🚀
- [ ] Real-time notifications
- [ ] Advanced analytics dashboard
- [ ] Automated reporting
- [ ] Multi-tenant support
- [ ] Mobile app integration
- [ ] Advanced filtering and search

---

## 🙏 Acknowledgments

- **Supabase** for the excellent database platform
- **Stripe** for robust payment processing
- **Bubble.io** for powerful no-code frontend
- **Node.js** community for excellent libraries
- **Open Source** contributors for inspiration

---

**🎉 Ready to deploy! This dashboard is production-ready and fully documented.**

**Status: ✅ COMPLETE - All client requirements addressed with bonus features included**