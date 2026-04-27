-- Create baybayin_models table for storing AI model metadata
create table public.baybayin_models (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  model_link text not null,
  sort_order integer not null default 0,
  description text,
  created_at timestamptz default now() not null,
  updated_at timestamptz default now() not null
);

-- Index for ordered listing
create index baybayin_models_sort_order_idx on public.baybayin_models (sort_order);

-- Auto-update updated_at on row change
create or replace function public.handle_updated_at()
returns trigger
language plpgsql
security definer set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger baybayin_models_updated_at
  before update on public.baybayin_models
  for each row execute procedure public.handle_updated_at();

-- Enable Row Level Security
alter table public.baybayin_models enable row level security;

-- Anyone (including anonymous) can read models
create policy "Models are publicly readable."
  on public.baybayin_models for select
  using (true);
