# CopyCat Mascot Bible v1.0

## Purpose

The mascot exists to make waiting feel reassuring. It never distracts
from the user's work.

## Character

Name: CopyCat (working name) Species: Domestic short-haired cat Style:
Premium flat illustration with subtle depth Target: macOS desktop users

## Personality

-   Curious
-   Calm
-   Observant
-   Helpful
-   Quiet
-   Never sarcastic
-   Never childish

## Emotional Rules

The mascot reflects system state, never invents emotion.

  Engine State        Mascot
  ------------------- -------------------------------------------
  Idle                Sitting and looking at the folder
  Preparing scan      Standing up
  Scanning            Walking slowly
  Hash verification   Inspecting a file with a magnifying glass
  Duplicate found     Small smile, points at duplicate
  Review              Sitting beside results
  Cleanup running     Carrying files to a recycle box
  Complete            Proud pose with tail raised
  Error               Concerned expression, not panicking

## Design Rules

-   Head approximately 42% of body height.
-   Large expressive eyes.
-   No clothing.
-   No accessories except optional magnifying glass during search.
-   Rounded silhouette.
-   Tail always visible.
-   Never anthropomorphic.

## Color Direction

Primary fur: warm light grey. Accent: soft orange ears. Eye colour:
emerald green. No saturated colours.

## Animation Principles

-   200--350 ms micro animations.
-   Walk cycle 8 frames.
-   Blink every 4--8 seconds.
-   Tail motion should be subtle.
-   Reduced Motion mode replaces movement with pose changes.

## Pose Inventory

Required: 1. Idle 2. Stand 3. Walk 1 4. Walk 2 5. Walk 3 6. Search 7.
Found 8. Thinking 9. Celebrate 10. Cleanup 11. Error 12. Sleep

## Asset Naming

mascot_idle.svg mascot_walk_01.svg mascot_walk_02.svg mascot_walk_03.svg
mascot_search.svg mascot_found.svg mascot_review.svg mascot_cleanup.svg
mascot_complete.svg mascot_error.svg

## Cursor Implementation Notes

-   Treat mascot as a reusable SwiftUI component.
-   State driven by scan engine events.
-   Use enum MascotState.
-   No business logic inside the view.
-   Support Light/Dark Mode.
-   Respect Reduce Motion accessibility setting.
