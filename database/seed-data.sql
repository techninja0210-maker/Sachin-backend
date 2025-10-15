-- ============================================================================
-- NFT Admin Dashboard - Seed Data for Testing
-- ============================================================================
-- Purpose: Sample data for testing admin dashboard functionality
-- Note: Only use this in development/test environments
-- ============================================================================

-- Insert sample BNPL transactions
insert into public.bnpl_transactions (user_id, order_id, payment_id, payment_method, amount_paid, bnpl_status, metadata) values
-- Replace these UUIDs with actual user IDs from your users table
('00000000-0000-0000-0000-000000000001'::uuid, 'ORDER-2025-001', 'pi_3ABC123XYZ', 'afterpay_clearpay', 150.00, 'success', '{"stripe_session": "cs_test_123", "nft_name": "Cool Ape #123"}'),
('00000000-0000-0000-0000-000000000002'::uuid, 'ORDER-2025-002', 'pi_3DEF456ABC', 'card', 75.50, 'success', '{"stripe_session": "cs_test_456", "nft_name": "Pixel Punk #456"}'),
('00000000-0000-0000-0000-000000000003'::uuid, 'ORDER-2025-003', 'pi_3GHI789DEF', 'afterpay_clearpay', 299.99, 'pending', '{"stripe_session": "cs_test_789", "nft_name": "Meta Dragon #789"}'),
('00000000-0000-0000-0000-000000000001'::uuid, 'ORDER-2025-004', 'pi_3JKL012GHI', 'afterpay_clearpay', 45.00, 'failed', '{"stripe_session": "cs_test_012", "error": "Payment declined", "nft_name": "Crypto Cat #012"}'),
('00000000-0000-0000-0000-000000000004'::uuid, 'ORDER-2025-005', 'pi_3MNO345JKL', 'card', 500.00, 'success', '{"stripe_session": "cs_test_345", "nft_name": "Rare Diamond #345"}');

-- Insert sample weekly subscriptions
insert into public.weekly_subscriptions (user_id, subscription_id, stripe_customer_id, start_date, status, next_billing_date, amount, currency, metadata) values
('00000000-0000-0000-0000-000000000001'::uuid, 'sub_1ABC123XYZ456', 'cus_ABC123XYZ', '2025-01-01', 'active', '2025-10-17', 5.00, 'AUD', '{"plan": "nft_generator_weekly", "auto_renew": true}'),
('00000000-0000-0000-0000-000000000002'::uuid, 'sub_2DEF456ABC789', 'cus_DEF456ABC', '2025-02-15', 'active', '2025-10-18', 5.00, 'AUD', '{"plan": "nft_generator_weekly", "auto_renew": true}'),
('00000000-0000-0000-0000-000000000003'::uuid, 'sub_3GHI789DEF012', 'cus_GHI789DEF', '2025-03-20', 'paused', null, 5.00, 'AUD', '{"plan": "nft_generator_weekly", "paused_reason": "user_request"}'),
('00000000-0000-0000-0000-000000000004'::uuid, 'sub_4JKL012GHI345', 'cus_JKL012GHI', '2025-01-10', 'canceled', null, 5.00, 'AUD', '{"plan": "nft_generator_weekly", "canceled_reason": "payment_failed", "canceled_at": "2025-09-15"}'),
('00000000-0000-0000-0000-000000000005'::uuid, 'sub_5MNO345JKL678', 'cus_MNO345JKL', '2025-09-01', 'active', '2025-10-16', 5.00, 'AUD', '{"plan": "nft_generator_weekly", "auto_renew": true}');

-- Insert sample NFT insurance logs
insert into public.nft_insurance_logs (user_id, nft_id, insurance_status, insurance_policy_id, coverage_amount, premium_paid, expiry_date, metadata) values
('00000000-0000-0000-0000-000000000001'::uuid, '10000000-0000-0000-0000-000000000001'::uuid, 'approved', 'POLICY-NFT-2025-001', 150.00, 7.50, '2026-01-15', '{"provider": "mock_insurance_api", "coverage_type": "theft_and_loss"}'),
('00000000-0000-0000-0000-000000000002'::uuid, '10000000-0000-0000-0000-000000000002'::uuid, 'approved', 'POLICY-NFT-2025-002', 75.50, 3.78, '2026-02-20', '{"provider": "mock_insurance_api", "coverage_type": "theft_and_loss"}'),
('00000000-0000-0000-0000-000000000003'::uuid, '10000000-0000-0000-0000-000000000003'::uuid, 'rejected', null, 299.99, 0, null, '{"provider": "mock_insurance_api", "rejection_reason": "NFT value too high for standard coverage"}'),
('00000000-0000-0000-0000-000000000001'::uuid, '10000000-0000-0000-0000-000000000004'::uuid, 'applied', null, 45.00, 0, null, '{"provider": "mock_insurance_api", "application_date": "2025-10-10", "status": "pending_review"}'),
('00000000-0000-0000-0000-000000000004'::uuid, '10000000-0000-0000-0000-000000000005'::uuid, 'approved', 'POLICY-NFT-2025-005', 500.00, 25.00, '2026-03-01', '{"provider": "mock_insurance_api", "coverage_type": "premium_theft_loss_damage"}');

-- ============================================================================
-- Verification Queries (for testing)
-- ============================================================================

-- Query to verify BNPL transactions
select 
    'BNPL Transactions' as table_name,
    count(*) as record_count,
    sum(amount_paid) as total_amount
from public.bnpl_transactions;

-- Query to verify subscriptions
select 
    'Weekly Subscriptions' as table_name,
    count(*) as record_count,
    count(*) filter (where status = 'active') as active_count
from public.weekly_subscriptions;

-- Query to verify insurance logs
select 
    'NFT Insurance Logs' as table_name,
    count(*) as record_count,
    count(*) filter (where insurance_status = 'approved') as approved_count
from public.nft_insurance_logs;

-- ============================================================================
-- Clean up seed data (run this to remove test data)
-- ============================================================================

-- Uncomment below to delete all seed data
-- delete from public.bnpl_transactions;
-- delete from public.weekly_subscriptions;
-- delete from public.nft_insurance_logs;

-- ============================================================================
-- Success message
-- ============================================================================

do $$
begin
    raise notice '✅ Seed data inserted successfully!';
    raise notice '📊 BNPL Transactions: 5 sample records';
    raise notice '📊 Weekly Subscriptions: 5 sample records';
    raise notice '📊 NFT Insurance Logs: 5 sample records';
    raise notice '⚠️  Remember to replace sample UUIDs with real user IDs from your users table';
end $$;

