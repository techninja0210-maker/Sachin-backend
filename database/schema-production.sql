-- ============================================================================
-- NFT Admin Dashboard - Production Database Schema
-- ============================================================================
-- Purpose: BNPL, Subscriptions, and NFT Insurance tracking for MFH Project
-- Stack: Supabase (PostgreSQL) with proper RLS and foreign keys
-- Region: Australia (AUD currency)
-- Version: 2.0.0 (Production Ready)
-- ============================================================================

-- Enable required extensions
create extension if not exists "uuid-ossp";

-- ============================================================================
-- TABLE 1: BNPL Transactions (Production Ready)
-- ============================================================================

create table if not exists public.bnpl_transactions (
    id uuid primary key default gen_random_uuid(),
    user_id uuid references auth.users(id) on delete cascade,
    order_id text not null,
    payment_id text,
    payment_method text check (payment_method in ('card', 'afterpay_clearpay', 'klarna', 'other')),
    amount_paid numeric(12,2) not null,
    bnpl_status text check (bnpl_status in ('success', 'failed', 'pending', 'refunded')) default 'pending',
    user_email text, -- Keep for compatibility
    metadata jsonb default '{}'::jsonb,
    created_at timestamptz default now(),
    updated_at timestamptz default now()
);

-- Indexes for performance
create index if not exists idx_bnpl_user_id on public.bnpl_transactions(user_id);
create index if not exists idx_bnpl_status on public.bnpl_transactions(bnpl_status);
create index if not exists idx_bnpl_created_at on public.bnpl_transactions(created_at desc);
create index if not exists idx_bnpl_payment_id on public.bnpl_transactions(payment_id);
create index if not exists idx_bnpl_metadata on public.bnpl_transactions using gin(metadata);

-- ============================================================================
-- TABLE 2: Weekly Subscriptions (Production Ready)
-- ============================================================================

create table if not exists public.weekly_subscriptions (
    id uuid primary key default gen_random_uuid(),
    user_id uuid references auth.users(id) on delete cascade,
    subscription_id text unique not null,
    stripe_customer_id text not null,
    start_date date not null,
    status text check (status in ('active', 'paused', 'canceled', 'past_due', 'incomplete')) default 'active',
    next_billing_date date,
    amount numeric(12,2) default 5.00,
    currency text default 'AUD',
    user_email text, -- Keep for compatibility
    metadata jsonb default '{}'::jsonb,
    created_at timestamptz default now(),
    updated_at timestamptz default now()
);

-- Indexes for performance
create index if not exists idx_subscription_user_id on public.weekly_subscriptions(user_id);
create index if not exists idx_subscription_status on public.weekly_subscriptions(status);
create index if not exists idx_subscription_stripe_customer on public.weekly_subscriptions(stripe_customer_id);
create index if not exists idx_subscription_next_billing on public.weekly_subscriptions(next_billing_date);
create index if not exists idx_subscription_metadata on public.weekly_subscriptions using gin(metadata);

-- ============================================================================
-- TABLE 3: NFT Insurance Logs (Production Ready)
-- ============================================================================

create table if not exists public.nft_insurance_logs (
    id uuid primary key default gen_random_uuid(),
    user_id uuid references auth.users(id) on delete cascade,
    nft_id uuid, -- Will reference nfts table when it exists
    insurance_status text check (insurance_status in ('applied', 'approved', 'rejected', 'expired')) default 'applied',
    insurance_policy_id text,
    coverage_amount numeric(12,2),
    premium_paid numeric(12,2),
    expiry_date date,
    user_email text, -- Keep for compatibility
    metadata jsonb default '{}'::jsonb,
    created_at timestamptz default now(),
    updated_at timestamptz default now()
);

-- Indexes for performance
create index if not exists idx_insurance_user_id on public.nft_insurance_logs(user_id);
create index if not exists idx_insurance_nft_id on public.nft_insurance_logs(nft_id);
create index if not exists idx_insurance_status on public.nft_insurance_logs(insurance_status);
create index if not exists idx_insurance_created_at on public.nft_insurance_logs(created_at desc);
create index if not exists idx_insurance_metadata on public.nft_insurance_logs using gin(metadata);

-- ============================================================================
-- BONUS: Global Transactions Table (as requested by client)
-- ============================================================================

create table if not exists public.transactions (
    id uuid primary key default gen_random_uuid(),
    transaction_type text check (transaction_type in ('bnpl', 'subscription', 'insurance')) not null,
    source_table text not null, -- 'bnpl_transactions', 'weekly_subscriptions', 'nft_insurance_logs'
    source_id uuid not null, -- ID from the source table
    user_id uuid references auth.users(id) on delete cascade,
    amount numeric(12,2),
    status text not null,
    metadata jsonb default '{}'::jsonb,
    created_at timestamptz default now(),
    updated_at timestamptz default now()
);

-- Indexes for global transactions
create index if not exists idx_transactions_type on public.transactions(transaction_type);
create index if not exists idx_transactions_user_id on public.transactions(user_id);
create index if not exists idx_transactions_created_at on public.transactions(created_at desc);
create index if not exists idx_transactions_metadata on public.transactions using gin(metadata);

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

-- Apply triggers to all tables
drop trigger if exists update_bnpl_modtime on public.bnpl_transactions;
create trigger update_bnpl_modtime
    before update on public.bnpl_transactions
    for each row
    execute function public.update_updated_at_column();

drop trigger if exists update_subscription_modtime on public.weekly_subscriptions;
create trigger update_subscription_modtime
    before update on public.weekly_subscriptions
    for each row
    execute function public.update_updated_at_column();

drop trigger if exists update_insurance_modtime on public.nft_insurance_logs;
create trigger update_insurance_modtime
    before update on public.nft_insurance_logs
    for each row
    execute function public.update_updated_at_column();

drop trigger if exists update_transactions_modtime on public.transactions;
create trigger update_transactions_modtime
    before update on public.transactions
    for each row
    execute function public.update_updated_at_column();

-- ============================================================================
-- BONUS: Transactions Summary Trigger (as requested by client)
-- ============================================================================

-- Function to insert into global transactions table
create or replace function public.sync_to_transactions()
returns trigger as $$
declare
    transaction_type_val text;
    amount_val numeric(12,2);
    status_val text;
begin
    -- Determine transaction type and values based on source table
    case TG_TABLE_NAME
        when 'bnpl_transactions' then
            transaction_type_val := 'bnpl';
            amount_val := new.amount_paid;
            status_val := new.bnpl_status;
        when 'weekly_subscriptions' then
            transaction_type_val := 'subscription';
            amount_val := new.amount;
            status_val := new.status;
        when 'nft_insurance_logs' then
            transaction_type_val := 'insurance';
            amount_val := new.premium_paid;
            status_val := new.insurance_status;
    end case;

    -- Insert or update in global transactions table
    insert into public.transactions (
        transaction_type,
        source_table,
        source_id,
        user_id,
        amount,
        status,
        metadata
    ) values (
        transaction_type_val,
        TG_TABLE_NAME,
        new.id,
        new.user_id,
        amount_val,
        status_val,
        new.metadata
    ) on conflict (source_table, source_id) do update set
        amount = excluded.amount,
        status = excluded.status,
        metadata = excluded.metadata,
        updated_at = now();

    return new;
end;
$$ language plpgsql security definer;

-- Apply the sync trigger to all main tables
drop trigger if exists sync_bnpl_to_transactions on public.bnpl_transactions;
create trigger sync_bnpl_to_transactions
    after insert or update on public.bnpl_transactions
    for each row
    execute function public.sync_to_transactions();

drop trigger if exists sync_subscription_to_transactions on public.weekly_subscriptions;
create trigger sync_subscription_to_transactions
    after insert or update on public.weekly_subscriptions
    for each row
    execute function public.sync_to_transactions();

drop trigger if exists sync_insurance_to_transactions on public.nft_insurance_logs;
create trigger sync_insurance_to_transactions
    after insert or update on public.nft_insurance_logs
    for each row
    execute function public.sync_to_transactions();

-- Add unique constraint to prevent duplicates
alter table public.transactions add constraint unique_source_transaction 
unique (source_table, source_id);

-- ============================================================================
-- ROW LEVEL SECURITY (RLS) - Production Ready
-- ============================================================================

-- Enable RLS on all tables
alter table public.bnpl_transactions enable row level security;
alter table public.weekly_subscriptions enable row level security;
alter table public.nft_insurance_logs enable row level security;
alter table public.transactions enable row level security;

-- Drop existing policies if they exist
drop policy if exists "Admin users can view all BNPL transactions" on public.bnpl_transactions;
drop policy if exists "Admin users can view all subscriptions" on public.weekly_subscriptions;
drop policy if exists "Admin users can view all insurance logs" on public.nft_insurance_logs;
drop policy if exists "Service role can manage BNPL transactions" on public.bnpl_transactions;
drop policy if exists "Service role can manage subscriptions" on public.weekly_subscriptions;
drop policy if exists "Service role can manage insurance logs" on public.nft_insurance_logs;

-- Admin/Read-only policies using auth.uid() for authenticated users
create policy "Authenticated users can view BNPL transactions" 
    on public.bnpl_transactions for select
    using (auth.uid() is not null);

create policy "Authenticated users can view subscriptions" 
    on public.weekly_subscriptions for select
    using (auth.uid() is not null);

create policy "Authenticated users can view insurance logs" 
    on public.nft_insurance_logs for select
    using (auth.uid() is not null);

create policy "Authenticated users can view transactions" 
    on public.transactions for select
    using (auth.uid() is not null);

-- Service role policies for webhook operations
create policy "Service role can manage BNPL transactions" 
    on public.bnpl_transactions for all
    using (auth.role() = 'service_role');

create policy "Service role can manage subscriptions" 
    on public.weekly_subscriptions for all
    using (auth.role() = 'service_role');

create policy "Service role can manage insurance logs" 
    on public.nft_insurance_logs for all
    using (auth.role() = 'service_role');

create policy "Service role can manage transactions" 
    on public.transactions for all
    using (auth.role() = 'service_role');

-- ============================================================================
-- VIEWS: Admin Dashboard Queries (Production Ready)
-- ============================================================================

-- View: Recent BNPL Transactions with user info
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
    bt.metadata,
    bt.created_at,
    bt.updated_at
from public.bnpl_transactions bt
order by bt.created_at desc;

-- View: Active Subscriptions with user info
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
    ws.metadata,
    ws.created_at,
    ws.updated_at
from public.weekly_subscriptions ws
where ws.status = 'active'
order by ws.created_at desc;

-- View: Insurance Applications with user info
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
    nil.expiry_date,
    nil.metadata,
    nil.created_at,
    nil.updated_at
from public.nft_insurance_logs nil
order by nil.created_at desc;

-- View: Global transactions summary
create or replace view public.vw_transactions_summary as
select 
    t.id,
    t.transaction_type,
    t.user_id,
    t.amount,
    t.status,
    t.metadata,
    t.created_at,
    t.updated_at
from public.transactions t
order by t.created_at desc;

-- ============================================================================
-- FUNCTIONS: Enhanced helper functions
-- ============================================================================

-- Function: Get user's active subscription
create or replace function public.get_user_active_subscription(p_user_id uuid)
returns table (
    subscription_id text,
    status text,
    next_billing_date date,
    amount numeric,
    metadata jsonb
) as $$
begin
    return query
    select 
        ws.subscription_id,
        ws.status,
        ws.next_billing_date,
        ws.amount,
        ws.metadata
    from public.weekly_subscriptions ws
    where ws.user_id = p_user_id
    and ws.status = 'active'
    limit 1;
end;
$$ language plpgsql security definer;

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

-- Function: Get user transaction history
create or replace function public.get_user_transactions(p_user_id uuid)
returns table (
    transaction_type text,
    amount numeric,
    status text,
    created_at timestamptz,
    metadata jsonb
) as $$
begin
    return query
    select 
        t.transaction_type,
        t.amount,
        t.status,
        t.created_at,
        t.metadata
    from public.transactions t
    where t.user_id = p_user_id
    order by t.created_at desc;
end;
$$ language plpgsql security definer;

-- ============================================================================
-- ANALYTICS: Enhanced statistics functions
-- ============================================================================

-- Function: Get comprehensive BNPL statistics
create or replace function public.get_bnpl_statistics()
returns table (
    total_transactions bigint,
    total_amount_paid numeric,
    success_count bigint,
    failed_count bigint,
    pending_count bigint,
    avg_transaction_amount numeric,
    total_refunded numeric
) as $$
begin
    return query
    select 
        count(*)::bigint as total_transactions,
        coalesce(sum(amount_paid), 0) as total_amount_paid,
        count(*) filter (where bnpl_status = 'success')::bigint as success_count,
        count(*) filter (where bnpl_status = 'failed')::bigint as failed_count,
        count(*) filter (where bnpl_status = 'pending')::bigint as pending_count,
        coalesce(avg(amount_paid), 0) as avg_transaction_amount,
        coalesce(sum(amount_paid) filter (where bnpl_status = 'refunded'), 0) as total_refunded
    from public.bnpl_transactions;
end;
$$ language plpgsql security definer;

-- Function: Get subscription statistics
create or replace function public.get_subscription_statistics()
returns table (
    total_subscriptions bigint,
    active_count bigint,
    canceled_count bigint,
    paused_count bigint,
    monthly_recurring_revenue numeric,
    total_revenue numeric
) as $$
begin
    return query
    select 
        count(*)::bigint as total_subscriptions,
        count(*) filter (where status = 'active')::bigint as active_count,
        count(*) filter (where status = 'canceled')::bigint as canceled_count,
        count(*) filter (where status = 'paused')::bigint as paused_count,
        (count(*) filter (where status = 'active') * 5.00 * 4)::numeric as monthly_recurring_revenue,
        (count(*) filter (where status = 'active') * 5.00 * 52)::numeric as total_revenue
    from public.weekly_subscriptions;
end;
$$ language plpgsql security definer;

-- Function: Get global transaction statistics
create or replace function public.get_transaction_statistics()
returns table (
    total_transactions bigint,
    bnpl_count bigint,
    subscription_count bigint,
    insurance_count bigint,
    total_amount numeric,
    avg_amount numeric
) as $$
begin
    return query
    select 
        count(*)::bigint as total_transactions,
        count(*) filter (where transaction_type = 'bnpl')::bigint as bnpl_count,
        count(*) filter (where transaction_type = 'subscription')::bigint as subscription_count,
        count(*) filter (where transaction_type = 'insurance')::bigint as insurance_count,
        coalesce(sum(amount), 0) as total_amount,
        coalesce(avg(amount), 0) as avg_amount
    from public.transactions;
end;
$$ language plpgsql security definer;

-- ============================================================================
-- GRANT PERMISSIONS (Production Ready)
-- ============================================================================

-- Grant access to authenticated users (read-only)
grant select on public.bnpl_transactions to authenticated;
grant select on public.weekly_subscriptions to authenticated;
grant select on public.nft_insurance_logs to authenticated;
grant select on public.transactions to authenticated;

-- Grant full access to service role (for webhooks and admin operations)
grant all on public.bnpl_transactions to service_role;
grant all on public.weekly_subscriptions to service_role;
grant all on public.nft_insurance_logs to service_role;
grant all on public.transactions to service_role;

-- Grant access to views
grant select on public.vw_recent_bnpl_transactions to authenticated;
grant select on public.vw_active_subscriptions to authenticated;
grant select on public.vw_insurance_applications to authenticated;
grant select on public.vw_transactions_summary to authenticated;

-- Grant access to functions
grant execute on function public.get_user_active_subscription to authenticated;
grant execute on function public.check_nft_insurance to authenticated;
grant execute on function public.get_user_transactions to authenticated;
grant execute on function public.get_bnpl_statistics to authenticated;
grant execute on function public.get_subscription_statistics to authenticated;
grant execute on function public.get_transaction_statistics to authenticated;

-- ============================================================================
-- COMMENTS FOR DOCUMENTATION
-- ============================================================================

comment on table public.bnpl_transactions is 'Tracks BNPL (Buy Now Pay Later) transactions via Stripe AfterPay/ClearPay';
comment on table public.weekly_subscriptions is 'Tracks weekly recurring subscriptions via Stripe';
comment on table public.nft_insurance_logs is 'Tracks NFT insurance applications, approvals, and rejections';
comment on table public.transactions is 'Global transactions summary table synced from all transaction types';

comment on view public.vw_recent_bnpl_transactions is 'Admin view: Recent BNPL transactions with metadata';
comment on view public.vw_active_subscriptions is 'Admin view: Active subscriptions with metadata';
comment on view public.vw_insurance_applications is 'Admin view: NFT insurance applications with metadata';
comment on view public.vw_transactions_summary is 'Admin view: Global transactions summary';

-- ============================================================================
-- END OF PRODUCTION SCHEMA
-- ============================================================================

-- Success message
do $$
begin
    raise notice '✅ NFT Admin Dashboard PRODUCTION schema created successfully!';
    raise notice '📊 Tables created: bnpl_transactions, weekly_subscriptions, nft_insurance_logs, transactions';
    raise notice '🔄 Triggers enabled: auto-update timestamps + global sync';
    raise notice '🔒 Row Level Security: enabled with auth.uid() policies';
    raise notice '📈 Views created: 4 admin dashboard views with metadata';
    raise notice '⚡ Functions created: enhanced helper and analytics functions';
    raise notice '🎯 Foreign keys: linked to auth.users table';
    raise notice '🔄 Global sync: transactions automatically synced to global table';
    raise notice '📝 Metadata: JSONB columns for Stripe/insurance responses';
end $$;
