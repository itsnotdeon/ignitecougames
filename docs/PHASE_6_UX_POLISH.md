# IGNITE Phase 6 — UX/Product Polish

## Goal
Turn the completed Journey + Minigames + Settings foundation into a more coherent, mobile-first release candidate without expanding the product scope.

## Completed
- Mobile-first spacing and safe-area handling.
- Minimum touch targets for primary controls.
- Sticky Journey actions on small screens.
- Reduced-motion support.
- Stronger visible focus states.
- Progress bars expose accessible progress semantics.
- Revealed card content exposes live-region semantics.
- Escape key provides a lightweight back affordance when appropriate.
- Active Journey survives a browser reload.
- Mobile overflow regression coverage.
- Couple form submission regression coverage.
- Phase 6 CSS/interaction layer kept separate from the legacy monolith.

## Product guardrails
- Journey remains the primary couple experience.
- Minigames remain directly accessible.
- Rituals stay embedded inside Journey.
- Progression stays secondary to the experience.
- No new feature category is introduced in Phase 6.

## Release gate
Phase 6 is complete when the Phase 1–5 E2E suite plus Phase 6 regression suite pass on the redesign/guided-journey branch.

## Next
After the release gate passes, move to Release Candidate verification: production build/deployment, final smoke test, and real-device visual review.

