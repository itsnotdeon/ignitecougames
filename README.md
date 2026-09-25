# IGNITE

IGNITE is a browser-based couple experience app built with vanilla HTML, CSS, and JavaScript.

## Current app

The production app lives in `redesign/` and is served through the root `index.html` redirect.

- `redesign/index.html` — application shell and boot sequence
- `redesign/scripts/` — application logic, journeys, features, minigames, and progression
- `redesign/styles/` — visual system and targeted style fixes
- `tests/e2e/` — Playwright end-to-end coverage
- `docs/` — product and release notes
- `.github/workflows/playwright.yml` — CI test workflow

## Development

```bash
npm install
npm run test:e2e
```

The application is currently **single-player/local-first**. Multiplayer infrastructure is intentionally not part of the current codebase.
