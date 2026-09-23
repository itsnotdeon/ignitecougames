# IGNITE Phase 7 — Feature Expansion

## Scope
Phase 7 adds continuity and personalization without changing the core Journey mental model.

### 7.1 Couple Memories
- Saves completed Journey moments locally.
- Optional note.
- Optional image up to 1 MB, stored as a local data URL.
- Home summary and Memories view.

### 7.2 Couple Streak
- Counts consecutive calendar days containing at least one saved memory.
- Does not depend on number of games played.

### 7.3 Couple Preferences
- Vibes: Romantic, Playful, Deep, Competitive, Spontaneous, Intimate.
- Duration: short / medium / long.
- Intensity: gentle / balanced / bold.
- Preferences are local and feed Journey generation.

### 7.4 Dynamic Journey Engine
- Uses level, preferences, and recent memories.
- Produces a Journey selection context instead of a static random choice.
- Keeps the existing Journey content architecture.

### 7.5 Unlockable Content
- Level-based unlock registry.
- Current unlocks are surfaced in Profile.
- Unlocks are descriptive first so existing Journey access is not broken.

### 7.6 Surprise Mode 2.0
- Uses the Dynamic Journey Engine.
- Considers saved vibe, duration, intensity, level, and recent Journey history.
- Keeps the user out of the selection loop.

## Code organization
- scripts/features/memories.js
- scripts/features/preferences.js
- scripts/features/dynamicJourney.js
- scripts/features/unlocks.js
- scripts/features/surprise.js
- scripts/features/ui.js
- scripts/ui/accessibility.js

The old standalone phase6.js was removed. Accessibility behavior now belongs to scripts/ui/accessibility.js and is initialized by app.js.

## QA policy
Phase 7 development is intentionally completed before the Playwright pass. After the feature set is frozen, run the full existing E2E suite once, then fix failures in a focused QA pass.
