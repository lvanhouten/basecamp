A labeled text field; set `multiline` for a textarea. Pass `error` to show the invalid state.

```jsx
<Input label="List name" placeholder="e.g. Weekend trip" />
<Input label="Notes" multiline rows={4} hint="Optional" />
<Input label="Email" error="That doesn't look right" defaultValue="x@" />
```

Focus ring uses the brand color; the invalid state uses danger. All native input props pass through.
