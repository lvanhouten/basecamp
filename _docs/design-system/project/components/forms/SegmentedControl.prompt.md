A pill-track segmented control for 2–4 short, mutually-exclusive options — the Clock module's Timer / Stopwatch / Alarm switch, or a list filter.

```jsx
const [mode, setMode] = React.useState('timer');
<SegmentedControl
  options={['Timer','Stopwatch','Alarm']}
  value={mode}
  onChange={setMode}
/>
```

Past ~4 options or long labels, use Tabs or a Select instead.
