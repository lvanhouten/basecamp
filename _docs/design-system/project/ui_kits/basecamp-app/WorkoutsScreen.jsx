/* basecamp UI kit — Workouts module (today's session). */
const { Card, Badge, ProgressRing, ListItem, Stat, Button, IconButton, Checkbox } = window.BasecampDesignSystem_e1341e;
const WI = window.BC.Icons;

function WorkoutsScreen({ onBack }) {
  const [ex, setEx] = React.useState([
    { id: 1, name: 'Goblet squat', detail: '3 × 10 · 20 kg', done: true },
    { id: 2, name: 'Bench press', detail: '4 × 8 · 45 kg', done: true },
    { id: 3, name: 'Bent-over row', detail: '4 × 8 · 40 kg', done: false },
    { id: 4, name: 'Overhead press', detail: '3 × 10 · 25 kg', done: false },
    { id: 5, name: 'Plank', detail: '3 × 45 s', done: false },
  ]);
  const toggle = (id) => setEx((xs) => xs.map((e) => (e.id === id ? { ...e, done: !e.done } : e)));
  const done = ex.filter((e) => e.done).length;
  const pct = Math.round((done / ex.length) * 100);

  return (
    <div className="bc-screenroot" data-module="workouts">
      <div className="bc-screen">
        <div className="bc-screen__pad">
          <div className="bc-screenhead bc-screenhead--lg">
            {onBack && <IconButton aria-label="Back" variant="ghost" onClick={onBack}>{<WI.chevronLeft />}</IconButton>}
            <div>
              <div className="bc-screenhead__eyebrow">Today · Strength</div>
              <h1 className="bc-screenhead__title">Upper body</h1>
            </div>
            <IconButton aria-label="Workout options" variant="soft">{<WI.more />}</IconButton>
          </div>

          <Card variant="raised" style={{ display: 'flex', alignItems: 'center', gap: 18 }}>
            <ProgressRing value={pct} size={84} thickness={7} label={<span style={{fontSize:'15px'}}><b>{done}</b>/{ex.length}</span>} />
            <div style={{ flex: 1, display: 'flex', justifyContent: 'space-between' }}>
              <Stat value="24" unit="min" label="Elapsed" />
              <Stat value="320" unit="kg" label="Volume" />
            </div>
          </Card>

          <div className="bc-chip-row">
            <Badge tone="module" dot>In progress</Badge>
            <Badge tone="neutral">{<WI.flame />}&nbsp;5-day streak</Badge>
          </div>

          <div>
            <div className="bc-section"><span className="bc-section__t">Exercises</span><span className="bc-section__a">Edit</span></div>
            <Card variant="outlined" style={{ padding: 6, marginTop: 12 }}>
              <div className="bc-rows">
                {ex.map((e) => (
                  <ListItem
                    key={e.id}
                    lead={<Checkbox checked={e.done} onChange={() => toggle(e.id)} aria-label={e.name} />}
                    title={e.name}
                    subtitle={e.detail}
                    done={e.done}
                    trailing={e.done ? <Badge tone="success">Done</Badge> : <span style={{ color: 'var(--text-tertiary)' }}>{<WI.chevronRight style={{ width: 18, height: 18 }} />}</span>}
                    onClick={() => toggle(e.id)}
                  />
                ))}
              </div>
            </Card>
          </div>

          <Button variant="primary" size="lg" block iconLeft={<WI.clock />}>Start rest timer · 1:30</Button>
        </div>
      </div>
    </div>
  );
}

window.BC.Screens = window.BC.Screens || {};
window.BC.Screens.Workouts = WorkoutsScreen;
