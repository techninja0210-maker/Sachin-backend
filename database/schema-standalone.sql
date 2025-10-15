-- ============================================================================
-- NFT Admin Dashboard - Standalone Database Schema
-- ============================================================================
-- Purpose: BNPL, Subscriptions, and NFT Insurance tracking
-- Stack: Supabase (PostgreSQL)
-- Region: Australia (AUD currency)
-- Version: 1.0.0 (Standalone - no user table dependencies)
-- ============================================================================

-- Enable UUID extension if not already enabled
create extension if not exists "uuid-ossp";

-- ============================================================================
-- TABLE 1: BNPL Transactions
-- ============================================================================
-- Tracks Buy Now Pay Later orders via Stripe AfterPay/ClearPay

create table if not exists public.bnpl_transactions (
    id uuid primary key default gen_random_uuid(),
    user_id uuid, -- Will add FK later when users table exists
    order_id text not null,
    payment_id text,
    payment_method text check (payment_method in ('card', 'afterpay_clearpay', 'klarna', 'other')),
    amount_paid numeric(12,2) not null,
    bnpl_status text check (bnpl_status in ('success', 'failed', 'pending', 'refunded')) default 'pending',
    user_email text, -- Temporary: store email directly until users table exists
    metadata jsonb default '{}'::jsonb,
    created_at timestamptz default now(),
    updated_at timestamptz default now()
);

-- Indexes for performance
create index if not exists idx_bnpl_user_id on public.bnpl_transactions(user_id);
create index if not exists idx_bnpl_status on public.bnpl_transactions(bnpl_status);
create index if not exists idx_bnpl_created_at on public.bnpl_transactions(created_at desc);
create index if not exists idx_bnpl_payment_id on public.bnpl_transactions(payment_id);

-- Comments for documentation
comment on table public.bnpl_transactions is 'Tracks BNPL (Buy Now Pay Later) transactions via Stripe AfterPay/ClearPay';
comment on column public.bnpl_transactions.user_id is 'User ID (FK will be added when users table exists)';
comment on column public.bnpl_transactions.order_id is 'Unique order identifier from checkout';
comment on column public.bnpl_transactions.payment_id is 'Stripe PaymentIntent ID';
comment on column public.bnpl_transactions.payment_method is 'Payment method used (card, afterpay_clearpay, etc.)';
comment on column public.bnpl_transactions.amount_paid is 'Transaction amount in AUD';
comment on column public.bnpl_transactions.bnpl_status is 'Transaction status: success, failed, pending, refunded';
comment on column public.bnpl_transactions.metadata is 'Additional Stripe data and custom fields (JSONB)';

-- ============================================================================
-- TABLE 2: Weekly Subscriptions
-- ============================================================================
-- Tracks weekly recurring subscriptions via Stripe

create table if not exists public.weekly_subscriptions (
    id uuid primary key default gen_random_uuid(),
    user_id uuid, -- Will add FK later when users table exists
    subscription_id text unique not null,
    stripe_customer_id text not null,
    start_date date not null,
    status text check (status in ('active', 'paused', 'canceled', 'past_due', 'incomplete')) default 'active',
    next_billing_date date,
    amount numeric(12,2) default 5.00,
    currency text default 'AUD',
    user_email text, -- Temporary: store email directly until users table exists
    metadata jsonb default '{}'::jsonb,
    created_at timestamptz default now(),
    updated_at timestamptz default now()
);

-- Indexes for performance
create index if not exists idx_subscription_user_id on public.weekly_subscriptions(user_id);
create index if not exists idx_subscription_status on public.weekly_subscriptions(status);
create index if not exists idx_subscription_stripe_customer on public.weekly_subscriptions(stripe_customer_id);
create index if not exists idx_subscription_next_billing on public.weekly_subscriptions(next_billing_date);

-- Comments for documentation
comment on table public.weekly_subscriptions is 'Tracks weekly recurring subscriptions via Stripe';
comment on column public.weekly_subscriptions.user_id is 'User ID (FK will be added when users table exists)';
comment on column public.weekly_subscriptions.subscription_id is 'Stripe Subscription ID (unique)';
comment on column public.weekly_subscriptions.stripe_customer_id is 'Stripe Customer ID';
comment on column public.weekly_subscriptions.start_date is 'Subscription start date';
comment on column public.weekly_subscriptions.status is 'Subscription status: active, paused, canceled, past_due, incomplete';
comment on column public.weekly_subscriptions.next_billing_date is 'Next scheduled billing date';
comment on column public.weekly_subscriptions.amount is 'Weekly subscription amount (default: 5.00 AUD)';
comment on column public.weekly_subscriptions.metadata is 'Additional Stripe data and custom fields (JSONB)';

-- ============================================================================
-- TABLE 3: NFT Insurance Logs
-- ============================================================================
-- Tracks NFT insurance applications and approvals

create table if not exists public.nft_insurance_logs (
    id uuid primary key default gen_random_uuid(),
    user_id uuid, -- Will add FK later when users table exists
    nft_id uuid, -- Will add FK later when nfts table exists
    insurance_status text check (insurance_status in ('applied', 'approved', 'rejected', 'expired')) default 'applied',
    insurance_policy_id text,
    coverage_amount numeric(12,2),
    premium_paid numeric(12,2),
    expiry_date date,
    user_email text, -- Temporary: store email directly until users table exists
    metadata jsonb default '{}'::jsonb,
    created_at timestamptz default now(),
    updated_at timestamptz default now()
);

-- Indexes for performance
create index if not exists idx_insurance_user_id on public.nft_insurance_logs(user_id);
create index if not exists idx_insurance_nft_id on public.nft_insurance_logs(nft_id);
create index if not exists idx_insurance_status on public.nft_insurance_logs(insurance_status);
create index if not exists idx_insurance_created_at on public.nft_insurance_logs(created_at desc);

-- Comments for documentation
comment on table public.nft_insurance_logs is 'Tracks NFT insurance applications, approvals, and rejections';
comment on column public.nft_insurance_logs.user_id is 'User ID (FK will be added when users/nfts tables exist)';
comment on column public.nft_insurance_logs.nft_id is 'NFT ID (FK will be added when nfts table exists)';
comment on column public.nft_insurance_logs.insurance_status is 'Insurance status: applied, approved, rejected, expired';
comment on column public.nft_insurance_logs.insurance_policy_id is 'Insurance provider policy ID';
comment on column public.nft_insurance_logs.coverage_amount is 'Coverage amount in AUD';
comment on column public.nft_insurance_logs.premium_paid is 'Insurance premium paid in AUD';
comment on column public.nft_insurance_logs.expiry_date is 'Insurance policy expiry date';
comment on column public.nft_insurance_logs.metadata is 'Additional insurance provider data (JSONB)';

-- ============================================================================
-- TRIGGERS: Auto-update updated_at timestamp
-- ============================================================================

-- Create or replace the trigger function
create or replace function public.update_updated_at_column()
returns trigger as $$
begin
    new.updated_at = now();
    return new;
end;
$$ language plpgsql;

-- Apply trigger to BNPL transactions
drop trigger if exists update_bnpl_modtime on public.bnpl_transactions;
create trigger update_bnpl_modtime
    before update on public.bnpl_transactions
    for each row
    execute function public.update_updated_at_column();

-- Apply trigger to weekly subscriptions
drop trigger if exists update_subscription_modtime on public.weekly_subscriptions;
create trigger update_subscription_modtime
    before update on public.weekly_subscriptions
    for each row
    execute function public.update_updated_at_column();

-- Apply trigger to NFT insurance logs
drop trigger if exists update_insurance_modtime on public.nft_insurance_logs;
create trigger update_insurance_modtime
    before update on public.nft_insurance_logs
    for each row
    execute function public.update_updated_at_column();

-- ============================================================================
-- ROW LEVEL SECURITY (RLS) - Optional but Recommended
-- ============================================================================

-- Enable RLS on all tables
alter table public.bnpl_transactions enable row level security;
alter table public.weekly_subscriptions enable row level security;
alter table public.nft_insurance_logs enable row level security;

-- Policy: Admin users can view all records
create policy "Admin users can view all BNPL transactions"
    on public.bnpl_transactions for select
    using (true); -- Allow all for now, refine when auth is added

create policy "Admin users can view all subscriptions"
    on public.weekly_subscriptions for select
    using (true); -- Allow all for now, refine when auth is added

create policy "Admin users can view all insurance logs"
    on public.nft_insurance_logs for select
    using (true); -- Allow all for now, refine when auth is added

-- Policy: Service role can insert/update (for webhooks)
create policy "Service role can manage BNPL transactions"
    on public.bnpl_transactions for all
    using (true); -- Allow all for service role

create policy "Service role can manage subscriptions"
    on public.weekly_subscriptions for all
    using (true); -- Allow all for service role

create policy "Service role can manage insurance logs"
    on public.nft_insurance_logs for all
    using (true); -- Allow all for service role

-- ============================================================================
-- VIEWS: Admin Dashboard Queries (without user joins)
-- ============================================================================

-- View: Recent BNPL Transactions
create or replace view public.vw_recent_bnpl_transactions as
select 
    bt.id,
    bt.user_id,
    bt.user_email,
    bt.order_id,
    bt.payment_id,
    bt.payment_method,
    bt.amount_paid,
    bt.bnpl_status,
    bt.created_at
from public.bnpl_transactions bt
order by bt.created_at desc;

comment on view public.vw_recent_bnpl_transactions is 'Admin view: Recent BNPL transactions';

-- View: Active Subscriptions
create or replace view public.vw_active_subscriptions as
select 
    ws.id,
    ws.user_id,
    ws.user_email,
    ws.subscription_id,
    ws.stripe_customer_id,
    ws.start_date,
    ws.status,
    ws.next_billing_date,
    ws.amount,
    ws.created_at
from public.weekly_subscriptions ws
where ws.status = 'active'
order by ws.created_at desc;

comment on view public.vw_active_subscriptions is 'Admin view: Active subscriptions';

-- View: Insurance Applications
create or replace view public.vw_insurance_applications as
select 
    nil.id,
    nil.user_id,
    nil.user_email,
    nil.nft_id,
    nil.insurance_status,
    nil.insurance_policy_id,
    nil.coverage_amount,
    nil.premium_paid,
    nil.created_at
from public.nft_insurance_logs nil
order by nil.created_at desc;

comment on view public.vw_insurance_applications is 'Admin view: NFT insurance applications';

-- ============================================================================
-- FUNCTIONS: Helper functions for common operations
-- ============================================================================

-- Function: Get user's active subscription
create or replace function public.get_user_active_subscription(p_user_id uuid)
returns table (
    subscription_id text,
    status text,
    next_billing_date date,
    amount numeric
) as $$
begin
    return query
    select 
        ws.subscription_id,
        ws.status,
        ws.next_billing_date,
        ws.amount
    from public.weekly_subscriptions ws
    where ws.user_id = p_user_id
    and ws.status = 'active'
    limit 1;
end;
$$ language plpgsql security definer;

comment on function public.get_user_active_subscription is 'Returns user active subscription details';

-- Function: Check if NFT has active insurance
create or replace function public.check_nft_insurance(p_nft_id uuid)
returns boolean as $$
declare
    has_insurance boolean;
begin
    select exists(
        select 1 
        from public.nft_insurance_logs 
        where nft_id = p_nft_id 
        and insurance_status = 'approved'
        and (expiry_date is null or expiry_date > current_date)
    ) into has_insurance;
    
    return has_insurance;
end;
$$ language plpgsql security definer;

comment on function public.check_nft_insurance is 'Checks if NFT has active insurance coverage';

-- ============================================================================
-- ANALYTICS: Summary statistics for admin dashboard
-- ============================================================================

-- Function: Get BNPL statistics
create or replace function public.get_bnpl_statistics()
returns table (
    total_transactions bigint,
    total_amount_paid numeric,
    success_count bigint,
    failed_count bigint,
    pending_count bigint,
    avg_transaction_amount numeric
) as $$
begin
    return query
    select 
        count(*)::bigint as total_transactions,
        coalesce(sum(amount_paid), 0) as total_amount_paid,
        count(*) filter (where bnpl_status = 'success')::bigint as success_count,
        count(*) filter (where bnpl_status = 'failed')::bigint as failed_count,
        count(*) filter (where bnpl_status = 'pending')::bigint as pending_count,
        coalesce(avg(amount_paid), 0) as avg_transaction_amount
    from public.bnpl_transactions;
end;
$$ language plpgsql security definer;

comment on function public.get_bnpl_statistics is 'Returns summary statistics for BNPL transactions';

-- Function: Get subscription statistics
create or replace function public.get_subscription_statistics()
returns table (
    total_subscriptions bigint,
    active_count bigint,
    canceled_count bigint,
    paused_count bigint,
    monthly_recurring_revenue numeric
) as $$
begin
    return query
    select 
        count(*)::bigint as total_subscriptions,
        count(*) filter (where status = 'active')::bigint as active_count,
        count(*) filter (where status = 'canceled')::bigint as canceled_count,
        count(*) filter (where status = 'paused')::bigint as paused_count,
        (count(*) filter (where status = 'active') * 5.00 * 4)::numeric as monthly_recurring_revenue
    from public.weekly_subscriptions;
end;
$$ language plpgsql security definer;

comment on function public.get_subscription_statistics is 'Returns summary statistics for subscriptions';

-- ============================================================================
-- GRANT PERMISSIONS
-- ============================================================================

-- Grant access to anon and authenticated users
grant select on public.bnpl_transactions to anon, authenticated;
grant select on public.weekly_subscriptions to anon, authenticated;
grant select on public.nft_insurance_logs to anon, authenticated;

-- Grant full access to service role (for webhooks and admin operations)
grant all on public.bnpl_transactions to service_role;
grant all on public.weekly_subscriptions to service_role;
grant all on public.nft_insurance_logs to service_role;

-- Grant access to views
grant select on public.vw_recent_bnpl_transactions to anon, authenticated;
grant select on public.vw_active_subscriptions to anon, authenticated;
grant select on public.vw_insurance_applications to anon, authenticated;

-- ============================================================================
-- END OF SCHEMA
-- ============================================================================

-- Success message
do $$
begin
    raise notice '✅ NFT Admin Dashboard schema created successfully!';
    raise notice '📊 Tables created: bnpl_transactions, weekly_subscriptions, nft_insurance_logs';
    raise notice '🔄 Triggers enabled: auto-update timestamps';
    raise notice '🔒 Row Level Security: enabled';
    raise notice '📈 Views created: 3 admin dashboard views';
    raise notice '⚡ Functions created: helper and analytics functions';
    raise notice '⚠️  Note: Foreign key constraints will be added when users/nfts tables exist';
end $$;


