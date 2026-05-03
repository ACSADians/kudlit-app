-- Separate LLM models (offline chatbot via flutter_gemma / MediaPipe) from
-- vision models (OCR/camera via YOLO TFLite / mlpackage).
--
-- All existing rows default to 'llm'. After running this migration, update
-- any vision model rows (e.g. KudVis-1-Turbo) manually:
--   UPDATE public.baybayin_models SET model_type = 'vision' WHERE name ILIKE '%kudvis%';
alter table public.baybayin_models
  add column model_type text not null default 'llm'
  constraint baybayin_models_model_type_check
    check (model_type in ('llm', 'vision'));

comment on column public.baybayin_models.model_type
  is '"llm": offline chatbot via flutter_gemma / MediaPipe LlmInference; '
     '"vision": YOLO OCR detection model (TFLite on Android, mlpackage on iOS).';

create index baybayin_models_type_sort_idx
  on public.baybayin_models (model_type, enabled, sort_order);
