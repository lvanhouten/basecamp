import React from 'react';

/**
 * basecamp SegmentedControl — pill-track single-select. Great for switching
 * Timer / Stopwatch / Alarm, or list filters. Controlled by `value` + `onChange`.
 */
export function SegmentedControl({ options = [], value, onChange, className = '', ...rest }) {
  const items = options.map((o) => (typeof o === 'string' ? { value: o, label: o } : o));
  return (
    <div className={['bc-segmented', className].filter(Boolean).join(' ')} role="tablist" {...rest}>
      {items.map((it) => (
        <button
          key={it.value}
          role="tab"
          type="button"
          className="bc-segmented__opt"
          aria-selected={value === it.value}
          onClick={() => onChange && onChange(it.value)}
        >
          {it.label}
        </button>
      ))}
    </div>
  );
}
