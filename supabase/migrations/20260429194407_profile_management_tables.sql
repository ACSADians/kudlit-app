-- Profile management tables for first-wave features.

-- 1) User profile preferences
create table public.user_preferences (
  id uuid references auth.users(id) on delete cascade primary key,
  theme_mode text not null default 'system',
  locale text not null default 'en',
  high_contrast boolean not null default false,
  reduced_motion boolean not null default false,
  data_sharing_consent boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint user_preferences_theme_mode_check
    check (theme_mode in ('system', 'light', 'dark'))
);

create trigger user_preferences_updated_at
  before update on public.user_preferences
  for each row execute procedure public.handle_updated_at();

alter table public.user_preferences enable row level security;

create policy "Users can view their own preferences."
  on public.user_preferences for select
  to authenticated
  using (auth.uid() = id);

create policy "Users can insert their own preferences."
  on public.user_preferences for insert
  to authenticated
  with check (auth.uid() = id);

create policy "Users can update their own preferences."
  on public.user_preferences for update
  to authenticated
  using (auth.uid() = id)
  with check (auth.uid() = id);

create policy "Users can delete their own preferences."
  on public.user_preferences for delete
  to authenticated
  using (auth.uid() = id);

-- 2) Lesson progress rollups
create table public.learning_progress (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users(id) on delete cascade not null,
  lesson_id text not null,
  completed boolean not null default false,
  score integer not null default 0,
  completed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, lesson_id),
  constraint learning_progress_score_check check (score >= 0)
);

create index learning_progress_user_id_idx
  on public.learning_progress (user_id);

create index learning_progress_user_completed_idx
  on public.learning_progress (user_id, completed, updated_at desc);

create trigger learning_progress_updated_at
  before update on public.learning_progress
  for each row execute procedure public.handle_updated_at();

alter table public.learning_progress enable row level security;

create policy "Users can view their own learning progress."
  on public.learning_progress for select
  to authenticated
  using (auth.uid() = user_id);

create policy "Users can insert their own learning progress."
  on public.learning_progress for insert
  to authenticated
  with check (auth.uid() = user_id);

create policy "Users can update their own learning progress."
  on public.learning_progress for update
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "Users can delete their own learning progress."
  on public.learning_progress for delete
  to authenticated
  using (auth.uid() = user_id);

-- 3) Scanner history entries
create table public.scan_history (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users(id) on delete cascade not null,
  image_path text,
  baybayin_text text,
  translated_text text,
  created_at timestamptz not null default now()
);

create index scan_history_user_created_idx
  on public.scan_history (user_id, created_at desc);

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

-- 4) Translation history and bookmarks
create table public.translation_history (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users(id) on delete cascade not null,
  source_text text not null,
  translated_text text not null,
  is_bookmarked boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
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
