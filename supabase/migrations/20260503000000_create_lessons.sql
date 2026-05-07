-- Lessons catalog with inline steps stored as JSONB.
--
-- Schema mirrors the existing asset JSON structure so the same
-- LessonModel.fromJson / LessonStepModel.fromJson parsers work unchanged.
--
-- lessons          — one row per lesson (id, title, subtitle, metadata)
-- lesson_steps     — one row per step, ordered by sort_order
--
-- Steps are stored relationally so individual steps can be updated
-- without replacing the whole lesson document.

-- ─── lessons ─────────────────────────────────────────────────────────────────

create table public.lessons (
  id           text primary key,           -- e.g. 'vowels-01'
  title        text not null,
  subtitle     text not null default '',
  sort_order   int  not null default 0,    -- controls lesson list ordering
  published    bool not null default false, -- only published lessons appear in app
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);

comment on table public.lessons is
  'Baybayin learning lessons. Each lesson contains an ordered list of steps.';

-- ─── lesson_steps ─────────────────────────────────────────────────────────────

create table public.lesson_steps (
  id               text not null,          -- e.g. 'ref-a'
  lesson_id        text not null references public.lessons (id) on delete cascade,
  sort_order       int  not null default 0,
  mode             text not null check (mode in ('reference', 'draw', 'freeInput')),
  label            text not null default '',
  glyph            text not null,
  -- Optional Storage URL for a custom glyph image. When present, the app
  -- renders the image instead of the font character.
  glyph_image      text,
  intro            text,
  prompt           text,
  narration        text,
  hint             text,
  success_feedback text,
  butty_tip        text,
  -- Array of accepted romanised answers (case-insensitive comparison in app).
  expected         text[] not null default '{}',
  hide_glyph       bool not null default false,
  primary key (lesson_id, id)
);

comment on table public.lesson_steps is
  'Ordered steps within a lesson. sort_order ASC determines playback order.';

-- Keep updated_at current automatically
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger lessons_set_updated_at
  before update on public.lessons
  for each row execute function public.set_updated_at();

-- ─── RLS ──────────────────────────────────────────────────────────────────────

alter table public.lessons      enable row level security;
alter table public.lesson_steps enable row level security;

-- Any authenticated (or anon) user can read published lessons.
create policy "Published lessons are publicly readable."
  on public.lessons for select
  using (published = true);

create policy "Steps of published lessons are publicly readable."
  on public.lesson_steps for select
  using (
    exists (
      select 1 from public.lessons l
      where l.id = lesson_steps.lesson_id
        and l.published = true
    )
  );

-- ─── Grants ──────────────────────────────────────────────────────────────────

grant select on public.lessons      to anon, authenticated;
grant select on public.lesson_steps to anon, authenticated;

-- ─── Seed: vowels-01 ─────────────────────────────────────────────────────────

insert into public.lessons (id, title, subtitle, sort_order, published)
values ('vowels-01', 'Baybayin Vowels', 'Three vowels, three shapes.', 1, true);

insert into public.lesson_steps
  (id, lesson_id, sort_order, mode, label, glyph, intro, narration, butty_tip,
   prompt, expected, hint, success_feedback)
values
  ('ref-a', 'vowels-01', 1, 'reference', 'A', 'a',
   'Let''s start with the vowel A.',
   'Notice the curve — the tail lifts from the bottom-right. Take your time and study the shape before you draw.',
   'When you''re ready, tap Got it to continue.',
   null, '{}', null, null),

  ('draw-a', 'vowels-01', 2, 'draw', 'A', 'a',
   null, null, null,
   'Draw the vowel A.',
   array['a'], 'Match the reference glyph above.', 'Tama! Your curve is clean.'),

  ('spell-a', 'vowels-01', 3, 'freeInput', '', 'a',
   null, null, null,
   'Type the romanization of this glyph.',
   array['a'], null, 'Correct. A is the foundation of Baybayin.'),

  ('ref-ei', 'vowels-01', 4, 'reference', 'E / I', 'e',
   'E and I share one glyph in Baybayin.',
   'It''s a mirrored curve — the same base as A, opposite direction.',
   'Two vowels, one shape. That''s vowel pairing.',
   null, '{}', null, null),

  ('draw-ei', 'vowels-01', 5, 'draw', 'E / I', 'e',
   null, null, null,
   'Draw the E / I glyph.',
   array['e', 'i'], null, 'Good. The mirrored curve is right.'),

  ('ref-ou', 'vowels-01', 6, 'reference', 'O / U', 'o',
   'O and U also share a glyph — a clean circle.',
   'Close the circle with a single, deliberate stroke.',
   'A clean close is the mark of a solid O / U.',
   null, '{}', null, null),

  ('spell-ou', 'vowels-01', 7, 'freeInput', 'O / U', 'o',
   null, null, null,
   'Type either romanization for this glyph.',
   array['o', 'u'], null, 'Tama! Either answer works — it''s vowel pairing.');
