-- ─── RBAC: role column on profiles ──────────────────────────────────────────
--
-- Two roles:
--   'user'  — default for all sign-ups (no special access)
--   'admin' — assigned manually via Supabase dashboard; can create stroke
--             patterns and access admin tools
--
-- Role is intentionally NOT stored in auth.users user_metadata because
-- users can overwrite their own metadata via the client SDK.

alter table public.profiles
  add column role text not null default 'user'
    constraint profiles_role_check check (role in ('user', 'admin'));

comment on column public.profiles.role is
  'RBAC role. Managed by admins only — never writable by the row owner.';

-- Allow users to read their own role (needed by the app).
-- The existing "Users can view their own profile." policy already covers SELECT
-- so no new SELECT policy is required here.

-- Prevent users from promoting themselves.
create policy "Only service role can set role."
  on public.profiles for update
  using (auth.uid() = id)
  with check (
    -- The role column must remain unchanged when updated by the row owner.
    -- Admins can change roles via service-role key from the dashboard.
    role = (select p.role from public.profiles p where p.id = auth.uid())
  );

-- ─── stroke_patterns ─────────────────────────────────────────────────────────
--
-- One row per recorded drawing attempt by an admin.
--
-- strokes: JSONB array of stroke objects —
--   [ { "points": [ { "x": 0.42, "y": 0.67, "t": 312 }, … ] }, … ]
--   x, y  — normalised canvas coordinates in [0, 1]
--   t     — milliseconds elapsed since the first touch of this stroke
--
-- device_info: JSONB — { "platform": "android", "width": 390, "height": 844 }
--   recorded for accuracy/scaling analysis

create table public.stroke_patterns (
  id           uuid         default gen_random_uuid() primary key,
  user_id      uuid         references auth.users(id) on delete cascade not null,
  glyph        text         not null,   -- e.g. 'a', 'ka', 'ng'
  label        text         not null,   -- human-readable e.g. 'A', 'Ka'
  strokes      jsonb        not null default '[]'::jsonb,
  canvas_width  float8      not null,
  canvas_height float8      not null,
  device_info  jsonb        not null default '{}'::jsonb,
  created_at   timestamptz  not null default now()
);

comment on table public.stroke_patterns is
  'Admin-recorded Baybayin stroke data for replay, model training and accuracy analysis.';

create index stroke_patterns_glyph_idx
  on public.stroke_patterns (glyph);

create index stroke_patterns_user_created_idx
  on public.stroke_patterns (user_id, created_at desc);

alter table public.stroke_patterns enable row level security;

-- Helper: is the current user an admin?
create or replace function public.is_admin()
returns boolean
language sql
security definer
stable
set search_path = ''
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and role = 'admin'
  );
$$;

-- Admins can read all patterns (for review / export).
create policy "Admins can view all stroke patterns."
  on public.stroke_patterns for select
  to authenticated
  using (public.is_admin());

-- Admins can insert their own patterns.
create policy "Admins can insert stroke patterns."
  on public.stroke_patterns for insert
  to authenticated
  with check (public.is_admin() and auth.uid() = user_id);

-- Admins can delete their own patterns.
create policy "Admins can delete their own stroke patterns."
  on public.stroke_patterns for delete
  to authenticated
  using (public.is_admin() and auth.uid() = user_id);
