# NFT Admin Dashboard - Bubble.io Workflow Guides

## 🎯 Complete Workflow Documentation

This guide provides step-by-step workflows for BNPL payments, subscriptions, and insurance integration in Bubble.io.

---

## 🛒 Workflow 1: BNPL Checkout (AfterPay/ClearPay)

### Use Case
User wants to purchase an NFT using Buy Now Pay Later (BNPL) via Stripe AfterPay/ClearPay.

### Prerequisites
- Stripe Official Plugin installed
- User logged in
- NFT selected for purchase

### Workflow Steps

#### Step 1: User Clicks "Buy with AfterPay"
**Trigger:** Button "Buy with AfterPay" is clicked

**Actions:**

1. **Create Stripe Checkout Session**
   - Plugin: Stripe Official Plugin → Create Checkout Session
   - Parameters:
     ```
     Mode: payment
     Line items:
       - Name: {NFT's name}
       - Amount: {NFT's price} * 100 (convert to cents)
       - Currency: AUD
       - Quantity: 1
     Payment method types: ["card", "afterpay_clearpay"]
     Success URL: https://yourapp.com/checkout/success?session_id={CHECKOUT_SESSION_ID}
     Cancel URL: https://yourapp.com/checkout/cancel
     Client reference ID: {Current User's ID}
     Metadata:
       - user_id: {Current User's ID}
       - nft_id: {Current NFT's ID}
       - order_id: {Generated order ID}
     ```

2. **Navigate to Checkout**
   - Action: Open external website
   - URL: Result of Step 1's URL

#### Step 2: Handle Successful Payment (Success Page)
**Trigger:** Page is loaded (success page)

**Conditions:**
- URL parameter "session_id" is not empty

**Actions:**

1. **Retrieve Session ID from URL**
   - Get data from URL parameter: session_id

2. **Display Success Message**
   - Show text: "Payment successful! Your NFT purchase is being processed."

3. **Optional: Fetch Session Details**
   - Plugin: Stripe → Retrieve Checkout Session
   - Session ID: {URL parameter session_id}

4. **Update UI**
   - Show success icon
   - Display order confirmation
   - Show "View My NFTs" button

**Note:** Webhook will automatically create BNPL transaction record in Supabase.

#### Step 3: Handle Canceled Payment (Cancel Page)
**Trigger:** Page is loaded (cancel page)

**Actions:**
1. Show message: "Payment was canceled. You can try again."
2. Button: "Return to NFT"

---

## 💳 Workflow 2: Weekly Subscription Setup

### Use Case
User wants to subscribe to weekly NFT Generator access for AUD 5.00/week.

### Prerequisites
- Stripe Official Plugin installed
- User logged in
- Subscription product created in Stripe Dashboard

### Setup in Stripe Dashboard (One-time)

1. Go to Stripe Dashboard → Products
2. Create Product:
   - Name: "NFT Generator Weekly Subscription"
   - Description: "Weekly access to NFT Generator"
3. Add Price:
   - Type: Recurring
   - Amount: 5.00 AUD
   - Billing period: Weekly (every 7 days)
   - Copy Price ID: `price_xxxxxxxxxxxxx`

### Workflow Steps

#### Step 1: User Clicks "Subscribe"
**Trigger:** Button "Subscribe Weekly" is clicked

**Conditions:**
- User does not have active subscription (check custom state or database)

**Actions:**

1. **Create Stripe Checkout Session**
   - Plugin: Stripe Official Plugin → Create Checkout Session
   - Parameters:
     ```
     Mode: subscription
     Line items:
       - Price ID: price_xxxxxxxxxxxxx (your subscription price ID)
       - Quantity: 1
     Payment method types: ["card"]
     Success URL: https://yourapp.com/subscription/success?session_id={CHECKOUT_SESSION_ID}
     Cancel URL: https://yourapp.com/subscription/cancel
     Client reference ID: {Current User's ID}
     Subscription data:
       - Metadata:
           user_id: {Current User's ID}
           plan: nft_generator_weekly
     ```

2. **Navigate to Checkout**
   - Action: Open external website
   - URL: Result of Step 1's URL

#### Step 2: Handle Subscription Success
**Trigger:** Page is loaded (subscription success page)

**Actions:**

1. **Show Success Message**
   - "Your subscription is active! Enjoy weekly access to NFT Generator."

2. **Update User Interface**
   - Show "Active Subscription" badge
   - Display next billing date
   - Enable NFT Generator access

**Note:** Webhook will automatically create subscription record in Supabase.

#### Step 3: Check User's Subscription Status (Any Page)
**Trigger:** Page is loaded

**Actions:**

1. **Make API Call to Supabase**
   - API: Supabase_REST → Get_User_Active_Subscription
   - Parameters:
     - user_id: {Current User's ID}

2. **Set Custom State**
   - State: has_active_subscription
   - Value: Result of Step 1 is not empty AND status = "active"

3. **Conditional Display**
   - If has_active_subscription = Yes:
     - Show NFT Generator access button
     - Show subscription details
   - If has_active_subscription = No:
     - Show "Subscribe" button
     - Hide NFT Generator access

#### Step 4: Handle Subscription Cancellation
**Trigger:** Button "Cancel Subscription" is clicked

**Actions:**

1. **Show Confirmation Popup**
   - Message: "Are you sure you want to cancel your subscription?"
   - Buttons: [Yes, Cancel]

2. **If Yes Clicked:**
   - Plugin: Stripe → Cancel Subscription
   - Subscription ID: {User's subscription_id from Supabase}
   - Parameters:
     ```
     Cancel at period end: Yes (allows access until end of billing period)
     ```

3. **Update UI**
   - Show message: "Your subscription will be canceled at the end of the current billing period."
   - Update subscription status display

**Note:** Webhook will update subscription status in Supabase.

---

## 🛡️ Workflow 3: NFT Insurance Purchase

### Use Case
User wants to add insurance coverage to their NFT purchase.

### Prerequisites
- Mock Insurance API configured in API Connector
- User purchasing an NFT
- Checkbox for insurance option

### Workflow Steps

#### Step 1: User Checks "Add Insurance"
**Trigger:** Checkbox "Add NFT Insurance" is checked

**Actions:**

1. **Show Insurance Details**
   - Display group: insurance_details
   - Text: "Insurance Coverage: 5% of NFT value"
   - Text: "Premium: ${NFT price * 0.05}"

2. **Calculate Premium**
   - Set custom state: insurance_premium
   - Value: {NFT's price} * 0.05

3. **Update Total Price**
   - Text: Total = {NFT price} + {insurance_premium}

#### Step 2: Verify Insurance Eligibility
**Trigger:** Button "Continue to Checkout" is clicked

**Conditions:**
- Checkbox "Add Insurance" is checked

**Actions:**

1. **Make API Call to Insurance API**
   - API: Mock_Insurance_API → Verify_NFT_Insurance
   - Body:
     ```json
     {
       "user_id": "{Current User's ID}",
       "nft_id": "{Current NFT's ID}",
       "plan": "standard"
     }
     ```

2. **Handle Response:**

   **If status = "approved":**
   - Set custom state: insurance_approved = Yes
   - Set custom state: insurance_policy_id = Result's policy_id
   - Show success message: "Insurance approved!"
   - Continue to checkout

   **If status = "rejected":**
   - Show error message: "Insurance cannot be applied to this NFT. Reason: {result's reason}"
   - Uncheck insurance checkbox
   - Set custom state: insurance_approved = No

#### Step 3: Create BNPL Transaction with Insurance
**Trigger:** Checkout session completed (webhook received)

**Server-side (Webhook):**
- Create BNPL transaction record
- If insurance was approved:
  - Create insurance log record:
    ```sql
    INSERT INTO nft_insurance_logs
    (user_id, nft_id, insurance_status, insurance_policy_id, 
     coverage_amount, premium_paid)
    VALUES
    (user_id, nft_id, 'approved', policy_id, 
     nft_price, premium_amount)
    ```

#### Step 4: Display Insurance Status
**Trigger:** User views their NFT

**Actions:**

1. **Check Insurance Status**
   - API: Supabase_REST → Get_NFT_Insurance_Logs
   - Filter: nft_id = {Current NFT's ID}

2. **Display Badge:**
   - If insurance_status = "approved":
     - Show green badge: "✓ Insured"
     - Show policy details on hover/click
   - If no insurance:
     - Show gray badge: "Not Insured"
     - Button: "Add Insurance"

---

## 📊 Workflow 4: Admin Dashboard Data Loading

### Use Case
Admin wants to view BNPL transactions, subscriptions, and insurance logs.

### Workflow: Load BNPL Transactions

**Trigger:** Page "Admin Dashboard" is loaded OR Tab "BNPL" is clicked

**Actions:**

1. **Show Loading Spinner**
   - Element: loading_spinner → visible = Yes

2. **Make API Call**
   - API: Supabase_REST → Get_BNPL_Transactions
   - Parameters:
     ```
     select: *
     order: created_at.desc
     limit: 100
     ```

3. **Handle Success:**
   - Hide loading spinner
   - Display data in repeating group: rg_bnpl_transactions
   - Update count text: "Showing {count} transactions"

4. **Handle Error:**
   - Hide loading spinner
   - Show error message: "Failed to load data. Please try again."
   - Log error to console

### Workflow: Filter BNPL Transactions

**Trigger:** Button "Apply Filters" is clicked

**Actions:**

1. **Get Filter Values**
   - user_id_filter = Input search_user_id's value
   - status_filter = Dropdown filter_status's value

2. **Build API Parameters:**
   - Base: select=*, order=created_at.desc
   - If user_id_filter is not empty:
     - Add: user_id=eq.{user_id_filter}
   - If status_filter is not "All":
     - Add: bnpl_status=eq.{status_filter}

3. **Make API Call with Filters**
   - API: Supabase_REST → Get_BNPL_Transactions
   - Parameters: {built parameters from Step 2}

4. **Refresh Repeating Group**
   - Repeating group: rg_bnpl_transactions
   - Data source: Result of Step 3

### Workflow: Export to CSV

**Trigger:** Button "Export to CSV" is clicked

**Actions:**

1. **Get Current Data**
   - Data: Repeating group rg_bnpl_transactions's list of items

2. **Format as CSV**
   - Headers: "Order ID,User ID,Amount,Status,Payment Method,Date"
   - Rows: For each item in list:
     ```
     {item's order_id},{item's user_id},{item's amount_paid},
     {item's bnpl_status},{item's payment_method},{item's created_at}
     ```

3. **Download File**
   - Action: Download data as CSV
   - Filename: bnpl_transactions_{current_date}.csv

---

## 🔔 Workflow 5: Handle Subscription Payment Failure

### Use Case
User's weekly subscription payment fails - lock their access to NFT Generator.

### Server-side (Webhook Handler)
When `invoice.payment_failed` event received:

1. Update subscription status to "past_due"
2. Lock user access (update user record)
3. Send email notification (optional)

### Client-side (Bubble)

**Trigger:** Page is loaded

**Actions:**

1. **Check Subscription Status**
   - API: Supabase_REST → Get_User_Active_Subscription
   - Parameters: user_id = {Current User's ID}

2. **Handle Past Due Status:**
   - If result's status = "past_due":
     - Show alert: "Your subscription payment failed. Please update your payment method."
     - Hide NFT Generator access
     - Show button: "Update Payment Method"
     - Display subscription details with error badge

3. **Handle Active Status:**
   - Show NFT Generator access
   - Display subscription details normally

### Workflow: Update Payment Method

**Trigger:** Button "Update Payment Method" is clicked

**Actions:**

1. **Create Stripe Billing Portal Session**
   - Plugin: Stripe → Create Billing Portal Session
   - Customer ID: {User's stripe_customer_id from Supabase}
   - Return URL: https://yourapp.com/subscription/updated

2. **Navigate to Billing Portal**
   - Action: Open external website
   - URL: Result of Step 1's URL

**Note:** User updates payment method in Stripe Billing Portal, and next invoice will retry automatically.

---

## 🧪 Workflow 6: Testing Workflows

### Test BNPL Payment

1. Go to NFT purchase page
2. Select AfterPay as payment method
3. Use Stripe test card: 4242 4242 4242 4242
4. Complete checkout
5. Verify transaction appears in admin dashboard
6. Check Supabase `bnpl_transactions` table

### Test Subscription

1. Click "Subscribe Weekly"
2. Use Stripe test card: 4242 4242 4242 4242
3. Complete checkout
4. Verify subscription appears in admin dashboard
5. Check Supabase `weekly_subscriptions` table
6. Test subscription cancellation

### Test Insurance

1. Add NFT to cart
2. Check "Add Insurance" checkbox
3. Verify insurance details display
4. Complete checkout
5. Verify insurance log in admin dashboard
6. Check Supabase `nft_insurance_logs` table

---

## 📋 Workflow Checklist

- [ ] BNPL checkout workflow implemented
- [ ] Subscription creation workflow implemented
- [ ] Subscription status checking implemented
- [ ] Subscription cancellation workflow implemented
- [ ] Insurance verification workflow implemented
- [ ] Admin dashboard data loading implemented
- [ ] Filter functionality implemented
- [ ] CSV export implemented
- [ ] Payment failure handling implemented
- [ ] Error handling added to all workflows
- [ ] Loading states added to all workflows
- [ ] Success/error messages configured
- [ ] All workflows tested with test data

---

## 🔗 Related Resources

- [Stripe Official Plugin Documentation](https://bubble.io/plugin/stripe-1488739244826x768734287091433500)
- [Supabase REST API](https://supabase.com/docs/guides/api)
- [Bubble Workflow Documentation](https://manual.bubble.io/core-resources/workflows)

---

**Version:** 1.0.0  
**Last Updated:** October 2025  
**Platform:** Bubble.io

