/* basecamp UI kit — Clock module (Timer / Stopwatch / Alarm). */
const { Card, Badge, ProgressRing, ListItem, SegmentedControl, Switch, IconButton } = window.BasecampDesignSystem_e1341e;
const CI = window.BC.Icons;

const pad = (n) => String(n).padStart(2, '0');
const fmtTimer = (s) => `${pad(Math.floor(s / 60))}:${pad(s % 60)}`;

function RoundBtn({ kind, icon, label, onClick }) {
  return (
    <button className={`bc-round bc-round--${kind}`} onClick={onClick} aria-label={label}>{icon}</button>
  );
}

function TimerView() {
  const TOTAL = 300;
  const [left, setLeft] = React.useState(TOTAL);
  const [run, setRun] = React.useState(false);
  React.useEffect(() => {
    if (!run) return;
    const t = setInterval(() => setLeft((x) => (x <= 1 ? (clearInterval(t), setRun(false), 0) : x - 1)), 1000);
    return () => clearInterval(t);
  }, [run]);
  const pct = (left / TOTAL) * 100;
  return (
    <div className="bc-timer">
      <div className="bc-timer__ring">
        <ProgressRing value={pct} size={244} thickness={10} label={null} />
        <div className="bc-timer__center">
          <div className="bc-timer__readout">{fmtTimer(left)}</div>
          <div className="bc-timer__sub">{run ? 'Focus' : left === 0 ? "Time's up" : 'Paused'}</div>
        </div>
      </div>
      <div className="bc-controls" style={{ marginTop: 18 }}>
        <RoundBtn kind="ghost" icon={<CI.reset />} label="Reset" onClick={() => { setRun(false); setLeft(TOTAL); }} />
        <RoundBtn kind="primary" icon={run ? <CI.pause /> : <CI.play />} label={run ? 'Pause' : 'Start'} onClick={() => setRun((r) => !r)} />
      </div>
    </div>
  );
}

function StopwatchView() {
  const [cs, setCs] = React.useState(0);
  const [run, setRun] = React.useState(false);
  const [laps, setLaps] = React.useState([]);
  React.useEffect(() => {
    if (!run) return;
    const t = setInterval(() => setCs((x) => x + 1), 10);
    return () => clearInterval(t);
  }, [run]);
  const m = Math.floor(cs / 6000), s = Math.floor((cs % 6000) / 100), c = cs % 100;
  return (
    <div className="bc-timer">
      <div className="bc-timer__readout" style={{ marginTop: 36 }}>{pad(m)}:{pad(s)}<span className="ms">.{pad(c)}</span></div>
      <div className="bc-timer__sub" style={{ marginBottom: 6 }}>Stopwatch</div>
      <div className="bc-controls" style={{ marginTop: 14 }}>
        <RoundBtn kind="ghost" icon={run ? <CI.flag /> : <CI.reset />} label={run ? 'Lap' : 'Reset'}
          onClick={() => (run ? setLaps((l) => [{ n: l.length + 1, t: cs }, ...l]) : (setCs(0), setLaps([])))} />
        <RoundBtn kind="primary" icon={run ? <CI.pause /> : <CI.play />} label={run ? 'Pause' : 'Start'} onClick={() => setRun((r) => !r)} />
      </div>
      {laps.length > 0 && (
        <Card variant="outlined" style={{ padding: 6, width: '100%', marginTop: 22 }}>
          <div className="bc-rows">
            {laps.map((l) => {
              const lm = Math.floor(l.t / 6000), ls = Math.floor((l.t % 6000) / 100), lc = l.t % 100;
              return <ListItem key={l.n} title={`Lap ${l.n}`} trailing={<span style={{ fontFamily: 'var(--font-numeric)', fontWeight: 600, fontVariantNumeric: 'tabular-nums', color: 'var(--text-secondary)' }}>{pad(lm)}:{pad(ls)}.{pad(lc)}</span>} />;
            })}
          </div>
        </Card>
      )}
    </div>
  );
}

function AlarmView() {
  const [alarms, setAlarms] = React.useState([
    { id: 1, time: '6:30', meri: 'AM', label: 'Wake up', on: true, days: 'Mon–Fri' },
    { id: 2, time: '7:30', meri: 'AM', label: 'Leave for gym', on: true, days: 'Weekdays' },
    { id: 3, time: '9:00', meri: 'PM', label: 'Wind down', on: false, days: 'Every day' },
  ]);
  const toggle = (id) => setAlarms((xs) => xs.map((a) => (a.id === id ? { ...a, on: !a.on } : a)));
  return (
    <div style={{ paddingTop: 8 }}>
      <Card variant="outlined" style={{ padding: 6 }}>
        <div className="bc-rows">
          {alarms.map((a) => (
            <ListItem
              key={a.id}
              lead={<CI.bell />}
              title={<span style={{ fontFamily: 'var(--font-numeric)', fontVariantNumeric: 'tabular-nums', fontSize: '22px', fontWeight: 700, color: a.on ? 'var(--text-primary)' : 'var(--text-tertiary)' }}>{a.time}<span style={{ fontSize: '13px', marginLeft: 4 }}>{a.meri}</span></span>}
              subtitle={`${a.label} · ${a.days}`}
              trailing={<Switch checked={a.on} onChange={() => toggle(a.id)} aria-label={a.label} />}
            />
          ))}
        </div>
      </Card>
    </div>
  );
}

function ClockScreen({ onBack }) {
  const [mode, setMode] = React.useState('Timer');
  return (
    <div className="bc-screenroot" data-module="clock">
      <div className="bc-screen">
        <div className="bc-screen__pad">
          <div className="bc-screenhead bc-screenhead--lg" style={{ paddingBottom: 8 }}>
            {onBack && <IconButton aria-label="Back" variant="ghost" onClick={onBack}>{<CI.chevronLeft />}</IconButton>}
            <h1 className="bc-screenhead__title">Clock</h1>
            <IconButton aria-label="Add alarm" variant="soft">{<CI.plus />}</IconButton>
          </div>
          <div style={{ display: 'flex', justifyContent: 'center' }}>
            <SegmentedControl options={['Timer', 'Stopwatch', 'Alarm']} value={mode} onChange={setMode} />
          </div>
          {mode === 'Timer' && <TimerView />}
          {mode === 'Stopwatch' && <StopwatchView />}
          {mode === 'Alarm' && <AlarmView />}
        </div>
      </div>
    </div>
  );
}

window.BC.Screens = window.BC.Screens || {};
window.BC.Screens.Clock = ClockScreen;
