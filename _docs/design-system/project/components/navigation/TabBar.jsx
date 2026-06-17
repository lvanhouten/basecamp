import React from 'react';

/**
 * basecamp TabBar — bottom navigation for the app shell. Items: { value, label, icon }.
 * The active item adopts the active module accent. Controlled by `value` + `onChange`.
 *
 * Pass `centerAction` ({ icon, label, onClick }) to render a raised brand FAB between the
 * items — the "launcher" pattern basecamp uses (Home · ⊕ Add · Activity). The FAB is an
 * action, not a selectable tab, so it never carries the selected state.
 */
export function TabBar({ items = [], value, onChange, centerAction = null, className = '', ...rest }) {
  const mid = Math.ceil(items.length / 2);
  const left = centerAction ? items.slice(0, mid) : items;
  const right = centerAction ? items.slice(mid) : [];

  const renderItem = (it) => (
    <button
      key={it.value}
      type="button"
      className="bc-tabbar__item"
      aria-selected={value === it.value}
      aria-label={it.label}
      onClick={() => onChange && onChange(it.value)}
    >
      {it.icon}
      <span>{it.label}</span>
    </button>
  );

  return (
    <nav className={['bc-tabbar', className].filter(Boolean).join(' ')} {...rest}>
      {left.map(renderItem)}
      {centerAction && (
        <button
          type="button"
          className="bc-tabbar__add"
          aria-label={centerAction.label}
          onClick={centerAction.onClick}
        >
          {centerAction.icon}
        </button>
      )}
      {right.map(renderItem)}
    </nav>
  );
}
