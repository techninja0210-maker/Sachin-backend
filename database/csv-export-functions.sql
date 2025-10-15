-- ============================================================================
-- NFT Admin Dashboard - CSV Export Functions
-- ============================================================================
-- Purpose: Database functions to support CSV export functionality
-- Version: 2.0.0
-- ============================================================================

-- ============================================================================
-- Function: Export BNPL Transactions to CSV Format
-- ============================================================================

create or replace function public.export_bnpl_transactions_csv(
    p_limit integer default 1000,
    p_user_filter text default null,
    p_status_filter text default null,
    p_date_from timestamptz default null,
    p_date_to timestamptz default null
)
returns table (
    csv_row text
) as $$
declare
    sql_query text;
begin
    -- Build dynamic query based on filters
    sql_query := '
        select 
            concat(
                coalesce(user_id::text, ''''), '','',
                coalesce(order_id, ''''), '','',
                coalesce(payment_id, ''''), '','',
                coalesce(payment_method, ''''), '','',
                coalesce(amount_paid::text, ''''), '','',
                coalesce(bnpl_status, ''''), '','',
                coalesce(user_email, ''''), '','',
                coalesce(created_at::text, ''''), '','',
                coalesce(updated_at::text, '''')
            ) as csv_row
        from public.bnpl_transactions
        where 1=1';
    
    -- Add filters if provided
    if p_user_filter is not null then
        sql_query := sql_query || ' and user_id::text = ''' || p_user_filter || '''';
    end if;
    
    if p_status_filter is not null then
        sql_query := sql_query || ' and bnpl_status = ''' || p_status_filter || '''';
    end if;
    
    if p_date_from is not null then
        sql_query := sql_query || ' and created_at >= ''' || p_date_from::text || '''';
    end if;
    
    if p_date_to is not null then
        sql_query := sql_query || ' and created_at <= ''' || p_date_to::text || '''';
    end if;
    
    sql_query := sql_query || ' order by created_at desc limit ' || p_limit;
    
    -- Return CSV header first
    return query select 'user_id,order_id,payment_id,payment_method,amount_paid,bnpl_status,user_email,created_at,updated_at'::text;
    
    -- Execute dynamic query
    return query execute sql_query;
end;
$$ language plpgsql security definer;

comment on function public.export_bnpl_transactions_csv is 'Export BNPL transactions in CSV format with filtering options';

-- ============================================================================
-- Function: Export Weekly Subscriptions to CSV Format
-- ============================================================================

create or replace function public.export_subscriptions_csv(
    p_limit integer default 1000,
    p_user_filter text default null,
    p_status_filter text default null,
    p_date_from timestamptz default null,
    p_date_to timestamptz default null
)
returns table (
    csv_row text
) as $$
declare
    sql_query text;
begin
    -- Build dynamic query based on filters
    sql_query := '
        select 
            concat(
                coalesce(user_id::text, ''''), '','',
                coalesce(subscription_id, ''''), '','',
                coalesce(stripe_customer_id, ''''), '','',
                coalesce(status, ''''), '','',
                coalesce(start_date::text, ''''), '','',
                coalesce(next_billing_date::text, ''''), '','',
                coalesce(amount::text, ''''), '','',
                coalesce(currency, ''''), '','',
                coalesce(user_email, ''''), '','',
                coalesce(created_at::text, ''''), '','',
                coalesce(updated_at::text, '''')
            ) as csv_row
        from public.weekly_subscriptions
        where 1=1';
    
    -- Add filters if provided
    if p_user_filter is not null then
        sql_query := sql_query || ' and user_id::text = ''' || p_user_filter || '''';
    end if;
    
    if p_status_filter is not null then
        sql_query := sql_query || ' and status = ''' || p_status_filter || '''';
    end if;
    
    if p_date_from is not null then
        sql_query := sql_query || ' and created_at >= ''' || p_date_from::text || '''';
    end if;
    
    if p_date_to is not null then
        sql_query := sql_query || ' and created_at <= ''' || p_date_to::text || '''';
    end if;
    
    sql_query := sql_query || ' order by created_at desc limit ' || p_limit;
    
    -- Return CSV header first
    return query select 'user_id,subscription_id,stripe_customer_id,status,start_date,next_billing_date,amount,currency,user_email,created_at,updated_at'::text;
    
    -- Execute dynamic query
    return query execute sql_query;
end;
$$ language plpgsql security definer;

comment on function public.export_subscriptions_csv is 'Export weekly subscriptions in CSV format with filtering options';

-- ============================================================================
-- Function: Export NFT Insurance Logs to CSV Format
-- ============================================================================

create or replace function public.export_insurance_logs_csv(
    p_limit integer default 1000,
    p_user_filter text default null,
    p_status_filter text default null,
    p_date_from timestamptz default null,
    p_date_to timestamptz default null
)
returns table (
    csv_row text
) as $$
declare
    sql_query text;
begin
    -- Build dynamic query based on filters
    sql_query := '
        select 
            concat(
                coalesce(user_id::text, ''''), '','',
                coalesce(nft_id::text, ''''), '','',
                coalesce(insurance_status, ''''), '','',
                coalesce(insurance_policy_id, ''''), '','',
                coalesce(coverage_amount::text, ''''), '','',
                coalesce(premium_paid::text, ''''), '','',
                coalesce(expiry_date::text, ''''), '','',
                coalesce(user_email, ''''), '','',
                coalesce(created_at::text, ''''), '','',
                coalesce(updated_at::text, '''')
            ) as csv_row
        from public.nft_insurance_logs
        where 1=1';
    
    -- Add filters if provided
    if p_user_filter is not null then
        sql_query := sql_query || ' and user_id::text = ''' || p_user_filter || '''';
    end if;
    
    if p_status_filter is not null then
        sql_query := sql_query || ' and insurance_status = ''' || p_status_filter || '''';
    end if;
    
    if p_date_from is not null then
        sql_query := sql_query || ' and created_at >= ''' || p_date_from::text || '''';
    end if;
    
    if p_date_to is not null then
        sql_query := sql_query || ' and created_at <= ''' || p_date_to::text || '''';
    end if;
    
    sql_query := sql_query || ' order by created_at desc limit ' || p_limit;
    
    -- Return CSV header first
    return query select 'user_id,nft_id,insurance_status,insurance_policy_id,coverage_amount,premium_paid,expiry_date,user_email,created_at,updated_at'::text;
    
    -- Execute dynamic query
    return query execute sql_query;
end;
$$ language plpgsql security definer;

comment on function public.export_insurance_logs_csv is 'Export NFT insurance logs in CSV format with filtering options';

-- ============================================================================
-- Function: Export Global Transactions Summary to CSV Format
-- ============================================================================

create or replace function public.export_global_transactions_csv(
    p_limit integer default 1000,
    p_user_filter text default null,
    p_type_filter text default null,
    p_date_from timestamptz default null,
    p_date_to timestamptz default null
)
returns table (
    csv_row text
) as $$
declare
    sql_query text;
begin
    -- Build dynamic query based on filters
    sql_query := '
        select 
            concat(
                coalesce(transaction_type, ''''), '','',
                coalesce(source_table, ''''), '','',
                coalesce(source_id::text, ''''), '','',
                coalesce(user_id::text, ''''), '','',
                coalesce(amount::text, ''''), '','',
                coalesce(status, ''''), '','',
                coalesce(created_at::text, ''''), '','',
                coalesce(updated_at::text, '''')
            ) as csv_row
        from public.transactions
        where 1=1';
    
    -- Add filters if provided
    if p_user_filter is not null then
        sql_query := sql_query || ' and user_id::text = ''' || p_user_filter || '''';
    end if;
    
    if p_type_filter is not null then
        sql_query := sql_query || ' and transaction_type = ''' || p_type_filter || '''';
    end if;
    
    if p_date_from is not null then
        sql_query := sql_query || ' and created_at >= ''' || p_date_from::text || '''';
    end if;
    
    if p_date_to is not null then
        sql_query := sql_query || ' and created_at <= ''' || p_date_to::text || '''';
    end if;
    
    sql_query := sql_query || ' order by created_at desc limit ' || p_limit;
    
    -- Return CSV header first
    return query select 'transaction_type,source_table,source_id,user_id,amount,status,created_at,updated_at'::text;
    
    -- Execute dynamic query
    return query execute sql_query;
end;
$$ language plpgsql security definer;

comment on function public.export_global_transactions_csv is 'Export global transactions summary in CSV format with filtering options';

-- ============================================================================
-- Function: Get Export Statistics
-- ============================================================================

create or replace function public.get_export_statistics()
returns table (
    table_name text,
    total_records bigint,
    last_export_date timestamptz,
    export_count bigint
) as $$
begin
    return query
    select 
        'bnpl_transactions'::text as table_name,
        count(*)::bigint as total_records,
        max(created_at) as last_export_date,
        0::bigint as export_count
    from public.bnpl_transactions
    
    union all
    
    select 
        'weekly_subscriptions'::text as table_name,
        count(*)::bigint as total_records,
        max(created_at) as last_export_date,
        0::bigint as export_count
    from public.weekly_subscriptions
    
    union all
    
    select 
        'nft_insurance_logs'::text as table_name,
        count(*)::bigint as total_records,
        max(created_at) as last_export_date,
        0::bigint as export_count
    from public.nft_insurance_logs
    
    union all
    
    select 
        'transactions'::text as table_name,
        count(*)::bigint as total_records,
        max(created_at) as last_export_date,
        0::bigint as export_count
    from public.transactions;
end;
$$ language plpgsql security definer;

comment on function public.get_export_statistics is 'Get statistics for export functionality';

-- ============================================================================
-- Function: Log Export Activity
-- ============================================================================

create or replace function public.log_export_activity(
    p_table_name text,
    p_export_type text,
    p_record_count integer,
    p_user_id uuid default null,
    p_filters jsonb default '{}'::jsonb
)
returns uuid as $$
declare
    log_id uuid;
begin
    -- Create export log entry
    insert into public.export_logs (
        table_name,
        export_type,
        record_count,
        user_id,
        filters,
        export_date
    ) values (
        p_table_name,
        p_export_type,
        p_record_count,
        p_user_id,
        p_filters,
        now()
    ) returning id into log_id;
    
    return log_id;
end;
$$ language plpgsql security definer;

-- ============================================================================
-- Table: Export Logs (for audit trail)
-- ============================================================================

create table if not exists public.export_logs (
    id uuid primary key default gen_random_uuid(),
    table_name text not null,
    export_type text not null,
    record_count integer not null,
    user_id uuid references auth.users(id) on delete set null,
    filters jsonb default '{}'::jsonb,
    export_date timestamptz default now(),
    created_at timestamptz default now()
);

-- Index for export logs
create index if not exists idx_export_logs_user_id on public.export_logs(user_id);
create index if not exists idx_export_logs_export_date on public.export_logs(export_date desc);
create index if not exists idx_export_logs_table_name on public.export_logs(table_name);

-- Enable RLS on export logs
alter table public.export_logs enable row level security;

-- Policy for export logs
create policy "Authenticated users can view export logs" 
    on public.export_logs for select
    using (auth.uid() is not null);

create policy "Service role can manage export logs" 
    on public.export_logs for all
    using (auth.role() = 'service_role');

-- Grant permissions
grant select on public.export_logs to authenticated;
grant all on public.export_logs to service_role;

-- Add trigger for updated_at
create trigger update_export_logs_modtime
    before update on public.export_logs
    for each row
    execute function public.update_updated_at_column();

comment on table public.export_logs is 'Audit log for CSV export activities';

-- ============================================================================
-- Grant Permissions for Export Functions
-- ============================================================================

grant execute on function public.export_bnpl_transactions_csv to authenticated;
grant execute on function public.export_subscriptions_csv to authenticated;
grant execute on function public.export_insurance_logs_csv to authenticated;
grant execute on function public.export_global_transactions_csv to authenticated;
grant execute on function public.get_export_statistics to authenticated;
grant execute on function public.log_export_activity to authenticated;

-- ============================================================================
-- Success Message
-- ============================================================================

do $$
begin
    raise notice '✅ CSV Export functions created successfully!';
    raise notice '📊 Functions created: export_bnpl_transactions_csv, export_subscriptions_csv, export_insurance_logs_csv, export_global_transactions_csv';
    raise notice '📈 Statistics function: get_export_statistics';
    raise notice '📝 Audit logging: log_export_activity, export_logs table';
    raise notice '🔒 Security: RLS enabled, proper permissions granted';
end $$;
