# JamTheDev Review Notes

Date captured: 2026-04-23

## Summary

This document records the review comments from `@JamTheDev` so they are tracked outside the PR thread and can be used as a follow-up checklist.

## Comments

### 1. Architectural changes should be communicated

File: `lib/app/router/app_router.dart`

Comment summary:
- Architectural changes like introducing `GoRouter` should be communicated ahead of time.
- The expectation is to inform the team when making framework-level or navigation-level changes.

Action:
- Notify the team before making similar architectural changes in the future.
- Add this expectation to internal notes/process if needed.

### 2. Reusable app strings should live in constants

File: `lib/app/app.dart`

Current example:
- `title: 'Kudlit'`

Comment summary:
- Strings used throughout the app should be centralized in a `constants.dart` file instead of being scattered as hardcoded literals.
- This should be kept in mind for future work as a general convention.

Action:
- Move shared/repeated strings into a constants file when touching related areas.
- Follow the same pattern for future features.

### 3. Replace boolean return type with an enum for clarity

File: `lib/features/auth/data/datasources/supabase_auth_datasource.dart`

Current behavior:
- `signUpWithEmail(...)` returns `Future<bool>`
- The comment says:
  `true` means email confirmation is pending
  `false` means the account was auto-confirmed

Comment summary:
- A boolean is not descriptive enough for this result.
- An enum would make the signup outcome clearer and more maintainable.

Suggested direction:
- Replace the boolean with something like `SignUpResult` or `SignUpStatus`.
- Example cases:
  `confirmationPending`
  `autoConfirmed`

## Merge Conflicts To Resolve

JamTheDev also requested resolving the current merge conflicts in these files:

- `lib/main.dart`
- `linux/flutter/generated_plugin_registrant.cc`
- `linux/flutter/generated_plugins.cmake`
- `macos/Flutter/GeneratedPluginRegistrant.swift`
- `pubspec.lock`
- `pubspec.yaml`
- `test/widget_test.dart`
- `windows/flutter/generated_plugin_registrant.cc`
- `windows/flutter/generated_plugins.cmake`

## Follow-up Checklist

- Communicate architectural changes before landing them.
- Introduce or use a shared `constants.dart` file for app-wide strings.
- Refactor signup result from `bool` to an enum.
- Resolve the listed merge conflicts before merge.
