# Android Rust Compatibility Analysis

Status: [OPEN]
Session: android-rust-compat

## Hypotheses

1. Android Rust targets or ABIs are incomplete, so native library loading fails on some devices.
2. Flutter Rust Bridge bindings, crate configuration, or initialization are inconsistent.
3. Android packaging omits native libraries or has incompatible NDK/SDK/build settings.
4. Dependencies and file/media APIs behave differently in Android release builds.
5. Media scanning or metadata parsing fails at runtime because of Android permissions or filesystem restrictions.

## Evidence

Pending repository and build inspection.

## Verification

Pending.
