# IGNITE Couple Games — unified Flutter rebuild

IGNITE is being unified as a Flutter + Dart app. **The user-provided `Ignite_optimized_vscode.html` is the primary source of truth for legacy behavior and content.** The supplied `lib.zip` is integrated as the source for supplementary screens, state providers, models, reusable widgets, and design foundations. The prior GitHub Flutter shell is retained only where it helps the unified app; it must not silently replace original HTML mechanics.

## Design direction

- **Normal Mode:** sweet, warm, elegant; blush, rose, and champagne. It must not become a plain white interface.
- **After Dark:** deep, intimate, elegant; wine, burgundy, violet, and obsidian.
- Consent and the ability to skip a prompt remain available in relationship/intimacy modes.

## Included product areas

### HTML-derived core modes

- Kartu Talk with HTML-sourced normal prompt content and persistent custom prompts.
- Ular Tangga Cinta with a separate HTML-derived 100-cell board implementation.
- Truth or Dare with prompts from both the HTML and the supplied Flutter archive.
- King & Slave with HTML-derived Command Card content, Power Card names, and a consent gate.
- Russian Roulette Cinta as a virtual-only chance game.
- Roleplay with HTML-derived normal role contexts and challenges.
- Chess & Command with an interactive board prototype and command-card interaction.
- Player-name/session setup and opening ritual screen.
- Data & Backup screen for Flutter SharedPreferences JSON.

### Screens reused from `lib.zip`

Home, Play, Memories, Bond, Profile, Truth or Dare, Snake & Ladder, This or That, Know Your Partner, Would You Rather, Story Continues, Two-Minute Challenge, Couple Charades, Dare Wheel, Gratitude Jar, Dream Planning, Couple Spa, Love Contract, and Guess Our Song, plus the supplied providers, models, theme, and reusable widgets.

## Run locally

Install Flutter stable, then run:

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

## Migration truthfulness

This is an integration milestone, **not yet a claim of full feature parity**. Full HTML topic-category management, all import formats, legacy localStorage migration, complete save/load snapshot compatibility, the global timer, complete King & Slave Power Card mechanics, and full legal chess rules still need implementation and QA. See [`docs/HTML_TO_FLUTTER_PARITY.md`](docs/HTML_TO_FLUTTER_PARITY.md) and [`docs/REBUILD_PLAN.md`](docs/REBUILD_PLAN.md).