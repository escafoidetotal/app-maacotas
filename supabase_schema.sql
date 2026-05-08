-- MaaCOTAS - Supabase Schema
-- Run this in your Supabase project > SQL Editor

-- ─── Profiles ─────────────────────────────────────────────────────────────────
create table if not exists public.profiles (
  id          uuid primary key references auth.users on delete cascade,
  name        text,
  photo_url   text,
  paw_points  int default 0,
  owned_items text[] default '{}',
  points_log  jsonb default '{}',
  current_streak int default 0,
  last_walk_date timestamptz,
  selected_theme text,
  created_at  timestamptz default now(),
  updated_at  timestamptz default now()
);

-- ─── Pets ─────────────────────────────────────────────────────────────────────
create table if not exists public.pets (
  id               text primary key,
  user_id          uuid references auth.users on delete cascade not null,
  name             text not null,
  breed            text,
  birthdate        date,
  weight           float,
  gender           text,
  photo_url        text,
  microchip_number text,
  insurance_info   text,
  selected_skin    text,
  owned_accessories text[] default '{}',
  equipped_hat     text,
  equipped_collar  text,
  equipped_outfit  text,
  created_at       timestamptz default now(),
  updated_at       timestamptz default now()
);

-- ─── Vaccines ─────────────────────────────────────────────────────────────────
create table if not exists public.vaccines (
  id           text primary key,
  pet_id       text references public.pets on delete cascade not null,
  user_id      uuid references auth.users on delete cascade not null,
  name         text,
  vaccine_date date,
  next_date    date,
  notes        text,
  created_at   timestamptz default now(),
  updated_at   timestamptz default now()
);

-- ─── Weight records ───────────────────────────────────────────────────────────
create table if not exists public.weight_records (
  id          text primary key,
  pet_id      text references public.pets on delete cascade not null,
  user_id     uuid references auth.users on delete cascade not null,
  weight      float not null,
  record_date date not null,
  notes       text,
  created_at  timestamptz default now(),
  updated_at  timestamptz default now()
);

-- ─── Deworming ────────────────────────────────────────────────────────────────
create table if not exists public.deworming (
  id               text primary key,
  pet_id           text references public.pets on delete cascade not null,
  user_id          uuid references auth.users on delete cascade not null,
  type             text,    -- 'internal' or 'external'
  product          text,
  application_date date,
  next_date        date,
  notes            text,
  created_at       timestamptz default now(),
  updated_at       timestamptz default now()
);

-- ─── Medications ──────────────────────────────────────────────────────────────
create table if not exists public.medications (
  id         text primary key,
  pet_id     text references public.pets on delete cascade not null,
  user_id    uuid references auth.users on delete cascade not null,
  name       text not null,
  dose       text,
  frequency  text,
  start_date date,
  end_date   date,
  is_active  boolean default true,
  notes      text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- ─── Walks ────────────────────────────────────────────────────────────────────
create table if not exists public.walks (
  id               text primary key,
  pet_id           text references public.pets on delete cascade not null,
  user_id          uuid references auth.users on delete cascade not null,
  walk_date        timestamptz,
  duration_minutes int,
  distance_km      float,
  notes            text,
  created_at       timestamptz default now(),
  updated_at       timestamptz default now()
);

-- ─── Vet appointments ─────────────────────────────────────────────────────────
create table if not exists public.vet_appointments (
  id               text primary key,
  pet_id           text references public.pets on delete cascade not null,
  user_id          uuid references auth.users on delete cascade not null,
  title            text,
  appointment_date timestamptz,
  vet_name         text,
  clinic           text,
  notes            text,
  is_completed     boolean default false,
  created_at       timestamptz default now(),
  updated_at       timestamptz default now()
);

-- ─── Row Level Security (RLS) - cada usuario solo ve sus datos ────────────────
alter table public.profiles enable row level security;
alter table public.pets enable row level security;
alter table public.vaccines enable row level security;
alter table public.weight_records enable row level security;
alter table public.deworming enable row level security;
alter table public.medications enable row level security;
alter table public.walks enable row level security;
alter table public.vet_appointments enable row level security;

-- Policies: usuario solo puede leer/escribir sus propios datos
create policy "own_profile" on public.profiles
  for all using (auth.uid() = id);

create policy "own_pets" on public.pets
  for all using (auth.uid() = user_id);

create policy "own_vaccines" on public.vaccines
  for all using (auth.uid() = user_id);

create policy "own_weight" on public.weight_records
  for all using (auth.uid() = user_id);

create policy "own_deworming" on public.deworming
  for all using (auth.uid() = user_id);

create policy "own_medications" on public.medications
  for all using (auth.uid() = user_id);

create policy "own_walks" on public.walks
  for all using (auth.uid() = user_id);

create policy "own_vet_appointments" on public.vet_appointments
  for all using (auth.uid() = user_id);

-- ─── Auto-create profile on signup ───────────────────────────────────────────
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer as $$
begin
  insert into public.profiles (id, name)
  values (new.id, new.raw_user_meta_data->>'name');
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
