-- Add `version` and `enabled` to baybayin_models so the client app can:
--   * Force a redownload of the on-device YOLO model when `version` is bumped.
--   * Hide a model from the in-app selector by toggling `enabled` to false.
alter table public.baybayin_models
  add column version integer not null default 1,
  add column enabled boolean not null default true;

comment on column public.baybayin_models.version
  is 'Monotonic version of the published model assets. Clients re-download '
     'when this is greater than the locally cached version.';
comment on column public.baybayin_models.enabled
  is 'When false, the model is hidden from in-app selectors and cannot be '
     'chosen by users. Existing local copies are not deleted.';

-- Helpful filter for the common "list selectable models" query.
create index baybayin_models_enabled_sort_idx
  on public.baybayin_models (enabled, sort_order);
