# IGNITE Couple Games — Flutter + Dart

IGNITE is being rebuilt as a Flutter application. This clean baseline replaces the old browser app as the repository's current source tree.

## Visual direction

- **Normal Mode:** sweet elegant — warm rose, champagne, and blush tones. It should not look plain white.
- **After Dark:** deep elegant — wine, burgundy, violet, and obsidian tones.
- The two modes should feel related while keeping distinct visual personalities.

## Run locally

Install Flutter stable, then run:

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

## Current baseline

The first rebuild commit establishes the Flutter shell, five main destinations, a game catalogue seeded from IGNITE product references, a working theme toggle, a Truth or Dare prompt flow, and initial CI configuration. This is a foundation, not a claim that every legacy feature has been ported.

## Reference materials

- `Ignite_optimized_vscode.html`: legacy browser product reference.
- `lib.zip`: supplied Flutter/Dart screens and providers to review and integrate.
- `docs/REBUILD_PLAN.md`: migration checklist and acceptance criteria.
