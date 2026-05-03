# Kudlit System Audit & Next Steps

Based on the recent PRs and audit documents, here is an overview of missing features and how to improve them properly to ensure the system works as intended.

## 1. Phone & Google Authentication
**Status:** Placeholder UI exists, but domain/data layers and real Supabase integration are incomplete or untested.
**Improvements:**
- Enable SMS Auth in `supabase/config.toml` (`enable_signup = true` under `[auth.sms]`).
- Complete the domain logic (`AuthRepository` needs `signInWithPhoneOtpStart`, `verifyPhoneOtp`, `signInWithGoogle`).
- Wire the UI to the Riverpod `AuthNotifier` so that the Login Screen correctly redirects upon successful OAuth or OTP verification without route hacks.

## 2. Profile Management
**Status:** First-wave features (Edit Name, Privacy Controls, Accessibility) are integrated with Supabase via `ProfileManagementRepository`.
**Improvements (Next Wave):**
- **Linked Sign-in Methods:** Allow users to link Phone/Google to existing accounts.
- **Session Activity:** Display active devices and add revocation capabilities.
- **Learning Progress Dashboard:** Currently read-only. Needs a reliable progress persistence model in the backend before enabling writes or resets.
- **Account Deletion:** Implement the backend token/session invalidation guarantees before removing the placeholder for this critical feature.

## 3. Scanner & Translator Native Capabilities
**Status:** YOLOv12 and Gemma 4 are planned for offline-first capabilities.
**Improvements:**
- Implement platform-specific ML model loading handling. Use the `android_model_link` and `ios_model_link` schema additions robustly.
- Ensure the Gallery picker (YOLO detection on selected images) handles large images efficiently without blocking the main thread.
- Establish the local persistence layer for Scanner History and Translator Bookmarks.

## 4. Technical Debt & Cleanup
**Status:** `build_runner` is broken; some merge conflicts exist.
**Improvements:**
- Manually write `.g.dart` files or standard boilerplate until `build_runner` is fixed.
- Centralize app strings into `lib/app/constants.dart` (as requested by JamTheDev).
- Refactor boolean return types in auth to explicit enums (e.g., `SignUpStatus.confirmationPending`).

## Next Steps
1. **Fix Backend Config:** Update `config.toml` to enable SMS and MFA.
2. **Complete Auth Wiring:** Finish the `PhoneSignInScreen` and Google Auth integration.
3. **Address Review Notes:** Extract constants and change bools to enums in the Auth data layer.
4. **Deploy Next-Wave Profile Features:** Begin work on Linked Sign-in Methods and Account Deletion backend logic.
