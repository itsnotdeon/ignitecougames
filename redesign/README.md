# IGNITE Redesign — Guided Journey

This branch starts the UX redesign without destroying the legacy build.

## Architecture
- redesign/index.html — app shell
- redesign/styles/app.css — visual system
- redesign/scripts/app.js — Journey state and interactions
- 0.0.1.html — legacy/reference build

## Product structure
1. Home — relationship dashboard and current IGNITE context
2. Play — Tonight's Journey + direct games and challenges
3. Bond — relationship-focused activities (planned)
4. Memories — saved moments and milestones
5. Profile / Settings — couple identity and configuration

Journey is intentionally part of Play: it is the adaptive experience layer that orchestrates multiple activities, while Quick Play provides direct access to individual games.
