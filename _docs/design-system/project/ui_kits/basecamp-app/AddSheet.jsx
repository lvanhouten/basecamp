/* basecamp UI kit — Add sheet: global quick-capture bottom sheet. */
const { Button } = window.BasecampDesignSystem_e1341e;
const DI = window.BC.Icons;

const DESTS = [
  { value: 'list', label: 'List item', icon: <DI.list /> },
  { value: 'workout', label: 'Workout', icon: <DI.dumbbell /> },
  { value: 'timer', label: 'Timer', icon: <DI.clock /> },
  { value: 'alarm', label: 'Alarm', icon: <DI.bell /> },
];

// Light inference: a time-like string nudges the destination toward Timer/Alarm.
function infer(text) {
  if (/\b\d{1,2}:\d{2}\b|\b\d+\s?(min|sec|m|s)\b/i.test(text)) return 'timer';
  if (/\b(\d{1,2})\s?(am|pm)\b/i.test(text)) return 'alarm';
  return null;
}

function AddSheet({ onClose, onAdd }) {
  const [text, setText] = React.useState('');
  const [dest, setDest] = React.useState('list');
  const [touched, setTouched] = React.useState(false);
  const inputRef = React.useRef(null);

  React.useEffect(() => { const t = setTimeout(() => inputRef.current && inputRef.current.focus(), 280); return () => clearTimeout(t); }, []);

  const onType = (e) => {
    const v = e.target.value;
    setText(v);
    if (!touched) { const g = infer(v); if (g) setDest(g); }
  };

  const submit = () => { if (text.trim()) onAdd && onAdd({ text: text.trim(), dest }); onClose && onClose(); };

  return (
    <React.Fragment>
      <div className="bc-scrim" onClick={onClose} />
      <div className="bc-sheet" role="dialog" aria-label="Quick add">
        <div className="bc-sheet__grab" />
        <div className="bc-sheet__title">Quick add</div>
        <input
          ref={inputRef}
          className="bc-sheet__field"
          placeholder="What's on your mind?"
          value={text}
          onChange={onType}
          onKeyDown={(e) => e.key === 'Enter' && submit()}
        />
        <div className="bc-sheet__lbl">Add to</div>
        <div className="bc-chips">
          {DESTS.map((d) => (
            <button key={d.value} className="bc-chip" aria-pressed={dest === d.value}
              onClick={() => { setDest(d.value); setTouched(true); }}>
              {d.icon}{d.label}
            </button>
          ))}
        </div>
        <div style={{ marginTop: 20 }}>
          <Button variant="primary" size="lg" block onClick={submit} disabled={!text.trim()}>
            Add
          </Button>
        </div>
      </div>
    </React.Fragment>
  );
}

window.BC.AddSheet = AddSheet;
