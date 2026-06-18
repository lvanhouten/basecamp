import React from 'react';

const Check = (
  <svg viewBox="0 0 24 24" fill="none" aria-hidden="true">
    <path d="M5 12.5L10 17.5L19 7" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" />
  </svg>
);

/**
 * basecamp Checkbox — label + animated checkmark. Module-aware checked fill.
 * Use `label` for a text row, or pass children for custom content.
 */
export function Checkbox({ label, checked, defaultChecked, onChange, disabled = false, className = '', children, ...rest }) {
  return (
    <label className={['bc-check', className].filter(Boolean).join(' ')}>
      <input
        type="checkbox"
        checked={checked}
        defaultChecked={defaultChecked}
        onChange={onChange}
        disabled={disabled}
        {...rest}
      />
      <span className="bc-check__box" aria-hidden="true">{Check}</span>
      {(label || children) && <span>{label || children}</span>}
    </label>
  );
}
