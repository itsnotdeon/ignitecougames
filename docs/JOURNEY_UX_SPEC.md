# IGNITE — Journey UX Specification v0.1

> This document turns the locked Product Direction into concrete UX decisions for the first playable redesign.
> Status: Working specification. Implementation may refine details after testing, but the core mental model should remain stable.

## 1. Product Job

IGNITE helps two people spend time together.

The first screen must answer one question:

> What kind of time do we want to spend together?

It must not present a catalogue of games.

## 2. Primary Navigation

The redesign uses three top-level destinations:

1. Journey — the default/home experience.
2. Minigames — direct access to individual games.
3. Settings — preferences, content/data management, and administration.

Journey owns the emotional/product experience. Minigames owns direct play. Settings owns management.

## 3. Journey Home

### Header
- IGNITE wordmark.
- Couple identity/name.
- Compact access to Settings.
- No large navigation bar competing with the hero.

### Hero
Primary message:

> Let's spend some time together.

Supporting message should communicate that IGNITE will guide the session without forcing it.

### Primary actions

If no active session:
- Start Normal
- Start After Dark

If an active session exists:
- Continue Journey — primary
- Start a new Journey — secondary

### Secondary action
A quiet Direct Play entry opens Minigames.

Settings is accessible but visually secondary.

### Important rule
Normal and After Dark are presented as experiences, not as game modes.

Normal copy direction:
- romantic
- playful
- warm

After Dark copy direction:
- intimate
- daring
- tasteful
- 18+ / consent-aware

## 4. Journey Start

Selecting a Journey does not immediately launch a card.

Show a short preparation screen:

- Journey name
- one-sentence mood description
- couple names
- approximate session shape: "A few moments together"
- Begin Journey
- Back

After Dark also shows the existing consent gate before content begins.

No tutorial carousel.

## 5. Journey Session

The session is a single continuous experience.

Conceptual state:

OPENING RITUAL
↓
ACTIVITY
↓
TRANSITION RITUAL
↓
ACTIVITY
↓
ACTIVITY / RITUAL
↓
CLOSING

The exact activity count can vary. The MVP target is around three meaningful activities and two or three rituals.

### Session chrome

Keep chrome minimal:
- small IGNITE mark
- couple identity when useful
- subtle progress indicator
- Exit control

Do not show a dense game HUD, XP bar, timer, or multiple competing controls by default.

### Activity screen

Each activity should feel like a moment, not a menu.

Primary action:
- Continue / Done

Secondary:
- Skip

The user should never need to return to Journey Home between activities.

## 6. Ritual UX

Rituals are transition moments, not a destination.

They should be visually lighter and shorter than main activities.

### Opening Ritual
Purpose: create readiness and shared attention.

Examples:
- Guess Color
- Rock Paper Scissors
- short shared question

### Transition Ritual
Purpose: reset the energy between activities.

Examples:
- quick challenge
- Guess Color
- Rock Paper Scissors
- one-line reflection

### Closing Ritual
Purpose: create emotional closure.

Examples:
- short reflection
- one final question
- simple shared action

Do not create a separate Ritual menu.

## 7. Continue / Skip / Exit

### Continue
Moves to the next planned moment.

### Skip
Skips the current activity and moves forward without penalty.

Skip should be quiet and non-judgmental.

### Exit
Ends the active session and saves enough state to offer Continue later.

If the user exits mid-session, do not treat it as a failure.

## 8. Journey Completion

Completion should feel calm and intimate.

Core message:

> Journey Complete ❤️

Supporting direction:

> That was your time.

Actions:
- Back to Journey
- Start another Journey

Do not introduce achievements, streaks, rewards, or XP celebration yet.

## 9. Normal Journey v0.1

Recommended first sequence:

1. Opening Ritual — quick shared challenge
2. Normal Card — talk/connection
3. Transition Ritual — playful reset
4. Truth or Dare — challenge/talk
5. Normal Card — second connection moment
6. Closing Ritual

This is a default sequence, not a rigid contract. Skip/continue must remain available.

## 10. After Dark Journey v0.1

Recommended first sequence:

1. Opening Ritual
2. Explicit Card
3. Transition Ritual
4. Intimate Truth or Dare
5. Roleplay
6. Closing Ritual

Existing consent, 18+, and stop-anytime mechanisms remain part of the flow.

Content remains intimate and tasteful rather than graphic.

## 11. Couple Identity

Before the first Journey, capture:

- Player 1 name
- Player 2 name
- optional couple name

During the Journey, use names contextually.

Do not repeatedly display a large profile card.

## 12. Persistence

Persist:
- couple identity
- active Journey type
- current step
- skipped/completed steps as needed
- session timestamp
- lightweight app preferences

Persistence should support Continue Journey, not become a visible feature.

## 13. Minigames Boundary

Minigames are always reachable without starting a Journey.

MVP:
- Roleplay
- King & Slave
- Chess
- Snake & Ladder

A Journey may later recommend a Minigame, but it should not require one for the core MVP.

## 14. Visual Hierarchy

The Journey Home should have one dominant decision.

Priority:

1. Continue Journey, if available
2. Start Normal / After Dark
3. Minigames
4. Settings

Avoid equal-sized cards for every feature.

The visual system should feel:
- intimate
- premium
- calm
- romantic
- modern

Use the legacy palette and editorial typography as DNA, but reduce dashboard-like borders and control density.

## 15. MVP Acceptance Test

A first-time couple should be able to:

1. Open IGNITE.
2. Understand the purpose without a tutorial.
3. Enter a Journey.
4. Know what to do next.
5. Continue without returning to a menu.
6. Skip something without feeling punished.
7. Exit and later continue.
8. Finish with a clear sense of completion.
9. Open Minigames directly when they want a specific game.

If these work, the Journey Foundation is doing its job.

## 16. Deliberately Not Solving Yet

Do not design these in this iteration:
- detailed XP economy
- Level progression
- achievements
- streaks
- advanced Couple Profile
- large content authoring system
- complex branching narrative
- recommendation engine
- social/account system

The purpose of v0.1 is to prove the shared Journey experience.
