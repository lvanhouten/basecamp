An icon-only control (back, more, add, settings) — always pass an `aria-label`.

```jsx
<IconButton aria-label="Add" variant="solid"><PlusIcon/></IconButton>
<IconButton aria-label="More" variant="ghost"><MoreIcon/></IconButton>
```

- **variant**: `ghost` (bare, hover fill), `soft` (module-tinted bg), `solid` (module-filled — use for a FAB-style add).
- **size**: `sm` 34 · `md` 44 · `lg` 52. Icons render at 20px.
