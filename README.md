# Issue #479: Follow after signup

Captured September 8, 2026 using Chromium and the local Firebase emulators at http://localhost:5000/space/frankly-local.

## What the evidence shows

These are controlled reproductions. Both videos delay Firebase auth-state notifications for non-anonymous users by five seconds. The banner on each capture identifies this condition. The first unmodified browser attempt succeeded, so these captures do not claim that every signup fails or that the delay occurs naturally for five seconds.

Before: Firebase creates the account, but the app still holds the anonymous user when signup returns. Email verification uses that stale user and the dialog shows an error. No community membership is created.

After: signup synchronizes the returned Firebase user before completing. The dialog closes, the Follow request completes, and the emulator confirms a community membership with status `member`. The Follow button disappears after the request completes.

The current code reproduces a signup error variant of the race; the original issue describes a silently skipped Follow action. Both involve application auth state lagging behind successful Firebase authentication. The automated tests also cover the guarded action and email login.

## Files

- before.png / after.png: final browser screenshots.
- before.webm / after.webm: original browser recordings, with no cuts or speed changes.
- index.html: side-by-side screenshots and video players. Open in Chrome or Edge.
- membership-results.json: read-only emulator verification for the accounts shown in the videos.
- delay-auth.js: exact local-only browser instrumentation. It delays notification delivery and adds the visible label; it does not change credentials, Firebase results, or membership writes.

## Reproduction

1. Start the local app and emulators. Use an anonymous browser session on the Frankly Local community.
2. After anonymous authentication initializes, evaluate delay-auth.js in that browser session.
3. Click Follow and create a fresh email account.
4. Wait at least five seconds and inspect the dialog and Follow button.
5. Inspect the account's memberships/{uid}/community-membership/{communityId} document in the local Firestore emulator.
6. Repeat with the fixed application and a new email account under the same delay.

Use this timing script only in the local development browser. Its hook is specific to the currently installed Firebase web SDK. It is documentation tooling, not part of the application change.

## Implementation and validation

Branch: fix/479-follow-after-signup, based on upstream staging.

UserService now uses UserCredential.user to synchronize application auth state before successful email signup/login returns. The auth-state listener continues profile initialization. No timeout or wait is added to guardSignedIn.

Browser regression suite: six tests pass after the fix. Before the fix, four assertions failed and two failure-path checks passed. Tests cover auth state and a guarded action before notification delivery, verification targeting the returned user, and unsuccessful authentication remaining signed out, for both signup and login.

Commands run from client/:

```sh
flutter test --platform chrome test/lib/features/user/data/services/user_service_email_auth_test.dart
flutter analyze lib/features/user/data/services/user_service.dart test/lib/features/user/data/services/user_service_email_auth_test.dart
```

Focused analysis: no issues. git diff --check: clean. The initial VM test attempt could not compile this web-dependent application; verification was performed on Chrome.
