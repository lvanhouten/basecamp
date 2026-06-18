The app's bottom navigation. The selected tab takes on the brand accent (or the active module accent — pair with a matching `data-module` on the screen).

basecamp uses the **launcher** pattern: two destinations (Home, Activity) split around a raised **⊕ Add** FAB that opens the global quick-capture sheet. Home is the "home base" that launches the modules (Lists, Workouts, Clock) as pushed views — so they aren't tabs.

```jsx
const items = [
  { value:'home',     label:'Home',     icon:<HomeIcon/> },
  { value:'activity', label:'Activity', icon:<PulseIcon/> },
];
<TabBar
  items={items}
  value={tab}
  onChange={setTab}
  centerAction={{ icon:<PlusIcon/>, label:'Quick add', onClick:openAddSheet }}
/>
```

- Omit `centerAction` for a plain N-tab bar (no FAB).
- With `centerAction`, the FAB is inserted at the midpoint of `items` — for the basecamp launcher pass exactly 2 items so it sits dead-center. The FAB is an action, never a selected tab.
