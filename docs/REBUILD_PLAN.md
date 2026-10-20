# IGNITE rebuild plan

## Source of truth

1. Use the supplied `lib.zip` as the reference for existing Flutter/Dart UI, providers, models, and game screens.
2. Use `Ignite_optimized_vscode.html` as the reference for legacy modes, behaviors, content, and product flows.
3. Keep the repository Flutter-first; do not continue the old HTML/CSS/JavaScript implementation as runtime code.

## Legacy browser modes to audit

Kartu Talk, Ular Tangga, Truth or Dare, King & Slave, Roulette, Roleplay, and Chess & Command. A similar title is not proof of behavior parity; each mode must be audited before being marked complete.

## Supplied Flutter source inventory

The archive includes Home, Play, Memories, Bond, Profile, Truth or Dare, Snake & Ladder, This or That, Know Your Partner, Would You Rather, Story Continues, Two-Minute Challenge, Couple Charades, Dare Wheel, Gratitude Jar, Dream Planning, Couple Spa, Love Contract, and Guess Our Song screens, plus providers, models, data, theme, and reusable widgets.

## Phases

1. Clean baseline: Flutter metadata, app shell, theme tokens, analyzer, tests, CI.
2. Integrate supplied source: bring in screens/providers/models from `lib.zip`, resolve dependencies and imports, run static analysis.
3. Feature parity: compare legacy modes, custom content, settings, progress, and backup/restore behavior.
4. Design system: preserve Normal Mode (sweet elegant) and After Dark (deep elegant) across all screens.
5. Gameplay QA: test start, play, next, replay, exit, navigation, empty states, and persisted data.
6. Release readiness: responsive layouts, accessibility, persistence safety, CI green, and release notes.

## Acceptance criteria

- Supported Flutter target builds and launches.
- Normal Mode stays warm and elegant, not plain white.
- After Dark stays deep, intimate, and visually distinct.
- No legacy mode is marked complete without a behavior-level audit.
- Persistence handles first launch and missing/corrupt data safely.
- `flutter analyze` and `flutter test` pass before release.
