/* basecamp UI kit — Calendar: cross-module view of every dated item. Week (default) / Month. */
const { Card, SegmentedControl, ListItem } = window.BasecampDesignSystem_e1341e;
const CAL = window.BC.Icons;

const calIcon = { lists: <CAL.list />, workouts: <CAL.dumbbell />, clock: <CAL.clock /> };
const DOW = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
const WEEKDAY = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
const MONTHS = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

// Fictional "today" for the kit; items keyed by day-of-month (all June 2026).
const TODAY = new Date(2026, 5, 16);
const ITEMS = {
  13: [{ mod: 'clock', title: 'Rest day', sub: 'No alarms' }],
  15: [{ mod: 'workouts', title: 'Upper body', sub: '5 exercises', time: '7:00 AM' }, { mod: 'lists', title: 'Team lunch', sub: 'Work', time: '12:30 PM' }],
  16: [{ mod: 'workouts', title: 'Evening run', sub: '5 km · easy', time: '6:00 PM' }, { mod: 'lists', title: 'Take out the trash', sub: 'Household', time: '7:30 PM' }, { mod: 'clock', title: 'Wind down', sub: 'Bedtime', time: '9:00 PM' }],
  17: [{ mod: 'lists', title: 'Dentist appointment', sub: 'Health', time: '2:00 PM' }, { mod: 'lists', title: 'Grocery run', sub: 'Errands', time: '5:30 PM' }],
  18: [{ mod: 'workouts', title: 'Long run', sub: '12 km', time: '7:00 AM' }],
  20: [{ mod: 'lists', title: 'Trip packing', sub: 'Due', time: 'All day' }],
};
const mondayIndex = (d) => (d.getDay() + 6) % 7;

function DayAgenda({ date }) {
  const rows = ITEMS[date.getDate()] || [];
  return (
    <div>
      <div className="bc-daygroup">{WEEKDAY[mondayIndex(date)]}, {MONTHS[date.getMonth()]} {date.getDate()}</div>
      {rows.length ? (
        <Card variant="outlined" style={{ padding: 6, marginTop: 10 }}>
          <div className="bc-rows">
            {rows.map((r, i) => (
              <div key={i} data-module={r.mod} style={{ display: 'contents' }}>
                <ListItem lead={<span className="bc-feedlead">{calIcon[r.mod]}</span>} title={r.title} subtitle={r.sub}
                  trailing={r.time ? <span className="bc-time">{r.time}</span> : null} />
              </div>
            ))}
          </div>
        </Card>
      ) : (
        <Card variant="flat" style={{ marginTop: 10, textAlign: 'center', color: 'var(--text-tertiary)', font: 'var(--type-body)', padding: '22px' }}>
          Nothing scheduled.
        </Card>
      )}
    </div>
  );
}

function WeekView({ selected, onSelect }) {
  const start = new Date(selected);
  start.setDate(selected.getDate() - mondayIndex(selected));
  const days = [...Array(7)].map((_, i) => { const d = new Date(start); d.setDate(start.getDate() + i); return d; });
  return (
    <React.Fragment>
      <Card variant="raised" style={{ padding: '12px 10px' }}>
        <div className="bc-cal-week">
          {days.map((d, i) => {
            const sel = d.getDate() === selected.getDate();
            const isToday = d.getDate() === TODAY.getDate();
            const has = !!ITEMS[d.getDate()];
            return (
              <button key={i} className={'bc-cal-day' + (sel ? ' is-sel' : '') + (isToday ? ' is-today' : '')} aria-selected={sel} onClick={() => onSelect(new Date(d))}>
                <span className="bc-cal-day__dow">{DOW[i]}</span>
                <span className="bc-cal-day__num">{d.getDate()}</span>
                <span className="bc-cal-day__dot" style={{ visibility: has ? 'visible' : 'hidden' }} />
              </button>
            );
          })}
        </div>
      </Card>
      <DayAgenda date={selected} />
    </React.Fragment>
  );
}

function MonthView({ selected, onSelect }) {
  const y = 2026, m = 5;
  const first = new Date(y, m, 1);
  const pad = mondayIndex(first);
  const dim = new Date(y, m + 1, 0).getDate();
  const cells = [...Array(pad).fill(null), ...[...Array(dim)].map((_, i) => i + 1)];
  while (cells.length % 7) cells.push(null);
  return (
    <React.Fragment>
      <Card variant="raised" style={{ padding: '14px 12px' }}>
        <div className="bc-cal-mtitle">{MONTHS[m]} {y}</div>
        <div className="bc-cal-month">
          {DOW.map((d, i) => <div key={'h' + i} className="bc-cal-mdow">{d}</div>)}
          {cells.map((n, i) => {
            if (!n) return <span key={i} />;
            const sel = n === selected.getDate();
            const isToday = n === TODAY.getDate();
            const has = !!ITEMS[n];
            return (
              <button key={i} className={'bc-cal-cell' + (isToday ? ' is-today' : '')} aria-selected={sel} onClick={() => onSelect(new Date(y, m, n))}>
                <span className="bc-cal-cell__num">{n}</span>
                <span className="bc-cal-cell__dot" style={{ visibility: has ? 'visible' : 'hidden' }} />
              </button>
            );
          })}
        </div>
      </Card>
      <DayAgenda date={selected} />
    </React.Fragment>
  );
}

function CalendarScreen() {
  const [mode, setMode] = React.useState('Week');
  const [selected, setSelected] = React.useState(new Date(TODAY));
  return (
    <div className="bc-screen" data-module="home">
      <div className="bc-screen__pad">
        <div className="bc-screenhead bc-screenhead--lg" style={{ paddingBottom: 8 }}>
          <h1 className="bc-screenhead__title">Calendar</h1>
        </div>
        <div style={{ display: 'flex', justifyContent: 'center' }}>
          <SegmentedControl options={['Week', 'Month']} value={mode} onChange={setMode} />
        </div>
        {mode === 'Week'
          ? <WeekView selected={selected} onSelect={setSelected} />
          : <MonthView selected={selected} onSelect={setSelected} />}
      </div>
    </div>
  );
}

window.BC.Screens = window.BC.Screens || {};
window.BC.Screens.Calendar = CalendarScreen;
