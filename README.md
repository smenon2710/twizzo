# Twizzo

A color-matching orb-shooter prototype built in Godot 4.7. Aim and shoot colored
orbs into a descending cluster; match 3+ same-colored orbs to pop them; clear
the board before the cluster reaches the bottom.

See [`Twizzo_Game_Plan.md`](./Twizzo_Game_Plan.md) for the full design vision
(psychology principles, meta-progression, Play Store considerations, etc.).
This README tracks what's actually been built so far.

## Status: core loop + first 5 levels playable

### Implemented
- **Aim & shoot** — mouse/touch aim clamped to an upward cone, with a live aim
  line and a launcher that shows the color of the loaded shot.
- **Hex-grid cluster** — orbs snap into an offset grid; flood-fill match
  detection pops groups of 3+; orbs cut off from the ceiling fall away.
- **Descending cluster** — the grid shifts down on a per-level timer for a
  fixed number of drops, then stops.
- **5 levels with a difficulty ramp**, each introducing at most one new
  difficulty dimension at a time:

  | Level | Rows | Colors | Drops | Interval | Endgame countdown |
  |-------|------|--------|-------|----------|--------------------|
  | 1 | 2 | 3 | 2 | 7.0s | none — clear whenever |
  | 2 | 4 | 3 | 5 | 8.0s | none — clear whenever |
  | 3 | 4 | 3 | 5 | 7.0s | 26s |
  | 4 | 5 | 4 | 6 | 6.5s | 20s |
  | 5 | 5 | 5 | 7 | 6.0s | 15s |

  Levels 1-2 are confidence-builders (no fail state once drops end). From
  Level 3 on, a countdown starts once drops end — clear the board before it
  hits zero or it's a loss. Clearing the last level loops back to Level 1.
- **HUD** — a prominent level number, with a live "Drops left: N" /
  "Clear it! Ns left" / "Clear the board to win!" status line beneath it, and
  a red line marking the lose boundary.
- **Instant retry** — tap/click after a win or loss reloads the level
  immediately (win advances to the next level; loss retries the same one).
- **Visual identity** — vivid saturated palette (red/blue/green/yellow/purple)
  with a flat "cartoon-sticker" render style (thick dark outline, flat fill,
  single clean gloss dot) instead of a glossy 3D-sphere look. Chosen over an
  earlier muted "ceramic bead" direction, which tested as too dull for a
  kid/young-audience target — see Section 10.3 of the game plan on audience
  and Families Policy considerations.
- Configured for mobile: Forward Mobile renderer, 720×1280 portrait lock.

### Not yet implemented (see game plan Section 9 / 6)
- Star rating
- Level-select map
- Power-ups (bomb / rainbow orbs)
- Streaks, leaderboards, shareable cards
- Chapter themes / meta-progression (Daily Challenge, Endless Mode)
- Play Store integration items (Section 10: odds disclosure, Data Safety, etc.)

## Project layout
```
main.tscn              Root scene: playfield, launcher, HUD, lose line
project.godot           Mobile renderer + portrait viewport config
scripts/
  main.gd               Game loop: level setup, shooting, win/lose, HUD
  playfield.gd           Hex-grid logic: placement, matching, gravity, descent
  launcher.gd            Aim input + loaded-orb/aim-line rendering
  orb.gd                 Self-drawn circle orb (no image assets)
  game_state.gd          Autoload: carries the current level index across
                          scene reloads
scenes/orb.tscn          Orb scene
Twizzo_Game_Plan.md      Original design document
```

## Running it
Open the project folder in Godot 4.7+ and press Play. Aim with the
mouse/touch, click/tap to shoot.
