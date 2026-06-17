Circular progress — list completion, workout goal, timer remaining. Stroke follows the active module accent.

```jsx
<ProgressRing value={62} size={72} />
<ProgressRing value={40} size={56} label={<b>4/10</b>} />
<ProgressRing value={80} label={null} />  /* ring only */
```

The fill animates on value change. Wrap in `data-module` to recolor.
