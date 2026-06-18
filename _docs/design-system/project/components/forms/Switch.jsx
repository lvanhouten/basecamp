import React from 'react';

/**
 * basecamp Switch — on/off toggle. Module-aware checked color.
 * Controlled via `checked` + `onChange`, or uncontrolled via `defaultChecked`.
 */
export function Switch({ checked, defaultChecked, onChange, disabled = false, className = '', ...rest }) {
  return (
    <label className={['bc-switch', className].filter(Boolean).join(' ')}>
      <input
        type="checkbox"
        role="switch"
        checked={checked}
        defaultChecked={defaultChecked}
        onChange={onChange}
        disabled={disabled}
        {...rest}
      />
      <span className="bc-switch__track" aria-hidden="true" />
      <span className="bc-switch__thumb" aria-hidden="true" />
    </label>
  );
}
