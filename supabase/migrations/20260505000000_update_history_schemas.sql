-- Bring scan_history, translation_history, and learning_progress in line with
-- the offline-first data model used by the Flutter app.

-- ─── 1) learning_progress — add step-tracking columns ────────────────────────

alter table public.learning_progress
  add column if not exists current_step integer not null default 0,
  add column if not exists total_steps  integer not null default 0;

-- ─── 2) scan_history — replace old schema with app-compatible one ─────────────
-- The old schema stored image_path / baybayin_text / translated_text.
-- The app now stores a JSON token list, a plain translation string, and uses
-- scanned_at as the timestamp name.

drop table if exists public.scan_history cascade;

create table public.scan_history (
  id          uuid default gen_random_uuid() primary key,
  user_id     uuid references auth.users(id) on delete cascade not null,
  tokens      jsonb not null default '[]',
  translation text not null default '',
  scanned_at  timestamptz not null default now()
);

create index scan_history_user_scanned_idx
  on public.scan_history (user_id, scanned_at desc);

alter table public.scan_history enable row level security;

create policy "Users can view their own scan history."
  on public.scan_history for select
  to authenticated
  using (auth.uid() = user_id);

create policy "Users can insert their own scan history."
  on public.scan_history for insert
  to authenticated
  with check (auth.uid() = user_id);

create policy "Users can delete their own scan history."
  on public.scan_history for delete
  to authenticated
  using (auth.uid() = user_id);

-- ─── 3) translation_history — replace old schema with app-compatible one ──────
-- The old schema had source_text / translated_text.
-- The app stores input_text, output_baybayin, output_latin, direction,
-- ai_response, is_bookmarked, and uses created_at as the timestamp name.

drop table if exists public.translation_history cascade;

create table public.translation_history (
  id             uuid default gen_random_uuid() primary key,
  user_id        uuid references auth.users(id) on delete cascade not null,
  input_text     text not null default '',
  output_baybayin text not null default '',
  output_latin   text not null default '',
  direction      text not null default 'latin_to_baybayin',
  ai_response    text,
  is_bookmarked  boolean not null default false,
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now(),
  constraint translation_history_direction_check
    check (direction in ('latin_to_baybayin', 'baybayin_to_latin'))
);

create index translation_history_user_created_idx
  on public.translation_history (user_id, created_at desc);

create index translation_history_bookmarked_idx
  on public.translation_history (user_id, updated_at desc)
  where is_bookmarked is true;

create trigger translation_history_updated_at
  before update on public.translation_history
  for each row execute procedure public.handle_updated_at();

alter table public.translation_history enable row level security;

create policy "Users can view their own translation history."
  on public.translation_history for select
  to authenticated
  using (auth.uid() = user_id);

create policy "Users can insert their own translation history."
  on public.translation_history for insert
  to authenticated
  with check (auth.uid() = user_id);

create policy "Users can update their own translation history."
  on public.translation_history for update
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "Users can delete their own translation history."
  on public.translation_history for delete
  to authenticated
  using (auth.uid() = user_id);
