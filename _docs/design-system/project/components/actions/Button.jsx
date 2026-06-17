import React from 'react';

/**
 * basecamp Button — pill action. Primary fill is module-aware: inside a
 * [data-module] scope it adopts that module's accent, else the brand coral.
 */
export function Button({
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
  const cls = [
    'bc-btn',
    `bc-btn--${variant}`,
    `bc-btn--${size}`,
    block ? 'bc-btn--block' : '',
    className,
  ].filter(Boolean).join(' ');

  return (
    <button type={type} className={cls} disabled={disabled || loading} aria-busy={loading || undefined} {...rest}>
      {loading && <span className="bc-btn__spinner" aria-hidden="true" />}
      {!loading && iconLeft && <span className="bc-btn__icon" aria-hidden="true">{iconLeft}</span>}
      {children != null && <span>{children}</span>}
      {!loading && iconRight && <span className="bc-btn__icon" aria-hidden="true">{iconRight}</span>}
    </button>
  );
}
