# IGNITE — Guided Journey

The `redesign/` directory contains the active IGNITE application.

## Structure

- `index.html` — app shell and boot sequence
- `scripts/app.js` — application state and navigation
- `scripts/journey/` — journey content, mechanics, and rituals
- `scripts/features/` — memories, preferences, adaptive behavior, and UI helpers
- `scripts/minigames/` — Chess, Snake, King & Slave, and roleplay
- `scripts/data/` — content data
- `scripts/ui/` — accessibility and UI helpers
- `styles/` — core styles and focused visual fix layers

## Product areas

1. Home — relationship dashboard and current context
2. Play — guided journey and direct minigames
3. Bond — relationship-focused activities
4. Memories — saved moments and milestones
5. Profile / Settings — identity and configuration

The current architecture is intentionally **single-player/local-first**. Multiplayer is not part of this build.
