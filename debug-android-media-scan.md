# Android media scan debugging

Status: [OPEN]
Session: android-media-scan

## Symptoms

- Android build succeeds.
- Android runtime does not discover videos, music, or images in the target directories.

## Hypotheses

- H1: Android storage or media runtime permission is missing or denied.
- H2: Desktop-specific default directory paths do not exist on Android.
- H3: Scoped storage prevents recursive access to the selected or public media directory.
- H4: The scanner relies on dart:io recursion without Android media-store adaptation.
- H5: Android paths or file extensions fail the scanner's filtering rules.

## Evidence

No runtime evidence collected yet.

## Changes

No business logic changes. Instrumentation is pending.
