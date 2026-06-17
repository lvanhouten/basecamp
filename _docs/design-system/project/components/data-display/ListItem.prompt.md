The workhorse row — list tasks, settings, workout sets, alarms. Combines a leading tile/check, title + subtitle, and trailing content.

```jsx
<ListItem lead={<ListIcon/>} title="Groceries" subtitle="3 of 8 done" trailing={<Chevron/>} onClick={open} />
<ListItem lead={<Checkbox checked readOnly/>} title="Oat milk" done />
<ListItem title="Vibrate" trailing={<Switch defaultChecked/>} />
```

The leading slot auto-tints with the module accent. Without `onClick` it's a static row; with it, a full-width button row.
