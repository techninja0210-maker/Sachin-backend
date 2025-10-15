# NFT Admin Dashboard - Testing Guide

## 🎯 Overview

Comprehensive testing guide for BNPL, Subscriptions, and Insurance functionality.

---

## 📋 Testing Checklist

### Database Tests
- [ ] All tables created successfully
- [ ] Triggers working (updated_at auto-updates)
- [ ] Views returning correct data
- [ ] RPC functions executing properly
- [ ] Sample data inserted correctly

### Webhook Tests
- [ ] Server starts without errors
- [ ] Health endpoint responds
- [ ] Stripe signature verification works
- [ ] BNPL transactions logged correctly
- [ ] Subscriptions created/updated correctly
- [ ] Payment failures handled properly
- [ ] User access locked on failure

### Bubble Tests
- [ ] API calls initialized successfully
- [ ] Repeating groups display data
- [ ] Filters work correctly
- [ ] Sorting works
- [ ] CSV export functions
- [ ] BNPL checkout flow works
- [ ] Subscription checkout works
- [ ] Insurance verification works

### Integration Tests
- [ ] End-to-end BNPL purchase
- [ ] End-to-end subscription creation
- [ ] End-to-end insurance application
- [ ] Webhook → Database → Bubble flow
- [ ] Payment failure → User lock flow

---

## 🧪 Test Scenarios

### Scenario 1: BNPL Purchase with AfterPay

**Objective:** Test complete BNPL purchase flow

**Steps:**
1. Open Bubble app NFT purchase page
2. Select NFT (e.g., $150 AUD)
3. Click "Buy with AfterPay"
4. Redirected to Stripe Checkout
5. Use test card: `4242 4242 4242 4242`
6. Complete checkout
7. Redirected to success page

**Expected Results:**
- ✅ Checkout session created successfully
- ✅ Payment processed
- ✅ Webhook received `checkout.session.completed` event
- ✅ BNPL transaction created in Supabase:
  ```sql
  SELECT * FROM bnpl_transactions 
  WHERE payment_method = 'afterpay_clearpay' 
  ORDER BY created_at DESC LIMIT 1;
  ```
- ✅ Transaction appears in Bubble admin dashboard
- ✅ Status shows "success"

**Test Data:**
```json
{
  "nft_price": 150.00,
  "payment_method": "afterpay_clearpay",
  "expected_status": "success"
}
```

---

### Scenario 2: BNPL Purchase Failure

**Objective:** Test failed BNPL payment handling

**Steps:**
1. Open NFT purchase page
2. Select NFT
3. Click "Buy with AfterPay"
4. Use declined test card: `4000 0000 0000 0002`
5. Attempt checkout

**Expected Results:**
- ✅ Payment declined
- ✅ Webhook received `payment_intent.payment_failed` event
- ✅ BNPL transaction created with status "failed"
- ✅ Error message displayed to user
- ✅ Transaction appears in admin dashboard with red badge

**Verification Query:**
```sql
SELECT * FROM bnpl_transactions 
WHERE bnpl_status = 'failed' 
ORDER BY created_at DESC LIMIT 1;
```

---

### Scenario 3: Weekly Subscription Creation

**Objective:** Test subscription signup flow

**Steps:**
1. Open subscription page in Bubble
2. Click "Subscribe Weekly - $5 AUD"
3. Redirected to Stripe Checkout
4. Enter test card: `4242 4242 4242 4242`
5. Complete checkout
6. Redirected to success page

**Expected Results:**
- ✅ Checkout session created (mode: subscription)
- ✅ Subscription created in Stripe
- ✅ Webhook received `customer.subscription.created` event
- ✅ Subscription record created in Supabase:
  ```sql
  SELECT * FROM weekly_subscriptions 
  WHERE status = 'active' 
  ORDER BY created_at DESC LIMIT 1;
  ```
- ✅ Next billing date set to 7 days from now
- ✅ Subscription appears in admin dashboard
- ✅ User has access to NFT Generator

**Verification:**
```sql
-- Check subscription
SELECT * FROM weekly_subscriptions WHERE user_id = 'test-user-id';

-- Check user access
SELECT * FROM get_user_active_subscription('test-user-id');
```

---

### Scenario 4: Subscription Payment Success

**Objective:** Test weekly recurring payment

**Steps:**
1. Wait for next billing date OR trigger manually:
   ```bash
   stripe trigger invoice.payment_succeeded
   ```
2. Check webhook logs
3. Verify database update

**Expected Results:**
- ✅ Webhook received `invoice.payment_succeeded` event
- ✅ Subscription status remains "active"
- ✅ Next billing date updated (+7 days)
- ✅ Payment logged in metadata
- ✅ User retains access

**Verification:**
```sql
SELECT subscription_id, status, next_billing_date, metadata 
FROM weekly_subscriptions 
WHERE subscription_id = 'sub_test_xxx';
```

---

### Scenario 5: Subscription Payment Failure

**Objective:** Test failed subscription payment and user lock

**Steps:**
1. Trigger payment failure:
   ```bash
   stripe trigger invoice.payment_failed
   ```
2. Check webhook logs
3. Verify user access locked

**Expected Results:**
- ✅ Webhook received `invoice.payment_failed` event
- ✅ Subscription status changed to "past_due"
- ✅ User access locked:
  ```sql
  SELECT subscription_locked, lock_reason 
  FROM users 
  WHERE id = 'test-user-id';
  ```
- ✅ Admin dashboard shows "Past Due" badge (orange)
- ✅ User cannot access NFT Generator
- ✅ "Update Payment Method" button shown

**Verification:**
```sql
SELECT * FROM weekly_subscriptions 
WHERE status = 'past_due' 
ORDER BY updated_at DESC LIMIT 1;
```

---

### Scenario 6: Subscription Cancellation

**Objective:** Test user canceling subscription

**Steps:**
1. In Bubble, user clicks "Cancel Subscription"
2. Confirm cancellation
3. Stripe cancels subscription
4. Webhook processes event

**Expected Results:**
- ✅ Subscription canceled in Stripe
- ✅ Webhook received `customer.subscription.deleted` event
- ✅ Subscription status changed to "canceled"
- ✅ Next billing date set to null
- ✅ User access locked
- ✅ Admin dashboard shows "Canceled" badge (red)

**Verification:**
```sql
SELECT * FROM weekly_subscriptions 
WHERE status = 'canceled' 
AND subscription_id = 'sub_test_xxx';
```

---

### Scenario 7: NFT Insurance Approval

**Objective:** Test insurance application and approval

**Steps:**
1. Open NFT purchase page
2. Check "Add Insurance" checkbox
3. Insurance details displayed (5% premium)
4. Click "Continue to Checkout"
5. Mock API called for verification
6. Checkout completed

**Expected Results:**
- ✅ Insurance premium calculated correctly (NFT price * 0.05)
- ✅ Mock API returns "approved" status
- ✅ Insurance policy ID generated
- ✅ Insurance log created in Supabase:
  ```sql
  SELECT * FROM nft_insurance_logs 
  WHERE insurance_status = 'approved' 
  ORDER BY created_at DESC LIMIT 1;
  ```
- ✅ Premium amount recorded
- ✅ Coverage amount equals NFT price
- ✅ Expiry date set to 1 year from now
- ✅ Admin dashboard shows insurance record

**Test Data:**
```json
{
  "nft_id": "test-nft-001",
  "nft_value": 150.00,
  "premium": 7.50,
  "expected_status": "approved"
}
```

---

### Scenario 8: NFT Insurance Rejection

**Objective:** Test insurance rejection handling

**Steps:**
1. Open NFT purchase page (high-value NFT > $500)
2. Check "Add Insurance"
3. Click "Continue to Checkout"
4. Mock API returns "rejected"

**Expected Results:**
- ✅ Mock API returns "rejected" status with reason
- ✅ Error message displayed: "Insurance cannot be applied. Reason: NFT value too high"
- ✅ Insurance checkbox unchecked automatically
- ✅ Insurance log created with status "rejected"
- ✅ Premium set to 0
- ✅ Policy ID is null

**Verification:**
```sql
SELECT * FROM nft_insurance_logs 
WHERE insurance_status = 'rejected' 
ORDER BY created_at DESC LIMIT 1;
```

---

### Scenario 9: Admin Dashboard Filtering

**Objective:** Test admin filtering functionality

**Steps:**
1. Open admin dashboard
2. Go to BNPL Transactions tab
3. Enter user ID in filter
4. Click "Apply Filters"
5. Verify filtered results

**Expected Results:**
- ✅ Only transactions for specified user shown
- ✅ Count updated correctly
- ✅ Sort order maintained (newest first)

**Test Filters:**
- Filter by user ID
- Filter by status (success/failed/pending)
- Filter by date range
- Combined filters

---

### Scenario 10: Admin Dashboard Statistics

**Objective:** Test statistics dashboard

**Steps:**
1. Open admin dashboard
2. Go to Statistics tab
3. Verify all statistics display

**Expected Results:**
- ✅ BNPL Statistics:
  - Total transactions count
  - Success count
  - Failed count
  - Total amount paid
  - Average transaction amount
- ✅ Subscription Statistics:
  - Total subscriptions
  - Active count
  - Canceled count
  - Monthly Recurring Revenue (MRR)
- ✅ Insurance Statistics:
  - Total applications
  - Approved count
  - Rejected count
  - Total coverage amount

**Verification Queries:**
```sql
-- BNPL Stats
SELECT * FROM get_bnpl_statistics();

-- Subscription Stats
SELECT * FROM get_subscription_statistics();

-- Insurance Stats
SELECT 
  COUNT(*) as total,
  COUNT(*) FILTER (WHERE insurance_status = 'approved') as approved,
  COUNT(*) FILTER (WHERE insurance_status = 'rejected') as rejected,
  SUM(coverage_amount) as total_coverage
FROM nft_insurance_logs;
```

---

## 🔧 Testing Tools

### 1. Postman Collection

**Setup:**
1. Import `postman/nft-admin-dashboard.postman_collection.json`
2. Create environment with variables:
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY`
   - `WEBHOOK_URL`
3. Run collection

**Key Requests:**
- Get All BNPL Transactions
- Get Active Subscriptions
- Get Insurance Logs
- Test Webhook Health
- Test BNPL Transaction (Dev)
- Test Subscription (Dev)

### 2. Stripe CLI

**Install:**
```bash
# macOS
brew install stripe/stripe-cli/stripe

# Windows
scoop install stripe
```

**Usage:**
```bash
# Login
stripe login

# Listen to webhooks
stripe listen --forward-to localhost:4242/webhook

# Trigger events
stripe trigger checkout.session.completed
stripe trigger invoice.payment_succeeded
stripe trigger invoice.payment_failed
stripe trigger customer.subscription.created
stripe trigger customer.subscription.deleted
```

### 3. Supabase SQL Editor

**Test Queries:**

```sql
-- View recent BNPL transactions
SELECT * FROM vw_recent_bnpl_transactions LIMIT 10;

-- View active subscriptions
SELECT * FROM vw_active_subscriptions;

-- View insurance applications
SELECT * FROM vw_insurance_applications LIMIT 10;

-- Check user subscription status
SELECT * FROM get_user_active_subscription('user-id-here');

-- Get statistics
SELECT * FROM get_bnpl_statistics();
SELECT * FROM get_subscription_statistics();

-- Check NFT insurance
SELECT check_nft_insurance('nft-id-here');
```

### 4. Browser Developer Tools

**Check:**
- Network tab for API calls
- Console for errors
- Application → Local Storage for session data

---

## 📊 Test Data

### Test Credit Cards (Stripe)

| Card Number | Scenario | Expected Result |
|:------------|:---------|:----------------|
| 4242 4242 4242 4242 | Success | Payment succeeds |
| 4000 0000 0000 0002 | Decline | Payment declined |
| 4000 0000 0000 9995 | Insufficient funds | Payment fails |
| 4000 0000 0000 0069 | Expired card | Payment fails |

### Test User IDs

```
00000000-0000-0000-0000-000000000001
00000000-0000-0000-0000-000000000002
00000000-0000-0000-0000-000000000003
```

### Test NFT IDs

```
10000000-0000-0000-0000-000000000001
10000000-0000-0000-0000-000000000002
10000000-0000-0000-0000-000000000003
```

---

## 🐛 Common Issues & Solutions

### Issue 1: Webhook Signature Verification Failed

**Symptoms:**
```
⚠️ Webhook signature verification failed
```

**Solution:**
1. Check `STRIPE_WEBHOOK_SECRET` in `.env`
2. Verify it matches Stripe CLI output or dashboard
3. Ensure raw body is used (not JSON parsed)

### Issue 2: Database Insert Fails

**Symptoms:**
```
❌ Error inserting BNPL transaction: null value in column "user_id"
```

**Solution:**
1. Verify user_id is being passed in metadata
2. Check Stripe checkout session includes `client_reference_id`
3. Ensure webhook handler extracts user_id correctly

### Issue 3: Bubble API Call Returns Empty

**Symptoms:**
- Repeating group shows no data
- API call returns `[]`

**Solution:**
1. Check Supabase has data:
   ```sql
   SELECT count(*) FROM bnpl_transactions;
   ```
2. Verify API call URL is correct
3. Re-initialize API call in Bubble
4. Check RLS policies allow access

### Issue 4: Insurance API Not Responding

**Symptoms:**
- Insurance verification hangs
- No response from mock API

**Solution:**
1. Mock API (Beeceptor) may be rate-limited
2. Create your own mock using Postman Mock Server
3. Or use Bubble's "Return data from API" with static JSON

---

## ✅ Test Results Template

```markdown
## Test Run: [Date]

### Environment
- Supabase: [Project URL]
- Stripe: Test Mode
- Bubble: Development
- Webhook: Local (localhost:4242)

### Test Results

| Scenario | Status | Notes |
|:---------|:-------|:------|
| BNPL Purchase Success | ✅ Pass | Transaction ID: txn_123 |
| BNPL Purchase Failure | ✅ Pass | Correctly shows error |
| Subscription Creation | ✅ Pass | Sub ID: sub_abc |
| Subscription Payment Success | ✅ Pass | Next billing updated |
| Subscription Payment Failure | ✅ Pass | User locked correctly |
| Subscription Cancellation | ✅ Pass | Status changed to canceled |
| Insurance Approval | ✅ Pass | Policy ID generated |
| Insurance Rejection | ✅ Pass | Error message shown |
| Admin Dashboard Filters | ✅ Pass | All filters working |
| Admin Dashboard Statistics | ✅ Pass | Correct calculations |

### Issues Found
- None

### Next Steps
- Deploy to staging
- Test with real Stripe account
- User acceptance testing
```

---

## 📝 Testing Checklist

Before marking complete:

- [ ] All 10 test scenarios passed
- [ ] Postman collection runs successfully
- [ ] Stripe CLI triggers work
- [ ] Database queries return expected data
- [ ] Bubble UI displays all data correctly
- [ ] Filters and sorting work
- [ ] CSV export works
- [ ] Error handling tested
- [ ] Edge cases tested (null values, empty strings, etc.)
- [ ] Performance tested (100+ records)
- [ ] Documentation updated with test results

---

## 🔗 Resources

- [Stripe Testing Documentation](https://stripe.com/docs/testing)
- [Supabase Testing Guide](https://supabase.com/docs/guides/getting-started/testing)
- [Bubble Testing Best Practices](https://manual.bubble.io/help-guides/testing-and-debugging)

---

**Version:** 1.0.0  
**Last Updated:** October 2025

