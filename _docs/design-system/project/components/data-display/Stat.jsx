import React from 'react';

/**
 * basecamp Stat — a big tabular number with an uppercase label. For dashboard
 * readouts (steps, streaks, totals). Pass `unit` for a small superscript suffix.
 */
export function Stat({ value, unit, label, className = '', ...rest }) {
  return (
    <div className={['bc-stat', className].filter(Boolean).join(' ')} {...rest}>
      <span className="bc-stat__value">{value}{unit && <sup>{unit}</sup>}</span>
      {label && <span className="bc-stat__label">{label}</span>}
    </div>
  );
}
