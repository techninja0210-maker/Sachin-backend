# 🏦 Stripe Official Plugin Setup Guide

## 📋 Overview

Complete setup guide for integrating Stripe Official Plugin with the NFT Admin Dashboard for BNPL transactions and weekly subscriptions.

---

## 🚀 Step 1: Install Stripe Official Plugin

### 1.1 Install Plugin
1. Go to your Bubble.io app
2. Navigate to **Plugins** → **Marketplace**
3. Search for **"Stripe Official Plugin"**
4. Click **Install** and **Add to app**

### 1.2 Plugin Configuration
1. Go to **Plugins** → **Installed plugins**
2. Click on **Stripe Official Plugin**
3. Configure with your Stripe keys:

```bubble
API Keys:
├── Test Mode:
│   ├── Publishable Key: pk_test_xxxxxxxxxxxxx
│   └── Secret Key: sk_test_xxxxxxxxxxxxx
└── Live Mode:
    ├── Publishable Key: pk_live_xxxxxxxxxxxxx
    └── Secret Key: sk_live_xxxxxxxxxxxxx
```

---

## 💳 Step 2: BNPL Transaction Setup

### 2.1 Create BNPL Checkout Session
```bubble
Workflow: Create_BNPL_Checkout
├── Trigger: Button "Buy with BNPL" clicked
├── Action: Stripe Official Plugin → Create Checkout Session
└── Parameters:
    ├── Success URL: {{app_url}}/payment-success
    ├── Cancel URL: {{app_url}}/payment-cancel
    ├── Payment Method Types: ["afterpay_clearpay", "klarna", "card"]
    ├── Line Items:
    │   ├── Price Data:
    │   │   ├── Currency: "aud"
    │   │   ├── Unit Amount: {{item_price * 100}}
    │   │   ├── Product Name: "NFT Purchase"
    │   │   └── Description: "Buy Now Pay Later NFT Purchase"
    │   └── Quantity: 1
    ├── Metadata:
    │   ├── user_id: {{current_user.id}}
    │   ├── order_type: "bnpl"
    │   └── nft_id: {{current_nft.id}}
    └── Mode: "payment"
```

### 2.2 Handle BNPL Success
```bubble
Workflow: Handle_BNPL_Success
├── Trigger: Page "payment-success" is loaded
├── Action: API Connector → Get_BNPL_Transactions
│   └── Filter by: order_id = {{URL parameter: session_id}}
├── Action: Show success message
└── Action: Navigate to dashboard
```

---

## 📅 Step 3: Weekly Subscription Setup

### 3.1 Create Subscription Price (One-time setup)
1. Go to **Stripe Dashboard** → **Products** → **Create Product**
2. Configure subscription:

```stripe
Product Details:
├── Name: "Weekly NFT Subscription"
├── Description: "Weekly subscription for NFT platform access"
└── Pricing:
    ├── Model: Recurring
    ├── Price: $5.00 AUD
    ├── Billing Period: Weekly
    └── Price ID: price_xxxxxxxxxxxxx (SAVE THIS!)
```

### 3.2 Create Subscription Checkout
```bubble
Workflow: Create_Subscription_Checkout
├── Trigger: Button "Subscribe Weekly" clicked
├── Action: Stripe Official Plugin → Create Checkout Session
└── Parameters:
    ├── Success URL: {{app_url}}/subscription-success
    ├── Cancel URL: {{app_url}}/subscription-cancel
    ├── Line Items:
    │   ├── Price ID: price_xxxxxxxxxxxxx (from Step 3.1)
    │   └── Quantity: 1
    ├── Metadata:
    │   ├── user_id: {{current_user.id}}
    │   ├── subscription_type: "weekly"
    │   └── plan_name: "weekly_nft_access"
    ├── Mode: "subscription"
    └── Subscription Data:
        ├── Trial Period Days: 0
        └── Collection Method: "charge_automatically"
```

### 3.3 Handle Subscription Success
```bubble
Workflow: Handle_Subscription_Success
├── Trigger: Page "subscription-success" is loaded
├── Action: API Connector → Get_Weekly_Subscriptions
│   └── Filter by: subscription_id = {{URL parameter: subscription_id}}
├── Action: Update user subscription status
└── Action: Show subscription details
```

---

## 🔧 Step 4: Webhook Configuration

### 4.1 Stripe Webhook Setup
1. Go to **Stripe Dashboard** → **Developers** → **Webhooks**
2. Click **Add endpoint**
3. Configure endpoint:

```stripe
Endpoint URL: https://your-webhook-domain.com/webhook
Events to send:
├── checkout.session.completed
├── invoice.payment_succeeded
├── invoice.payment_failed
├── customer.subscription.deleted
├── payment_intent.succeeded
└── payment_intent.payment_failed
```

### 4.2 Webhook Secret
1. Copy the **Signing Secret** (whsec_xxxxxxxxxxxxx)
2. Add to your webhook server environment variables

---

## 📊 Step 5: Admin Dashboard Integration

### 5.1 BNPL Transactions Display
```bubble
Repeating Group: BNPL_Transactions
├── Data Source: API Connector → Get_BNPL_Transactions
├── Columns:
│   ├── User ID: {{item.user_id}}
│   ├── Order ID: {{item.order_id}}
│   ├── Payment Method: {{item.payment_method}}
│   ├── Amount: ${{item.amount_paid}}
│   ├── Status: {{item.bnpl_status}}
│   └── Date: {{item.created_at}}
└── Filtering: By user_id and status
```

### 5.2 Subscription Management
```bubble
Repeating Group: Weekly_Subscriptions
├── Data Source: API Connector → Get_Weekly_Subscriptions
├── Columns:
│   ├── User ID: {{item.user_id}}
│   ├── Subscription ID: {{item.subscription_id}}
│   ├── Status: {{item.status}}
│   ├── Next Billing: {{item.next_billing_date}}
│   └── Amount: ${{item.amount}}
└── Actions:
    ├── View Details
    └── Cancel Subscription (if needed)
```

---

## 🛠️ Step 6: Error Handling

### 6.1 Payment Failed Workflow
```bubble
Workflow: Handle_Payment_Failed
├── Trigger: Webhook received (invoice.payment_failed)
├── Action: Show user notification
├── Action: Update subscription status to "past_due"
├── Action: Lock user access temporarily
└── Action: Send email notification
```

### 6.2 Subscription Cancellation
```bubble
Workflow: Handle_Subscription_Cancelled
├── Trigger: Webhook received (customer.subscription.deleted)
├── Action: Update subscription status to "canceled"
├── Action: Lock user access
├── Action: Show cancellation confirmation
└── Action: Offer reactivation options
```

---

## 🔒 Step 7: Security Configuration

### 7.1 Environment Variables
```bubble
Stripe Keys:
├── Test Mode:
│   ├── STRIPE_PUBLISHABLE_KEY: pk_test_xxxxxxxxxxxxx
│   └── STRIPE_SECRET_KEY: sk_test_xxxxxxxxxxxxx
└── Live Mode:
    ├── STRIPE_PUBLISHABLE_KEY: pk_live_xxxxxxxxxxxxx
    └── STRIPE_SECRET_KEY: sk_live_xxxxxxxxxxxxx
```

### 7.2 API Security
- Never expose secret keys in frontend code
- Use Stripe Official Plugin for all payment operations
- Validate webhook signatures in backend
- Use HTTPS for all payment URLs

---

## 📋 Step 8: Testing Checklist

### 8.1 BNPL Testing
- [ ] Test AfterPay checkout flow
- [ ] Test Klarna checkout flow
- [ ] Test card payment fallback
- [ ] Verify webhook events are received
- [ ] Check database records are created
- [ ] Test payment failure scenarios

### 8.2 Subscription Testing
- [ ] Test weekly subscription creation
- [ ] Test recurring billing
- [ ] Test subscription cancellation
- [ ] Test payment failure handling
- [ ] Verify subscription status updates
- [ ] Test trial period (if applicable)

### 8.3 Admin Dashboard Testing
- [ ] Verify BNPL transactions display
- [ ] Verify subscription management
- [ ] Test filtering and sorting
- [ ] Test CSV export functionality
- [ ] Verify real-time updates

---

## 🚀 Step 9: Production Deployment

### 9.1 Go Live Checklist
- [ ] Switch to live Stripe keys
- [ ] Update webhook endpoint to production URL
- [ ] Test all payment flows in live mode
- [ ] Configure proper error handling
- [ ] Set up monitoring and alerts
- [ ] Document all configurations

### 9.2 Monitoring
- Monitor webhook delivery success rates
- Set up alerts for payment failures
- Track subscription churn rates
- Monitor BNPL transaction success rates
- Set up logging for all payment events

---

## 📚 Additional Resources

### Documentation Links
- [Stripe Official Plugin Documentation](https://bubble.io/plugin/stripe-1488739244826x768734287091433500)
- [Stripe API Documentation](https://stripe.com/docs/api)
- [AfterPay Integration Guide](https://stripe.com/docs/payments/afterpay-clearpay)
- [Stripe Webhooks Guide](https://stripe.com/docs/webhooks)

### Support
- Stripe Support: https://support.stripe.com
- Bubble.io Support: https://bubble.io/contact
- Project Documentation: See `/docs` folder

---

## ✅ Success Criteria

The Stripe integration is complete when:
- ✅ BNPL transactions process successfully
- ✅ Weekly subscriptions create and bill automatically
- ✅ Webhook events update the database correctly
- ✅ Admin dashboard displays all payment data
- ✅ Error handling works for failed payments
- ✅ All payment flows work in production mode
