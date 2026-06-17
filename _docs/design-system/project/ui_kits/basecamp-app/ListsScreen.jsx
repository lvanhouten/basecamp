/* basecamp UI kit — Lists module (a list detail with checkable items). */
const { Card, Badge, ProgressRing, ListItem, Checkbox, SegmentedControl, IconButton, Button } = window.BasecampDesignSystem_e1341e;
const LI = window.BC.Icons;

function ListsScreen({ onBack }) {
  const [items, setItems] = React.useState([
    { id: 1, text: 'Oat milk', done: true },
    { id: 2, text: 'Sourdough loaf', done: false },
    { id: 3, text: 'Cherry tomatoes', done: false },
    { id: 4, text: 'Olive oil', done: true },
    { id: 5, text: 'Coffee beans', done: false },
    { id: 6, text: 'Dark chocolate', done: false },
  ]);
  const [filter, setFilter] = React.useState('All');
  const [draft, setDraft] = React.useState('');
  const nextId = React.useRef(7);

  const toggle = (id) => setItems((xs) => xs.map((i) => (i.id === id ? { ...i, done: !i.done } : i)));
  const add = () => {
    const t = draft.trim();
    if (!t) return;
    setItems((xs) => [...xs, { id: nextId.current++, text: t, done: false }]);
    setDraft('');
  };
  const done = items.filter((i) => i.done).length;
  const shown = items.filter((i) => (filter === 'All' ? true : filter === 'Open' ? !i.done : i.done));

  return (
    <div className="bc-screenroot" data-module="lists">
      <div className="bc-screen">
        <div className="bc-screen__pad">
          <div className="bc-screenhead bc-screenhead--lg">
            {onBack && <IconButton aria-label="Back" variant="ghost" onClick={onBack}>{<LI.chevronLeft />}</IconButton>}
            <div>
              <div className="bc-screenhead__eyebrow">List · Household</div>
              <h1 className="bc-screenhead__title">Groceries</h1>
            </div>
            <IconButton aria-label="List options" variant="soft">{<LI.more />}</IconButton>
          </div>

          <Card variant="raised" className="bc-summary">
            <ProgressRing value={Math.round((done / items.length) * 100)} size={56} label={<b style={{fontSize:'13px'}}>{done}/{items.length}</b>} />
            <div style={{ flex: 1, marginLeft: 14 }}>
              <div style={{ font: 'var(--type-subhead)', color: 'var(--text-primary)' }}>{items.length - done} left to grab</div>
              <div style={{ font: 'var(--type-caption)', color: 'var(--text-tertiary)', marginTop: 2 }}>Updated 2m ago</div>
            </div>
          </Card>

          <SegmentedControl options={['All', 'Open', 'Done']} value={filter} onChange={setFilter} />

          <Card variant="outlined" style={{ padding: 6 }}>
            <div className="bc-rows">
              {shown.map((i) => (
                <ListItem
                  key={i.id}
                  lead={<Checkbox checked={i.done} onChange={() => toggle(i.id)} aria-label={i.text} />}
                  title={i.text}
                  done={i.done}
                  onClick={() => toggle(i.id)}
                />
              ))}
              {shown.length === 0 && (
                <div style={{ padding: '22px', textAlign: 'center', color: 'var(--text-tertiary)', font: 'var(--type-body)' }}>Nothing here yet.</div>
              )}
            </div>
          </Card>
        </div>
      </div>

      <div className="bc-pinned">
        <Card variant="flat" className="bc-addbar" style={{ padding: 6 }}>
          <IconButton aria-label="Add item" variant="solid" onClick={add}>{<LI.plus />}</IconButton>
          <input
            placeholder="Add an item…"
            value={draft}
            onChange={(e) => setDraft(e.target.value)}
            onKeyDown={(e) => e.key === 'Enter' && add()}
          />
        </Card>
      </div>
    </div>
  );
}

window.BC.Screens = window.BC.Screens || {};
window.BC.Screens.Lists = ListsScreen;
