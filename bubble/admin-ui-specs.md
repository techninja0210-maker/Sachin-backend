# NFT Admin Dashboard - Bubble.io UI Specifications

## 🎯 Overview

This document provides detailed specifications for building the admin interface in Bubble.io to view BNPL transactions, weekly subscriptions, and NFT insurance logs.

---

## 📋 Pages Structure

### Page 1: Admin Dashboard (Main)
**URL:** `/admin-dashboard`

**Layout:**
```
┌─────────────────────────────────────────────┐
│  NFT Admin Dashboard                   [?]  │
├─────────────────────────────────────────────┤
│  [BNPL] [Subscriptions] [Insurance] [Stats] │
├─────────────────────────────────────────────┤
│                                             │
│  Content Area (Dynamic based on tab)       │
│                                             │
└─────────────────────────────────────────────┘
```

**Elements:**
- Group: `Header`
  - Text: "NFT Admin Dashboard"
  - Icon: Help icon
- Group: `Navigation_Tabs`
  - Button: "BNPL Transactions"
  - Button: "Subscriptions"
  - Button: "Insurance Logs"
  - Button: "Statistics"
- Group: `Content_Area` (visible based on custom state)

---

## 🛒 Tab 1: BNPL Transactions View

### Data Source
**API Call:** `Supabase_REST - Get_BNPL_Transactions`

### UI Elements

#### Filters Section
```
Group: Filters_BNPL (Horizontal layout)
├── Input: search_user_id (Placeholder: "Filter by User ID")
├── Dropdown: filter_status (Options: All, Success, Failed, Pending)
├── Button: btn_apply_filters
└── Button: btn_reset_filters
```

#### Repeating Group Configuration
```
Repeating Group: rg_bnpl_transactions
├── Type of content: BNPL Transaction (from API)
├── Data source: Get data from external API → Supabase_REST - Get_BNPL_Transactions
├── Layout: Fixed number of cells (10)
├── Rows: 10
├── Columns: 1
```

#### Cell Layout (Each row)
```
┌────────────────────────────────────────────────────────────────┐
│ Order ID: ORDER-2025-001                    Status: [SUCCESS]  │
│ User: user@example.com                      Amount: $150.00    │
│ Payment Method: AfterPay                    Date: Oct 10, 2025 │
│ Payment ID: pi_3ABC123XYZ                                      │
└────────────────────────────────────────────────────────────────┘
```

**Cell Elements:**
- Text: `order_id` (Bold, 16px)
- Text: `bnpl_status` (Badge with conditional formatting)
  - Success: Green background (#10B981)
  - Failed: Red background (#EF4444)
  - Pending: Yellow background (#F59E0B)
- Text: `user_id` or user email (if joined)
- Text: `amount_paid` (Format as currency)
- Text: `payment_method` (Capitalized)
- Text: `created_at` (Format as "MMM DD, YYYY")
- Text: `payment_id` (Gray, smaller font)

#### Action Buttons
```
Group: Actions_BNPL (Bottom of page)
├── Button: btn_export_csv ("Export to CSV")
├── Button: btn_refresh ("Refresh Data")
└── Text: Showing X of Y records
```

---

## 💳 Tab 2: Weekly Subscriptions View

### Data Source
**API Call:** `Supabase_REST - Get_Weekly_Subscriptions`

### UI Elements

#### Filters Section
```
Group: Filters_Subscriptions (Horizontal layout)
├── Input: search_user_id (Placeholder: "Filter by User ID")
├── Dropdown: filter_status (Options: All, Active, Paused, Canceled, Past Due)
├── Date Picker: filter_date_from (Optional)
├── Button: btn_apply_filters
└── Button: btn_reset_filters
```

#### Repeating Group Configuration
```
Repeating Group: rg_subscriptions
├── Type of content: Weekly Subscription (from API)
├── Data source: Get data from external API → Supabase_REST - Get_Weekly_Subscriptions
├── Layout: Fixed number of cells (10)
├── Rows: 10
```

#### Cell Layout
```
┌────────────────────────────────────────────────────────────────┐
│ Subscription ID: sub_1ABC123XYZ456          Status: [ACTIVE]   │
│ User: user@example.com                      Amount: $5.00/week │
│ Customer ID: cus_ABC123XYZ                                     │
│ Start Date: Jan 01, 2025    Next Billing: Oct 17, 2025        │
└────────────────────────────────────────────────────────────────┘
```

**Cell Elements:**
- Text: `subscription_id` (Bold, 16px)
- Text: `status` (Badge with conditional formatting)
  - Active: Green (#10B981)
  - Paused: Yellow (#F59E0B)
  - Canceled: Red (#EF4444)
  - Past Due: Orange (#F97316)
- Text: User email/ID
- Text: `amount` (Format as currency + "/week")
- Text: `stripe_customer_id` (Gray, smaller)
- Text: `start_date` (Format as "MMM DD, YYYY")
- Text: `next_billing_date` (Format as "MMM DD, YYYY", highlight if within 7 days)

#### Statistics Summary (Top of page)
```
Group: Stats_Subscriptions (Horizontal layout, 4 columns)
├── Text: Total Subscriptions: {count}
├── Text: Active: {count_active}
├── Text: Paused: {count_paused}
└── Text: MRR: ${monthly_recurring_revenue}
```

Use API call: `Get_Subscription_Statistics`

---

## 🛡️ Tab 3: NFT Insurance Logs View

### Data Source
**API Call:** `Supabase_REST - Get_NFT_Insurance_Logs`

### UI Elements

#### Filters Section
```
Group: Filters_Insurance (Horizontal layout)
├── Input: search_user_id (Placeholder: "Filter by User ID")
├── Input: search_nft_id (Placeholder: "Filter by NFT ID")
├── Dropdown: filter_status (Options: All, Applied, Approved, Rejected, Expired)
├── Button: btn_apply_filters
└── Button: btn_reset_filters
```

#### Repeating Group Configuration
```
Repeating Group: rg_insurance_logs
├── Type of content: NFT Insurance Log (from API)
├── Data source: Get data from external API → Supabase_REST - Get_NFT_Insurance_Logs
├── Layout: Fixed number of cells (10)
├── Rows: 10
```

#### Cell Layout
```
┌────────────────────────────────────────────────────────────────┐
│ NFT ID: 10000000-0000-0000-0000-000000000001  Status: [APPROVED]│
│ User: user@example.com                      Premium: $7.50     │
│ Policy ID: POLICY-NFT-2025-001              Coverage: $150.00  │
│ Applied: Oct 10, 2025       Expires: Jan 15, 2026             │
└────────────────────────────────────────────────────────────────┘
```

**Cell Elements:**
- Text: `nft_id` (Bold, 16px, truncated with ellipsis)
- Text: `insurance_status` (Badge)
  - Approved: Green (#10B981)
  - Rejected: Red (#EF4444)
  - Applied: Blue (#3B82F6)
  - Expired: Gray (#6B7280)
- Text: User email/ID
- Text: `premium_paid` (Format as currency)
- Text: `insurance_policy_id` (Gray, smaller, show "N/A" if null)
- Text: `coverage_amount` (Format as currency)
- Text: `created_at` (Format as "MMM DD, YYYY")
- Text: `expiry_date` (Format as "MMM DD, YYYY", highlight if expiring within 30 days)

---

## 📊 Tab 4: Statistics Dashboard

### Data Sources
- `Get_BNPL_Statistics`
- `Get_Subscription_Statistics`

### Layout
```
┌─────────────────────────────────────────────┐
│  BNPL Transaction Statistics                │
├─────────────────────────────────────────────┤
│  Total: 150    Success: 140    Failed: 10   │
│  Total Amount: $15,234.50                   │
│  Avg Transaction: $101.56                   │
└─────────────────────────────────────────────┘

┌─────────────────────────────────────────────┐
│  Subscription Statistics                    │
├─────────────────────────────────────────────┤
│  Total: 85     Active: 72      Canceled: 13 │
│  Monthly Recurring Revenue: $1,440.00       │
└─────────────────────────────────────────────┘

┌─────────────────────────────────────────────┐
│  Insurance Statistics                       │
├─────────────────────────────────────────────┤
│  Total Applications: 45                     │
│  Approved: 35      Rejected: 10             │
│  Total Coverage: $4,500.00                  │
└─────────────────────────────────────────────┘
```

**Elements:**
- Group: `Stats_BNPL` (3 columns)
- Group: `Stats_Subscriptions` (3 columns)
- Group: `Stats_Insurance` (3 columns)
- Use API calls to fetch real-time statistics

---

## 🎨 Design Guidelines

### Color Scheme
- **Primary:** #2563EB (Blue)
- **Success:** #10B981 (Green)
- **Warning:** #F59E0B (Yellow)
- **Danger:** #EF4444 (Red)
- **Gray:** #6B7280
- **Background:** #F9FAFB
- **White:** #FFFFFF

### Typography
- **Headers:** 24px, Bold, #1F2937
- **Subheaders:** 18px, Semibold, #374151
- **Body:** 14px, Regular, #6B7280
- **Labels:** 12px, Medium, #9CA3AF

### Spacing
- Page padding: 24px
- Element spacing: 16px
- Card padding: 20px
- Button padding: 12px 24px

### Badges (Status Indicators)
- Border radius: 12px
- Padding: 4px 12px
- Font size: 12px
- Font weight: Medium
- Text: Uppercase

---

## 🔧 Workflows

### Workflow 1: Load BNPL Transactions
**Trigger:** Page is loaded or "BNPL" tab is clicked

**Steps:**
1. Show loading spinner
2. Make API call: `Supabase_REST - Get_BNPL_Transactions`
   - Parameters:
     - `order`: created_at.desc
     - `limit`: 100
3. Hide loading spinner
4. Display data in `rg_bnpl_transactions`
5. Handle errors (show error message if API fails)

### Workflow 2: Filter BNPL Transactions
**Trigger:** "Apply Filters" button is clicked

**Steps:**
1. Get values from:
   - `search_user_id` input
   - `filter_status` dropdown
2. Make API call: `Supabase_REST - Get_BNPL_Transactions`
   - Parameters:
     - `user_id`: eq.{search_user_id} (if not empty)
     - `bnpl_status`: eq.{filter_status} (if not "All")
     - `order`: created_at.desc
3. Refresh `rg_bnpl_transactions` with new data

### Workflow 3: Export to CSV
**Trigger:** "Export to CSV" button is clicked

**Steps:**
1. Get current data from repeating group
2. Use Bubble's CSV export plugin or:
   - Create download link with CSV data
   - Format: Order ID, User ID, Amount, Status, Date, Payment Method
3. Trigger download

### Workflow 4: Load Subscriptions
**Trigger:** "Subscriptions" tab is clicked

**Steps:**
1. Make API call: `Supabase_REST - Get_Weekly_Subscriptions`
2. Make API call: `Get_Subscription_Statistics`
3. Display subscription data
4. Display statistics in summary boxes

### Workflow 5: Load Insurance Logs
**Trigger:** "Insurance" tab is clicked

**Steps:**
1. Make API call: `Supabase_REST - Get_NFT_Insurance_Logs`
2. Display insurance data
3. Highlight expiring policies (expiry_date within 30 days)

---

## 📱 Responsive Design

### Desktop (> 1024px)
- Full layout with all columns visible
- Sidebar navigation
- 3-4 column statistics

### Tablet (768px - 1024px)
- 2 column statistics
- Condensed filters (collapsible)
- Smaller padding

### Mobile (< 768px)
- Single column layout
- Stacked statistics
- Hamburger menu for tabs
- Scrollable tables

---

## ✅ Implementation Checklist

- [ ] Install Stripe Official Plugin
- [ ] Install API Connector Plugin
- [ ] Configure Supabase REST API in API Connector
- [ ] Configure Mock Insurance API
- [ ] Create Admin Dashboard page
- [ ] Create navigation tabs (Custom State: current_tab)
- [ ] Build BNPL Transactions repeating group
- [ ] Build Subscriptions repeating group
- [ ] Build Insurance Logs repeating group
- [ ] Build Statistics dashboard
- [ ] Add filter functionality for all tables
- [ ] Add CSV export buttons
- [ ] Test all API calls with real data
- [ ] Add error handling for failed API calls
- [ ] Add loading states/spinners
- [ ] Test responsive design
- [ ] Add pagination (if needed)
- [ ] Document workflows

---

## 🔗 Custom States

### Page-level Custom States

| State Name | Type | Default Value | Purpose |
|:-----------|:-----|:--------------|:--------|
| `current_tab` | Text | "bnpl" | Track active tab (bnpl, subscriptions, insurance, stats) |
| `loading` | Yes/No | No | Show/hide loading spinner |
| `error_message` | Text | "" | Display API error messages |
| `filter_user_id` | Text | "" | Store user ID filter |
| `filter_status` | Text | "All" | Store status filter |

---

## 🧩 Reusable Elements

### Element 1: Status Badge
**Type:** Reusable Element

**Properties:**
- `status_text` (Text)
- `status_type` (Text: success, warning, danger, info)

**Conditional Formatting:**
- If `status_type` = "success" → Green background
- If `status_type` = "warning" → Yellow background
- If `status_type` = "danger" → Red background
- If `status_type` = "info" → Blue background

### Element 2: Data Table Row
**Type:** Reusable Element

**Properties:**
- `data_object` (Custom data type)
- `columns` (List of column names)

---

## 📝 Notes

- All views are **read-only** (no edit/delete functionality)
- Data refreshes on page load and manual refresh button click
- Filters apply client-side if data is small, server-side (API params) if large
- Use Bubble's privacy rules to restrict admin page access
- CSV export uses current filtered data, not all data
- Pagination recommended if records > 100

---

**Version:** 1.0.0  
**Last Updated:** October 2025  
**Compatible with:** Bubble.io (Latest version)

