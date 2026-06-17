/* basecamp UI kit — Brief: the forward-looking daily digest ("what's now / next"). */
const { Card, Badge, ProgressRing, Avatar, ListItem } = window.BasecampDesignSystem_e1341e;
const BRI = window.BC.Icons;

const briefIcon = { lists: <BRI.list />, workouts: <BRI.dumbbell />, clock: <BRI.clock /> };

function BriefScreen({ go }) {
  const today = [
    { mod: 'workouts', title: 'Evening run', sub: '5 km · easy pace', time: '6:00 PM' },
    { mod: 'lists', title: 'Take out the trash', sub: 'Household', time: '7:30 PM' },
    { mod: 'clock', title: 'Wind down', sub: 'Bedtime reminder', time: '9:00 PM' },
  ];
  const later = [
    { mod: 'lists', title: 'Dentist appointment', sub: 'Wed · 2:00 PM' },
    { mod: 'workouts', title: 'Long run', sub: 'Thu · 7:00 AM' },
  ];

  return (
    <div className="bc-screen" data-module="home">
      <div className="bc-screen__pad">
        <div className="bc-hero">
          <div className="bc-hero__top">
            <div className="bc-hero__date">Tuesday · Jun 16</div>
            <button className="bc-avatarbtn" aria-label="Profile" onClick={() => go && go('modules')}>
              <Avatar name="Riley Chen" size="lg" />
            </button>
          </div>
          <div className="bc-hero__hi">Good morning, Riley</div>
        </div>

        <Card variant="raised" className="bc-summary">
          <ProgressRing value={60} size={64} label={<b style={{ fontSize: '15px' }}>60%</b>} />
          <div style={{ flex: 1, marginLeft: 16 }}>
            <div style={{ font: 'var(--type-subhead)', color: 'var(--text-primary)' }}>3 of 5 done today</div>
            <div style={{ font: 'var(--type-caption)', color: 'var(--text-tertiary)', marginTop: 2 }}>Nice pace — 2 things left</div>
          </div>
          <Badge tone="success" dot>On track</Badge>
        </Card>

        <div>
          <div className="bc-section"><span className="bc-section__t">Up next today</span><span className="bc-section__a" onClick={() => go && go('calendar')}>Calendar</span></div>
          <Card variant="outlined" style={{ padding: 6, marginTop: 12 }}>
            <div className="bc-rows">
              {today.map((r, i) => (
                <div key={i} data-module={r.mod} style={{ display: 'contents' }}>
                  <ListItem lead={briefIcon[r.mod]} title={r.title} subtitle={r.sub}
                    trailing={<span className="bc-time">{r.time}</span>} onClick={() => go && go(r.mod)} />
                </div>
              ))}
            </div>
          </Card>
        </div>

        <div>
          <div className="bc-section"><span className="bc-section__t">Later this week</span></div>
          <Card variant="outlined" style={{ padding: 6, marginTop: 12 }}>
            <div className="bc-rows">
              {later.map((r, i) => (
                <div key={i} data-module={r.mod} style={{ display: 'contents' }}>
                  <ListItem lead={briefIcon[r.mod]} title={r.title} subtitle={r.sub}
                    trailing={<BRI.chevronRight style={{ width: 18, height: 18 }} />} onClick={() => go && go('calendar')} />
                </div>
              ))}
            </div>
          </Card>
        </div>
      </div>
    </div>
  );
}

window.BC.Screens = window.BC.Screens || {};
window.BC.Screens.Brief = BriefScreen;
