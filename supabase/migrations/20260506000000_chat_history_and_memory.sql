-- Butty chat: cloud sync for raw history + long-term semantic memory.
--
-- Adds two tables aligned with the offline-first pattern already used by
-- scan_history and translation_history:
--   * chat_messages       — episodic raw turns (one row per user/Butty msg)
--   * chat_memory_facts   — semantic distilled facts about the user, used
--                           to seed Butty's system prompt across sessions

-- ─── 1) chat_messages — raw conversation log ─────────────────────────────────

create table public.chat_messages (
  id          uuid default gen_random_uuid() primary key,
  user_id     uuid references auth.users(id) on delete cascade not null,
  content     text not null default '',
  is_user     boolean not null,
  image_url   text,
  created_at  timestamptz not null default now()
);

create index chat_messages_user_created_idx
  on public.chat_messages (user_id, created_at desc);

alter table public.chat_messages enable row level security;

create policy "Users can view their own chat messages."
  on public.chat_messages for select
  to authenticated
  using (auth.uid() = user_id);

create policy "Users can insert their own chat messages."
  on public.chat_messages for insert
  to authenticated
  with check (auth.uid() = user_id);

create policy "Users can delete their own chat messages."
  on public.chat_messages for delete
  to authenticated
  using (auth.uid() = user_id);

-- ─── 2) chat_memory_facts — distilled long-term context ──────────────────────
-- Populated by the on-device memory extraction pass that runs every N turns
-- and on app pause. fact_type is a free-form tag (preference, topic,
-- personal, skill, …) that lets us shape future prompt sections.

create table public.chat_memory_facts (
  id                  uuid default gen_random_uuid() primary key,
  user_id             uuid references auth.users(id) on delete cascade not null,
  fact_type           text not null default 'general',
  content             text not null,
  source_message_id   uuid references public.chat_messages(id) on delete set null,
  created_at          timestamptz not null default now(),
  last_referenced_at  timestamptz not null default now()
);

create index chat_memory_facts_user_created_idx
  on public.chat_memory_facts (user_id, created_at desc);

create unique index chat_memory_facts_user_content_unique
  on public.chat_memory_facts (user_id, lower(content));

alter table public.chat_memory_facts enable row level security;

create policy "Users can view their own chat memory facts."
  on public.chat_memory_facts for select
  to authenticated
  using (auth.uid() = user_id);

create policy "Users can insert their own chat memory facts."
  on public.chat_memory_facts for insert
  to authenticated
  with check (auth.uid() = user_id);

create policy "Users can update their own chat memory facts."
  on public.chat_memory_facts for update
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "Users can delete their own chat memory facts."
  on public.chat_memory_facts for delete
  to authenticated
  using (auth.uid() = user_id);
