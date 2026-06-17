A checkbox with an animated check, for opt-in rows. For task/list completion prefer `ListItem` with its built-in check affordance.

```jsx
<Checkbox label="Email me a daily recap" defaultChecked />
<Checkbox label="Vibrate on alarm" checked={v} onChange={e=>setV(e.target.checked)} />
```
