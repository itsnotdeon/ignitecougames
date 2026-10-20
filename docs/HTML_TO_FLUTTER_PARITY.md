# IGNITE HTML → Flutter Integration Matrix

**Priority rule:** `Ignite_optimized_vscode.html` is the source of truth for legacy game behavior and content. The supplied `lib.zip` is reused for supplementary app screens and reusable Flutter infrastructure. The existing GitHub Flutter baseline is retained only where it helps the unified product; it must not replace HTML behavior silently.

## Source inventory

- HTML source: `Ignite_optimized_vscode.html` (user-provided; primary behavior source).
- Flutter archive: `lib.zip` (user-provided; 39 Dart files in the archive, including screens/providers/models/theme/widgets).
- Existing GitHub tree before integration: generic Flutter shell with five tabs, placeholder Memories/Bond pages, and a basic Truth or Dare flow.

## Feature mapping and current status

| HTML capability | Flutter destination | Status in this integration |
|---|---|---|
| Player names and session start | `home/html_session_setup_screen.dart`, `CoupleProvider` | Partial: names persist and setup/ritual screen exists; not every legacy screen shares all session state yet |
| Opening ritual: Rock-Paper-Scissors | `home/html_session_setup_screen.dart` | Partial implementation |
| Opening ritual: guess a card color | `home/html_session_setup_screen.dart` | Simplified digital warm-up; not a full physical-card flow |
| Normal card prompts | `data/html_legacy_content.dart`, `play/kartu_talk_screen.dart` | Source prompts integrated |
| Explicit card categories and custom topics | `play/kartu_talk_screen.dart` | Custom topics persist locally; original HTML's full multi-category topic manager is not yet fully ported |
| Snake & Ladder, 100-cell board | `play/html_snake_ladder_screen.dart` | Partial behavior port: 100 cells, turns, dice, snakes/ladders, special prompts; original board layout/state edge cases need QA |
| Truth or Dare prompts | `data/truth_or_dare_data.dart` | HTML normal prompts merged with ZIP prompts; source HTML's full topic settings/import behavior not yet ported |
| King & Slave | `play/king_slave_screen.dart` | Partial: source command prompts and Power Card names integrated, consent gate and round switching; complete original power mechanics and all session counters remain to port |
| Russian Roulette Cinta | `play/roulette_screen.dart` | Partial: virtual bullet count, turn rotation, hit counts and reset; animation and all HTML overlays are not ported |
| Roleplay | `play/roleplay_screen.dart`, `data/html_legacy_content.dart` | Normal role and 13 source-derived context/challenge pairs integrated; custom scenario is currently screen-session state, explicit built-in roles are not yet ported |
| Chess & Command | `play/chess_command_screen.dart` | Partial prototype: board, selection, moves, undo/reset and command draw; full legal chess rules, check/checkmate, promotion, castling and en-passant are not implemented yet |
| HTML topic import/export (JSON, CSV, Excel, Word, PDF) | Not yet fully mapped | Outstanding; Flutter backup currently exports/restores SharedPreferences JSON, not the HTML's topic formats |
| HTML full-game save/load snapshot | Not yet fully mapped | Outstanding; current data backup is not backward-compatible with HTML snapshots |
| Custom content management for cards, Truth/Dare, King & Slave, Roleplay | Partially mapped | Kartu Talk custom topics exist; other content editors/importers still outstanding |
| Roulette rules and explicit-mode consent | Individual HTML-derived screens | Basic consent/rules notices exist; original mode gate/slider and navigation policy need parity work |
| Global timer presets/custom timer | Not yet ported from HTML | Outstanding |
| Original HTML localStorage migration | Not yet ported | Outstanding; browser localStorage data requires an explicit JSON migration/import strategy |

## Flutter screens reused from `lib.zip`

The existing archive screens/providers/models/theme/widgets are retained as supplementary app features: Home, Play, Memories, Bond, Profile; Truth or Dare, Snake & Ladder, This or That, Know Your Partner, Would You Rather, Story Continues, Two-Minute Challenge, Couple Charades, Dare Wheel, Gratitude Jar, Dream Planning, Couple Spa, Love Contract, Guess Our Song; and app/couple/bond/memories providers plus models and reusable UI components.

## Important integrity notes

- Do not label a mode complete until its behavior-level tests pass against the HTML source.
- The HTML's Roulette is a virtual Russian-roulette-style chance mechanic; it must never be implemented as a real firearm feature.
- Consent and skip actions must remain available in relationship/intimacy modes.
- The ZIP's 36-cell Snake & Ladder is retained as an extra app screen, while the HTML-derived 100-cell screen is separately accessible to avoid silently substituting one game's rules for the other.
- The current data-tools screen backs up Flutter SharedPreferences values. It does not parse the HTML `undi-topik-data-*` or save-game snapshot format.
- Flutter analysis, widget tests and platform builds must be run in a Flutter SDK environment before release. The audit environment used to prepare this migration did not have `flutter`/`dart` executables available.