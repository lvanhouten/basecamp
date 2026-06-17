import React from 'react';

/**
 * basecamp Input — text field with optional label, hint, and error.
 * Renders a <textarea> when `multiline` is set. Forwards the rest to the control.
 */
export function Input({
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
  const hintId = (hint || error) ? `${fieldId}-hint` : undefined;
  const Control = multiline ? 'textarea' : 'input';

  return (
    <div className={['bc-field', className].filter(Boolean).join(' ')}>
      {label && <label className="bc-field__label" htmlFor={fieldId}>{label}</label>}
      <Control
        id={fieldId}
        className="bc-input"
        aria-invalid={error ? 'true' : undefined}
        aria-describedby={hintId}
        rows={multiline ? rows : undefined}
        {...rest}
      />
      {(error || hint) && (
        <span id={hintId} className={`bc-field__hint${error ? ' bc-field__hint--error' : ''}`}>
          {error || hint}
        </span>
      )}
    </div>
  );
}
