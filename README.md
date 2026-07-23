# Twizzo

A color-matching orb-shooter prototype built in Godot 4.7. Aim and shoot colored
orbs into a descending cluster; match 3+ same-colored orbs to pop them; clear
the board before the cluster reaches the bottom.

See [`Twizzo_Game_Plan.md`](./Twizzo_Game_Plan.md) for the full design vision
(psychology principles, meta-progression, Play Store considerations, etc.).
This README tracks what's actually been built so far.

## Status: 5 levels, star rating, one power-up, a level-select map, and a daily streak

### Implemented
- **Aim & shoot** — mouse/touch aim clamped to an upward cone, with a live aim
  line and a launcher that shows the color of the loaded shot.
- **Hex-grid cluster** — orbs snap into an offset grid; flood-fill match
  detection pops groups of 3+; orbs cut off from the ceiling fall away.
- **Descending cluster** — the grid shifts down on a per-level timer for a
  fixed number of drops, then stops.
- **Rainbow orb power-up** — ~12% of shots (a hidden, flat-probability
  schedule) are a wildcard. On landing it's a universal wild: it pops
  *every* distinct-color neighbor group that would reach 3+ once it joins
  (not just the single largest — closer to genre convention, and it can
  chain a multi-color combo). A resting, unused wildcard always bridges into
  any future match that touches it, so it can never get permanently stuck
  as dead weight.
- **Daily streak** — consecutive calendar days played, with a 1-day grace
  (missing exactly one day doesn't reset it, shown as a dimmed flame icon;
  missing two or more resets it to 1). Shown on the level-select screen,
  persisted alongside star progress.
- **5 levels with a difficulty ramp**, each introducing at most one new
  difficulty dimension at a time:

  | Level | Rows | Colors | Drops | Interval | Endgame countdown | 3★ / 2★ time |
  |-------|------|--------|-------|----------|--------------------|--------------|
  | 1 | 2 | 3 | 2 | 7.0s | none — clear whenever | 50s / 80s |
  | 2 | 4 | 3 | 5 | 8.0s | none — clear whenever | 80s / 125s |
  | 3 | 4 | 3 | 5 | 7.0s | 26s | 35s / 50s |
  | 4 | 5 | 4 | 6 | 6.5s | 20s | 32s / 48s |
  | 5 | 5 | 5 | 7 | 6.0s | 15s | 30s / 45s |

  Levels 1-2 are confidence-builders (no fail state once drops end). From
  Level 3 on, a countdown starts once drops end — clear the board before it
  hits zero or it's a loss. Clearing the last level loops back to Level 1.
- **Star rating** — 1-3 stars based on total clear time (thresholds above).
  A live gauge (green → red) plus a paired star row sit just above the
  launcher throughout play, so the player can see in real time which rating
  they're currently tracking toward, not just find out at the end.
- **Level-select map** — the game's actual entry point: 5 nodes on a simple
  zigzag path, each showing the level number and best-ever star rating.
  Levels 2+ are locked (padlock icon, dimmed) until the previous level has
  been cleared at least once.
- **Save persistence** — best star ratings (and therefore unlock state) are
  written to `user://save.json` on every level clear and reloaded on launch.
- **Navigation** — a "< MAP" button is visible throughout every level (not
  just at the end) to bail back to the level-select screen at any time; the
  level-select screen has an "EXIT" button that quits the app.
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

### A real bug worth knowing about (fixed)
Godot `Control` nodes (labels, color rects used as panels) intercept clicks
via the engine's GUI input system by default, *before* `_unhandled_input`
ever sees them — which is what every custom button/input handler in this
project relies on. Every purely-visual `Control` across all three scenes now
has `mouse_filter = 2` (ignore) set explicitly. If a new tappable area is
added later and silently doesn't respond to input, check this first.

### Pending / open items
- **Level gating** is a simple "previous level cleared" rule for now — no
  star-threshold gating like the game plan's later-chapter concept (Section
  6.1) yet.
- Star-rating time thresholds are first-pass estimates, loosened generously
  after real playtesting on Levels 1-3; Levels 4-5 haven't been playtested
  against their thresholds yet.
- Not yet implemented (see game plan Section 6/9/10): friends leaderboard,
  shareable cards, chapter themes, Daily Challenge, Weekly Gauntlet,
  Endless/Survival mode (next planned feature), and all Play Store readiness
  items (odds disclosure — now actually relevant given the rainbow orb, Data
  Safety, Families Policy decision, monetization model, AAB packaging,
  offline verification).

## Project layout
```
main.tscn                Level scene: playfield, launcher, HUD, star/gauge, lose line
project.godot            Mobile renderer + portrait viewport config; level_select is the entry point
scripts/
  main.gd                Game loop: level setup, shooting, win/lose, HUD, star rating
  playfield.gd           Hex-grid logic: placement, matching (incl. wildcard bridging), gravity, descent
  launcher.gd            Aim input + loaded-orb/aim-line rendering (incl. wildcard preview)
  orb.gd                 Self-drawn circle orb (no image assets); wildcard pie-wheel rendering
  star_display.gd        Small drawn 3-star row (used live during play and as the win result)
  star_gauge.gd          Draining green→red bar showing time left in the current star tier
  text_button.gd         Reusable tap-target button (background chip + label)
  level_node.gd          One level-select map node: number, stars/lock state, tap-to-select
  level_select.gd        Level-select screen controller: unlock gating, navigation, exit
  streak_display.gd      Drawn flame icon + count for the daily streak
  game_state.gd          Autoload: level index, best stars, streak, save/load to user://save.json
scenes/
  orb.tscn, level_node.tscn, level_select.tscn, text_button.tscn, streak_display.tscn
Twizzo_Game_Plan.md      Original design document
```

## Running it
Open the project folder in Godot 4.7+ and press Play — it opens on the
level-select map. Aim with the mouse/touch, click/tap to shoot.
