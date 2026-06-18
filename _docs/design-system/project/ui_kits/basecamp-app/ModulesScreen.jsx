/* basecamp UI kit — Modules: the launcher + manager grid for all of a user's spaces. */
const { Card, Badge } = window.BasecampDesignSystem_e1341e;
const MOD = window.BC.Icons;

function ModTile({ module, icon, name, meta, foot, onOpen }) {
  return (
    <div data-module={module} style={{ display: 'contents' }}>
      <Card variant="raised" interactive className="bc-tile" onClick={onOpen}>
        <div className="bc-tile__top">
          <span className="bc-tile__icon">{icon}</span>
          <span className="bc-tile__chev">{<MOD.chevronRight />}</span>
        </div>
        <div>
          <div className="bc-tile__name">{name}</div>
          <div className="bc-tile__meta">{meta}</div>
        </div>
        <div className="bc-tile__foot">{foot}</div>
      </Card>
    </div>
  );
}

function AddTile({ icon, name, onClick }) {
  return (
    <button className="bc-addtile" onClick={onClick}>
      <span className="bc-addtile__icon">{icon}</span>
      <span className="bc-addtile__name">{name}</span>
      <span className="bc-addtile__plus">{<MOD.plus />}</span>
    </button>
  );
}

function ModulesScreen({ go, onAddModule }) {
  return (
    <div className="bc-screen" data-module="home">
      <div className="bc-screen__pad">
        <div className="bc-screenhead bc-screenhead--lg" style={{ paddingBottom: 6 }}>
          <h1 className="bc-screenhead__title">Modules</h1>
        </div>

        <div>
          <div className="bc-section"><span className="bc-section__t">Your modules</span><span className="bc-section__a">Edit</span></div>
          <div className="bc-tiles" style={{ marginTop: 12 }}>
            <ModTile module="lists" icon={<MOD.list />} name="Lists" meta="3 lists · 12 open"
              onOpen={() => go('lists')}
              foot={<div className="bc-mini"><div className="bc-mini__fill" style={{ width: '40%' }} /></div>} />
            <ModTile module="workouts" icon={<MOD.dumbbell />} name="Workouts" meta="Evening run"
              onOpen={() => go('workouts')}
              foot={<Badge tone="module">6:00 PM</Badge>} />
            <ModTile module="clock" icon={<MOD.clock />} name="Clock" meta="2 alarms set"
              onOpen={() => go('clock')}
              foot={<Badge tone="module">Next 7:30</Badge>} />
          </div>
        </div>

        <div>
          <div className="bc-section"><span className="bc-section__t">Add a module</span></div>
          <div className="bc-tiles" style={{ marginTop: 12 }}>
            <AddTile icon={<MOD.book />} name="Journal" onClick={() => onAddModule && onAddModule('Journal')} />
            <AddTile icon={<MOD.target />} name="Goals" onClick={() => onAddModule && onAddModule('Goals')} />
          </div>
        </div>
      </div>
    </div>
  );
}

window.BC.Screens = window.BC.Screens || {};
window.BC.Screens.Modules = ModulesScreen;
