# Database Files

## Files Included

### `schema-standalone.sql` ⭐ **MAIN FILE**
- **USE THIS FILE** for database setup
- Complete working schema with all tables, triggers, and functions
- Works independently without requiring existing users/nfts tables
- Currently deployed and working in Supabase

**To Deploy:**
1. Open Supabase SQL Editor
2. Copy entire contents of this file
3. Paste and run
4. Verify success messages appear

### `seed-data.sql` - Optional Test Data
- Sample data for testing and demonstration
- Contains 5 sample records per table:
  - BNPL transactions
  - Weekly subscriptions
  - NFT insurance logs
- Run this AFTER running schema-standalone.sql

**To Use:**
1. First run schema-standalone.sql
2. Then run this file to populate with test data
3. Refresh your admin dashboard to see demo data

---

## Quick Start

```sql
-- Step 1: Run main schema (required)
-- Copy and run: schema-standalone.sql

-- Step 2: Add test data (optional)
-- Copy and run: seed-data.sql

-- Step 3: Verify
SELECT COUNT(*) FROM bnpl_transactions;
SELECT COUNT(*) FROM weekly_subscriptions;
SELECT COUNT(*) FROM nft_insurance_logs;
```

---

## Database Schema

**Tables Created:**
- `bnpl_transactions` - BNPL purchase tracking
- `weekly_subscriptions` - Subscription management
- `nft_insurance_logs` - Insurance application tracking

**Additional Features:**
- Auto-updating timestamps (triggers)
- Row Level Security (RLS) policies
- Admin dashboard views
- Analytics functions
- Helper functions

---

## Current Status

✅ Schema deployed to Supabase
✅ All 3 tables operational
✅ Ready for production use

For detailed documentation, see: `../docs/SETUP.md`

