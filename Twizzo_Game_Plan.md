# Twizzo — Game Design Plan
*(working name — checked against Play Store search; no existing game titled Twizzo found as of this check. Backup alternates: Zibbi, Pokka — verify availability before use)*

## 1. Concept Summary

**Genre:** Level-based color-matching shooter (Candy Crush + Tetris + bubble shooter lineage)

**Elevator pitch:** Aim and shoot colored orbs into a descending cluster. Match 3+ same-colored orbs to pop them. Clear each level's goal before the cluster reaches the bottom. One mechanic, instantly readable, no language or reading required.

**Positioning:** A "pocket break" game — designed to be picked up for 2–5 minutes (commute, queue, bathroom, waiting for coffee) and to leave the player wanting to come back, not to demand long sessions.

**Name rationale:** "Twizzo" is two easy syllables, phonetically simple in almost every language, and hints at the twisting/aiming action central to gameplay. Same naming logic as Candy Crush (describes the action) and Tetris (short, brandable, easy to say globally). Unlike "Poppo" or "Bloop," it doesn't collide with existing Play Store titles as of this check.

---

## 2. Session Design: Built for 2–5 Minutes

This isn't just a design constraint — it's the core hook. The game is built so a "quick break" naturally turns into 2-3 replays.

| Design choice | Why it works for short sessions |
|---|---|
| Levels last 20–45 seconds | Fits multiple attempts inside a 2–5 min window |
| Zero loading between retries | No friction between "I lost" and "I'll try again" |
| No forced tutorial | Player is playing within 3 seconds of opening the app |
| Session naturally ends on a high | Last level of a session is tuned to end in a near-win or a win, not a hard loss (see Section 3.5) |

---

## 3. Psychology Principles — Applied Systematically

### 3.1 Instant Gratification
- First orb can be shot within 2–3 seconds of app open — no menus, no walls.
- Every match gives immediate visual + audio payoff (satisfying pop, small screen shake, color burst).
- Feedback is faster than thought — the brain never waits for a reward.

### 3.2 Variable Ratio Reinforcement (the strongest hook in behavioral psychology)
- Power-up orbs (bomb, rainbow) appear on a *hidden* semi-random schedule — same principle as slot machines and loot boxes.
- Occasional "jackpot" levels award bonus stars or a rare cosmetic — unpredictable, so anticipation stays high every session.
- Reward sizes vary (small pop → chain reaction → mega clear) so no two sessions feel identical.

### 3.3 Near-Miss Effect
- Levels are tuned so failed attempts often end 1–2 orbs short of the goal ("almost had it").
- This is a deliberate, well-documented hook — near-misses drive replay far more than clean losses or clean wins.
- Use carefully and sparingly (see Section 7 — ethical guardrails) so it motivates rather than frustrates.

### 3.4 Micro-Progress & Visible Momentum
- In-level progress bar fills with every match.
- Level map (Candy Crush-style path) visually fills in after every session — progress is never invisible.
- Daily streak counter, visible on open, with a small flame/counter icon.

### 3.5 Loss Aversion & Streaks
- Daily streak is the single strongest retention lever: missing a day breaks a visible number the player has invested in.
- Soft-landing design: a missed day dims the streak but doesn't zero it out immediately (1-day "grace") — keeps loss aversion working without feeling punishing enough to make people quit entirely.
- Session end-point is tuned to land on a win/near-win (see 3.3) so the player's *last* memory of the session is positive — increasing the pull to return.

### 3.6 Low-Stakes Retry / Zero Failure Cost
- No lives system, no timers that lock you out, no ads forced on failure.
- Retry is one tap, instant. Removing all friction between "losing" and "trying again" is what turns a 2-minute break into a 5-minute one.

### 3.7 Social Proof & Comparison
- Optional, lightweight leaderboard (friends only, not global by default) — comparison motivates without becoming overwhelming.
- Star count and level number are shareable in one tap (a screenshot-ready summary card).

### 3.8 Autonomy Within Guardrails
- Player chooses aim and shot timing — meaningful control — but color layout, descent speed, and power-up timing are all system-tuned.
- This balance (real choice + curated challenge) is what makes the game feel skill-based rather than purely random, which matters for long-term trust and retention.

### 3.9 Curiosity Gap
- Level map shows silhouettes of upcoming level themes/rewards without revealing them — curiosity about "what's next" pulls players one level further than they planned.
- Occasional mystery reward chest that opens after N stars collected.

### 3.10 Comfort & Low Cognitive Load
- One core mechanic throughout — no reading, no complex menus.
- Palette and sound designed to feel calming rather than stimulating, so the game works as a *break* — not something that raises stress.

---

## 4. Level Structure

| Element | Design |
|---|---|
| Level goal | One clear visible target per level (e.g. "Clear 30 orbs," "Clear all yellow orbs") |
| Difficulty curve | Levels 1–10: slow descent, 3 colors. 11–20: faster descent, 4–5 colors, armored orbs (2 hits) |
| Star rating | 1–3 stars based on speed/efficiency — replay incentive without forcing it |
| Power-ups | Bomb orb, rainbow orb — scheduled-but-hidden appearance (Section 3.2) |
| Level map | Visible, finite, winding path — shows progress and upcoming silhouettes |
| Retry | Instant, free, unlimited |

---

## 5. Progression & Meta Layer (Phase 2)

- Chapter/world breaks every 10–15 levels with new visual theme + new light mechanic
- Daily streak with soft-landing grace period (Section 3.5)
- Friends-only leaderboard
- Shareable summary cards for social proof loop

---

## 6. Long-Term Progression for Advanced Players

The base 20-level curve (Section 4) only covers onboarding. Without a plan past that, skilled players hit a ceiling and churn — the exact opposite of what a habit-forming break app needs. This section defines what keeps a player engaged at month 3, month 6, and beyond.

### 6.1 Chaptered Difficulty Tiers
- Content is released in **chapters of 15–20 levels**, each raising the ceiling: more colors, faster descent, new obstacle types (armored orbs, moving blockers, shrinking play field).
- Chapters are gated lightly (e.g. reach 2 stars on 80% of the previous chapter) so pacing stays smooth without hard walls.
- New chapters keep the "curiosity gap" mechanic alive (Section 3.9) — there's always a next visible destination on the level map.

### 6.2 Mastery Layer (for players who've cleared available levels)
- **Star re-runs:** any completed level can be replayed for a 3rd star or a better time — turns "finished" content into ongoing skill practice rather than a dead end.
- **Daily Challenge:** one curated hard level per day, same for all players, with a leaderboard reset every 24 hours. This is the single best lever for advanced-player retention — it's always fresh, always comparable, and costs almost no extra content to produce.
- **Weekly Gauntlet:** a short run of 5 escalating levels with no retries, for players who want a harder, higher-stakes mode without changing the core game's low-stakes casual identity.

### 6.3 Endless/Survival Mode
- Unlocked after finishing the base chapters — descent speed increases indefinitely, no fixed goal, just "how far can you go."
- Personal best + friend leaderboard for this mode specifically.
- Serves the advanced-player need for a skill ceiling that isn't authored level-by-level (cheap to build, effectively infinite replay value).

### 6.4 Skill-Based Meta-Progression (not pay-to-win)
- Cosmetic unlocks (orb skins, launcher styles, pop effects) tied to star milestones and Daily Challenge streaks — status signals for advanced players, no gameplay advantage.
- Optional "mastery badge" per chapter (e.g. 3-starring every level) — a completionist goal layered on top of raw progression.

### 6.5 Difficulty Auto-Tuning
- Track individual player win rate and average completion time; if an advanced player is consistently clearing levels fast, subtly increase descent speed or color count within their *next* chapter's normal bounds.
- Keeps skilled players inside their flow-state zone rather than letting the fixed curve feel too easy — without making it feel unfair, since adjustments stay within the level's designed range.

### 6.6 Why This Matters for Retention
Casual/short-session players are captured by Sections 3.1–3.10 (instant rewards, streaks, near-misses). But those players plateau in skill quickly. Without 6.1–6.5, the game's *best* players — the ones most likely to keep it in their daily rotation for months — run out of reasons to open it. Daily Challenge and Endless Mode in particular are low-cost, high-retention additions that should be prioritized early, even if chapter content beyond the first 2–3 rolls out slower.

---

## 7. Visual & Audio Direction

- Bright but soft palette — energetic, not garish or anxiety-inducing
- Satisfying, tactile pop sound; subtle haptic feedback on mobile
- Minimal text, icon-driven UI — playable without reading a single word

---

## 8. Ethical Guardrails (Recommended)

Hooking mechanics work — but a break app that leaves people feeling drained or manipulated will lose trust and churn hard. A few guardrails worth building in from day one:

- **No pay-to-skip failure walls** — monetize cosmetics/themes, not frustration.
- **Cap near-miss frequency** — near-misses should feel motivating, not designed to bait rage-replays. A ceiling (e.g. no more than 1 in 4 losses is a "near miss") keeps this honest.
- **Gentle streak loss, not punishing** — a broken streak shouldn't feel catastrophic enough to make someone quit the app entirely.
- **Natural session end cues** — after ~5 minutes or 3 consecutive plays, a subtle, non-guilt "nice run!" screen rather than infinite auto-continue, so the app respects that it's meant to be a *break*, not a sink.

---

## 9. Prototype Scope (v0.1)

1. Launcher + orb cluster grid, match-3 popping + gravity logic
2. 5 hand-built levels, increasing descent speed/colors
3. Star rating + instant retry
4. Simple level-select map
5. One variable-reward power-up (to test Section 3.2 in practice)

**Not in v0.1:** streaks, leaderboards, chapter themes, shareable cards — these are Phase 2, added once the core loop's replay pull is validated.

---

## 10. Google Play Store Considerations

Building for Play Store adds real constraints on top of the design — some are policy requirements, not optional choices.

### 10.1 Disclosure Requirement for Randomized Rewards
- Google Play **requires disclosed odds** for any randomized virtual item mechanic (power-up drops, mystery chests, loot-box-style rewards) under its Play Console policies for "the Ability to Purchase or Otherwise Obtain Randomized Virtual Items."
- This directly affects **Section 3.2 (Variable Ratio Reinforcement)** and **Section 6.4 (mystery chests)** — the underlying probability schedule can stay hidden from a *feel* standpoint, but if any randomized item can be earned via purchase, the odds must be published (typically in-app, near the point of purchase, or in store listing).
- Action: keep a written odds table for every randomized reward from day one, even before publishing — needed for the Play Console declaration form regardless of whether items are purchasable or purely earned.

### 10.2 Data Safety & Privacy
- Play Console requires a completed **Data Safety section** disclosing what data is collected (analytics, ad IDs, crash logs) and whether it's shared with third parties.
- If Section 6 leaderboards/friends features use any account or contact data, that must be disclosed and (for EU/UK users) covered under GDPR consent flows.
- Recommendation: keep telemetry minimal at launch (session length, level completion, retention) — easier compliance, and it's the data that actually matters for tuning Section 6.5 (auto-tuning) and the near-miss/streak systems.

### 10.3 Age Rating & Families Policy
- Content itself (colorful matching game, no violence) will likely qualify for a low IARC rating (Everyone/PEGI 3).
- However, if monetization uses variable rewards + ads aimed broadly, Google scrutinizes whether the app might appeal to children — if so, **Play Families Policy** applies: no behavioral ads to children, stricter limits on notifications/streak-pressure mechanics targeting kids specifically.
- Recommendation: decide target audience explicitly (general audience vs. not-for-kids) before implementing Section 3.5 (streak loss aversion) and push notifications — the aggressive-hook mechanics need lighter treatment if under-13 users are a realistic chunk of the audience.

### 10.4 Monetization Model
- Two realistic paths for this game type on Play Store:
  - **Rewarded ads** (opt-in, e.g. watch an ad for one extra move/retry) — low-friction, matches the low-stakes philosophy in Section 3.6.
  - **Play Billing for cosmetics** (orb skins, launcher styles from Section 6.4) — no pay-to-win, keeps monetization separate from the fairness of the core loop.
- Avoid interstitial ads on every retry — directly conflicts with Section 3.6 (zero-friction retry) and Section 8 guardrails; would undercut the "always one more try" hook by adding real friction.
- All monetization must go through **Google Play Billing** for any digital purchase — third-party payment cannot be used for in-app digital goods.

### 10.5 Technical Requirements
- Target the current required **API level** (Play Console enforces a minimum target SDK annually — check current requirement at submission time, as it updates yearly).
- 64-bit support is mandatory.
- Ship as an **Android App Bundle (.aab)**, not a raw APK.
- **App size matters more here than usual**: since this is positioned as a "quick break" app (Section 2), install friction directly works against the use case — a bloated download people abandon before the first install defeats the whole "instant gratification" premise. Target a lean initial download (defer chapter art/assets via Play Asset Delivery if the game grows past ~2-3 chapters).

### 10.6 Offline Support
- Given the target use case (commute, queue, waiting rooms — Section 2), **reliable offline play is a functional requirement, not a nice-to-have**. Poor connectivity in exactly these moments would break the core "instant" promise.
- Design: core level content and progress should work fully offline; only leaderboards, Daily Challenge sync, and rewarded ads need connectivity, and those should degrade gracefully (e.g. "Daily Challenge will sync when you're back online") rather than blocking play.

### 10.7 Store Listing / ASO
- Short, phonetic name (Twizzo) is an advantage for **Play Store search and global discoverability** — same logic as the naming rationale in Section 1.
- Icon and first 2 screenshots should show the core pop/match action directly — Play Store listings are judged in the first second, similar to Section 3.1's instant-gratification principle applied to acquisition, not just gameplay.
- Consider a short (15–30s) preview video showing one full level start-to-finish — reduces uncertainty for a user deciding whether to install a "quick break" app.

---

## 11. Next Steps

- [ ] Build playable prototype (HTML/JS) per v0.1 scope
- [ ] Playtest specifically for "one more try" pull and session length (target: 3–5 min average)
- [ ] Tune near-miss frequency and descent curve based on playtest data
- [ ] Validate streak/social mechanics before Phase 2 build
- [ ] Prioritize Daily Challenge + Endless Mode (Section 6.2, 6.3) early — cheapest, highest-leverage retention tools for advanced players
- [ ] Decide target audience (general vs. not-for-kids) before finalizing streak/notification aggressiveness — affects Families Policy compliance (Section 10.3)
- [ ] Draft odds-disclosure table for all randomized rewards before implementing them (Section 10.1)
- [ ] Confirm offline-first architecture for core gameplay before building sync-dependent features (Section 10.6)
