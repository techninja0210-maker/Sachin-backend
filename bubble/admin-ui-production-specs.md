# NFT Admin Dashboard - Production UI Specifications

## 🎯 Overview

Production-ready admin dashboard UI specifications for Bubble.io integration with Supabase backend.

## 📋 Page Structure

### Main Admin Dashboard Page
- **URL:** `/admin-dashboard`
- **Access:** Admin users only
- **Layout:** Tab-based interface with 3 main sections

---

## 🔧 Core Components

### 1. Tab Navigation
```bubble
Component: Tab Group
- Tab 1: "BNPL Transactions" (icon: credit-card)
- Tab 2: "Weekly Subscriptions" (icon: calendar)  
- Tab 3: "NFT Insurance Logs" (icon: shield)
- Tab 4: "Global Summary" (icon: chart-bar) [BONUS]
```

### 2. Filter Controls (All Tabs)
```bubble
Container: Filter Bar
├── Input: "User ID Filter" (placeholder: "Filter by user ID...")
├── Dropdown: "Status Filter" 
│   ├── BNPL: ["All", "success", "failed", "pending", "refunded"]
│   ├── Subscriptions: ["All", "active", "paused", "canceled", "past_due"]
│   └── Insurance: ["All", "applied", "approved", "rejected", "expired"]
├── Dropdown: "Sort By"
│   └── Options: ["created_at", "updated_at", "amount_paid", "amount", "premium_paid"]
├── Button: "Sort Order" (toggle ASC/DESC)
└── Button: "Export CSV" (BONUS feature)
```

### 3. Data Display Tables

#### BNPL Transactions Table
```bubble
Repeating Group: BNPL_Transactions
├── Data Source: API Call - Get_Admin_Views_BNPL
├── Columns:
│   ├── User ID (text)
│   ├── Order ID (text)
│   ├── Payment ID (text)
│   ├── Payment Method (text)
│   ├── Amount (currency - AUD)
│   ├── Status (badge with color coding)
│   ├── Created Date (date)
│   └── Actions (button: "View Details")
└── Styling: Striped rows, hover effects
```

#### Weekly Subscriptions Table  
```bubble
Repeating Group: Weekly_Subscriptions
├── Data Source: API Call - Get_Admin_Views_Subscriptions
├── Columns:
│   ├── User ID (text)
│   ├── Subscription ID (text)
│   ├── Customer ID (text)
│   ├── Status (badge with color coding)
│   ├── Start Date (date)
│   ├── Next Billing (date)
│   ├── Amount (currency - AUD)
│   └── Actions (button: "View Details")
└── Styling: Striped rows, hover effects
```

#### NFT Insurance Logs Table
```bubble
Repeating Group: NFT_Insurance_Logs
├── Data Source: API Call - Get_Admin_Views_Insurance
├── Columns:
│   ├── User ID (text)
│   ├── NFT ID (text)
│   ├── Policy ID (text)
│   ├── Status (badge with color coding)
│   ├── Coverage Amount (currency - AUD)
│   ├── Premium Paid (currency - AUD)
│   ├── Expiry Date (date)
│   └── Actions (button: "View Details")
└── Styling: Striped rows, hover effects
```

### 4. Statistics Cards (Dashboard Header)
```bubble
Container: Stats_Overview
├── Card: BNPL Stats
│   ├── Total Transactions (number)
│   ├── Total Amount (currency)
│   ├── Success Rate (%)
│   └── Average Amount (currency)
├── Card: Subscription Stats
│   ├── Active Subscriptions (number)
│   ├── Monthly Revenue (currency)
│   ├── Churn Rate (%)
│   └── Average Lifetime (days)
└── Card: Insurance Stats
    ├── Total Applications (number)
    ├── Approval Rate (%)
    ├── Total Premiums (currency)
    └── Active Policies (number)
```

---

## 🎨 Styling Guidelines

### Color Scheme
- **Primary:** #3B82F6 (Blue)
- **Success:** #10B981 (Green)
- **Warning:** #F59E0B (Amber)
- **Error:** #EF4444 (Red)
- **Background:** #F9FAFB (Light Gray)
- **Card Background:** #FFFFFF (White)

### Status Badge Colors
```css
BNPL Status:
- success: Green (#10B981)
- failed: Red (#EF4444)
- pending: Amber (#F59E0B)
- refunded: Gray (#6B7280)

Subscription Status:
- active: Green (#10B981)
- paused: Amber (#F59E0B)
- canceled: Red (#EF4444)
- past_due: Orange (#F97316)

Insurance Status:
- approved: Green (#10B981)
- applied: Blue (#3B82F6)
- rejected: Red (#EF4444)
- expired: Gray (#6B7280)
```

### Typography
- **Headers:** Inter, 24px, Bold
- **Subheaders:** Inter, 18px, Semi-Bold
- **Body Text:** Inter, 14px, Regular
- **Table Text:** Inter, 13px, Regular
- **Small Text:** Inter, 12px, Regular

---

## ⚡ API Integration

### Custom States Required
```bubble
Custom States:
├── user_filter (text, default: "")
├── status_filter (text, default: "")
├── transaction_type_filter (text, default: "")
├── page_limit (number, default: 50)
├── sort_order (text, default: "desc")
├── sort_field (text, default: "created_at")
├── current_tab (text, default: "bnpl")
└── export_data (list, default: empty)
```

### API Calls Setup
```bubble
API Calls:
├── Get_Admin_Views_BNPL
├── Get_Admin_Views_Subscriptions
├── Get_Admin_Views_Insurance
├── Get_Global_Transactions_Summary (BONUS)
├── Get_BNPL_Statistics
├── Get_Subscription_Statistics
└── Get_Transaction_Statistics (BONUS)
```

---

## 🔄 Workflows

### Page Load Workflow
```bubble
Trigger: Page is loaded
Actions:
1. Initialize custom states with default values
2. Make API call: Get_BNPL_Statistics
3. Make API call: Get_Subscription_Statistics
4. Make API call: Get_Admin_Views_BNPL
5. Display BNPL data in repeating group
6. Show loading spinner during API calls
7. Hide loading spinner when data is loaded
```

### Tab Switch Workflow
```bubble
Trigger: Tab is clicked
Actions:
1. Set custom state: current_tab = selected tab
2. If tab = "bnpl": Make API call: Get_Admin_Views_BNPL
3. If tab = "subscriptions": Make API call: Get_Admin_Views_Subscriptions
4. If tab = "insurance": Make API call: Get_Admin_Views_Insurance
5. If tab = "summary": Make API call: Get_Global_Transactions_Summary
6. Update repeating group data source
7. Reset filters to default values
```

### Filter Workflow
```bubble
Trigger: Filter input changes
Actions:
1. Set custom state: user_filter = input value
2. Make API call with updated parameters
3. Update repeating group data source
4. Show loading spinner
5. Hide loading spinner when new data loads
```

### Sort Workflow
```bubble
Trigger: Sort dropdown changes
Actions:
1. Set custom state: sort_field = selected option
2. Toggle custom state: sort_order (asc/desc)
3. Make API call with updated sort parameters
4. Update repeating group data source
```

### Export CSV Workflow (BONUS)
```bubble
Trigger: Export CSV button is clicked
Actions:
1. Get current repeating group data
2. Convert data to CSV format
3. Create downloadable file
4. Trigger browser download
5. Show success message
```

---

## 📱 Responsive Design

### Desktop (1200px+)
- 3-column layout for statistics cards
- Full-width tables with all columns visible
- Side-by-side filter controls

### Tablet (768px - 1199px)
- 2-column layout for statistics cards
- Tables with horizontal scrolling
- Stacked filter controls

### Mobile (320px - 767px)
- 1-column layout for statistics cards
- Cards layout instead of tables
- Collapsible filter section

---

## 🚀 Performance Optimizations

### Data Loading
- Load only 50 records per page initially
- Implement pagination for large datasets
- Cache statistics data for 5 minutes
- Use API views for optimized queries

### UI Performance
- Lazy load repeating groups
- Debounce filter inputs (300ms delay)
- Show skeleton loaders during API calls
- Implement error boundaries for failed API calls

---

## 🔒 Security Considerations

### Access Control
- Page accessible only to authenticated admin users
- API calls use Supabase anon key (read-only)
- No sensitive data displayed in UI
- Logout functionality on all pages

### Data Privacy
- Mask sensitive IDs (show first 8 characters)
- No full payment details displayed
- Export functionality respects user permissions
- Audit log for admin actions

---

## 📊 Analytics Integration

### Tracked Events
- Page views
- Tab switches
- Filter usage
- Export actions
- Error occurrences

### Metrics Dashboard
- Real-time statistics updates
- Historical trend charts
- User engagement metrics
- Performance monitoring

---

## 🧪 Testing Checklist

### Functionality Tests
- [ ] All tabs load correctly
- [ ] Filters work as expected
- [ ] Sorting functions properly
- [ ] Export CSV works (if implemented)
- [ ] Statistics cards display correctly
- [ ] Responsive design works on all devices

### API Integration Tests
- [ ] All API calls return data
- [ ] Error handling works for failed calls
- [ ] Loading states display properly
- [ ] Data refreshes correctly
- [ ] Custom states update properly

### UI/UX Tests
- [ ] Color coding for status badges
- [ ] Hover effects on table rows
- [ ] Loading spinners show/hide correctly
- [ ] Error messages display appropriately
- [ ] Success messages show for actions

---

## 📝 Implementation Notes

### Bubble.io Setup
1. Install required plugins (API Connector, Stripe Official)
2. Configure API Connector with Supabase endpoints
3. Set up custom states for filtering and sorting
4. Create repeating groups with proper data sources
5. Implement workflows for user interactions
6. Add responsive styling and animations

### Data Flow
1. Page loads → Initialize states → Fetch statistics
2. User switches tab → Fetch tab-specific data
3. User applies filter → Refresh data with filter
4. User changes sort → Refresh data with new sort
5. User exports data → Generate CSV and download

### Error Handling
- Show user-friendly error messages for API failures
- Implement retry logic for failed requests
- Log errors for debugging purposes
- Provide fallback UI for offline scenarios

---

## 🎯 Success Metrics

### Performance Targets
- Page load time: < 2 seconds
- API response time: < 500ms
- Filter response time: < 300ms
- Export generation: < 5 seconds

### User Experience Goals
- Intuitive navigation between tabs
- Fast filtering and sorting
- Clear visual feedback for all actions
- Responsive design across all devices
- Accessible to users with disabilities

---

This specification provides a complete guide for implementing a production-ready admin dashboard in Bubble.io with proper integration to the Supabase backend and enhanced user experience features.
