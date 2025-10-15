# CSV Export Functionality for NFT Admin Dashboard

## 🎯 Overview

Implementation guide for CSV export functionality in Bubble.io admin dashboard.

## 📋 CSV Export Features

### 1. Export All BNPL Transactions
- Export all BNPL transaction data to CSV
- Include all columns: user_id, order_id, payment_id, payment_method, amount_paid, bnpl_status, created_at, updated_at
- Apply current filters and sorting

### 2. Export All Subscriptions
- Export all subscription data to CSV
- Include all columns: user_id, subscription_id, stripe_customer_id, status, start_date, next_billing_date, amount, created_at, updated_at
- Apply current filters and sorting

### 3. Export All Insurance Logs
- Export all insurance log data to CSV
- Include all columns: user_id, nft_id, insurance_status, insurance_policy_id, coverage_amount, premium_paid, expiry_date, created_at, updated_at
- Apply current filters and sorting

### 4. Export Global Transactions Summary (BONUS)
- Export combined data from all transaction types
- Include transaction_type column to identify source
- Unified format for comprehensive analysis

---

## 🔧 Implementation in Bubble.io

### 1. Custom States for Export
```bubble
Custom States:
├── export_data (list, default: empty)
├── export_filename (text, default: "")
├── export_in_progress (yes/no, default: no)
└── export_format (text, default: "csv")
```

### 2. Export Button Component
```bubble
Button: Export_CSV_Button
├── Text: "Export CSV"
├── Icon: download
├── Style: Secondary button
├── Condition: Show when data is loaded
└── Workflow: export_to_csv
```

### 3. Export Workflow
```bubble
Workflow: export_to_csv
Trigger: Export CSV button is clicked

Actions:
1. Set custom state: export_in_progress = yes
2. Show loading spinner on export button
3. Get current repeating group data
4. Convert data to CSV format
5. Generate filename with timestamp
6. Create downloadable file
7. Trigger browser download
8. Set custom state: export_in_progress = no
9. Hide loading spinner
10. Show success message
11. Log export action for analytics
```

### 4. CSV Generation Logic
```javascript
// JavaScript code for CSV generation (use in Bubble's JavaScript element)
function generateCSV(data, filename) {
  if (!data || data.length === 0) {
    return null;
  }

  // Get column headers from first row
  const headers = Object.keys(data[0]);
  
  // Create CSV content
  let csvContent = headers.join(',') + '\n';
  
  // Add data rows
  data.forEach(row => {
    const values = headers.map(header => {
      const value = row[header];
      // Escape values that contain commas, quotes, or newlines
      if (typeof value === 'string' && (value.includes(',') || value.includes('"') || value.includes('\n'))) {
        return '"' + value.replace(/"/g, '""') + '"';
      }
      return value || '';
    });
    csvContent += values.join(',') + '\n';
  });
  
  // Create and trigger download
  const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
  const link = document.createElement('a');
  const url = URL.createObjectURL(blob);
  link.setAttribute('href', url);
  link.setAttribute('download', filename);
  link.style.visibility = 'hidden';
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
  
  return true;
}
```

---

## 📊 CSV File Format Examples

### BNPL Transactions CSV
```csv
user_id,order_id,payment_id,payment_method,amount_paid,bnpl_status,user_email,created_at,updated_at
00000000-0000-0000-0000-000000000001,ORDER-2025-001,pi_3ABC123XYZ,afterpay_clearpay,150.00,success,alice@example.com,2025-10-15T10:30:00Z,2025-10-15T10:30:00Z
00000000-0000-0000-0000-000000000002,ORDER-2025-002,pi_3DEF456ABC,card,99.99,success,bob@example.com,2025-10-15T11:15:00Z,2025-10-15T11:15:00Z
```

### Weekly Subscriptions CSV
```csv
user_id,subscription_id,stripe_customer_id,status,start_date,next_billing_date,amount,currency,user_email,created_at,updated_at
00000000-0000-0000-0000-000000000001,sub_1234567890,cus_ABCDEF123,active,2025-10-01,2025-10-08,5.00,AUD,alice@example.com,2025-10-01T09:00:00Z,2025-10-15T10:30:00Z
00000000-0000-0000-0000-000000000002,sub_0987654321,cus_XYZ789ABC,active,2025-10-05,2025-10-12,5.00,AUD,bob@example.com,2025-10-05T14:20:00Z,2025-10-15T11:15:00Z
```

### NFT Insurance Logs CSV
```csv
user_id,nft_id,insurance_status,insurance_policy_id,coverage_amount,premium_paid,expiry_date,user_email,created_at,updated_at
00000000-0000-0000-0000-000000000001,10000000-0000-0000-0000-000000000001,approved,POLICY-2025-001,150.00,7.50,2026-10-15,alice@example.com,2025-10-15T10:30:00Z,2025-10-15T10:30:00Z
00000000-0000-0000-0000-000000000002,10000000-0000-0000-0000-000000000002,applied,POLICY-2025-002,99.99,5.00,2026-10-15,bob@example.com,2025-10-15T11:15:00Z,2025-10-15T11:15:00Z
```

### Global Transactions Summary CSV (BONUS)
```csv
transaction_type,source_table,source_id,user_id,amount,status,created_at,updated_at
bnpl,bnpl_transactions,abc123,00000000-0000-0000-0000-000000000001,150.00,success,2025-10-15T10:30:00Z,2025-10-15T10:30:00Z
subscription,weekly_subscriptions,def456,00000000-0000-0000-0000-000000000001,5.00,active,2025-10-15T10:30:00Z,2025-10-15T10:30:00Z
insurance,nft_insurance_logs,ghi789,00000000-0000-0000-0000-000000000001,7.50,approved,2025-10-15T10:30:00Z,2025-10-15T10:30:00Z
```

---

## 🎨 UI Components

### Export Button Styling
```css
.export-button {
  background-color: #10B981; /* Green */
  color: white;
  border: none;
  border-radius: 6px;
  padding: 8px 16px;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 8px;
  transition: background-color 0.2s;
}

.export-button:hover {
  background-color: #059669;
}

.export-button:disabled {
  background-color: #9CA3AF;
  cursor: not-allowed;
}

.export-button.loading {
  background-color: #3B82F6;
}
```

### Loading State
```bubble
Button States:
├── Default: "Export CSV" with download icon
├── Loading: "Exporting..." with spinner icon
├── Success: "Exported!" with checkmark icon (briefly)
└── Error: "Export Failed" with error icon
```

### Success Message
```bubble
Popup: Export_Success
├── Title: "Export Successful"
├── Message: "Your data has been exported to CSV file: {{export_filename}}"
├── Button: "OK"
└── Duration: Auto-close after 3 seconds
```

---

## ⚡ Advanced Features

### 1. Filtered Export
```bubble
Workflow: export_filtered_data
Actions:
1. Get current filter values from custom states
2. Apply filters to data before export
3. Generate filename with filter info
4. Export only filtered data
```

### 2. Date Range Export
```bubble
Input: Date_Range_Picker
├── Start Date: date picker
├── End Date: date picker
└── Apply to export: checkbox

Workflow: export_date_range
Actions:
1. Get date range from inputs
2. Filter data by created_at date range
3. Export filtered data
```

### 3. Bulk Export (All Tabs)
```bubble
Button: Export_All_Data
├── Text: "Export All Data"
├── Workflow: export_all_tabs
└── Generate: ZIP file with multiple CSVs

Workflow: export_all_tabs
Actions:
1. Export BNPL transactions to bnpl_transactions.csv
2. Export subscriptions to subscriptions.csv
3. Export insurance logs to insurance_logs.csv
4. Create ZIP file with all CSVs
5. Download ZIP file
```

### 4. Scheduled Exports
```bubble
Workflow: schedule_export
Actions:
1. Set up recurring export (daily/weekly/monthly)
2. Generate timestamped filename
3. Export data automatically
4. Send email notification with file
5. Log export in audit trail
```

---

## 🔒 Security & Privacy

### Data Protection
- Mask sensitive data in exports (partial user IDs)
- Remove full payment details from CSV
- Add data classification headers
- Implement export logging

### Access Control
- Only admin users can export data
- Log all export activities
- Set export limits (max records per export)
- Implement export approval workflow for sensitive data

### File Security
```csv
# Add security headers to CSV files
# Data Classification: Internal Use Only
# Export Date: 2025-10-15
# Exported By: admin@company.com
# Records Count: 150
# Data Retention: 30 days
```

---

## 📊 Analytics & Monitoring

### Export Metrics
- Track export frequency by user
- Monitor export file sizes
- Log export errors and failures
- Track most exported data types

### Usage Analytics
```bubble
Track Events:
├── export_initiated
├── export_completed
├── export_failed
├── export_cancelled
└── export_downloaded
```

---

## 🧪 Testing Checklist

### Functionality Tests
- [ ] Export button appears on all tabs
- [ ] CSV generation works correctly
- [ ] File download triggers properly
- [ ] Filename includes timestamp
- [ ] All data columns are included
- [ ] Special characters are escaped
- [ ] Large datasets export successfully
- [ ] Filtered exports work correctly

### UI/UX Tests
- [ ] Loading state shows during export
- [ ] Success message displays correctly
- [ ] Error handling works properly
- [ ] Button states change appropriately
- [ ] Export button is accessible
- [ ] Mobile export works correctly

### Performance Tests
- [ ] Export completes within 10 seconds
- [ ] Large datasets don't crash browser
- [ ] Memory usage stays reasonable
- [ ] Multiple exports work simultaneously

---

## 🚀 Implementation Steps

### Step 1: Add Export Button
1. Add export button to each tab
2. Style button consistently
3. Add loading states
4. Test button appearance

### Step 2: Implement CSV Generation
1. Add JavaScript element to page
2. Implement CSV generation function
3. Test with sample data
4. Handle edge cases

### Step 3: Add Export Workflow
1. Create export workflow
2. Connect to button trigger
3. Add error handling
4. Test workflow execution

### Step 4: Enhance Features
1. Add filtered export
2. Implement bulk export
3. Add export logging
4. Test all features

### Step 5: Security & Testing
1. Add access controls
2. Implement data masking
3. Test security features
4. Complete testing checklist

---

## 📝 Notes

- CSV exports respect current user permissions
- Files are generated client-side for security
- No server-side file storage required
- Compatible with all modern browsers
- Works with Bubble.io's JavaScript element
- Can be extended for other export formats (Excel, JSON)

This implementation provides a complete CSV export solution for the NFT Admin Dashboard with proper security, user experience, and performance considerations.
