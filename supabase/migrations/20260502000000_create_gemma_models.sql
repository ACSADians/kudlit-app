-- Gemma models catalog — distinct from baybayin_models (YOLO/scanner).
-- Only name and download link needed for on-device Gemma inference.
create table public.gemma_models (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  model_link text not null,
  created_at timestamptz default now() not null
);

-- Enable Row Level Security
alter table public.gemma_models enable row level security;

-- Anyone (including anonymous) can read models
create policy "Gemma models are publicly readable."
  on public.gemma_models for select
  using (true);
