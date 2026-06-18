The base surface container — every module tile, panel, and grouped section sits on a Card.

```jsx
<Card variant="raised">…</Card>
<Card variant="outlined" interactive onClick={open}>Tap me</Card>
```

- **variant**: `raised` (soft shadow, default), `outlined` (hairline border), `flat` (sunken fill, no shadow).
- `interactive` adds a hover lift — pair with `as="button"` or `onClick` for tappable module tiles.
- Default padding is `--space-6` (20px); override with your own style if a child needs full-bleed.
