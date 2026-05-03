-- Add per-platform model links to baybayin_models.
-- android_model_link / ios_model_link are optional; when present they take
-- precedence over the generic model_link for the respective OS.
alter table public.baybayin_models
  add column android_model_link text,
  add column ios_model_link text;

comment on column public.baybayin_models.android_model_link
  is 'Android-specific download URL; falls back to model_link when null.';
comment on column public.baybayin_models.ios_model_link
  is 'iOS-specific download URL; falls back to model_link when null.';
