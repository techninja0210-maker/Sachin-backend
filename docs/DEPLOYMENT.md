# NFT Admin Dashboard - Deployment Guide

## 🎯 Overview

This guide covers deploying the NFT Admin Dashboard to production environments.

---

## 🚀 Deployment Options

### Option 1: Railway (Recommended for Webhooks)
- ✅ Easy deployment
- ✅ Automatic HTTPS
- ✅ Environment variable management
- ✅ Free tier available

### Option 2: Heroku
- ✅ Well-documented
- ✅ Add-ons ecosystem
- ⚠️ Paid plans required

### Option 3: AWS / DigitalOcean
- ✅ Full control
- ✅ Scalable
- ⚠️ More complex setup

---

## 📦 Part 1: Deploy Webhook Server to Railway

### Step 1: Prepare for Deployment

1. Ensure all code is committed:
   ```bash
   git add .
   git commit -m "Prepare for deployment"
   ```

2. Verify `.gitignore` excludes `.env` files

3. Test locally one more time:
   ```bash
   cd webhooks
   npm test
   ```

### Step 2: Install Railway CLI

```bash
npm install -g @railway/cli
```

### Step 3: Login to Railway

```bash
railway login
```

Browser will open for authentication.

### Step 4: Initialize Railway Project

```bash
cd webhooks
railway init
```

Choose:
- Create new project
- Name: `nft-admin-webhook`

### Step 5: Set Environment Variables

```bash
# Set all environment variables
railway variables set SUPABASE_URL=https://your-project.supabase.co
railway variables set SUPABASE_ANON_KEY=your-anon-key
railway variables set SUPABASE_SERVICE_KEY=your-service-key
railway variables set STRIPE_SECRET_KEY=sk_live_xxxxx
railway variables set STRIPE_PUBLISHABLE_KEY=pk_live_xxxxx
railway variables set STRIPE_WEBHOOK_SECRET=whsec_xxxxx
railway variables set NODE_ENV=production
railway variables set PORT=4242
```

⚠️ **Important:** Use **live** Stripe keys for production!

### Step 6: Deploy

```bash
railway up
```

Wait for deployment to complete (~2-3 minutes).

### Step 7: Get Deployment URL

```bash
railway domain
```

Or check Railway dashboard for URL (e.g., `https://nft-admin-webhook.up.railway.app`)

### Step 8: Test Deployed Webhook

```bash
curl https://your-railway-url.up.railway.app/health
```

Expected response:
```json
{
  "status": "healthy",
  "service": "nft-admin-webhook",
  "version": "1.0.0"
}
```

---

## 🔗 Part 2: Configure Stripe Production Webhook

### Step 1: Create Webhook Endpoint

1. Go to [Stripe Dashboard](https://dashboard.stripe.com) (LIVE MODE)
2. Navigate to **Developers → Webhooks**
3. Click "Add endpoint"
4. Enter URL: `https://your-railway-url.up.railway.app/webhook`

### Step 2: Select Events

Select these events:
- ✅ `checkout.session.completed`
- ✅ `invoice.payment_succeeded`
- ✅ `invoice.payment_failed`
- ✅ `customer.subscription.created`
- ✅ `customer.subscription.updated`
- ✅ `customer.subscription.deleted`
- ✅ `payment_intent.succeeded`
- ✅ `payment_intent.payment_failed`

### Step 3: Get Webhook Secret

1. Click on newly created webhook
2. Click "Reveal" under "Signing secret"
3. Copy secret (starts with `whsec_`)

### Step 4: Update Railway Environment

```bash
railway variables set STRIPE_WEBHOOK_SECRET=whsec_live_xxxxx
```

### Step 5: Test Webhook

1. In Stripe Dashboard, go to webhook details
2. Click "Send test webhook"
3. Select event: `checkout.session.completed`
4. Click "Send test webhook"
5. Verify response shows success

---

## 🎨 Part 3: Deploy Bubble.io App

### Step 1: Switch to Live Stripe Keys

1. Open Bubble editor
2. Go to **Plugins → Stripe**
3. Add live keys:
   ```
   Publishable Key (live): pk_live_xxxxx
   Secret Key (live): sk_live_xxxxx
   ```

### Step 2: Update API Connector (if using production Supabase)

If using separate production Supabase:
1. Go to **Plugins → API Connector**
2. Update Supabase_REST API:
   - URL: Production Supabase URL
   - Headers: Production anon key

### Step 3: Test in Development

1. Click "Preview" in Bubble
2. Test all workflows:
   - BNPL checkout
   - Subscription creation
   - Insurance verification
3. Verify data appears in production Supabase

### Step 4: Deploy to Live

1. Click "Deploy to live"
2. Add deployment notes
3. Click "Deploy"
4. Wait for deployment (~1-2 minutes)

### Step 5: Test Live App

1. Visit live app URL
2. Test complete user flows
3. Verify webhooks are received
4. Check production database

---

## 🗄️ Part 4: Production Database Setup

### Option A: Use Same Supabase Project

If using same Supabase for dev and production:
- ✅ No additional setup needed
- ⚠️ Use RLS to separate dev/prod data

### Option B: Create Production Supabase Project

1. Create new Supabase project: `nft-admin-prod`
2. Run schema:
   ```bash
   psql -h your-prod-host -U postgres -d postgres -f database/schema.sql
   ```
3. Update all services with production credentials

### Recommended: Row Level Security

Add RLS policies to separate environments:

```sql
-- Enable RLS
ALTER TABLE bnpl_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE weekly_subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE nft_insurance_logs ENABLE ROW LEVEL SECURITY;

-- Policy: Only production users
CREATE POLICY "Production users only"
ON bnpl_transactions
FOR ALL
USING (
  EXISTS (
    SELECT 1 FROM users 
    WHERE users.id = bnpl_transactions.user_id 
    AND users.environment = 'production'
  )
);
```

---

## 🔐 Part 5: Security Checklist

### Environment Variables
- [ ] All secrets stored in Railway/Heroku (not in code)
- [ ] `.env` files in `.gitignore`
- [ ] No hardcoded API keys in Bubble
- [ ] Webhook secrets rotated from test to live

### Stripe
- [ ] Live mode enabled
- [ ] Webhook signature verification enabled
- [ ] Test mode disabled in production
- [ ] Payment method restrictions configured

### Supabase
- [ ] Row Level Security (RLS) enabled
- [ ] Service key only used server-side
- [ ] Anon key used client-side only
- [ ] Database backups enabled

### Bubble
- [ ] Privacy rules configured
- [ ] Admin pages restricted to admin users
- [ ] API workflows secured
- [ ] SSL/HTTPS enabled (automatic on Bubble)

---

## 📊 Part 6: Monitoring & Logging

### Railway Logs

View logs:
```bash
railway logs
```

Or in Railway dashboard → Deployments → View logs

### Stripe Dashboard

Monitor:
- Payments → View all payments
- Subscriptions → Active subscriptions
- Webhooks → Event logs

### Supabase Dashboard

Monitor:
- Database → Table Editor (view records)
- Logs → View database logs
- API → Monitor API usage

### Bubble Logs

- Server logs → View workflow errors
- App logs → View user actions

---

## 🚨 Part 7: Rollback Plan

### If Webhook Server Fails

1. Check Railway logs:
   ```bash
   railway logs --tail
   ```

2. Rollback to previous deployment:
   ```bash
   railway rollback
   ```

3. Or redeploy from git:
   ```bash
   railway up
   ```

### If Bubble App Fails

1. Go to Bubble editor
2. Settings → Version control
3. Restore previous version
4. Deploy to live

### If Database Issues

1. Check Supabase logs
2. Restore from backup:
   - Supabase Dashboard → Database → Backups
   - Select backup point
   - Click "Restore"

---

## 📈 Part 8: Scaling Considerations

### Webhook Server

**Current:** Single Railway instance

**Scale to:**
- Multiple instances (Railway auto-scaling)
- Load balancer
- Queue system (Bull/Redis) for high volume

### Database

**Current:** Supabase free/pro tier

**Scale to:**
- Supabase Pro plan (more connections)
- Database indexing optimization
- Read replicas for analytics

### Bubble

**Current:** Bubble standard plan

**Scale to:**
- Bubble Production plan (more capacity)
- Dedicated instance
- API workflow optimization

---

## ✅ Deployment Checklist

### Pre-Deployment
- [ ] All tests passing locally
- [ ] Code reviewed and committed
- [ ] Environment variables documented
- [ ] Backup database
- [ ] Test mode thoroughly tested

### Deployment
- [ ] Webhook server deployed to Railway
- [ ] Environment variables set
- [ ] Stripe webhook endpoint created
- [ ] Webhook secret updated
- [ ] Bubble app deployed to live
- [ ] Live Stripe keys configured
- [ ] Production database ready

### Post-Deployment
- [ ] Health check endpoint responds
- [ ] Test BNPL transaction (small amount)
- [ ] Test subscription creation
- [ ] Test insurance verification
- [ ] Verify webhook events received
- [ ] Check database records created
- [ ] Monitor logs for errors
- [ ] Test admin dashboard access

### Monitoring
- [ ] Set up uptime monitoring (UptimeRobot, Pingdom)
- [ ] Configure error alerts (Railway, Sentry)
- [ ] Set up Stripe email notifications
- [ ] Document on-call procedures

---

## 🆘 Troubleshooting Production Issues

### Webhook Not Receiving Events

**Check:**
1. Railway deployment status
2. Webhook URL in Stripe dashboard
3. Webhook secret matches
4. Railway logs for errors

**Fix:**
```bash
# View logs
railway logs --tail

# Restart service
railway restart
```

### Database Connection Errors

**Check:**
1. Supabase service status
2. Connection string correct
3. Service key valid
4. Database not paused (free tier)

**Fix:**
- Verify `SUPABASE_URL` and `SUPABASE_SERVICE_KEY`
- Check Supabase dashboard for issues
- Restart webhook service

### Bubble API Calls Failing

**Check:**
1. API Connector configuration
2. Supabase anon key valid
3. RLS policies allow access
4. CORS settings

**Fix:**
- Re-initialize API calls
- Check Supabase API logs
- Verify headers in API Connector

---

## 📞 Support Resources

- **Railway:** https://railway.app/help
- **Stripe:** https://support.stripe.com
- **Supabase:** https://supabase.com/support
- **Bubble:** https://bubble.io/support

---

## 🔄 Continuous Deployment

### Setup GitHub Actions (Optional)

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy to Railway

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Use Node.js
        uses: actions/setup-node@v2
        with:
          node-version: '16'
      - name: Install Railway
        run: npm install -g @railway/cli
      - name: Deploy to Railway
        run: railway up
        env:
          RAILWAY_TOKEN: ${{ secrets.RAILWAY_TOKEN }}
```

---

**Version:** 1.0.0  
**Last Updated:** October 2025  
**Deployment Platform:** Railway + Bubble.io + Supabase

