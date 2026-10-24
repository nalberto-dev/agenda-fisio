-- Minha Agenda: execute este arquivo uma vez no SQL Editor do Supabase.

create table if not exists public.patients (
  id             uuid primary key default gen_random_uuid(),
  user_id        uuid not null default auth.uid() references auth.users(id) on delete cascade,
  name           text not null,
  phone          text not null default '',
  fee            numeric(10,2) not null default 0 check (fee >= 0),
  total_sessions int  not null default 10 check (total_sessions >= 1),
  default_time   time not null default '15:00',
  notes          text not null default '',
  created_at     timestamptz not null default now()
);

create table if not exists public.appointments (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null default auth.uid() references auth.users(id) on delete cascade,
  patient_id   uuid not null references public.patients(id) on delete cascade,
  date         date not null,
  time         time not null,
  duration     int  not null default 50 check (duration > 0),
  kind         text not null default 'Sessão',
  status       text not null default 'agendado'
               check (status in ('agendado','realizado','cancelado','remarcado')),
  reminder_min int  not null default 30 check (reminder_min >= 0),
  note         text not null default '',
  created_at   timestamptz not null default now()
);

create index if not exists patients_user_idx     on public.patients (user_id);
create index if not exists appts_user_date_idx   on public.appointments (user_id, date);
create index if not exists appts_patient_idx     on public.appointments (patient_id);

-- Permissões explícitas para a API de Dados (exigidas pelo Supabase a partir de 30/10).
-- Só quem está logado ("authenticated") acessa; "anon" não recebe nada de propósito.
grant select, insert, update, delete on public.patients     to authenticated;
grant select, insert, update, delete on public.appointments to authenticated;
grant select, insert, update, delete on public.patients     to service_role;
grant select, insert, update, delete on public.appointments to service_role;

-- Cada pessoa vê e altera somente os próprios dados.
alter table public.patients     enable row level security;
alter table public.appointments enable row level security;

drop policy if exists "patients_own" on public.patients;
create policy "patients_own" on public.patients
  for all to authenticated
  using      (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

drop policy if exists "appointments_own" on public.appointments;
create policy "appointments_own" on public.appointments
  for all to authenticated
  using (user_id = (select auth.uid()))
  with check (
    user_id = (select auth.uid())
    and exists (select 1 from public.patients p
                where p.id = patient_id and p.user_id = (select auth.uid()))
  );

-- ===== Perfil: nome de exibição ("Como você gostaria de ser chamado?") =====
create table if not exists public.profiles (
  user_id      uuid primary key references auth.users(id) on delete cascade,
  display_name text not null default '' check (char_length(display_name) <= 60),
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);
grant select, insert, update on public.profiles to authenticated;
grant select, insert, update, delete on public.profiles to service_role;
alter table public.profiles enable row level security;
drop policy if exists "profiles_select_own" on public.profiles;
create policy "profiles_select_own" on public.profiles for select to authenticated using (user_id = (select auth.uid()));
drop policy if exists "profiles_insert_own" on public.profiles;
create policy "profiles_insert_own" on public.profiles for insert to authenticated with check (user_id = (select auth.uid()));
drop policy if exists "profiles_update_own" on public.profiles;
create policy "profiles_update_own" on public.profiles for update to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));

create or replace function public.handle_new_user() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  insert into public.profiles (user_id, display_name)
  values (new.id, left(btrim(coalesce(new.raw_user_meta_data->>'display_name', '')), 60))
  on conflict (user_id) do nothing;
  return new;
end; $$;
revoke execute on function public.handle_new_user() from public, anon, authenticated;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
  for each row execute function public.handle_new_user();
insert into public.profiles (user_id, display_name)
select id, left(btrim(coalesce(raw_user_meta_data->>'display_name', '')), 60) from auth.users
on conflict (user_id) do nothing;
