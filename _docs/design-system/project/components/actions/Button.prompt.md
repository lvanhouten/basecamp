A pill-shaped action button whose primary fill adapts to the active module accent — use for the main call-to-action on any screen.

```jsx
<Button variant="primary" size="md" onClick={start}>Start workout</Button>
<Button variant="secondary" iconLeft={<PlusIcon/>}>Add item</Button>
<Button variant="ghost" size="sm">Skip</Button>
```

- **variant**: `primary` (module-aware fill), `secondary` (outlined surface), `ghost` (tinted text), `danger` (destructive).
- **size**: `sm` (34px) · `md` (44px, default) · `lg` (52px).
- `block` stretches full-width (common for mobile bottom CTAs). `loading` swaps in a spinner. `iconLeft` / `iconRight` take any node.
- Wrap a screen/section in `data-module="lists|workouts|clock"` to recolor primary buttons to that accent automatically.
