# Supabase Phone + Google Auth Implementation Plan (Kudlit)

## Problem
Kudlit currently has working email/password auth (sign in, sign up, reset), but:
- Phone auth UI is placeholder-only (`TODO` for send OTP and verify OTP).
- Google auth button exists but is not implemented.
- Account creation paths are inconsistent (email has dedicated sign-up flow; phone/google do not yet have a defined product flow).

## Current State (from codebase analysis)
- **Data/domain implemented only for email auth**
  - `AuthRepository` supports only email sign-in/sign-up/reset/sign-out.
  - `SupabaseAuthDatasource` supports only email sign-in/sign-up/reset/sign-out.
- **Presentation**
  - `LoginScreen` has actions for phone/email/google.
  - Google currently shows a snack bar: “coming soon”.
  - `PhoneSignInScreen` and `PhoneOtpScreen` are UI-only with simulated delays and TODO markers.
  - `SignUpScreen` currently supports email/password only.
- **Routing/auth state**
  - `AuthNotifier` is stream-driven from Supabase auth state and already works for session-based redirects.
  - Router redirect logic is in place for authenticated vs unauthenticated states.
- **Config**
  - Supabase is initialized from `.env` (`SUPABASE_URL`, `SUPABASE_ANON_KEY`).
  - A mobile deep-link scheme already exists for password reset (`kudlit://auth/reset`), but OAuth callback plumbing is not yet defined.

## Approach
Implement phone OTP and Google OAuth as first-class auth methods across dashboard config, clean architecture layers, and UI flows. Keep auth state centralized in `AuthNotifier` so GoRouter redirects continue to work without route hacks.

## Todos
1. **Define product behavior for account creation paths** ✅
   - **Confirmed:** phone and Google stay on the Login entry points (not duplicated on the Create Account screen).
   - First successful phone/Google auth implicitly creates the account when needed, then proceeds through normal authenticated routing.

2. **Supabase Auth provider setup**
   - Enable **Phone** and **Google** providers in Supabase project auth settings.
   - Configure OTP settings (expiry, retry/rate constraints) and allowed redirect URLs.
   - Configure mobile/web callback URLs for OAuth and verify they map to app routing/deep-link behavior.

3. **Extend domain contracts**
   - Update `AuthRepository` to include:
     - `signInWithPhoneOtpStart(phoneNumber)`
     - `verifyPhoneOtp(phoneNumber, token)`
     - `signInWithGoogle()`
   - Add/adjust domain entities/value objects if needed for OTP phase states.

4. **Implement datasource + repository for new methods**
   - In `SupabaseAuthDatasourceImpl`, add Supabase auth calls:
     - phone OTP send
     - phone OTP verify
     - Google OAuth sign-in
   - Map `AuthException` errors to existing `Failure` types (and add focused failures if necessary).
   - Preserve stream-based auth state semantics.

5. **Add use cases + providers + notifier methods**
   - Add use cases for phone OTP start/verify and Google sign-in.
   - Register providers in `auth_provider.dart`.
   - Add notifier actions in `auth_notifier.dart` and ensure they produce consistent loading/error states.

6. **Wire presentation flows**
   - **LoginScreen**: replace Google placeholder with real notifier action.
   - **PhoneSignInScreen**: send OTP through notifier and navigate only on success.
   - **PhoneOtpScreen**: verify OTP through notifier and handle invalid/expired code UX.
   - **SignUpScreen**: keep email-only and add/adjust copy if needed so alternative methods are clearly discoverable from Login.

7. **Platform callback/deep-link integration**
   - Configure platform files for OAuth callback handling as required by `supabase_flutter` for Android/iOS/Web.
   - Ensure callback returns into app and auth stream update redirects to home.

8. **Error handling + messaging + limits**
   - Add user-facing messages for OTP invalid/expired, rate-limited sends, provider cancellation, and OAuth failures.
   - Keep failure-to-message mapping centralized and consistent with existing auth constants.

9. **Testing and hardening**
   - Add domain/use-case tests for phone and Google auth flows.
   - Add repository/datasource tests for error mapping.
   - Add presentation tests for phone and Google CTA behavior (at least notifier + screen interaction coverage).

10. **Validation and branch rollout**
   - Run analyze + tests after implementation.
   - Land on a dedicated branch and verify manual happy paths:
     - phone sign-in (new + returning)
     - Google sign-in (new + returning)
     - email sign-up/sign-in regression

## Notes / Guardrails
- Reuse existing clean architecture boundaries; do not place Supabase SDK logic in presentation.
- Keep domain pure Dart (no Flutter imports).
- Keep `AuthNotifier` as the single orchestrator for auth state transitions.
- Avoid silent auth failures; surface mapped errors to UI.
- Confirm final implementation details against current Supabase docs before coding.
