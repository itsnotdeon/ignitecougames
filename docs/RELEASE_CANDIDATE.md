# IGNITE Release Candidate — Verification Gate

Branch: redesign/guided-journey

## Automated gate
- Phase 1–5 Journey/Minigame/Progression/Settings regression suite.
- Phase 6 mobile overflow regression.
- Active Journey reload persistence regression.
- Couple profile mobile submission regression.
- Reduced-motion regression.
- Chromium desktop project.
- Pixel 5 mobile project.
- Playwright trace/screenshots retained on failure.
- Playwright report uploaded by CI when a run fails.

## Manual gate
- Verify Home, Journey Intro, Normal, After Dark, Completion, Minigames and Settings visually on a real phone.
- Verify typography, spacing, safe-area behavior and sticky Journey controls.
- Verify backup/export/import and reset flows manually before production release.
- Verify After Dark consent language and exit behavior.

## Release rule
Do not call this production-ready until the automated CI run is green and the manual mobile smoke test is complete.
