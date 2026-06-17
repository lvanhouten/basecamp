/* @ds-bundle: {"format":3,"namespace":"BasecampDesignSystem_e1341e","components":[{"name":"Button","sourcePath":"components/actions/Button.jsx"},{"name":"IconButton","sourcePath":"components/actions/IconButton.jsx"},{"name":"Avatar","sourcePath":"components/data-display/Avatar.jsx"},{"name":"Badge","sourcePath":"components/data-display/Badge.jsx"},{"name":"Card","sourcePath":"components/data-display/Card.jsx"},{"name":"ListItem","sourcePath":"components/data-display/ListItem.jsx"},{"name":"ProgressRing","sourcePath":"components/data-display/ProgressRing.jsx"},{"name":"Stat","sourcePath":"components/data-display/Stat.jsx"},{"name":"Tag","sourcePath":"components/data-display/Tag.jsx"},{"name":"Checkbox","sourcePath":"components/forms/Checkbox.jsx"},{"name":"Input","sourcePath":"components/forms/Input.jsx"},{"name":"SegmentedControl","sourcePath":"components/forms/SegmentedControl.jsx"},{"name":"Switch","sourcePath":"components/forms/Switch.jsx"},{"name":"TabBar","sourcePath":"components/navigation/TabBar.jsx"}],"sourceHashes":{"components/actions/Button.jsx":"143a678d31ce","components/actions/IconButton.jsx":"7afb52bb5a9e","components/data-display/Avatar.jsx":"9efcea44c050","components/data-display/Badge.jsx":"14522f9ab484","components/data-display/Card.jsx":"d339d7b65964","components/data-display/ListItem.jsx":"10c3c23390e5","components/data-display/ProgressRing.jsx":"0bff8821f6f9","components/data-display/Stat.jsx":"45f32d051522","components/data-display/Tag.jsx":"04bf10e86d4c","components/forms/Checkbox.jsx":"0d8676f2c465","components/forms/Input.jsx":"8f2e8e9b3ed2","components/forms/SegmentedControl.jsx":"ba47d02b9b37","components/forms/Switch.jsx":"5222815c994e","components/navigation/TabBar.jsx":"27bf337fe25f","ui_kits/basecamp-app/ActivityScreen.jsx":"2c1d20599ef9","ui_kits/basecamp-app/AddSheet.jsx":"6bb7eaf7ccd8","ui_kits/basecamp-app/BriefScreen.jsx":"fbd707c94ac2","ui_kits/basecamp-app/CalendarScreen.jsx":"a4943f3a56db","ui_kits/basecamp-app/ClockScreen.jsx":"4b24a315222e","ui_kits/basecamp-app/ListsScreen.jsx":"0fd935435db1","ui_kits/basecamp-app/ModulesScreen.jsx":"ec4d1b638a74","ui_kits/basecamp-app/Shell.jsx":"7ba5e201bdd9","ui_kits/basecamp-app/WorkoutsScreen.jsx":"6a6575fa2a0d","ui_kits/basecamp-app/icons.jsx":"c96033be4eeb"},"inlinedExternals":[],"unexposedExports":[]} */

(() => {

const __ds_ns = (window.BasecampDesignSystem_e1341e = window.BasecampDesignSystem_e1341e || {});

const __ds_scope = {};

(__ds_ns.__errors = __ds_ns.__errors || []);

// components/actions/Button.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
/**
 * basecamp Button — pill action. Primary fill is module-aware: inside a
 * [data-module] scope it adopts that module's accent, else the brand coral.
 */
function Button({
  variant = 'primary',
  size = 'md',
  block = false,
  loading = false,
  disabled = false,
  iconLeft = null,
  iconRight = null,
  type = 'button',
  className = '',
  children,
  ...rest
}) {
  const cls = ['bc-btn', `bc-btn--${variant}`, `bc-btn--${size}`, block ? 'bc-btn--block' : '', className].filter(Boolean).join(' ');
  return /*#__PURE__*/React.createElement("button", _extends({
    type: type,
    className: cls,
    disabled: disabled || loading,
    "aria-busy": loading || undefined
  }, rest), loading && /*#__PURE__*/React.createElement("span", {
    className: "bc-btn__spinner",
    "aria-hidden": "true"
  }), !loading && iconLeft && /*#__PURE__*/React.createElement("span", {
    className: "bc-btn__icon",
    "aria-hidden": "true"
  }, iconLeft), children != null && /*#__PURE__*/React.createElement("span", null, children), !loading && iconRight && /*#__PURE__*/React.createElement("span", {
    className: "bc-btn__icon",
    "aria-hidden": "true"
  }, iconRight));
}
Object.assign(__ds_scope, { Button });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/actions/Button.jsx", error: String((e && e.message) || e) }); }

// components/actions/IconButton.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
/**
 * basecamp IconButton — square, pill-radius control wrapping a single icon.
 * Pass a 24px icon node (e.g. Lucide <svg>) as children. Always give an aria-label.
 */
function IconButton({
  variant = 'ghost',
  size = 'md',
  disabled = false,
  className = '',
  children,
  ...rest
}) {
  const cls = ['bc-iconbtn', `bc-iconbtn--${variant}`, `bc-iconbtn--${size}`, className].filter(Boolean).join(' ');
  return /*#__PURE__*/React.createElement("button", _extends({
    type: "button",
    className: cls,
    disabled: disabled
  }, rest), children);
}
Object.assign(__ds_scope, { IconButton });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/actions/IconButton.jsx", error: String((e && e.message) || e) }); }

// components/data-display/Avatar.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
/**
 * basecamp Avatar — circular user/entity image or initials fallback.
 */
function Avatar({
  src,
  name = '',
  size = 'md',
  className = '',
  ...rest
}) {
  const initials = name.split(' ').map(p => p[0]).filter(Boolean).slice(0, 2).join('').toUpperCase();
  const cls = ['bc-avatar', `bc-avatar--${size}`, className].filter(Boolean).join(' ');
  return /*#__PURE__*/React.createElement("span", _extends({
    className: cls,
    role: "img",
    "aria-label": name || undefined
  }, rest), src ? /*#__PURE__*/React.createElement("img", {
    src: src,
    alt: name
  }) : initials);
}
Object.assign(__ds_scope, { Avatar });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/data-display/Avatar.jsx", error: String((e && e.message) || e) }); }

// components/data-display/Badge.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
/**
 * basecamp Badge — small status/label pill. `dot` adds a leading status dot.
 * Use tone="module" to inherit the active module accent.
 */
function Badge({
  tone = 'neutral',
  dot = false,
  className = '',
  children,
  ...rest
}) {
  const cls = ['bc-badge', `bc-badge--${tone}`, className].filter(Boolean).join(' ');
  return /*#__PURE__*/React.createElement("span", _extends({
    className: cls
  }, rest), dot && /*#__PURE__*/React.createElement("span", {
    className: "bc-badge__dot",
    "aria-hidden": "true"
  }), children);
}
Object.assign(__ds_scope, { Badge });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/data-display/Badge.jsx", error: String((e && e.message) || e) }); }

// components/data-display/Card.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
/**
 * basecamp Card — rounded surface container. Compose freely.
 * `interactive` adds hover lift; pass `as="button"`/`onClick` for tappable cards.
 */
function Card({
  variant = 'raised',
  interactive = false,
  as = 'div',
  className = '',
  children,
  ...rest
}) {
  const Tag = as;
  const cls = ['bc-card', `bc-card--${variant}`, interactive ? 'bc-card--interactive' : '', className].filter(Boolean).join(' ');
  return /*#__PURE__*/React.createElement(Tag, _extends({
    className: cls
  }, rest), children);
}
Object.assign(__ds_scope, { Card });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/data-display/Card.jsx", error: String((e && e.message) || e) }); }

// components/data-display/ListItem.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
/**
 * basecamp ListItem — a row with optional leading icon, title, subtitle, and
 * trailing content. Pass `onClick` to make it a tappable button row; pass
 * `done` to render the title with a completed (struck-through) style.
 */
function ListItem({
  lead,
  title,
  subtitle,
  trailing,
  done = false,
  onClick,
  className = '',
  ...rest
}) {
  const interactive = !!onClick;
  const Tag = interactive ? 'button' : 'div';
  const cls = ['bc-listitem', interactive ? 'bc-listitem--button' : '', className].filter(Boolean).join(' ');
  return /*#__PURE__*/React.createElement(Tag, _extends({
    className: cls,
    onClick: onClick,
    type: interactive ? 'button' : undefined
  }, rest), lead && /*#__PURE__*/React.createElement("span", {
    className: "bc-listitem__lead"
  }, lead), /*#__PURE__*/React.createElement("span", {
    className: "bc-listitem__body"
  }, /*#__PURE__*/React.createElement("span", {
    className: `bc-listitem__title${done ? ' bc-listitem__title--done' : ''}`
  }, title), subtitle && /*#__PURE__*/React.createElement("span", {
    className: "bc-listitem__sub"
  }, subtitle)), trailing != null && /*#__PURE__*/React.createElement("span", {
    className: "bc-listitem__trail"
  }, trailing));
}
Object.assign(__ds_scope, { ListItem });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/data-display/ListItem.jsx", error: String((e && e.message) || e) }); }

// components/data-display/ProgressRing.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
/**
 * basecamp ProgressRing — circular progress, module-aware stroke.
 * `value` is 0–100. Renders its own % label unless `label` is supplied
 * (pass `label={null}` for no label, or a node like a duration).
 */
function ProgressRing({
  value = 0,
  size = 64,
  thickness = 6,
  label,
  className = '',
  ...rest
}) {
  const v = Math.max(0, Math.min(100, value));
  const r = (size - thickness) / 2;
  const c = 2 * Math.PI * r;
  const offset = c * (1 - v / 100);
  const content = label === undefined ? `${Math.round(v)}%` : label;
  return /*#__PURE__*/React.createElement("span", _extends({
    className: ['bc-ring', className].filter(Boolean).join(' '),
    style: {
      width: size,
      height: size
    },
    role: "img",
    "aria-label": `${Math.round(v)} percent`
  }, rest), /*#__PURE__*/React.createElement("svg", {
    width: size,
    height: size,
    viewBox: `0 0 ${size} ${size}`
  }, /*#__PURE__*/React.createElement("circle", {
    className: "bc-ring__track",
    cx: size / 2,
    cy: size / 2,
    r: r,
    strokeWidth: thickness
  }), /*#__PURE__*/React.createElement("circle", {
    className: "bc-ring__fill",
    cx: size / 2,
    cy: size / 2,
    r: r,
    strokeWidth: thickness,
    strokeDasharray: c,
    strokeDashoffset: offset
  })), content !== null && /*#__PURE__*/React.createElement("span", {
    className: "bc-ring__label",
    style: {
      fontSize: Math.max(11, size * 0.24)
    }
  }, content));
}
Object.assign(__ds_scope, { ProgressRing });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/data-display/ProgressRing.jsx", error: String((e && e.message) || e) }); }

// components/data-display/Stat.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
/**
 * basecamp Stat — a big tabular number with an uppercase label. For dashboard
 * readouts (steps, streaks, totals). Pass `unit` for a small superscript suffix.
 */
function Stat({
  value,
  unit,
  label,
  className = '',
  ...rest
}) {
  return /*#__PURE__*/React.createElement("div", _extends({
    className: ['bc-stat', className].filter(Boolean).join(' ')
  }, rest), /*#__PURE__*/React.createElement("span", {
    className: "bc-stat__value"
  }, value, unit && /*#__PURE__*/React.createElement("sup", null, unit)), label && /*#__PURE__*/React.createElement("span", {
    className: "bc-stat__label"
  }, label));
}
Object.assign(__ds_scope, { Stat });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/data-display/Stat.jsx", error: String((e && e.message) || e) }); }

// components/data-display/Tag.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
const X = /*#__PURE__*/React.createElement("svg", {
  viewBox: "0 0 24 24",
  fill: "none",
  "aria-hidden": "true"
}, /*#__PURE__*/React.createElement("path", {
  d: "M6 6l12 12M18 6L6 18",
  stroke: "currentColor",
  strokeWidth: "2",
  strokeLinecap: "round"
}));

/**
 * basecamp Tag — input/filter chip. Pass `onRemove` to render a × button.
 */
function Tag({
  onRemove,
  className = '',
  children,
  ...rest
}) {
  const cls = ['bc-tag', onRemove ? '' : 'bc-tag--plain', className].filter(Boolean).join(' ');
  return /*#__PURE__*/React.createElement("span", _extends({
    className: cls
  }, rest), children, onRemove && /*#__PURE__*/React.createElement("button", {
    type: "button",
    className: "bc-tag__x",
    "aria-label": "Remove",
    onClick: onRemove
  }, X));
}
Object.assign(__ds_scope, { Tag });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/data-display/Tag.jsx", error: String((e && e.message) || e) }); }

// components/forms/Checkbox.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
const Check = /*#__PURE__*/React.createElement("svg", {
  viewBox: "0 0 24 24",
  fill: "none",
  "aria-hidden": "true"
}, /*#__PURE__*/React.createElement("path", {
  d: "M5 12.5L10 17.5L19 7",
  stroke: "currentColor",
  strokeWidth: "2.5",
  strokeLinecap: "round",
  strokeLinejoin: "round"
}));

/**
 * basecamp Checkbox — label + animated checkmark. Module-aware checked fill.
 * Use `label` for a text row, or pass children for custom content.
 */
function Checkbox({
  label,
  checked,
  defaultChecked,
  onChange,
  disabled = false,
  className = '',
  children,
  ...rest
}) {
  return /*#__PURE__*/React.createElement("label", {
    className: ['bc-check', className].filter(Boolean).join(' ')
  }, /*#__PURE__*/React.createElement("input", _extends({
    type: "checkbox",
    checked: checked,
    defaultChecked: defaultChecked,
    onChange: onChange,
    disabled: disabled
  }, rest)), /*#__PURE__*/React.createElement("span", {
    className: "bc-check__box",
    "aria-hidden": "true"
  }, Check), (label || children) && /*#__PURE__*/React.createElement("span", null, label || children));
}
Object.assign(__ds_scope, { Checkbox });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/forms/Checkbox.jsx", error: String((e && e.message) || e) }); }

// components/forms/Input.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
/**
 * basecamp Input — text field with optional label, hint, and error.
 * Renders a <textarea> when `multiline` is set. Forwards the rest to the control.
 */
function Input({
  label,
  hint,
  error,
  multiline = false,
  rows = 3,
  id,
  className = '',
  ...rest
}) {
  const autoId = React.useId();
  const fieldId = id || autoId;
  const hintId = hint || error ? `${fieldId}-hint` : undefined;
  const Control = multiline ? 'textarea' : 'input';
  return /*#__PURE__*/React.createElement("div", {
    className: ['bc-field', className].filter(Boolean).join(' ')
  }, label && /*#__PURE__*/React.createElement("label", {
    className: "bc-field__label",
    htmlFor: fieldId
  }, label), /*#__PURE__*/React.createElement(Control, _extends({
    id: fieldId,
    className: "bc-input",
    "aria-invalid": error ? 'true' : undefined,
    "aria-describedby": hintId,
    rows: multiline ? rows : undefined
  }, rest)), (error || hint) && /*#__PURE__*/React.createElement("span", {
    id: hintId,
    className: `bc-field__hint${error ? ' bc-field__hint--error' : ''}`
  }, error || hint));
}
Object.assign(__ds_scope, { Input });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/forms/Input.jsx", error: String((e && e.message) || e) }); }

// components/forms/SegmentedControl.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
/**
 * basecamp SegmentedControl — pill-track single-select. Great for switching
 * Timer / Stopwatch / Alarm, or list filters. Controlled by `value` + `onChange`.
 */
function SegmentedControl({
  options = [],
  value,
  onChange,
  className = '',
  ...rest
}) {
  const items = options.map(o => typeof o === 'string' ? {
    value: o,
    label: o
  } : o);
  return /*#__PURE__*/React.createElement("div", _extends({
    className: ['bc-segmented', className].filter(Boolean).join(' '),
    role: "tablist"
  }, rest), items.map(it => /*#__PURE__*/React.createElement("button", {
    key: it.value,
    role: "tab",
    type: "button",
    className: "bc-segmented__opt",
    "aria-selected": value === it.value,
    onClick: () => onChange && onChange(it.value)
  }, it.label)));
}
Object.assign(__ds_scope, { SegmentedControl });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/forms/SegmentedControl.jsx", error: String((e && e.message) || e) }); }

// components/forms/Switch.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
/**
 * basecamp Switch — on/off toggle. Module-aware checked color.
 * Controlled via `checked` + `onChange`, or uncontrolled via `defaultChecked`.
 */
function Switch({
  checked,
  defaultChecked,
  onChange,
  disabled = false,
  className = '',
  ...rest
}) {
  return /*#__PURE__*/React.createElement("label", {
    className: ['bc-switch', className].filter(Boolean).join(' ')
  }, /*#__PURE__*/React.createElement("input", _extends({
    type: "checkbox",
    role: "switch",
    checked: checked,
    defaultChecked: defaultChecked,
    onChange: onChange,
    disabled: disabled
  }, rest)), /*#__PURE__*/React.createElement("span", {
    className: "bc-switch__track",
    "aria-hidden": "true"
  }), /*#__PURE__*/React.createElement("span", {
    className: "bc-switch__thumb",
    "aria-hidden": "true"
  }));
}
Object.assign(__ds_scope, { Switch });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/forms/Switch.jsx", error: String((e && e.message) || e) }); }

// components/navigation/TabBar.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
/**
 * basecamp TabBar — bottom navigation for the app shell. Items: { value, label, icon }.
 * The active item adopts the active module accent. Controlled by `value` + `onChange`.
 *
 * Pass `centerAction` ({ icon, label, onClick }) to render a raised brand FAB between the
 * items — the "launcher" pattern basecamp uses (Home · ⊕ Add · Activity). The FAB is an
 * action, not a selectable tab, so it never carries the selected state.
 */
function TabBar({
  items = [],
  value,
  onChange,
  centerAction = null,
  className = '',
  ...rest
}) {
  const mid = Math.ceil(items.length / 2);
  const left = centerAction ? items.slice(0, mid) : items;
  const right = centerAction ? items.slice(mid) : [];
  const renderItem = it => /*#__PURE__*/React.createElement("button", {
    key: it.value,
    type: "button",
    className: "bc-tabbar__item",
    "aria-selected": value === it.value,
    "aria-label": it.label,
    onClick: () => onChange && onChange(it.value)
  }, it.icon, /*#__PURE__*/React.createElement("span", null, it.label));
  return /*#__PURE__*/React.createElement("nav", _extends({
    className: ['bc-tabbar', className].filter(Boolean).join(' ')
  }, rest), left.map(renderItem), centerAction && /*#__PURE__*/React.createElement("button", {
    type: "button",
    className: "bc-tabbar__add",
    "aria-label": centerAction.label,
    onClick: centerAction.onClick
  }, centerAction.icon), right.map(renderItem));
}
Object.assign(__ds_scope, { TabBar });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/navigation/TabBar.jsx", error: String((e && e.message) || e) }); }

// ui_kits/basecamp-app/ActivityScreen.jsx
try { (() => {
/* basecamp UI kit — Activity (completion feed + insights header; solo or friends). */
const {
  Card,
  Badge,
  Stat,
  ListItem,
  Avatar,
  SegmentedControl
} = window.BasecampDesignSystem_e1341e;
const VI = window.BC.Icons;
const modIcon = {
  lists: /*#__PURE__*/React.createElement(VI.list, null),
  workouts: /*#__PURE__*/React.createElement(VI.dumbbell, null),
  clock: /*#__PURE__*/React.createElement(VI.clock, null)
};
function Spark() {
  const data = [['M', 4], ['T', 6], ['W', 3], ['T', 7], ['F', 5], ['S', 2], ['S', 6]];
  const max = 8;
  return /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement("div", {
    className: "bc-spark"
  }, data.map(([d, v], i) => /*#__PURE__*/React.createElement("div", {
    key: i,
    className: 'bc-spark__bar' + (i === 6 ? ' bc-spark__bar--on' : ''),
    style: {
      height: v / max * 100 + '%'
    }
  }))), /*#__PURE__*/React.createElement("div", {
    className: "bc-spark__days"
  }, data.map(([d], i) => /*#__PURE__*/React.createElement("span", {
    key: i
  }, d))));
}
const SOLO = {
  Today: [{
    icon: 'workouts',
    title: 'Finished Evening run',
    sub: '5.2 km · easy pace',
    time: '6:12 PM'
  }, {
    icon: 'lists',
    title: 'Checked off "Oat milk"',
    sub: 'Groceries',
    time: '9:03 AM'
  }, {
    icon: 'lists',
    title: 'Completed Morning routine',
    sub: '6 of 6 done',
    time: '8:15 AM'
  }],
  Yesterday: [{
    icon: 'workouts',
    title: 'Finished Upper body',
    sub: '5 exercises · 320 kg',
    time: '7:40 AM'
  }, {
    icon: 'clock',
    title: 'Pasta timer done',
    sub: '8:00',
    time: '8:30 PM'
  }, {
    icon: 'lists',
    title: 'Checked off "Finish chapter 4"',
    sub: 'Reading list',
    time: '10:15 PM'
  }]
};
const FRIENDS = {
  Today: [{
    who: 'Maya Rivera',
    title: 'completed Morning yoga',
    sub: 'Workouts',
    time: '7:30 AM',
    kudos: 4
  }, {
    who: 'Sam Okafor',
    title: 'finished Trip packing',
    sub: 'Lists · 12 items',
    time: '11:02 AM',
    kudos: 2
  }],
  Yesterday: [{
    who: 'Jordan Lee',
    title: 'ran a 10 km route',
    sub: 'Workouts · new distance PR',
    time: '6:45 PM',
    kudos: 9
  }, {
    who: 'Maya Rivera',
    title: 'hit a 14-day streak',
    sub: 'Daily reading',
    time: '9:20 PM',
    kudos: 6
  }]
};
function ActivityScreen() {
  const [scope, setScope] = React.useState('You');
  const feed = scope === 'You' ? SOLO : FRIENDS;
  return /*#__PURE__*/React.createElement("div", {
    className: "bc-screenroot",
    "data-module": "home"
  }, /*#__PURE__*/React.createElement("div", {
    className: "bc-screen"
  }, /*#__PURE__*/React.createElement("div", {
    className: "bc-screen__pad"
  }, /*#__PURE__*/React.createElement("div", {
    className: "bc-screenhead bc-screenhead--lg",
    style: {
      paddingBottom: 6
    }
  }, /*#__PURE__*/React.createElement("h1", {
    className: "bc-screenhead__title"
  }, "Activity")), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      justifyContent: 'center'
    }
  }, /*#__PURE__*/React.createElement(SegmentedControl, {
    options: ['You', 'Friends'],
    value: scope,
    onChange: setScope
  })), scope === 'You' && /*#__PURE__*/React.createElement(Card, {
    variant: "raised"
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      justifyContent: 'space-between',
      alignItems: 'flex-start',
      marginBottom: 16
    }
  }, /*#__PURE__*/React.createElement(Stat, {
    value: "18",
    label: "Done this week"
  }), /*#__PURE__*/React.createElement(Stat, {
    value: "5",
    unit: "day",
    label: "Streak"
  }), /*#__PURE__*/React.createElement("span", {
    className: "bc-kudos",
    style: {
      alignSelf: 'center'
    }
  }, /*#__PURE__*/React.createElement(VI.trending, null), " +12%")), /*#__PURE__*/React.createElement(Spark, null)), scope === 'Friends' && /*#__PURE__*/React.createElement(Card, {
    variant: "flat",
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 12
    }
  }, /*#__PURE__*/React.createElement("span", {
    className: "bc-feedlead"
  }, /*#__PURE__*/React.createElement(VI.users, null)), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      font: 'var(--type-subhead)',
      color: 'var(--text-primary)'
    }
  }, "3 friends were active today"), /*#__PURE__*/React.createElement("div", {
    style: {
      font: 'var(--type-caption)',
      color: 'var(--text-tertiary)',
      marginTop: 2
    }
  }, "Cheer them on with a tap"))), Object.entries(feed).map(([day, rows]) => /*#__PURE__*/React.createElement("div", {
    key: day
  }, /*#__PURE__*/React.createElement("div", {
    className: "bc-daygroup"
  }, day), /*#__PURE__*/React.createElement(Card, {
    variant: "outlined",
    style: {
      padding: 6,
      marginTop: 10
    }
  }, /*#__PURE__*/React.createElement("div", {
    className: "bc-rows"
  }, rows.map((r, i) => scope === 'You' ? /*#__PURE__*/React.createElement(ListItem, {
    key: i,
    lead: /*#__PURE__*/React.createElement("span", {
      className: "bc-feedlead"
    }, modIcon[r.icon]),
    title: r.title,
    subtitle: r.sub,
    trailing: /*#__PURE__*/React.createElement("span", {
      style: {
        font: 'var(--type-caption)',
        color: 'var(--text-tertiary)',
        fontFamily: 'var(--font-numeric)',
        fontVariantNumeric: 'tabular-nums'
      }
    }, r.time)
  }) : /*#__PURE__*/React.createElement(ListItem, {
    key: i,
    lead: /*#__PURE__*/React.createElement(Avatar, {
      name: r.who,
      size: "md"
    }),
    title: /*#__PURE__*/React.createElement("span", null, /*#__PURE__*/React.createElement("b", {
      style: {
        fontWeight: 700
      }
    }, r.who.split(' ')[0]), " ", r.title),
    subtitle: `${r.sub} · ${r.time}`,
    trailing: /*#__PURE__*/React.createElement("span", {
      className: "bc-kudos"
    }, /*#__PURE__*/React.createElement(VI.heart, null), " ", r.kudos)
  })))))))));
}
window.BC.Screens = window.BC.Screens || {};
window.BC.Screens.Activity = ActivityScreen;
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/basecamp-app/ActivityScreen.jsx", error: String((e && e.message) || e) }); }

// ui_kits/basecamp-app/AddSheet.jsx
try { (() => {
/* basecamp UI kit — Add sheet: global quick-capture bottom sheet. */
const {
  Button
} = window.BasecampDesignSystem_e1341e;
const DI = window.BC.Icons;
const DESTS = [{
  value: 'list',
  label: 'List item',
  icon: /*#__PURE__*/React.createElement(DI.list, null)
}, {
  value: 'workout',
  label: 'Workout',
  icon: /*#__PURE__*/React.createElement(DI.dumbbell, null)
}, {
  value: 'timer',
  label: 'Timer',
  icon: /*#__PURE__*/React.createElement(DI.clock, null)
}, {
  value: 'alarm',
  label: 'Alarm',
  icon: /*#__PURE__*/React.createElement(DI.bell, null)
}];

// Light inference: a time-like string nudges the destination toward Timer/Alarm.
function infer(text) {
  if (/\b\d{1,2}:\d{2}\b|\b\d+\s?(min|sec|m|s)\b/i.test(text)) return 'timer';
  if (/\b(\d{1,2})\s?(am|pm)\b/i.test(text)) return 'alarm';
  return null;
}
function AddSheet({
  onClose,
  onAdd
}) {
  const [text, setText] = React.useState('');
  const [dest, setDest] = React.useState('list');
  const [touched, setTouched] = React.useState(false);
  const inputRef = React.useRef(null);
  React.useEffect(() => {
    const t = setTimeout(() => inputRef.current && inputRef.current.focus(), 280);
    return () => clearTimeout(t);
  }, []);
  const onType = e => {
    const v = e.target.value;
    setText(v);
    if (!touched) {
      const g = infer(v);
      if (g) setDest(g);
    }
  };
  const submit = () => {
    if (text.trim()) onAdd && onAdd({
      text: text.trim(),
      dest
    });
    onClose && onClose();
  };
  return /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement("div", {
    className: "bc-scrim",
    onClick: onClose
  }), /*#__PURE__*/React.createElement("div", {
    className: "bc-sheet",
    role: "dialog",
    "aria-label": "Quick add"
  }, /*#__PURE__*/React.createElement("div", {
    className: "bc-sheet__grab"
  }), /*#__PURE__*/React.createElement("div", {
    className: "bc-sheet__title"
  }, "Quick add"), /*#__PURE__*/React.createElement("input", {
    ref: inputRef,
    className: "bc-sheet__field",
    placeholder: "What's on your mind?",
    value: text,
    onChange: onType,
    onKeyDown: e => e.key === 'Enter' && submit()
  }), /*#__PURE__*/React.createElement("div", {
    className: "bc-sheet__lbl"
  }, "Add to"), /*#__PURE__*/React.createElement("div", {
    className: "bc-chips"
  }, DESTS.map(d => /*#__PURE__*/React.createElement("button", {
    key: d.value,
    className: "bc-chip",
    "aria-pressed": dest === d.value,
    onClick: () => {
      setDest(d.value);
      setTouched(true);
    }
  }, d.icon, d.label))), /*#__PURE__*/React.createElement("div", {
    style: {
      marginTop: 20
    }
  }, /*#__PURE__*/React.createElement(Button, {
    variant: "primary",
    size: "lg",
    block: true,
    onClick: submit,
    disabled: !text.trim()
  }, "Add"))));
}
window.BC.AddSheet = AddSheet;
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/basecamp-app/AddSheet.jsx", error: String((e && e.message) || e) }); }

// ui_kits/basecamp-app/BriefScreen.jsx
try { (() => {
/* basecamp UI kit — Brief: the forward-looking daily digest ("what's now / next"). */
const {
  Card,
  Badge,
  ProgressRing,
  Avatar,
  ListItem
} = window.BasecampDesignSystem_e1341e;
const BRI = window.BC.Icons;
const briefIcon = {
  lists: /*#__PURE__*/React.createElement(BRI.list, null),
  workouts: /*#__PURE__*/React.createElement(BRI.dumbbell, null),
  clock: /*#__PURE__*/React.createElement(BRI.clock, null)
};
function BriefScreen({
  go
}) {
  const today = [{
    mod: 'workouts',
    title: 'Evening run',
    sub: '5 km · easy pace',
    time: '6:00 PM'
  }, {
    mod: 'lists',
    title: 'Take out the trash',
    sub: 'Household',
    time: '7:30 PM'
  }, {
    mod: 'clock',
    title: 'Wind down',
    sub: 'Bedtime reminder',
    time: '9:00 PM'
  }];
  const later = [{
    mod: 'lists',
    title: 'Dentist appointment',
    sub: 'Wed · 2:00 PM'
  }, {
    mod: 'workouts',
    title: 'Long run',
    sub: 'Thu · 7:00 AM'
  }];
  return /*#__PURE__*/React.createElement("div", {
    className: "bc-screen",
    "data-module": "home"
  }, /*#__PURE__*/React.createElement("div", {
    className: "bc-screen__pad"
  }, /*#__PURE__*/React.createElement("div", {
    className: "bc-hero"
  }, /*#__PURE__*/React.createElement("div", {
    className: "bc-hero__top"
  }, /*#__PURE__*/React.createElement("div", {
    className: "bc-hero__date"
  }, "Tuesday \xB7 Jun 16"), /*#__PURE__*/React.createElement("button", {
    className: "bc-avatarbtn",
    "aria-label": "Profile",
    onClick: () => go && go('modules')
  }, /*#__PURE__*/React.createElement(Avatar, {
    name: "Riley Chen",
    size: "lg"
  }))), /*#__PURE__*/React.createElement("div", {
    className: "bc-hero__hi"
  }, "Good morning, Riley")), /*#__PURE__*/React.createElement(Card, {
    variant: "raised",
    className: "bc-summary"
  }, /*#__PURE__*/React.createElement(ProgressRing, {
    value: 60,
    size: 64,
    label: /*#__PURE__*/React.createElement("b", {
      style: {
        fontSize: '15px'
      }
    }, "60%")
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      marginLeft: 16
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      font: 'var(--type-subhead)',
      color: 'var(--text-primary)'
    }
  }, "3 of 5 done today"), /*#__PURE__*/React.createElement("div", {
    style: {
      font: 'var(--type-caption)',
      color: 'var(--text-tertiary)',
      marginTop: 2
    }
  }, "Nice pace \u2014 2 things left")), /*#__PURE__*/React.createElement(Badge, {
    tone: "success",
    dot: true
  }, "On track")), /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement("div", {
    className: "bc-section"
  }, /*#__PURE__*/React.createElement("span", {
    className: "bc-section__t"
  }, "Up next today"), /*#__PURE__*/React.createElement("span", {
    className: "bc-section__a",
    onClick: () => go && go('calendar')
  }, "Calendar")), /*#__PURE__*/React.createElement(Card, {
    variant: "outlined",
    style: {
      padding: 6,
      marginTop: 12
    }
  }, /*#__PURE__*/React.createElement("div", {
    className: "bc-rows"
  }, today.map((r, i) => /*#__PURE__*/React.createElement("div", {
    key: i,
    "data-module": r.mod,
    style: {
      display: 'contents'
    }
  }, /*#__PURE__*/React.createElement(ListItem, {
    lead: briefIcon[r.mod],
    title: r.title,
    subtitle: r.sub,
    trailing: /*#__PURE__*/React.createElement("span", {
      className: "bc-time"
    }, r.time),
    onClick: () => go && go(r.mod)
  })))))), /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement("div", {
    className: "bc-section"
  }, /*#__PURE__*/React.createElement("span", {
    className: "bc-section__t"
  }, "Later this week")), /*#__PURE__*/React.createElement(Card, {
    variant: "outlined",
    style: {
      padding: 6,
      marginTop: 12
    }
  }, /*#__PURE__*/React.createElement("div", {
    className: "bc-rows"
  }, later.map((r, i) => /*#__PURE__*/React.createElement("div", {
    key: i,
    "data-module": r.mod,
    style: {
      display: 'contents'
    }
  }, /*#__PURE__*/React.createElement(ListItem, {
    lead: briefIcon[r.mod],
    title: r.title,
    subtitle: r.sub,
    trailing: /*#__PURE__*/React.createElement(BRI.chevronRight, {
      style: {
        width: 18,
        height: 18
      }
    }),
    onClick: () => go && go('calendar')
  }))))))));
}
window.BC.Screens = window.BC.Screens || {};
window.BC.Screens.Brief = BriefScreen;
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/basecamp-app/BriefScreen.jsx", error: String((e && e.message) || e) }); }

// ui_kits/basecamp-app/CalendarScreen.jsx
try { (() => {
/* basecamp UI kit — Calendar: cross-module view of every dated item. Week (default) / Month. */
const {
  Card,
  SegmentedControl,
  ListItem
} = window.BasecampDesignSystem_e1341e;
const CAL = window.BC.Icons;
const calIcon = {
  lists: /*#__PURE__*/React.createElement(CAL.list, null),
  workouts: /*#__PURE__*/React.createElement(CAL.dumbbell, null),
  clock: /*#__PURE__*/React.createElement(CAL.clock, null)
};
const DOW = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
const WEEKDAY = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
const MONTHS = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

// Fictional "today" for the kit; items keyed by day-of-month (all June 2026).
const TODAY = new Date(2026, 5, 16);
const ITEMS = {
  13: [{
    mod: 'clock',
    title: 'Rest day',
    sub: 'No alarms'
  }],
  15: [{
    mod: 'workouts',
    title: 'Upper body',
    sub: '5 exercises',
    time: '7:00 AM'
  }, {
    mod: 'lists',
    title: 'Team lunch',
    sub: 'Work',
    time: '12:30 PM'
  }],
  16: [{
    mod: 'workouts',
    title: 'Evening run',
    sub: '5 km · easy',
    time: '6:00 PM'
  }, {
    mod: 'lists',
    title: 'Take out the trash',
    sub: 'Household',
    time: '7:30 PM'
  }, {
    mod: 'clock',
    title: 'Wind down',
    sub: 'Bedtime',
    time: '9:00 PM'
  }],
  17: [{
    mod: 'lists',
    title: 'Dentist appointment',
    sub: 'Health',
    time: '2:00 PM'
  }, {
    mod: 'lists',
    title: 'Grocery run',
    sub: 'Errands',
    time: '5:30 PM'
  }],
  18: [{
    mod: 'workouts',
    title: 'Long run',
    sub: '12 km',
    time: '7:00 AM'
  }],
  20: [{
    mod: 'lists',
    title: 'Trip packing',
    sub: 'Due',
    time: 'All day'
  }]
};
const mondayIndex = d => (d.getDay() + 6) % 7;
function DayAgenda({
  date
}) {
  const rows = ITEMS[date.getDate()] || [];
  return /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement("div", {
    className: "bc-daygroup"
  }, WEEKDAY[mondayIndex(date)], ", ", MONTHS[date.getMonth()], " ", date.getDate()), rows.length ? /*#__PURE__*/React.createElement(Card, {
    variant: "outlined",
    style: {
      padding: 6,
      marginTop: 10
    }
  }, /*#__PURE__*/React.createElement("div", {
    className: "bc-rows"
  }, rows.map((r, i) => /*#__PURE__*/React.createElement("div", {
    key: i,
    "data-module": r.mod,
    style: {
      display: 'contents'
    }
  }, /*#__PURE__*/React.createElement(ListItem, {
    lead: /*#__PURE__*/React.createElement("span", {
      className: "bc-feedlead"
    }, calIcon[r.mod]),
    title: r.title,
    subtitle: r.sub,
    trailing: r.time ? /*#__PURE__*/React.createElement("span", {
      className: "bc-time"
    }, r.time) : null
  }))))) : /*#__PURE__*/React.createElement(Card, {
    variant: "flat",
    style: {
      marginTop: 10,
      textAlign: 'center',
      color: 'var(--text-tertiary)',
      font: 'var(--type-body)',
      padding: '22px'
    }
  }, "Nothing scheduled."));
}
function WeekView({
  selected,
  onSelect
}) {
  const start = new Date(selected);
  start.setDate(selected.getDate() - mondayIndex(selected));
  const days = [...Array(7)].map((_, i) => {
    const d = new Date(start);
    d.setDate(start.getDate() + i);
    return d;
  });
  return /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement(Card, {
    variant: "raised",
    style: {
      padding: '12px 10px'
    }
  }, /*#__PURE__*/React.createElement("div", {
    className: "bc-cal-week"
  }, days.map((d, i) => {
    const sel = d.getDate() === selected.getDate();
    const isToday = d.getDate() === TODAY.getDate();
    const has = !!ITEMS[d.getDate()];
    return /*#__PURE__*/React.createElement("button", {
      key: i,
      className: 'bc-cal-day' + (sel ? ' is-sel' : '') + (isToday ? ' is-today' : ''),
      "aria-selected": sel,
      onClick: () => onSelect(new Date(d))
    }, /*#__PURE__*/React.createElement("span", {
      className: "bc-cal-day__dow"
    }, DOW[i]), /*#__PURE__*/React.createElement("span", {
      className: "bc-cal-day__num"
    }, d.getDate()), /*#__PURE__*/React.createElement("span", {
      className: "bc-cal-day__dot",
      style: {
        visibility: has ? 'visible' : 'hidden'
      }
    }));
  }))), /*#__PURE__*/React.createElement(DayAgenda, {
    date: selected
  }));
}
function MonthView({
  selected,
  onSelect
}) {
  const y = 2026,
    m = 5;
  const first = new Date(y, m, 1);
  const pad = mondayIndex(first);
  const dim = new Date(y, m + 1, 0).getDate();
  const cells = [...Array(pad).fill(null), ...[...Array(dim)].map((_, i) => i + 1)];
  while (cells.length % 7) cells.push(null);
  return /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement(Card, {
    variant: "raised",
    style: {
      padding: '14px 12px'
    }
  }, /*#__PURE__*/React.createElement("div", {
    className: "bc-cal-mtitle"
  }, MONTHS[m], " ", y), /*#__PURE__*/React.createElement("div", {
    className: "bc-cal-month"
  }, DOW.map((d, i) => /*#__PURE__*/React.createElement("div", {
    key: 'h' + i,
    className: "bc-cal-mdow"
  }, d)), cells.map((n, i) => {
    if (!n) return /*#__PURE__*/React.createElement("span", {
      key: i
    });
    const sel = n === selected.getDate();
    const isToday = n === TODAY.getDate();
    const has = !!ITEMS[n];
    return /*#__PURE__*/React.createElement("button", {
      key: i,
      className: 'bc-cal-cell' + (isToday ? ' is-today' : ''),
      "aria-selected": sel,
      onClick: () => onSelect(new Date(y, m, n))
    }, /*#__PURE__*/React.createElement("span", {
      className: "bc-cal-cell__num"
    }, n), /*#__PURE__*/React.createElement("span", {
      className: "bc-cal-cell__dot",
      style: {
        visibility: has ? 'visible' : 'hidden'
      }
    }));
  }))), /*#__PURE__*/React.createElement(DayAgenda, {
    date: selected
  }));
}
function CalendarScreen() {
  const [mode, setMode] = React.useState('Week');
  const [selected, setSelected] = React.useState(new Date(TODAY));
  return /*#__PURE__*/React.createElement("div", {
    className: "bc-screen",
    "data-module": "home"
  }, /*#__PURE__*/React.createElement("div", {
    className: "bc-screen__pad"
  }, /*#__PURE__*/React.createElement("div", {
    className: "bc-screenhead bc-screenhead--lg",
    style: {
      paddingBottom: 8
    }
  }, /*#__PURE__*/React.createElement("h1", {
    className: "bc-screenhead__title"
  }, "Calendar")), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      justifyContent: 'center'
    }
  }, /*#__PURE__*/React.createElement(SegmentedControl, {
    options: ['Week', 'Month'],
    value: mode,
    onChange: setMode
  })), mode === 'Week' ? /*#__PURE__*/React.createElement(WeekView, {
    selected: selected,
    onSelect: setSelected
  }) : /*#__PURE__*/React.createElement(MonthView, {
    selected: selected,
    onSelect: setSelected
  })));
}
window.BC.Screens = window.BC.Screens || {};
window.BC.Screens.Calendar = CalendarScreen;
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/basecamp-app/CalendarScreen.jsx", error: String((e && e.message) || e) }); }

// ui_kits/basecamp-app/ClockScreen.jsx
try { (() => {
/* basecamp UI kit — Clock module (Timer / Stopwatch / Alarm). */
const {
  Card,
  Badge,
  ProgressRing,
  ListItem,
  SegmentedControl,
  Switch,
  IconButton
} = window.BasecampDesignSystem_e1341e;
const CI = window.BC.Icons;
const pad = n => String(n).padStart(2, '0');
const fmtTimer = s => `${pad(Math.floor(s / 60))}:${pad(s % 60)}`;
function RoundBtn({
  kind,
  icon,
  label,
  onClick
}) {
  return /*#__PURE__*/React.createElement("button", {
    className: `bc-round bc-round--${kind}`,
    onClick: onClick,
    "aria-label": label
  }, icon);
}
function TimerView() {
  const TOTAL = 300;
  const [left, setLeft] = React.useState(TOTAL);
  const [run, setRun] = React.useState(false);
  React.useEffect(() => {
    if (!run) return;
    const t = setInterval(() => setLeft(x => x <= 1 ? (clearInterval(t), setRun(false), 0) : x - 1), 1000);
    return () => clearInterval(t);
  }, [run]);
  const pct = left / TOTAL * 100;
  return /*#__PURE__*/React.createElement("div", {
    className: "bc-timer"
  }, /*#__PURE__*/React.createElement("div", {
    className: "bc-timer__ring"
  }, /*#__PURE__*/React.createElement(ProgressRing, {
    value: pct,
    size: 244,
    thickness: 10,
    label: null
  }), /*#__PURE__*/React.createElement("div", {
    className: "bc-timer__center"
  }, /*#__PURE__*/React.createElement("div", {
    className: "bc-timer__readout"
  }, fmtTimer(left)), /*#__PURE__*/React.createElement("div", {
    className: "bc-timer__sub"
  }, run ? 'Focus' : left === 0 ? "Time's up" : 'Paused'))), /*#__PURE__*/React.createElement("div", {
    className: "bc-controls",
    style: {
      marginTop: 18
    }
  }, /*#__PURE__*/React.createElement(RoundBtn, {
    kind: "ghost",
    icon: /*#__PURE__*/React.createElement(CI.reset, null),
    label: "Reset",
    onClick: () => {
      setRun(false);
      setLeft(TOTAL);
    }
  }), /*#__PURE__*/React.createElement(RoundBtn, {
    kind: "primary",
    icon: run ? /*#__PURE__*/React.createElement(CI.pause, null) : /*#__PURE__*/React.createElement(CI.play, null),
    label: run ? 'Pause' : 'Start',
    onClick: () => setRun(r => !r)
  })));
}
function StopwatchView() {
  const [cs, setCs] = React.useState(0);
  const [run, setRun] = React.useState(false);
  const [laps, setLaps] = React.useState([]);
  React.useEffect(() => {
    if (!run) return;
    const t = setInterval(() => setCs(x => x + 1), 10);
    return () => clearInterval(t);
  }, [run]);
  const m = Math.floor(cs / 6000),
    s = Math.floor(cs % 6000 / 100),
    c = cs % 100;
  return /*#__PURE__*/React.createElement("div", {
    className: "bc-timer"
  }, /*#__PURE__*/React.createElement("div", {
    className: "bc-timer__readout",
    style: {
      marginTop: 36
    }
  }, pad(m), ":", pad(s), /*#__PURE__*/React.createElement("span", {
    className: "ms"
  }, ".", pad(c))), /*#__PURE__*/React.createElement("div", {
    className: "bc-timer__sub",
    style: {
      marginBottom: 6
    }
  }, "Stopwatch"), /*#__PURE__*/React.createElement("div", {
    className: "bc-controls",
    style: {
      marginTop: 14
    }
  }, /*#__PURE__*/React.createElement(RoundBtn, {
    kind: "ghost",
    icon: run ? /*#__PURE__*/React.createElement(CI.flag, null) : /*#__PURE__*/React.createElement(CI.reset, null),
    label: run ? 'Lap' : 'Reset',
    onClick: () => run ? setLaps(l => [{
      n: l.length + 1,
      t: cs
    }, ...l]) : (setCs(0), setLaps([]))
  }), /*#__PURE__*/React.createElement(RoundBtn, {
    kind: "primary",
    icon: run ? /*#__PURE__*/React.createElement(CI.pause, null) : /*#__PURE__*/React.createElement(CI.play, null),
    label: run ? 'Pause' : 'Start',
    onClick: () => setRun(r => !r)
  })), laps.length > 0 && /*#__PURE__*/React.createElement(Card, {
    variant: "outlined",
    style: {
      padding: 6,
      width: '100%',
      marginTop: 22
    }
  }, /*#__PURE__*/React.createElement("div", {
    className: "bc-rows"
  }, laps.map(l => {
    const lm = Math.floor(l.t / 6000),
      ls = Math.floor(l.t % 6000 / 100),
      lc = l.t % 100;
    return /*#__PURE__*/React.createElement(ListItem, {
      key: l.n,
      title: `Lap ${l.n}`,
      trailing: /*#__PURE__*/React.createElement("span", {
        style: {
          fontFamily: 'var(--font-numeric)',
          fontWeight: 600,
          fontVariantNumeric: 'tabular-nums',
          color: 'var(--text-secondary)'
        }
      }, pad(lm), ":", pad(ls), ".", pad(lc))
    });
  }))));
}
function AlarmView() {
  const [alarms, setAlarms] = React.useState([{
    id: 1,
    time: '6:30',
    meri: 'AM',
    label: 'Wake up',
    on: true,
    days: 'Mon–Fri'
  }, {
    id: 2,
    time: '7:30',
    meri: 'AM',
    label: 'Leave for gym',
    on: true,
    days: 'Weekdays'
  }, {
    id: 3,
    time: '9:00',
    meri: 'PM',
    label: 'Wind down',
    on: false,
    days: 'Every day'
  }]);
  const toggle = id => setAlarms(xs => xs.map(a => a.id === id ? {
    ...a,
    on: !a.on
  } : a));
  return /*#__PURE__*/React.createElement("div", {
    style: {
      paddingTop: 8
    }
  }, /*#__PURE__*/React.createElement(Card, {
    variant: "outlined",
    style: {
      padding: 6
    }
  }, /*#__PURE__*/React.createElement("div", {
    className: "bc-rows"
  }, alarms.map(a => /*#__PURE__*/React.createElement(ListItem, {
    key: a.id,
    lead: /*#__PURE__*/React.createElement(CI.bell, null),
    title: /*#__PURE__*/React.createElement("span", {
      style: {
        fontFamily: 'var(--font-numeric)',
        fontVariantNumeric: 'tabular-nums',
        fontSize: '22px',
        fontWeight: 700,
        color: a.on ? 'var(--text-primary)' : 'var(--text-tertiary)'
      }
    }, a.time, /*#__PURE__*/React.createElement("span", {
      style: {
        fontSize: '13px',
        marginLeft: 4
      }
    }, a.meri)),
    subtitle: `${a.label} · ${a.days}`,
    trailing: /*#__PURE__*/React.createElement(Switch, {
      checked: a.on,
      onChange: () => toggle(a.id),
      "aria-label": a.label
    })
  })))));
}
function ClockScreen({
  onBack
}) {
  const [mode, setMode] = React.useState('Timer');
  return /*#__PURE__*/React.createElement("div", {
    className: "bc-screenroot",
    "data-module": "clock"
  }, /*#__PURE__*/React.createElement("div", {
    className: "bc-screen"
  }, /*#__PURE__*/React.createElement("div", {
    className: "bc-screen__pad"
  }, /*#__PURE__*/React.createElement("div", {
    className: "bc-screenhead bc-screenhead--lg",
    style: {
      paddingBottom: 8
    }
  }, onBack && /*#__PURE__*/React.createElement(IconButton, {
    "aria-label": "Back",
    variant: "ghost",
    onClick: onBack
  }, /*#__PURE__*/React.createElement(CI.chevronLeft, null)), /*#__PURE__*/React.createElement("h1", {
    className: "bc-screenhead__title"
  }, "Clock"), /*#__PURE__*/React.createElement(IconButton, {
    "aria-label": "Add alarm",
    variant: "soft"
  }, /*#__PURE__*/React.createElement(CI.plus, null))), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      justifyContent: 'center'
    }
  }, /*#__PURE__*/React.createElement(SegmentedControl, {
    options: ['Timer', 'Stopwatch', 'Alarm'],
    value: mode,
    onChange: setMode
  })), mode === 'Timer' && /*#__PURE__*/React.createElement(TimerView, null), mode === 'Stopwatch' && /*#__PURE__*/React.createElement(StopwatchView, null), mode === 'Alarm' && /*#__PURE__*/React.createElement(AlarmView, null))));
}
window.BC.Screens = window.BC.Screens || {};
window.BC.Screens.Clock = ClockScreen;
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/basecamp-app/ClockScreen.jsx", error: String((e && e.message) || e) }); }

// ui_kits/basecamp-app/ListsScreen.jsx
try { (() => {
/* basecamp UI kit — Lists module (a list detail with checkable items). */
const {
  Card,
  Badge,
  ProgressRing,
  ListItem,
  Checkbox,
  SegmentedControl,
  IconButton,
  Button
} = window.BasecampDesignSystem_e1341e;
const LI = window.BC.Icons;
function ListsScreen({
  onBack
}) {
  const [items, setItems] = React.useState([{
    id: 1,
    text: 'Oat milk',
    done: true
  }, {
    id: 2,
    text: 'Sourdough loaf',
    done: false
  }, {
    id: 3,
    text: 'Cherry tomatoes',
    done: false
  }, {
    id: 4,
    text: 'Olive oil',
    done: true
  }, {
    id: 5,
    text: 'Coffee beans',
    done: false
  }, {
    id: 6,
    text: 'Dark chocolate',
    done: false
  }]);
  const [filter, setFilter] = React.useState('All');
  const [draft, setDraft] = React.useState('');
  const nextId = React.useRef(7);
  const toggle = id => setItems(xs => xs.map(i => i.id === id ? {
    ...i,
    done: !i.done
  } : i));
  const add = () => {
    const t = draft.trim();
    if (!t) return;
    setItems(xs => [...xs, {
      id: nextId.current++,
      text: t,
      done: false
    }]);
    setDraft('');
  };
  const done = items.filter(i => i.done).length;
  const shown = items.filter(i => filter === 'All' ? true : filter === 'Open' ? !i.done : i.done);
  return /*#__PURE__*/React.createElement("div", {
    className: "bc-screenroot",
    "data-module": "lists"
  }, /*#__PURE__*/React.createElement("div", {
    className: "bc-screen"
  }, /*#__PURE__*/React.createElement("div", {
    className: "bc-screen__pad"
  }, /*#__PURE__*/React.createElement("div", {
    className: "bc-screenhead bc-screenhead--lg"
  }, onBack && /*#__PURE__*/React.createElement(IconButton, {
    "aria-label": "Back",
    variant: "ghost",
    onClick: onBack
  }, /*#__PURE__*/React.createElement(LI.chevronLeft, null)), /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement("div", {
    className: "bc-screenhead__eyebrow"
  }, "List \xB7 Household"), /*#__PURE__*/React.createElement("h1", {
    className: "bc-screenhead__title"
  }, "Groceries")), /*#__PURE__*/React.createElement(IconButton, {
    "aria-label": "List options",
    variant: "soft"
  }, /*#__PURE__*/React.createElement(LI.more, null))), /*#__PURE__*/React.createElement(Card, {
    variant: "raised",
    className: "bc-summary"
  }, /*#__PURE__*/React.createElement(ProgressRing, {
    value: Math.round(done / items.length * 100),
    size: 56,
    label: /*#__PURE__*/React.createElement("b", {
      style: {
        fontSize: '13px'
      }
    }, done, "/", items.length)
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      marginLeft: 14
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      font: 'var(--type-subhead)',
      color: 'var(--text-primary)'
    }
  }, items.length - done, " left to grab"), /*#__PURE__*/React.createElement("div", {
    style: {
      font: 'var(--type-caption)',
      color: 'var(--text-tertiary)',
      marginTop: 2
    }
  }, "Updated 2m ago"))), /*#__PURE__*/React.createElement(SegmentedControl, {
    options: ['All', 'Open', 'Done'],
    value: filter,
    onChange: setFilter
  }), /*#__PURE__*/React.createElement(Card, {
    variant: "outlined",
    style: {
      padding: 6
    }
  }, /*#__PURE__*/React.createElement("div", {
    className: "bc-rows"
  }, shown.map(i => /*#__PURE__*/React.createElement(ListItem, {
    key: i.id,
    lead: /*#__PURE__*/React.createElement(Checkbox, {
      checked: i.done,
      onChange: () => toggle(i.id),
      "aria-label": i.text
    }),
    title: i.text,
    done: i.done,
    onClick: () => toggle(i.id)
  })), shown.length === 0 && /*#__PURE__*/React.createElement("div", {
    style: {
      padding: '22px',
      textAlign: 'center',
      color: 'var(--text-tertiary)',
      font: 'var(--type-body)'
    }
  }, "Nothing here yet."))))), /*#__PURE__*/React.createElement("div", {
    className: "bc-pinned"
  }, /*#__PURE__*/React.createElement(Card, {
    variant: "flat",
    className: "bc-addbar",
    style: {
      padding: 6
    }
  }, /*#__PURE__*/React.createElement(IconButton, {
    "aria-label": "Add item",
    variant: "solid",
    onClick: add
  }, /*#__PURE__*/React.createElement(LI.plus, null)), /*#__PURE__*/React.createElement("input", {
    placeholder: "Add an item\u2026",
    value: draft,
    onChange: e => setDraft(e.target.value),
    onKeyDown: e => e.key === 'Enter' && add()
  }))));
}
window.BC.Screens = window.BC.Screens || {};
window.BC.Screens.Lists = ListsScreen;
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/basecamp-app/ListsScreen.jsx", error: String((e && e.message) || e) }); }

// ui_kits/basecamp-app/ModulesScreen.jsx
try { (() => {
/* basecamp UI kit — Modules: the launcher + manager grid for all of a user's spaces. */
const {
  Card,
  Badge
} = window.BasecampDesignSystem_e1341e;
const MOD = window.BC.Icons;
function ModTile({
  module,
  icon,
  name,
  meta,
  foot,
  onOpen
}) {
  return /*#__PURE__*/React.createElement("div", {
    "data-module": module,
    style: {
      display: 'contents'
    }
  }, /*#__PURE__*/React.createElement(Card, {
    variant: "raised",
    interactive: true,
    className: "bc-tile",
    onClick: onOpen
  }, /*#__PURE__*/React.createElement("div", {
    className: "bc-tile__top"
  }, /*#__PURE__*/React.createElement("span", {
    className: "bc-tile__icon"
  }, icon), /*#__PURE__*/React.createElement("span", {
    className: "bc-tile__chev"
  }, /*#__PURE__*/React.createElement(MOD.chevronRight, null))), /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement("div", {
    className: "bc-tile__name"
  }, name), /*#__PURE__*/React.createElement("div", {
    className: "bc-tile__meta"
  }, meta)), /*#__PURE__*/React.createElement("div", {
    className: "bc-tile__foot"
  }, foot)));
}
function AddTile({
  icon,
  name,
  onClick
}) {
  return /*#__PURE__*/React.createElement("button", {
    className: "bc-addtile",
    onClick: onClick
  }, /*#__PURE__*/React.createElement("span", {
    className: "bc-addtile__icon"
  }, icon), /*#__PURE__*/React.createElement("span", {
    className: "bc-addtile__name"
  }, name), /*#__PURE__*/React.createElement("span", {
    className: "bc-addtile__plus"
  }, /*#__PURE__*/React.createElement(MOD.plus, null)));
}
function ModulesScreen({
  go,
  onAddModule
}) {
  return /*#__PURE__*/React.createElement("div", {
    className: "bc-screen",
    "data-module": "home"
  }, /*#__PURE__*/React.createElement("div", {
    className: "bc-screen__pad"
  }, /*#__PURE__*/React.createElement("div", {
    className: "bc-screenhead bc-screenhead--lg",
    style: {
      paddingBottom: 6
    }
  }, /*#__PURE__*/React.createElement("h1", {
    className: "bc-screenhead__title"
  }, "Modules")), /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement("div", {
    className: "bc-section"
  }, /*#__PURE__*/React.createElement("span", {
    className: "bc-section__t"
  }, "Your modules"), /*#__PURE__*/React.createElement("span", {
    className: "bc-section__a"
  }, "Edit")), /*#__PURE__*/React.createElement("div", {
    className: "bc-tiles",
    style: {
      marginTop: 12
    }
  }, /*#__PURE__*/React.createElement(ModTile, {
    module: "lists",
    icon: /*#__PURE__*/React.createElement(MOD.list, null),
    name: "Lists",
    meta: "3 lists \xB7 12 open",
    onOpen: () => go('lists'),
    foot: /*#__PURE__*/React.createElement("div", {
      className: "bc-mini"
    }, /*#__PURE__*/React.createElement("div", {
      className: "bc-mini__fill",
      style: {
        width: '40%'
      }
    }))
  }), /*#__PURE__*/React.createElement(ModTile, {
    module: "workouts",
    icon: /*#__PURE__*/React.createElement(MOD.dumbbell, null),
    name: "Workouts",
    meta: "Evening run",
    onOpen: () => go('workouts'),
    foot: /*#__PURE__*/React.createElement(Badge, {
      tone: "module"
    }, "6:00 PM")
  }), /*#__PURE__*/React.createElement(ModTile, {
    module: "clock",
    icon: /*#__PURE__*/React.createElement(MOD.clock, null),
    name: "Clock",
    meta: "2 alarms set",
    onOpen: () => go('clock'),
    foot: /*#__PURE__*/React.createElement(Badge, {
      tone: "module"
    }, "Next 7:30")
  }))), /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement("div", {
    className: "bc-section"
  }, /*#__PURE__*/React.createElement("span", {
    className: "bc-section__t"
  }, "Add a module")), /*#__PURE__*/React.createElement("div", {
    className: "bc-tiles",
    style: {
      marginTop: 12
    }
  }, /*#__PURE__*/React.createElement(AddTile, {
    icon: /*#__PURE__*/React.createElement(MOD.book, null),
    name: "Journal",
    onClick: () => onAddModule && onAddModule('Journal')
  }), /*#__PURE__*/React.createElement(AddTile, {
    icon: /*#__PURE__*/React.createElement(MOD.target, null),
    name: "Goals",
    onClick: () => onAddModule && onAddModule('Goals')
  })))));
}
window.BC.Screens = window.BC.Screens || {};
window.BC.Screens.Modules = ModulesScreen;
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/basecamp-app/ModulesScreen.jsx", error: String((e && e.message) || e) }); }

// ui_kits/basecamp-app/Shell.jsx
try { (() => {
/* basecamp UI kit — app shell chrome: PhoneFrame, StatusBar, ScreenHeader.
 * Exposes window.BC.Shell. Platform-agnostic mobile frame. */
(function () {
  const React = window.React;
  const h = React.createElement;
  const {
    IconButton
  } = window.BasecampDesignSystem_e1341e;
  const I = window.BC.Icons;
  function StatusBar() {
    return h('div', {
      className: 'bc-statusbar'
    }, h('span', {
      className: 'bc-statusbar__time'
    }, '9:41'), h('div', {
      className: 'bc-statusbar__icons'
    }, h('svg', {
      width: 18,
      height: 12,
      viewBox: '0 0 18 12',
      fill: 'currentColor'
    }, h('rect', {
      x: 0,
      y: 8,
      width: 3,
      height: 4,
      rx: 1
    }), h('rect', {
      x: 5,
      y: 5,
      width: 3,
      height: 7,
      rx: 1
    }), h('rect', {
      x: 10,
      y: 2,
      width: 3,
      height: 10,
      rx: 1
    }), h('rect', {
      x: 15,
      y: 0,
      width: 3,
      height: 12,
      rx: 1
    })), h('svg', {
      width: 17,
      height: 12,
      viewBox: '0 0 17 12',
      fill: 'none'
    }, h('path', {
      d: 'M8.5 3.5c2 0 3.8.8 5 2M3.5 1.5C5 .5 6.7 0 8.5 0s3.5.5 5 1.5M8.5 6.5c.8 0 1.6.3 2.2.9',
      stroke: 'currentColor',
      strokeWidth: 1.6,
      strokeLinecap: 'round'
    }), h('circle', {
      cx: 8.5,
      cy: 10.5,
      r: 1.2,
      fill: 'currentColor'
    })), h('svg', {
      width: 26,
      height: 13,
      viewBox: '0 0 26 13',
      fill: 'none'
    }, h('rect', {
      x: 0.5,
      y: 0.5,
      width: 21,
      height: 12,
      rx: 3,
      stroke: 'currentColor',
      strokeOpacity: 0.4
    }), h('rect', {
      x: 2,
      y: 2,
      width: 16,
      height: 9,
      rx: 1.5,
      fill: 'currentColor'
    }), h('rect', {
      x: 23,
      y: 4,
      width: 2,
      height: 5,
      rx: 1,
      fill: 'currentColor',
      fillOpacity: 0.4
    }))));
  }
  function ScreenHeader({
    title,
    eyebrow,
    action,
    onAction,
    actionLabel,
    large
  }) {
    return h('header', {
      className: 'bc-screenhead' + (large ? ' bc-screenhead--lg' : '')
    }, h('div', null, eyebrow && h('div', {
      className: 'bc-screenhead__eyebrow'
    }, eyebrow), h('h1', {
      className: 'bc-screenhead__title'
    }, title)), action && h(IconButton, {
      'aria-label': actionLabel || 'Action',
      variant: 'soft',
      onClick: onAction
    }, action));
  }
  function PhoneFrame({
    children,
    theme
  }) {
    return h('div', {
      className: 'bc-phone',
      'data-theme': theme === 'dark' ? 'dark' : undefined
    }, h('div', {
      className: 'bc-phone__notch'
    }), h(StatusBar), children);
  }
  window.BC.Shell = {
    PhoneFrame,
    StatusBar,
    ScreenHeader
  };
})();
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/basecamp-app/Shell.jsx", error: String((e && e.message) || e) }); }

// ui_kits/basecamp-app/WorkoutsScreen.jsx
try { (() => {
/* basecamp UI kit — Workouts module (today's session). */
const {
  Card,
  Badge,
  ProgressRing,
  ListItem,
  Stat,
  Button,
  IconButton,
  Checkbox
} = window.BasecampDesignSystem_e1341e;
const WI = window.BC.Icons;
function WorkoutsScreen({
  onBack
}) {
  const [ex, setEx] = React.useState([{
    id: 1,
    name: 'Goblet squat',
    detail: '3 × 10 · 20 kg',
    done: true
  }, {
    id: 2,
    name: 'Bench press',
    detail: '4 × 8 · 45 kg',
    done: true
  }, {
    id: 3,
    name: 'Bent-over row',
    detail: '4 × 8 · 40 kg',
    done: false
  }, {
    id: 4,
    name: 'Overhead press',
    detail: '3 × 10 · 25 kg',
    done: false
  }, {
    id: 5,
    name: 'Plank',
    detail: '3 × 45 s',
    done: false
  }]);
  const toggle = id => setEx(xs => xs.map(e => e.id === id ? {
    ...e,
    done: !e.done
  } : e));
  const done = ex.filter(e => e.done).length;
  const pct = Math.round(done / ex.length * 100);
  return /*#__PURE__*/React.createElement("div", {
    className: "bc-screenroot",
    "data-module": "workouts"
  }, /*#__PURE__*/React.createElement("div", {
    className: "bc-screen"
  }, /*#__PURE__*/React.createElement("div", {
    className: "bc-screen__pad"
  }, /*#__PURE__*/React.createElement("div", {
    className: "bc-screenhead bc-screenhead--lg"
  }, onBack && /*#__PURE__*/React.createElement(IconButton, {
    "aria-label": "Back",
    variant: "ghost",
    onClick: onBack
  }, /*#__PURE__*/React.createElement(WI.chevronLeft, null)), /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement("div", {
    className: "bc-screenhead__eyebrow"
  }, "Today \xB7 Strength"), /*#__PURE__*/React.createElement("h1", {
    className: "bc-screenhead__title"
  }, "Upper body")), /*#__PURE__*/React.createElement(IconButton, {
    "aria-label": "Workout options",
    variant: "soft"
  }, /*#__PURE__*/React.createElement(WI.more, null))), /*#__PURE__*/React.createElement(Card, {
    variant: "raised",
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 18
    }
  }, /*#__PURE__*/React.createElement(ProgressRing, {
    value: pct,
    size: 84,
    thickness: 7,
    label: /*#__PURE__*/React.createElement("span", {
      style: {
        fontSize: '15px'
      }
    }, /*#__PURE__*/React.createElement("b", null, done), "/", ex.length)
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      display: 'flex',
      justifyContent: 'space-between'
    }
  }, /*#__PURE__*/React.createElement(Stat, {
    value: "24",
    unit: "min",
    label: "Elapsed"
  }), /*#__PURE__*/React.createElement(Stat, {
    value: "320",
    unit: "kg",
    label: "Volume"
  }))), /*#__PURE__*/React.createElement("div", {
    className: "bc-chip-row"
  }, /*#__PURE__*/React.createElement(Badge, {
    tone: "module",
    dot: true
  }, "In progress"), /*#__PURE__*/React.createElement(Badge, {
    tone: "neutral"
  }, /*#__PURE__*/React.createElement(WI.flame, null), "\xA05-day streak")), /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement("div", {
    className: "bc-section"
  }, /*#__PURE__*/React.createElement("span", {
    className: "bc-section__t"
  }, "Exercises"), /*#__PURE__*/React.createElement("span", {
    className: "bc-section__a"
  }, "Edit")), /*#__PURE__*/React.createElement(Card, {
    variant: "outlined",
    style: {
      padding: 6,
      marginTop: 12
    }
  }, /*#__PURE__*/React.createElement("div", {
    className: "bc-rows"
  }, ex.map(e => /*#__PURE__*/React.createElement(ListItem, {
    key: e.id,
    lead: /*#__PURE__*/React.createElement(Checkbox, {
      checked: e.done,
      onChange: () => toggle(e.id),
      "aria-label": e.name
    }),
    title: e.name,
    subtitle: e.detail,
    done: e.done,
    trailing: e.done ? /*#__PURE__*/React.createElement(Badge, {
      tone: "success"
    }, "Done") : /*#__PURE__*/React.createElement("span", {
      style: {
        color: 'var(--text-tertiary)'
      }
    }, /*#__PURE__*/React.createElement(WI.chevronRight, {
      style: {
        width: 18,
        height: 18
      }
    })),
    onClick: () => toggle(e.id)
  }))))), /*#__PURE__*/React.createElement(Button, {
    variant: "primary",
    size: "lg",
    block: true,
    iconLeft: /*#__PURE__*/React.createElement(WI.clock, null)
  }, "Start rest timer \xB7 1:30"))));
}
window.BC.Screens = window.BC.Screens || {};
window.BC.Screens.Workouts = WorkoutsScreen;
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/basecamp-app/WorkoutsScreen.jsx", error: String((e && e.message) || e) }); }

// ui_kits/basecamp-app/icons.jsx
try { (() => {
/* basecamp UI kit — icon set (Lucide-style, 24×24, 2px stroke, currentColor).
 * Exposes window.BC.Icons — a map of React components. Pass like icon={<I.home/>}. */
(function () {
  const React = window.React;
  const s = (children, extra) => function Icon(props) {
    return React.createElement('svg', Object.assign({
      viewBox: '0 0 24 24',
      fill: 'none',
      xmlns: 'http://www.w3.org/2000/svg',
      width: 24,
      height: 24
    }, props), children.map((d, i) => React.createElement(d.t || 'path', Object.assign({
      key: i,
      stroke: 'currentColor',
      strokeWidth: 2,
      strokeLinecap: 'round',
      strokeLinejoin: 'round',
      fill: 'none'
    }, d))));
  };
  const P = d => ({
    d
  });
  const C = (cx, cy, r) => ({
    t: 'circle',
    cx,
    cy,
    r
  });
  const Icons = {
    home: s([P('M3 10.5 12 3l9 7.5'), P('M5 9v11h14V9')]),
    list: s([P('M9 6h12M9 12h12M9 18h12'), P('M4 6h.01M4 12h.01M4 18h.01')]),
    dumbbell: s([P('M6.5 6.5l11 11'), P('M3.8 8.6 8.6 3.8M2.4 10l1.4-1.4M14 18.6l1.4 1.4'), P('M15.4 15.4 20.2 20.2M20.2 14l-1.4 1.4M10 3.8 8.6 5.2')]),
    clock: s([C(12, 12, 9), P('M12 7v5l3 2')]),
    plus: s([P('M12 5v14M5 12h14')]),
    check: s([P('M5 12.5 10 17.5 19 7')]),
    chevronRight: s([P('M9 6l6 6-6 6')]),
    chevronLeft: s([P('M15 6l-6 6 6 6')]),
    more: s([C(5, 12, 0.6), C(12, 12, 0.6), C(19, 12, 0.6)]),
    bell: s([P('M6 9a6 6 0 1 1 12 0c0 5 2 6 2 6H4s2-1 2-6'), P('M10.5 20a1.8 1.8 0 0 0 3 0')]),
    play: s([{
      t: 'path',
      d: 'M7 5l12 7-12 7V5z',
      fill: 'currentColor',
      stroke: 'none'
    }]),
    pause: s([P('M8 5v14M16 5v14')]),
    reset: s([P('M3 12a9 9 0 1 0 3-6.7L3 8'), P('M3 4v4h4')]),
    flag: s([P('M5 21V4M5 4h12l-2 4 2 4H5')]),
    settings: s([C(12, 12, 3), P('M19.4 15a1.6 1.6 0 0 0 .3 1.8l.1.1a2 2 0 1 1-2.8 2.8l-.1-.1a1.6 1.6 0 0 0-2.7 1.1V21a2 2 0 1 1-4 0v-.2A1.6 1.6 0 0 0 7 19.3l-.1.1a2 2 0 1 1-2.8-2.8l.1-.1A1.6 1.6 0 0 0 3 13.6H3a2 2 0 1 1 0-4h.2A1.6 1.6 0 0 0 4.7 7l-.1-.1A2 2 0 1 1 7.4 4l.1.1A1.6 1.6 0 0 0 9.3 4.3 1.6 1.6 0 0 0 10.3 3V3a2 2 0 1 1 4 0v.2a1.6 1.6 0 0 0 2.7 1.1l.1-.1a2 2 0 1 1 2.8 2.8l-.1.1a1.6 1.6 0 0 0-.3 1.8z')]),
    search: s([C(11, 11, 7), P('M21 21l-3.6-3.6')]),
    calendar: s([{
      t: 'rect',
      x: 3,
      y: 5,
      width: 18,
      height: 16,
      rx: 2
    }, P('M3 9h18M8 3v4M16 3v4')]),
    flame: s([P('M12 3c1 3-2 4-2 7a2.5 2.5 0 0 0 5 0c0-.7-.2-1.3-.5-1.8C16.5 10 18 12 18 14a6 6 0 1 1-12 0c0-4 4-6 6-11z')]),
    target: s([C(12, 12, 9), C(12, 12, 5), C(12, 12, 1)]),
    trash: s([P('M4 7h16M9 7V5a1 1 0 0 1 1-1h4a1 1 0 0 1 1 1v2M6 7l1 13h10l1-13')]),
    x: s([P('M6 6l12 12M18 6L6 18')]),
    moon: s([P('M20 14.5A8 8 0 0 1 9.5 4 7 7 0 1 0 20 14.5z')]),
    sun: s([C(12, 12, 4), P('M12 2v2M12 20v2M4 12H2M22 12h-2M5 5l1.5 1.5M17.5 17.5 19 19M19 5l-1.5 1.5M6.5 17.5 5 19')]),
    footprints: s([P('M4 16c0-2 .5-3 .5-5S4 7 5.5 7 7 9 7 11s-.5 3-.5 5-2 1.5-2.5 0z'), P('M17 20c0-2 .5-3 .5-5S17 11 18.5 11 20 13 20 15s-.5 3-.5 5-2 1.5-2.5 0z')]),
    droplet: s([P('M12 3s6 6 6 10a6 6 0 1 1-12 0c0-4 6-10 6-10z')]),
    bed: s([P('M3 18V8M3 12h13a4 4 0 0 1 4 4v2M3 18h18'), C(7.5, 10.5, 1.5)]),
    coffee: s([P('M4 8h13v5a4 4 0 0 1-4 4H8a4 4 0 0 1-4-4V8z'), P('M17 9h2a2 2 0 0 1 0 4h-2M7 4v1M11 4v1')]),
    book: s([P('M5 4h12a1 1 0 0 1 1 1v15H6a1 1 0 0 1-1-1V4z'), P('M5 17h13')]),
    sparkle: s([P('M12 3l1.8 5.2L19 10l-5.2 1.8L12 17l-1.8-5.2L5 10l5.2-1.8z')]),
    heart: s([P('M12 20s-7-4.3-9.2-8.5C1.4 8.8 2.7 5.5 6 5.5c2 0 3.2 1.4 4 2.6.8-1.2 2-2.6 4-2.6 3.3 0 4.6 3.3 3.2 6C19 15.7 12 20 12 20z')]),
    trending: s([P('M3 16l5-5 4 4 7-7'), P('M16 8h5v5')]),
    users: s([C(9, 8, 3.2), P('M3 20c0-3.3 2.7-5 6-5s6 1.7 6 5'), P('M16 5.2A3 3 0 0 1 16 11M18 15c2.4.4 4 1.9 4 5')]),
    pulse: s([P('M3 12h3.5l2-7 4 14 2.5-7H21')]),
    grid: s([{
      t: 'rect',
      x: 4,
      y: 4,
      width: 7,
      height: 7,
      rx: 1.6
    }, {
      t: 'rect',
      x: 13,
      y: 4,
      width: 7,
      height: 7,
      rx: 1.6
    }, {
      t: 'rect',
      x: 4,
      y: 13,
      width: 7,
      height: 7,
      rx: 1.6
    }, {
      t: 'rect',
      x: 13,
      y: 13,
      width: 7,
      height: 7,
      rx: 1.6
    }])
  };
  window.BC = window.BC || {};
  window.BC.Icons = Icons;
})();
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/basecamp-app/icons.jsx", error: String((e && e.message) || e) }); }

__ds_ns.Button = __ds_scope.Button;

__ds_ns.IconButton = __ds_scope.IconButton;

__ds_ns.Avatar = __ds_scope.Avatar;

__ds_ns.Badge = __ds_scope.Badge;

__ds_ns.Card = __ds_scope.Card;

__ds_ns.ListItem = __ds_scope.ListItem;

__ds_ns.ProgressRing = __ds_scope.ProgressRing;

__ds_ns.Stat = __ds_scope.Stat;

__ds_ns.Tag = __ds_scope.Tag;

__ds_ns.Checkbox = __ds_scope.Checkbox;

__ds_ns.Input = __ds_scope.Input;

__ds_ns.SegmentedControl = __ds_scope.SegmentedControl;

__ds_ns.Switch = __ds_scope.Switch;

__ds_ns.TabBar = __ds_scope.TabBar;

})();
