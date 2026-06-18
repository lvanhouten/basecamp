# basecamp — Design System

**basecamp** is a mobile app: an all-in-one *home base* for tracking the things in your
life. From a single calm dashboard you drop into focused **modules** — today there are
**Lists**, **Workouts**, and a **Clock** (Timer, Stopwatch, Alarms) — and the home screen
stitches them into one "here's your day" glance.

This repository is the brand + product design system: design tokens, reusable React UI
primitives, foundation specimens, and a high-fidelity interactive recreation of the app.

> **Origin & sources.** This system was designed from scratch for the basecamp brief —
> there was no prior codebase, Figma file, or brand kit to import. The visual direction
> (bold & playful — coral primary, sunshine-yellow joy accent, deep-navy ink, with a
> friendly **tent** logo mark) was chosen for an energetic, encouraging product feel. If a
> real basecamp codebase or Figma exists, link it here so future work can be reconciled
> against it.

---

## The brand in one breath
Warm, energetic, encouraging. basecamp makes tracking feel light. It speaks plainly,
celebrates small wins, and never nags \u2014 bright and upbeat, but never noisy. Think the
friendliness of a good trail buddy.

---

## Content fundamentals

**Voice — a calm, encouraging guide.** Plain, warm, never hype. We help you make progress
and get out of the way.

- **Person.** Address the user as **you**; the app refers to itself rarely and never as "I".
  Headers are often possessive or contextual: "Today's plan", "Your week", "Up next".
- **Casing.** **Sentence case everywhere** — buttons, headers, labels, nav. Never Title
  Case, never ALL CAPS in prose. (Small uppercase *eyebrow* labels with letter-spacing are
  a visual device — e.g. `MODULES`, `UP NEXT` — not sentence content.)
- **Brand name.** Lowercase **basecamp** in running text and the wordmark. Capitalize
  **Basecamp** only at the start of a sentence.
- **Tone.** Encouraging, not pushy. "Nice pace — 2 things left", "On track", "Time's up".
  Avoid exclamation overload, avoid guilt ("You missed…"). A missed item is a neutral fact.
- **Verbs.** Direct and short on actions: "Start day", "Add item", "Mark complete",
  "Start rest timer". Lead buttons with a verb.
- **Numbers.** Tabular and honest: "3 of 8 done", "5-day streak", "320 kg", "24 min".
  Use real units. Time is `mm:ss` (timer) or `h:mm AM` (alarms).
- **Emoji.** **No emoji** in product UI or brand copy. Meaning is carried by Lucide icons,
  the module accent colors, and type — never emoji.
- **Length.** Microcopy is tight. List subtitles are a phrase, not a sentence. Empty states
  are one calm line ("Nothing here yet.").

**Examples**
- Greeting: *"Good morning, Riley"* · eyebrow *"Tuesday · Jun 16"*
- Encouragement: *"Nice pace — 2 things left"*, badge *"On track"*
- Empty: *"Nothing here yet."*
- CTA: *"Start day"*, *"Add an item…"* (placeholder), *"Start rest timer · 1:30"*

---

## Visual foundations

**Palette.** Bold & playful, anchored on **coral** (`--brand` `#FF5A3C`) with a
**sunshine-yellow joy accent** (`--joy` `#FFC844`) for streaks, highlights, and small
celebrations, all grounded by a **deep-navy ink** (`--neutral-900` `#1A1A2E`). Neutrals are
a cool, navy-leaning grey ramp on near-white surfaces. Status colors are clear and friendly
— green / amber / a distinct red (kept separate from the coral brand). **Modules are
brand-unified**: every module (Lists, Workouts, Clock) shares the coral accent and is
differentiated by its **icon**, not its color — a deliberately calm, cohesive look. The
`[data-module]` theming hook is still wired throughout (set `data-module="…"` on a screen and
module-aware components read `--module*`), it simply resolves to coral everywhere today.
Per-module accent ramps (grass `#1FA971`, violet `#6C5CE7`, sky `#2E90E0`) remain defined in
`tokens/colors.css` so colored modules can be re-enabled by editing those four scope rules.

**Typography.** **Hanken Grotesk** for everything — a friendly grotesk with enough warmth
to feel human and enough neutrality to disappear. Weights 400–800; display sizes use tight
tracking (`-0.02em`) and ExtraBold (800). **Numerics — timers, stopwatch, durations, stats,
alarm times, counts — are set in Hanken Grotesk too**, with tabular lining figures
(`font-variant-numeric: tabular-nums`) so digit columns stay fixed-width and don't jump. We
deliberately avoid a monospace face for the clock: Hanken's plain **round zero (no slash)**
reads cleaner and keeps the whole product on one typeface (this is the `--font-numeric`
token, which aliases the brand sans). A system monospace (`--font-mono`) is used only for
code / token-name labels in these spec cards. Body is 15px; the full-screen timer reads at ~76px.

**Shape & radii.** Gently rounded. Controls and inputs use `--radius-md` (14px), cards/tiles
`--radius-lg` (20px), sheets `--radius-xl` (28px). **Pills** (`--radius-full`) for all
primary buttons, chips, badges, avatars, and FAB-style icon buttons. The phone frame uses a
52px radius. Nothing is sharp-cornered.

**Backgrounds.** Flat and quiet. The app sits on a single near-white (or near-black in dark)
fill — **no photographic or illustrative backgrounds, no busy patterns**. The one permitted
flourish is a *very* soft radial wash behind the device frame in the kit stage. Content lives
on solid `--surface-card` panels. Imagery, when present, is user content (avatars), not brand
texture.

**Cards.** Solid `--surface-card`, large radius, **soft low navy-tinted shadow** (`--shadow-md`)
for raised cards or a 1px `--border-subtle` hairline for outlined ones. No gradients, no
colored left-border accents, no heavy borders. Interactive cards lift 2px on hover.

**Elevation & shadows.** A 5-step soft shadow scale, all tinted with navy (`rgba(27,31,38,…)`)
rather than pure black, so shadows read calm. Dark mode deepens to near-black. Sheets and
sticky bars may use a `--blur` backdrop.

**Borders & hairlines.** Thin, low-contrast (`--border-subtle` / `--border-default`). Rows in
a group are separated by a single hairline, not boxed individually.

**Motion.** Quick and gentle. `--ease-standard` for most transitions (140–220ms). A soft
spring (`--ease-spring`) is reserved for *affordances that should feel alive* — toggle thumbs,
checkbox pops, button press (scale 0.97), card lift. **No long, looping, or decorative
animation.** Progress rings ease their fill over ~340ms. Everything respects
`prefers-reduced-motion`.

**Interaction states.**
- *Hover:* surfaces shift one step (`--surface-sunken`), tinted buttons darken to the
  module-deep tone, ghost buttons gain a tint wash.
- *Press / active:* a subtle **scale-down** (0.92–0.97), never a color flash.
- *Focus:* a 3px brand-tinted **focus ring** (`--ring`); danger controls use a red ring.
- *Disabled:* 40–45% opacity, no transform.
- *Selected:* adopts the module accent (tab bar item, segmented control, checked toggle).

**Transparency & blur.** Used sparingly — the kit's floating theme toggle and any sticky
top bar use a `saturate+blur` backdrop. Otherwise surfaces are opaque.

**Layout rules.** Mobile-first, single column, `--gutter` (16px) screen padding, content
capped at `--content-max` (480px) on larger viewports. The app shell is a scrolling content
area with a **fixed bottom navigation bar** — basecamp uses the *launcher* pattern: two
destinations (Home, Activity) split around a raised **⊕ Add** FAB (the global quick-capture).
Home launches the modules (Lists, Workouts, Clock) as pushed views, so they aren't tabs. Some
screens pin an input/action bar above the nav. Touch targets are never below 44px (`--tap-min`).

---

## Iconography

basecamp uses **[Lucide](https://lucide.dev)** — a clean, open-source icon set with a
consistent **2px stroke, rounded line-caps/joins**, drawn on a 24×24 grid. The calm, even
stroke weight matches the brand's soft-minimal feel. Icons are **line icons** (not filled)
except where a glyph is inherently solid (e.g. a play triangle).

- **Why Lucide:** no custom icon font or sprite exists for this from-scratch brand, so we
  standardize on Lucide rather than inventing inconsistent one-off SVGs. *(Substitution flag:
  Lucide is the chosen set, not a recreation of a pre-existing basecamp icon library.)*
- **In this repo:** the UI kit ships a hand-picked subset as React components in
  `ui_kits/basecamp-app/icons.jsx` (`window.BC.Icons`) using Lucide's actual paths, so the
  kit runs offline. For new work you can also pull the full set from the Lucide CDN.
- **Color:** icons inherit `currentColor`. In tinted tiles they take the module accent; in
  the tab bar the active item takes the accent, inactive are `--text-tertiary`.
- **Sizing:** 24px in nav and leading tiles, 20px inside buttons, 18px for trailing chevrons.
- **No emoji, no unicode glyphs** are used as icons anywhere.

**Brand assets** live in `assets/`: `mark.svg` (the **tent** mark — an A-frame with a
doorway cut out as a true hole, so it sits on any background, drawn in `currentColor`),
`app-icon.svg` (white tent + a sunshine-yellow pennant on a coral gradient tile), and the
wordmark lockup is set in Hanken Grotesk ExtraBold (`base` in navy ink, `camp` in brand
coral) — see `guidelines/brand-logo.card.html`.

---

## Index / manifest

**Foundations**
- `styles.css` — the single entry point consumers link. `@import` manifest only.
- `tokens/` — `colors.css`, `typography.css`, `spacing.css`, `radii.css`, `shadows.css`,
  `motion.css`, `fonts.css`, `base.css`.
- `assets/` — `mark.svg`, `app-icon.svg`.
- `guidelines/*.card.html` — foundation specimen cards (Brand, Colors, Type, Spacing).

**Components** (`components/` → `window.BasecampDesignSystem_e1341e`)
- `actions/` — **Button**, **IconButton**
- `forms/` — **Input**, **Switch**, **Checkbox**, **SegmentedControl**
- `data-display/` — **Card**, **Badge**, **Tag**, **Avatar**, **ProgressRing**, **ListItem**, **Stat**
- `navigation/` — **TabBar** (supports the launcher FAB via `centerAction`)
- `components/components.css` — shipped interaction styles for the above.

Each component directory has `<Name>.jsx`, `<Name>.d.ts`, `<Name>.prompt.md`, and a
`@dsCard` specimen HTML.

**UI kit**
- `ui_kits/basecamp-app/` — interactive app recreation. Launcher nav (Brief · Calendar · ⊕ · Activity · Modules) with the Lists / Workouts / Clock modules as pushed views. See its `README.md`.

**Other**
- `SKILL.md` — makes this system usable as a downloadable Agent Skill.

---

## Using the tokens
Always build against the **semantic aliases**, not raw scales:
`--surface-app/-card/-sunken`, `--text-primary/-secondary/-tertiary`, `--border-subtle`,
`--brand*`, `--module*`, `--success/-warning/-danger`. Wrap a screen in
`[data-theme="dark"]` for dark mode and `[data-module="lists|workouts|clock"]` for accent
theming — both are pure CSS scope swaps.

## Known caveats
- **Fonts load from the Google Fonts CDN** (`tokens/fonts.css`) rather than self-hosted
  binaries. To self-host, drop `.woff2` files in `assets/fonts/` and swap the `@import` for
  local `@font-face` rules — the `--font-*` tokens stay the same.
