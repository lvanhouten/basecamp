---
name: basecamp-design
description: Use this skill to generate well-branded interfaces and assets for basecamp, either for production or throwaway prototypes/mocks/etc. Contains essential design guidelines, colors, type, fonts, assets, and UI kit components for prototyping.
user-invocable: true
---

Read the README.md file within this skill, and explore the other available files.

If creating visual artifacts (slides, mocks, throwaway prototypes, etc), copy assets out and create static HTML files for the user to view. If working on production code, you can copy assets and read the rules here to become an expert in designing with this brand.

If the user invokes this skill without any other guidance, ask them what they want to build or design, ask some questions, and act as an expert designer who outputs HTML artifacts _or_ production code, depending on the need.

## What's here
- `readme.md` — the full design guide: brand voice, content fundamentals, visual foundations, iconography, and a file manifest. **Start here.**
- `styles.css` — the single CSS entry point. Link it (or `@import` it) and you get every token, the webfonts, base resets, and component styles.
- `tokens/` — design tokens (colors incl. light/dark + module accents, type, spacing, radii, shadows, motion).
- `components/` — React UI primitives (Button, IconButton, Input, Switch, Checkbox, SegmentedControl, Card, Badge, Tag, Avatar, ProgressRing, ListItem, Stat, TabBar). Each has a `.d.ts` (props) and `.prompt.md` (usage).
- `ui_kits/basecamp-app/` — a full interactive recreation of the app (Brief, Calendar, Activity, Modules + the Lists/Workouts/Clock module views) to crib layouts and patterns from.
- `assets/` — logo mark + app icon.
- `guidelines/*.card.html` — visual specimen cards.

## Fast start for a prototype
1. Link `styles.css`.
2. Set type with `--font-sans` (Hanken Grotesk). For any timer/number use `--font-numeric` (the brand sans) with `font-variant-numeric: tabular-nums` — round zero, fixed-width digits. (`--font-mono` is the system monospace, for code/token labels only.)
3. Build against semantic tokens: `--surface-*`, `--text-*`, `--brand*`, `--module*`.
4. Wrap a screen in `data-module="lists|workouts|clock"` for accent theming, and
   `data-theme="dark"` for dark mode.
5. Icons: Lucide (line, 2px). Reuse `ui_kits/basecamp-app/icons.jsx` or pull from the Lucide CDN. No emoji.
6. Voice: sentence case, "you", calm + encouraging, tight microcopy.
