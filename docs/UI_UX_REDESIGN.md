# IGNITE UI/UX redesign

## Direction

**Reimagine IGNITE** with a Premium Romantic visual language and balanced visual/functional priorities. This is a progressive implementation: shared design foundations first, followed by screen-by-screen interaction and responsive QA.

## Visual worlds

- **Normal Mode:** warm petal pink, rose, mauve, and champagne. Surfaces use warm blush tints rather than plain white.
- **After Dark:** obsidian plum, wine, velvet, and luminous rose. This is a distinct palette, not simply a darkened Normal Mode.
- **Typography:** editorial Playfair Display for prominent headings and Poppins for readable interface copy.
- **Shapes:** rounded surfaces with controlled borders, restrained depth, and generous breathing room.
- **Interaction:** clear primary action, visible selection, consistent control sizes, readable helper text, and floating feedback.

## Implemented in this pass

- Semantic palette tokens in `lib/theme/app_colors.dart`.
- Shared component themes for text, buttons, inputs, cards, chips, progress indicators, dialogs, snackbars, and bottom sheets in `lib/theme/app_theme.dart`.
- Refined reusable `CustomCard` depth and motion.
- Rebuilt bottom navigation with safe-area support, consistent selected states, and Indonesian labels.
- Reimagined Home with a responsive editorial welcome panel, clear primary session action, relationship progress, daily connection prompt, and quick game launch.
- Improved game-library hierarchy and card treatment.
- Localized Memories and Bond page headings and normalized spacing in Profile.

## Non-negotiable behavior

- Preserve the HTML as the source of truth for core game mechanics and legacy content.
- Preserve Normal and After Dark as distinct themes.
- Keep all existing game entry points and session setup actions.
- Do not represent compilation success as proof of full feature parity.

## Implemented in the latest game-screen pass

- `KartuTalkScreen`: responsive card layout, warm romantic gradients, custom-topic actions retained, and HTML's initially empty explicit-content behavior preserved.
- `HtmlSnakeLadderScreen`: retained the 100-cell HTML board and game movement, improved board surfaces and responsive maximum width.
- `IgniteRouletteScreen`: replaced literal weapon-like iconography with a virtual chance-game presentation, clearer score/turn hierarchy, and consent-first start.
- `KingSlaveScreen`: refreshed command/power card presentation and retained consent gating for actions.
- `IgniteRoleplayScreen`: editorial scenario card, explicit-mode consent gate, custom scenario dialog, and explicit content remains empty until users add it.
- `ChessCommandScreen`: responsive board, selected-square state, consent gate, and undo now restores the previous side to move. It is still a simplified board interaction and does not validate official chess move rules.
- `TruthOrDareScreen`: fallback selection now respects the current theme, so Normal Mode cannot fall back into After Dark cards when a category/type filter is empty; completion avoids nested state updates.

## Next implementation stages

1. Complete the remaining interaction polish for Truth or Dare and other supplementary game screens.
2. Audit HTML parity for the session setup, import/export, topic categories, and persistence rather than assuming visual parity means behavioral parity.
3. Check responsive layout, long Indonesian strings, keyboard/safe-area behavior, and accessibility.
4. Verify Flutter analyze/tests on the newest commit and manually test key flows in browser and Android.
