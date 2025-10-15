# NFT Admin Dashboard - API Reference

## 🎯 Overview

Complete API reference for Supabase REST API, Webhook endpoints, and Mock Insurance API.

---

## 📊 Supabase REST API

Base URL: `https://YOUR_PROJECT.supabase.co/rest/v1`

### Authentication

All requests require headers:
```
apikey: YOUR_SUPABASE_ANON_KEY
Authorization: Bearer YOUR_SUPABASE_ANON_KEY
Content-Type: application/json
```

---

## 🛒 BNPL Transactions API

### Get All BNPL Transactions

```http
GET /bnpl_transactions
```

**Query Parameters:**
| Parameter | Type | Description | Example |
|:----------|:-----|:------------|:--------|
| `select` | string | Fields to return | `*` or `id,order_id,amount_paid` |
| `order` | string | Sort order | `created_at.desc` |
| `limit` | integer | Max records | `100` |
| `user_id` | string | Filter by user | `eq.uuid-here` |
| `bnpl_status` | string | Filter by status | `eq.success` |

**Example Request:**
```bash
curl -X GET \
  'https://your-project.supabase.co/rest/v1/bnpl_transactions?select=*&order=created_at.desc&limit=10' \
  -H 'apikey: YOUR_KEY' \
  -H 'Authorization: Bearer YOUR_KEY'
```

**Response:**
```json
[
  {
    "id": "uuid",
    "user_id": "uuid",
    "order_id": "ORDER-2025-001",
    "payment_id": "pi_3ABC123XYZ",
    "payment_method": "afterpay_clearpay",
    "amount_paid": 150.00,
    "bnpl_status": "success",
    "metadata": {
      "nft_name": "Cool Ape #123"
    },
    "created_at": "2025-10-10T12:00:00Z",
    "updated_at": "2025-10-10T12:00:00Z"
  }
]
```

### Get BNPL Transaction by ID

```http
GET /bnpl_transactions?id=eq.{transaction_id}
```

### Get User's BNPL Transactions

```http
GET /bnpl_transactions?user_id=eq.{user_id}&order=created_at.desc
```

### Get BNPL Statistics

```http
POST /rpc/get_bnpl_statistics
```

**Request Body:**
```json
{}
```

**Response:**
```json
[
  {
    "total_transactions": 150,
    "total_amount_paid": 15234.50,
    "success_count": 140,
    "failed_count": 10,
    "pending_count": 0,
    "avg_transaction_amount": 101.56
  }
]
```

---

## 💳 Weekly Subscriptions API

### Get All Subscriptions

```http
GET /weekly_subscriptions
```

**Query Parameters:**
| Parameter | Type | Description | Example |
|:----------|:-----|:------------|:--------|
| `select` | string | Fields to return | `*` |
| `order` | string | Sort order | `created_at.desc` |
| `status` | string | Filter by status | `eq.active` |
| `user_id` | string | Filter by user | `eq.uuid-here` |

**Example Request:**
```bash
curl -X GET \
  'https://your-project.supabase.co/rest/v1/weekly_subscriptions?status=eq.active' \
  -H 'apikey: YOUR_KEY' \
  -H 'Authorization: Bearer YOUR_KEY'
```

**Response:**
```json
[
  {
    "id": "uuid",
    "user_id": "uuid",
    "subscription_id": "sub_1ABC123XYZ456",
    "stripe_customer_id": "cus_ABC123XYZ",
    "start_date": "2025-01-01",
    "status": "active",
    "next_billing_date": "2025-10-17",
    "amount": 5.00,
    "currency": "AUD",
    "metadata": {
      "plan": "nft_generator_weekly"
    },
    "created_at": "2025-01-01T00:00:00Z",
    "updated_at": "2025-10-10T12:00:00Z"
  }
]
```

### Get User's Active Subscription

```http
POST /rpc/get_user_active_subscription
```

**Request Body:**
```json
{
  "p_user_id": "user-uuid-here"
}
```

**Response:**
```json
[
  {
    "subscription_id": "sub_1ABC123XYZ456",
    "status": "active",
    "next_billing_date": "2025-10-17",
    "amount": 5.00
  }
]
```

### Get Subscription Statistics

```http
POST /rpc/get_subscription_statistics
```

**Request Body:**
```json
{}
```

**Response:**
```json
[
  {
    "total_subscriptions": 85,
    "active_count": 72,
    "canceled_count": 13,
    "paused_count": 0,
    "monthly_recurring_revenue": 1440.00
  }
]
```

---

## 🛡️ NFT Insurance Logs API

### Get All Insurance Logs

```http
GET /nft_insurance_logs
```

**Query Parameters:**
| Parameter | Type | Description | Example |
|:----------|:-----|:------------|:--------|
| `select` | string | Fields to return | `*` |
| `order` | string | Sort order | `created_at.desc` |
| `insurance_status` | string | Filter by status | `eq.approved` |
| `user_id` | string | Filter by user | `eq.uuid-here` |
| `nft_id` | string | Filter by NFT | `eq.uuid-here` |

**Example Request:**
```bash
curl -X GET \
  'https://your-project.supabase.co/rest/v1/nft_insurance_logs?insurance_status=eq.approved' \
  -H 'apikey: YOUR_KEY' \
  -H 'Authorization: Bearer YOUR_KEY'
```

**Response:**
```json
[
  {
    "id": "uuid",
    "user_id": "uuid",
    "nft_id": "uuid",
    "insurance_status": "approved",
    "insurance_policy_id": "POLICY-NFT-2025-001",
    "coverage_amount": 150.00,
    "premium_paid": 7.50,
    "expiry_date": "2026-01-15",
    "metadata": {
      "provider": "mock_insurance_api",
      "coverage_type": "theft_and_loss"
    },
    "created_at": "2025-10-10T12:00:00Z",
    "updated_at": "2025-10-10T12:00:00Z"
  }
]
```

### Check NFT Insurance Status

```http
POST /rpc/check_nft_insurance
```

**Request Body:**
```json
{
  "p_nft_id": "nft-uuid-here"
}
```

**Response:**
```json
true  // or false
```

---

## 📈 Admin Views API

### Get Recent BNPL Transactions (View)

```http
GET /vw_recent_bnpl_transactions
```

**Response includes user email (joined from users table):**
```json
[
  {
    "id": "uuid",
    "user_id": "uuid",
    "user_email": "user@example.com",
    "order_id": "ORDER-2025-001",
    "payment_id": "pi_3ABC123XYZ",
    "payment_method": "afterpay_clearpay",
    "amount_paid": 150.00,
    "bnpl_status": "success",
    "created_at": "2025-10-10T12:00:00Z"
  }
]
```

### Get Active Subscriptions (View)

```http
GET /vw_active_subscriptions
```

### Get Insurance Applications (View)

```http
GET /vw_insurance_applications
```

---

## 🔔 Webhook Server API

Base URL: `http://localhost:4242` (development) or `https://your-domain.com` (production)

### Health Check

```http
GET /health
```

**Response:**
```json
{
  "status": "healthy",
  "service": "nft-admin-webhook",
  "version": "1.0.0",
  "timestamp": "2025-10-10T12:00:00.000Z"
}
```

### Stripe Webhook Endpoint

```http
POST /webhook
```

**Headers:**
```
stripe-signature: t=timestamp,v1=signature
Content-Type: application/json
```

**Request Body:** (Stripe event object)
```json
{
  "id": "evt_xxx",
  "object": "event",
  "type": "checkout.session.completed",
  "data": {
    "object": { /* Stripe object */ }
  }
}
```

**Response:**
```json
{
  "received": true,
  "event": "checkout.session.completed"
}
```

**Supported Events:**
- `checkout.session.completed`
- `invoice.payment_succeeded`
- `invoice.payment_failed`
- `customer.subscription.created`
- `customer.subscription.updated`
- `customer.subscription.deleted`
- `payment_intent.succeeded`
- `payment_intent.payment_failed`

### Test BNPL Transaction (Development Only)

```http
POST /test/bnpl
```

**Request Body:**
```json
{
  "user_id": "uuid",
  "order_id": "TEST-ORDER-001",
  "payment_id": "pi_test_123",
  "payment_method": "afterpay_clearpay",
  "amount_paid": 99.99,
  "bnpl_status": "success",
  "metadata": {
    "test": true
  }
}
```

**Response:**
```json
{
  "success": true,
  "message": "Test BNPL transaction created"
}
```

### Test Subscription (Development Only)

```http
POST /test/subscription
```

**Request Body:**
```json
{
  "user_id": "uuid",
  "subscription_id": "sub_test_123",
  "stripe_customer_id": "cus_test_123",
  "start_date": "2025-10-10",
  "status": "active",
  "next_billing_date": "2025-10-17",
  "amount": 5.00,
  "currency": "AUD",
  "metadata": {
    "test": true
  }
}
```

---

## 🛡️ Mock Insurance API

Base URL: `https://mock-insurance-api.free.beeceptor.com`

### Verify Insurance Coverage

```http
POST /insurance/verify
```

**Request Body:**
```json
{
  "user_id": "uuid",
  "nft_id": "uuid",
  "plan": "standard"
}
```

**Response (Success):**
```json
{
  "status": "approved",
  "policy_id": "POLICY-MOCK-12345",
  "coverage_amount": 100.00,
  "premium": 5.00,
  "expiry_date": "2026-10-10"
}
```

**Response (Rejection):**
```json
{
  "status": "rejected",
  "reason": "NFT value too high for standard coverage"
}
```

### Get Insurance Quote

```http
POST /insurance/quote
```

**Request Body:**
```json
{
  "nft_value": 150.00,
  "coverage_type": "theft_and_loss"
}
```

**Response:**
```json
{
  "premium": 7.50,
  "coverage_amount": 150.00,
  "coverage_percentage": 5,
  "valid_for_days": 30
}
```

---

## 🔍 Query Operators (Supabase)

### Comparison Operators

| Operator | Description | Example |
|:---------|:------------|:--------|
| `eq` | Equals | `status=eq.active` |
| `neq` | Not equals | `status=neq.canceled` |
| `gt` | Greater than | `amount_paid=gt.100` |
| `gte` | Greater than or equal | `amount_paid=gte.100` |
| `lt` | Less than | `amount_paid=lt.50` |
| `lte` | Less than or equal | `amount_paid=lte.50` |
| `like` | Pattern matching | `order_id=like.*2025*` |
| `ilike` | Case-insensitive like | `order_id=ilike.*order*` |
| `is` | Check for null | `policy_id=is.null` |
| `in` | In list | `status=in.(active,paused)` |

### Ordering

```
order=column_name.asc   // Ascending
order=column_name.desc  // Descending
```

### Limiting

```
limit=100               // Max 100 records
offset=50               // Skip first 50
```

### Selecting Columns

```
select=id,name,created_at           // Specific columns
select=*                            // All columns
select=id,user:users(email)         // With join
```

---

## 📊 Response Codes

| Code | Description |
|:-----|:------------|
| 200 | Success |
| 201 | Created |
| 400 | Bad Request |
| 401 | Unauthorized |
| 403 | Forbidden |
| 404 | Not Found |
| 500 | Internal Server Error |

---

## 🔐 Rate Limiting

### Supabase
- Free tier: 500 requests/minute
- Pro tier: Higher limits

### Webhook Server
- No rate limiting (implement if needed)

### Mock Insurance API
- Beeceptor free tier: ~50 requests/day
- Consider self-hosting for production

---

## 📝 Examples

### Get Last 10 Successful BNPL Transactions

```bash
curl -X GET \
  'https://your-project.supabase.co/rest/v1/bnpl_transactions?select=*&bnpl_status=eq.success&order=created_at.desc&limit=10' \
  -H 'apikey: YOUR_KEY' \
  -H 'Authorization: Bearer YOUR_KEY'
```

### Get User's Active Subscription

```bash
curl -X POST \
  'https://your-project.supabase.co/rest/v1/rpc/get_user_active_subscription' \
  -H 'apikey: YOUR_KEY' \
  -H 'Authorization: Bearer YOUR_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"p_user_id": "user-uuid-here"}'
```

### Get All Approved Insurance

```bash
curl -X GET \
  'https://your-project.supabase.co/rest/v1/nft_insurance_logs?insurance_status=eq.approved&order=created_at.desc' \
  -H 'apikey: YOUR_KEY' \
  -H 'Authorization: Bearer YOUR_KEY'
```

---

## 🔗 Additional Resources

- [Supabase REST API Docs](https://supabase.com/docs/guides/api)
- [PostgREST Documentation](https://postgrest.org/)
- [Stripe Webhook Events](https://stripe.com/docs/api/events/types)

---

**Version:** 1.0.0  
**Last Updated:** October 2025

