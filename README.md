# Issue 537: moderator livestream creation

Screenshots show only synthetic fixtures in the local Frankly app and Firebase emulators. No real Mux stream or production event was created. No logs, account identifiers, credentials, or database dumps are included in this package.

## Reproduction and observed result

1. Sign into a local community as a moderator.
2. Open the synthetic “Issue 537 Livestream Template” and select Livestream (`before-selection.png`).
3. Create a public event for a future date and submit Create Event.
4. Before: the UI shows “Something went wrong” (`before-error.png`). Backend tests identify the underlying unauthorized rejection; the original rules also reject moderator stream-document writes.
5. After: the same moderator successfully creates the public livestream and reaches its event page (`after-event.png`). Local database verification confirmed the event type, visibility, moderator ownership, and private stream document. An authenticated client read confirmed stream instructions are accessible to the moderator.

## Scope of the after screenshot

The fixed Firebase callable and Firestore rules run normally. Because local setup has no working Mux credentials, only the external HTTPS provisioning response from Mux is replaced with synthetic stream IDs through a local Node preload stub. Authorization and Firestore requests are not intercepted. This verifies event creation and persistence; real Mux provisioning and playback are not tested. The stub is not application code and was removed from the running environment after evidence capture.

## Validation

- 10 callable tests pass: owner/admin/moderator success; facilitator/member/attendee/nonmember/banned/outsider/unauthenticated rejection before provisioning.
- 76 Firestore rules tests pass, including 24 new livestream cases covering atomic event + private stream creation, credential reads, cross-community rejection, and forbidden updates/deletes.
- Current `moderator` and legacy `mod` role names are covered. Existing rules fixtures now use the current role name.
- Baseline regression runs: 3 callable failures and 4 rules failures against the original implementation; all pass after the fix.
- Functions build passed; focused Dart analysis reported no issues.

Deploy both CreateLiveStream and the Firestore rules. Existing admin/owner access is retained. Lower roles remain unable to provision streams or access stream credentials.
