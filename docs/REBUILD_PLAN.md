# IGNITE rebuild plan

## Source of truth

1. The supplied `lib.zip` is the initial Flutter/Dart implementation.
2. `Ignite_optimized_vscode.html` is a reference for the existing product's modes, behavior, and content; it is not included as the app runtime.
3. The repository's current code should remain Flutter-first.

## Existing Flutter screens in the supplied source

- Home, Play, Memories, Bond, Profile
- Truth or Dare
- Snake & Ladder
- This or That
- Know Your Partner
- Would You Rather
- Story Continues
- Two-Minute Challenge
- Couple Charades
- Dare Wheel
- Gratitude Jar
- Dream Planning
- Couple Spa
- Love Contract
- Guess Our Song

## Legacy browser modes to audit against the Flutter app

The earlier HTML app documented these modes: Kartu Talk, Ular Tangga, Truth or Dare, King & Slave, Roulette, Roleplay, and Chess & Command. The Flutter source has a Snake & Ladder screen and a Truth or Dare screen, but a name match alone does not prove complete behavior parity. Kartu Talk, King & Slave, Roulette, Roleplay, and Chess & Command require explicit product decisions and implementation or documented replacement before parity can be claimed.

## Phases

1. **Baseline and build health:** establish Flutter project metadata, dependencies, analyzer, tests, and CI.
2. **Compile and stabilize:** run `flutter pub get`, `flutter analyze`, and `flutter test`; fix errors and lifecycle/persistence problems.
3. **Feature parity audit:** compare each legacy mode, settings, custom content, progress, and import/export behavior with the Flutter implementation.
4. **Design-system pass:** unify theme tokens and components while preserving Normal Mode (sweet elegant) and After Dark (deep elegant).
5. **Gameplay QA:** test each game flow, reset/replay behavior, navigation, empty states, and saved data.
6. **Release readiness:** device-size checks, accessibility, persistence migration, CI green, and documented release steps.

## Acceptance criteria

- App builds and launches on a supported Flutter target.
- Normal Mode remains warm, romantic, and elegant rather than plain white.
- After Dark remains deep, intimate, and visually distinct.
- No legacy mode is marked complete without a behavior-level audit.
- State persistence handles first launch, corrupted/missing values, and restart safely.
- `flutter analyze` and `flutter test` pass in CI before release.