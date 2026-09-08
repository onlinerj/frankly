# Issue 443: Word-cloud export evidence

Captured against the local Frankly app and Firebase emulators using synthetic data.

## Reproduction

1. Create an event with two word-cloud prompts, “What matters?” and “Next steps?”.
2. Store Trust and 世界 🌍 for the first prompt and Listening for the second, all from one participant.
3. Open Community Admin → Event Data → download data for “Issue 443 - Word Cloud Export”.
4. Before: Polls & Suggestions Data reports None and the export is unavailable despite the stored word-cloud responses (`before-admin.png`).
5. After: Polls, Suggestions & Word Clouds reports 3 Items; select it and download (`after-admin.png`).
6. The actual downloaded `prompt-responses-wordcloud-443.csv` contains one Wordcloud row per response, the correct prompts and participant, Main room, and zero upvotes. Unicode survives UTF-8 decoding; the file starts with a UTF-8 BOM.

`api-after.json` is the actual local GetMeetingWordCloudData callable response. The screenshot and download fixture intentionally uses legacy responses without metadata, so Time is blank. New submission timestamps and prompt metadata are covered by the storage and backend tests. No Excel, external calendar, or production environment is depicted.

## Validation

- Six backend emulator tests: admin and event-creator access; rejection of ordinary members, outsiders, and unauthenticated callers; malformed paths; main/breakout responses, multiple entries, saved/legacy prompts and timestamps, and cross-event isolation.
- Two browser CSV tests: word-cloud-only and mixed exports, Unicode, quoting/newlines, formula sanitization, room names, and UTF-8 BOM.
- One browser Firestore-emulator storage test: metadata persistence, concurrent duplicate submission, multiple entries, and removal.
- All nine targeted tests passed. Functions build passed. Focused backend analysis is clean; client analysis reports only two pre-existing avoid_print warnings.

## Compatibility

Existing string responses remain readable and exportable. Legacy timestamps cannot be reconstructed and are left blank; legacy prompt text falls back to the current agenda. New entries retain their submission prompt and time. Upvotes default to zero because word clouds currently have no voting mechanism. Existing duplicate suppression, explicit removal, and agenda reset behavior are preserved. Ending an event does not delete the stored responses.
