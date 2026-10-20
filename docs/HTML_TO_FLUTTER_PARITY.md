# IGNITE HTML → Flutter Integration Matrix

**Priority rule:** `Ignite_optimized_vscode.html` is the source of truth for legacy game behavior and content. The supplied `lib.zip` is reused for supplementary app screens and reusable Flutter infrastructure. Existing GitHub features are retained where they add value, but must not silently replace HTML behavior.

## Source inventory

- Primary source: user-provided `Ignite_optimized_vscode.html` (380 KB).
- Supplementary source: user-provided `lib.zip` (Flutter screens, providers, models, theme, and widgets).
- GitHub repository: `itsnotdeon/ignitecougames`.
- HTML's original main menu: Mulai, Muat Game, Pengaturan, Tentang, Keluar.
- HTML's game selection: Kartu Talk/Kartu Biasa, Ular Tangga Cinta, Truth or Dare, King & Slave, Russian Roulette Cinta, Roleplay, Chess & Command, plus a “coming soon” tile.
- HTML supports Mode Biasa and Mode Eksplisit. The HTML's initial explicit-topic categories are intentionally empty until the user adds/imports content; do not fill them with ordinary prompts without permission.

## Feature mapping and current status

| HTML capability | Flutter destination | Status |
|---|---|---|
| Player names and session start | `home/html_session_setup_screen.dart`, `CoupleProvider` | Partial: names persist and setup is available; all legacy screens do not yet share a unified session controller |
| Opening ritual: Rock-Paper-Scissors | `home/html_session_setup_screen.dart` | Implemented five-round flow with alternating hidden choices; verify end-to-end in browser/device QA |
| Opening ritual: guess a card color | `home/html_session_setup_screen.dart` | Implemented five-round alternating digital warm-up; verify end-to-end in browser/device QA |
| Normal card prompts | `data/html_legacy_content.dart`, `play/kartu_talk_screen.dart` | HTML `NORMAL_NEW_TOPICS.cards` included; imported HTML topic snapshots override the normal card pool when available |
| Explicit card categories and custom topics | `play/kartu_talk_screen.dart` | Partial: local custom topics exist; full three-category manager and category-level CRUD/import are outstanding |
| Snake & Ladder, 100-cell board | `play/html_snake_ladder_screen.dart` | Partial: board, turns, dice, snakes/ladders, special prompts; edge cases and visual parity still need QA |
| Truth or Dare | `data/truth_or_dare_data.dart`, `play/truth_or_dare_screen.dart` | HTML normal prompts are merged with ZIP content; HTML category editing and import/export are outstanding |
| King & Slave | `play/king_slave_screen.dart` | Partial: HTML command prompts/Power Card names, consent gate and round switching; full power mechanics and counters need parity work |
| Russian Roulette Cinta | `play/roulette_screen.dart` | Partial: virtual chance mechanic, turn rotation, hit counts and reset; animation/overlays/rules flow need parity QA |
| Roleplay | `play/roleplay_screen.dart`, `data/html_legacy_content.dart` | Partial: source-derived context/challenge content; built-in role library, separate normal/explicit role lists and persistent custom scenarios remain |
| Chess & Command | `play/chess_command_screen.dart` | Prototype: board, selection, moves, undo/reset and command draw; legal chess rules (check/checkmate, promotion, castling, en-passant) are not implemented |
| Mode switch and explicit-mode consent | Individual HTML-derived screens | Basic notices/consent exist; HTML's complete navigation gate and settings behavior need parity work |
| Topic settings and custom content | `screens/profile/data_tools_screen.dart` and game screens | Partial: imported normal card topics are used by Kartu Talk, imported Truth/Dare topics are added to its draw pool, and custom Kartu Talk prompts remain separate; full category editor, edit/delete per topic, and explicit-category CRUD remain outstanding |
| Import/export topics (JSON) | `screens/profile/data_tools_screen.dart` | Partial: imports HTML `ignite-couple-game-topics-export` and `ignite-couple-game-save` snapshots, validates shape, stores original structured snapshot, and exports the topic snapshot via clipboard; file picker/download and all-category editing remain outstanding |
| Per-category import (Excel, Word, PDF, JSON; CSV for Roleplay) and template download | Not yet mapped | Outstanding |
| Save/load complete game snapshot | `screens/profile/data_tools_screen.dart` | Partial: imports and preserves HTML `ignite-couple-game-save` JSON snapshot and can copy it back out; active session state is not yet fully restored into Flutter game controllers |
| Global timer presets/custom timer | Not yet mapped | Outstanding |
| Original HTML localStorage migration | Not yet mapped | Outstanding; browser data requires a deliberate export/import strategy |

## Flutter features retained from `lib.zip`

Home, Play, Memories, Bond, Profile; Truth or Dare, Snake & Ladder (ZIP's separate board), This or That, Know Your Partner, Would You Rather, Story Continues, Two-Minute Challenge, Couple Charades, Dare Wheel, Gratitude Jar, Dream Planning, Couple Spa, Love Contract, Guess Our Song; plus providers, models, theme, and reusable UI components.

## Integrity and safety notes

- Keep the HTML-derived 100-cell Snake & Ladder separate from the ZIP's 36-cell board; they are different experiences.
- The HTML's Roulette is a virtual chance mechanic, not a real firearm feature.
- Consent and skip actions must remain available in relationship/intimacy modes.
- Do not mark a mode complete until behavior-level tests pass against the HTML.
- Flutter analysis and widget tests passed in GitHub Actions for commit `c924c30a946c77760d56ac14c4aa954f667110a1`. The five-round ritual update is a later commit and must pass its own CI run before it is treated as verified. A green CI confirms static analysis and the current test suite only; it does not establish full feature parity or a release-ready platform build.
