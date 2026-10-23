-- Firm Garage — Row Level Security baseline. REVIEW then run in Supabase SQL editor.
-- Table/column names are taken from your front-end code (firms, favorites, saved_comparisons,
-- firm_reviews, trading_journal, admin_users). If a column differs, adjust before running.
-- Test as a normal user AND as an admin afterwards.

alter table public.firms             enable row level security;
alter table public.favorites         enable row level security;
alter table public.saved_comparisons enable row level security;
alter table public.firm_reviews      enable row level security;
alter table public.trading_journal   enable row level security;
alter table public.admin_users       enable row level security;

-- Helper: is the caller an admin who has completed 2FA (aal2)?
create or replace function public.is_admin_aal2() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.admin_users a where a.user_id = auth.uid())
     and coalesce(auth.jwt() ->> 'aal','') = 'aal2';
$$;

-- admin_users: a user can see only their own row; nobody can write from the client.
drop policy if exists "own admin row" on public.admin_users;
create policy "own admin row" on public.admin_users for select to authenticated using (user_id = auth.uid());

-- firms: public can read active firms; admins (with 2FA) manage everything.
drop policy if exists "public read active firms" on public.firms;
create policy "public read active firms" on public.firms for select using (status = 'active');
drop policy if exists "admin all firms" on public.firms;
create policy "admin all firms" on public.firms for all to authenticated using (public.is_admin_aal2()) with check (public.is_admin_aal2());

-- Per-user private data: only the owner.
do $$ declare t text; begin
  foreach t in array array['favorites','saved_comparisons','trading_journal'] loop
    execute format('drop policy if exists "owner all" on public.%I', t);
    execute format('create policy "owner all" on public.%I for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid())', t);
  end loop;
end $$;

-- Reviews: anyone reads approved; users read/insert their own (forced to pending); admins moderate.
drop policy if exists "read approved reviews" on public.firm_reviews;
create policy "read approved reviews" on public.firm_reviews for select using (status = 'approved');
drop policy if exists "read own reviews" on public.firm_reviews;
create policy "read own reviews" on public.firm_reviews for select to authenticated using (user_id = auth.uid());
drop policy if exists "insert own pending review" on public.firm_reviews;
create policy "insert own pending review" on public.firm_reviews for insert to authenticated with check (user_id = auth.uid() and status = 'pending');
drop policy if exists "admin moderate reviews" on public.firm_reviews;
create policy "admin moderate reviews" on public.firm_reviews for all to authenticated using (public.is_admin_aal2()) with check (public.is_admin_aal2());
