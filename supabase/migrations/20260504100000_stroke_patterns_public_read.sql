-- Allow any authenticated (or anonymous) user to read stroke patterns.
-- Stroke order data is not sensitive — it is used for lesson playback.
-- Admin-only INSERT/DELETE policies remain unchanged.

create policy "Stroke patterns are publicly readable."
  on public.stroke_patterns for select
  to anon, authenticated
  using (true);

-- Drop the old admin-only select policy (superseded above).
drop policy if exists "Admins can view all stroke patterns." on public.stroke_patterns;
