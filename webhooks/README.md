# NFT Admin Webhook Server

## 🎯 Overview

Node.js + Express webhook server for handling Stripe events (BNPL, Subscriptions, Insurance payments) and updating Supabase database.

---

## 🚀 Quick Start

### 1. Install Dependencies
```bash
cd webhooks
npm install
```

### 2. Configure Environment
```bash
# Copy example environment file
cp env.example .env

# Edit .env and add your credentials
nano .env  # or use your preferred editor
```

### 3. Run the Server
```bash
# Development mode (with auto-reload)
npm run dev

# Production mode
npm start
```

The server will start on `http://localhost:4242`

---

## 🔧 Configuration

### Required Environment Variables

| Variable | Description | Example |
|:---------|:------------|:--------|
| `SUPABASE_URL` | Your Supabase project URL | `https://abc123.supabase.co` |
| `SUPABASE_SERVICE_KEY` | Supabase service role key (secret) | `eyJhbGc...` |
| `STRIPE_SECRET_KEY` | Stripe secret key (test or live) | `sk_test_xxx` |
| `STRIPE_WEBHOOK_SECRET` | Stripe webhook signing secret | `whsec_xxx` |
| `PORT` | Server port | `4242` |
| `NODE_ENV` | Environment (development/production) | `development` |

---

## 📡 Webhook Events Handled

### Checkout Events
- ✅ `checkout.session.completed` - BNPL purchases, subscription starts

### Invoice Events (Subscriptions)
- ✅ `invoice.payment_succeeded` - Subscription payment success
- ✅ `invoice.payment_failed` - Subscription payment failure (locks user)

### Subscription Events
- ✅ `customer.subscription.created` - New subscription
- ✅ `customer.subscription.updated` - Subscription status change
- ✅ `customer.subscription.deleted` - Subscription canceled

### Payment Intent Events
- ✅ `payment_intent.succeeded` - Direct payment success
- ✅ `payment_intent.payment_failed` - Direct payment failure

---

## 🧪 Testing

### Local Testing with Stripe CLI

1. **Install Stripe CLI**
   ```bash
   # macOS
   brew install stripe/stripe-cli/stripe
   
   # Windows
   scoop bucket add stripe https://github.com/stripe/scoop-stripe-cli.git
   scoop install stripe
   ```

2. **Login to Stripe**
   ```bash
   stripe login
   ```

3. **Forward Webhooks to Local Server**
   ```bash
   stripe listen --forward-to localhost:4242/webhook
   ```
   
   Copy the webhook signing secret (starts with `whsec_`) and add to `.env`

4. **Trigger Test Events**
   ```bash
   # Test successful checkout
   stripe trigger checkout.session.completed
   
   # Test successful invoice payment
   stripe trigger invoice.payment_succeeded
   
   # Test failed invoice payment
   stripe trigger invoice.payment_failed
   
   # Test subscription created
   stripe trigger customer.subscription.created
   ```

### Manual Testing with cURL

```bash
# Health check
curl http://localhost:4242/health

# Test BNPL transaction (development only)
curl -X POST http://localhost:4242/test/bnpl \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "00000000-0000-0000-0000-000000000001",
    "order_id": "TEST-ORDER-001",
    "payment_id": "pi_test_123",
    "payment_method": "afterpay_clearpay",
    "amount_paid": 99.99,
    "bnpl_status": "success",
    "metadata": {"test": true}
  }'
```

---

## 🔐 Security

### Webhook Signature Verification
All webhooks are verified using Stripe's signature verification:
```javascript
const event = stripe.webhooks.constructEvent(
  req.body, 
  signature, 
  WEBHOOK_SECRET
);
```

### Best Practices
- ✅ Never commit `.env` files
- ✅ Use test keys in development
- ✅ Rotate webhook secrets regularly
- ✅ Use HTTPS in production
- ✅ Implement rate limiting for production
- ✅ Monitor webhook failures

---

## 🛠 Database Operations

### BNPL Transactions
```javascript
await insertBNPLTransaction({
  user_id: 'uuid',
  order_id: 'ORDER-123',
  payment_id: 'pi_xxx',
  payment_method: 'afterpay_clearpay',
  amount_paid: 99.99,
  bnpl_status: 'success'
});
```

### Subscriptions
```javascript
await upsertSubscription({
  user_id: 'uuid',
  subscription_id: 'sub_xxx',
  stripe_customer_id: 'cus_xxx',
  status: 'active',
  next_billing_date: '2025-10-17'
});
```

### User Access Control
```javascript
await lockUserAccess(userId, 'subscription_payment_failed');
```

---

## 📊 Monitoring

### Server Logs
The webhook server logs all events:
```
🔔 Received event: checkout.session.completed
📦 Processing checkout.session.completed: cs_test_xxx
✅ BNPL transaction inserted: ORDER-123
✅ Checkout completed successfully
```

### Error Handling
All errors are caught and logged:
```
❌ Error inserting BNPL transaction: [error details]
⚠️ Webhook signature verification failed
```

---

## 🚀 Deployment

### Railway
```bash
# Install Railway CLI
npm install -g @railway/cli

# Login
railway login

# Deploy
railway up
```

### Heroku
```bash
# Create app
heroku create nft-admin-webhook

# Set environment variables
heroku config:set SUPABASE_URL=your_url
heroku config:set SUPABASE_SERVICE_KEY=your_key
# ... set all other variables

# Deploy
git push heroku main
```

### Update Stripe Webhook URL
After deployment, update your Stripe webhook endpoint:
1. Go to Stripe Dashboard → Webhooks
2. Add endpoint: `https://your-domain.com/webhook`
3. Select events to listen for
4. Copy webhook signing secret to your environment variables

---

## 🐛 Troubleshooting

### Webhook Not Receiving Events
1. Check Stripe Dashboard → Webhooks → Recent events
2. Verify webhook URL is correct
3. Ensure server is running and accessible
4. Check firewall settings

### Signature Verification Fails
1. Verify `STRIPE_WEBHOOK_SECRET` is correct
2. Ensure raw body is used (not JSON parsed)
3. Check Stripe CLI is forwarding correctly

### Database Insert Errors
1. Verify Supabase credentials
2. Check table names match schema
3. Ensure service key has proper permissions
4. Review Row Level Security (RLS) policies

---

## 📚 API Reference

### Endpoints

#### `POST /webhook`
Receives Stripe webhook events

**Headers:**
- `stripe-signature`: Webhook signature for verification

**Response:**
```json
{
  "received": true,
  "event": "checkout.session.completed"
}
```

#### `GET /health`
Health check endpoint

**Response:**
```json
{
  "status": "healthy",
  "service": "nft-admin-webhook",
  "version": "1.0.0",
  "timestamp": "2025-10-10T12:00:00.000Z"
}
```

#### `POST /test/bnpl` (Development Only)
Test BNPL transaction creation

#### `POST /test/subscription` (Development Only)
Test subscription creation

---

## 📝 Notes

- This webhook server is designed to be **modular and standalone**
- All database operations use Supabase service key for admin access
- Subscription failures automatically lock user access
- BNPL transactions are tracked for analytics
- All events include metadata for debugging

---

## 🔗 Resources

- [Stripe Webhooks Documentation](https://stripe.com/docs/webhooks)
- [Stripe CLI Documentation](https://stripe.com/docs/stripe-cli)
- [Supabase JavaScript Client](https://supabase.com/docs/reference/javascript/introduction)
- [Express.js Documentation](https://expressjs.com/)

---

**Version:** 1.0.0  
**Last Updated:** October 2025

