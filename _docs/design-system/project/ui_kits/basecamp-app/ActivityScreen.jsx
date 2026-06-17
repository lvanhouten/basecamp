/* basecamp UI kit — Activity (completion feed + insights header; solo or friends). */
const { Card, Badge, Stat, ListItem, Avatar, SegmentedControl } = window.BasecampDesignSystem_e1341e;
const VI = window.BC.Icons;

const modIcon = { lists: <VI.list />, workouts: <VI.dumbbell />, clock: <VI.clock /> };

function Spark() {
  const data = [['M', 4], ['T', 6], ['W', 3], ['T', 7], ['F', 5], ['S', 2], ['S', 6]];
  const max = 8;
  return (
    <div>
      <div className="bc-spark">
        {data.map(([d, v], i) => (
          <div key={i} className={'bc-spark__bar' + (i === 6 ? ' bc-spark__bar--on' : '')} style={{ height: (v / max * 100) + '%' }} />
        ))}
      </div>
      <div className="bc-spark__days">{data.map(([d], i) => <span key={i}>{d}</span>)}</div>
    </div>
  );
}

const SOLO = {
  Today: [
    { icon: 'workouts', title: 'Finished Evening run', sub: '5.2 km · easy pace', time: '6:12 PM' },
    { icon: 'lists', title: 'Checked off "Oat milk"', sub: 'Groceries', time: '9:03 AM' },
    { icon: 'lists', title: 'Completed Morning routine', sub: '6 of 6 done', time: '8:15 AM' },
  ],
  Yesterday: [
    { icon: 'workouts', title: 'Finished Upper body', sub: '5 exercises · 320 kg', time: '7:40 AM' },
    { icon: 'clock', title: 'Pasta timer done', sub: '8:00', time: '8:30 PM' },
    { icon: 'lists', title: 'Checked off "Finish chapter 4"', sub: 'Reading list', time: '10:15 PM' },
  ],
};

const FRIENDS = {
  Today: [
    { who: 'Maya Rivera', title: 'completed Morning yoga', sub: 'Workouts', time: '7:30 AM', kudos: 4 },
    { who: 'Sam Okafor', title: 'finished Trip packing', sub: 'Lists · 12 items', time: '11:02 AM', kudos: 2 },
  ],
  Yesterday: [
    { who: 'Jordan Lee', title: 'ran a 10 km route', sub: 'Workouts · new distance PR', time: '6:45 PM', kudos: 9 },
    { who: 'Maya Rivera', title: 'hit a 14-day streak', sub: 'Daily reading', time: '9:20 PM', kudos: 6 },
  ],
};

function ActivityScreen() {
  const [scope, setScope] = React.useState('You');
  const feed = scope === 'You' ? SOLO : FRIENDS;

  return (
    <div className="bc-screenroot" data-module="home">
      <div className="bc-screen">
        <div className="bc-screen__pad">
          <div className="bc-screenhead bc-screenhead--lg" style={{ paddingBottom: 6 }}>
            <h1 className="bc-screenhead__title">Activity</h1>
          </div>

          <div style={{ display: 'flex', justifyContent: 'center' }}>
            <SegmentedControl options={['You', 'Friends']} value={scope} onChange={setScope} />
          </div>

          {scope === 'You' && (
            <Card variant="raised">
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 16 }}>
                <Stat value="18" label="Done this week" />
                <Stat value="5" unit="day" label="Streak" />
                <span className="bc-kudos" style={{ alignSelf: 'center' }}><VI.trending /> +12%</span>
              </div>
              <Spark />
            </Card>
          )}

          {scope === 'Friends' && (
            <Card variant="flat" style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
              <span className="bc-feedlead"><VI.users /></span>
              <div style={{ flex: 1 }}>
                <div style={{ font: 'var(--type-subhead)', color: 'var(--text-primary)' }}>3 friends were active today</div>
                <div style={{ font: 'var(--type-caption)', color: 'var(--text-tertiary)', marginTop: 2 }}>Cheer them on with a tap</div>
              </div>
            </Card>
          )}

          {Object.entries(feed).map(([day, rows]) => (
            <div key={day}>
              <div className="bc-daygroup">{day}</div>
              <Card variant="outlined" style={{ padding: 6, marginTop: 10 }}>
                <div className="bc-rows">
                  {rows.map((r, i) => (
                    scope === 'You' ? (
                      <ListItem key={i} lead={<span className="bc-feedlead">{modIcon[r.icon]}</span>}
                        title={r.title} subtitle={r.sub}
                        trailing={<span style={{ font: 'var(--type-caption)', color: 'var(--text-tertiary)', fontFamily: 'var(--font-numeric)', fontVariantNumeric: 'tabular-nums' }}>{r.time}</span>} />
                    ) : (
                      <ListItem key={i} lead={<Avatar name={r.who} size="md" />}
                        title={<span><b style={{ fontWeight: 700 }}>{r.who.split(' ')[0]}</b> {r.title}</span>}
                        subtitle={`${r.sub} · ${r.time}`}
                        trailing={<span className="bc-kudos"><VI.heart /> {r.kudos}</span>} />
                    )
                  ))}
                </div>
              </Card>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

window.BC.Screens = window.BC.Screens || {};
window.BC.Screens.Activity = ActivityScreen;
