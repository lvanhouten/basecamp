import React from 'react';

/**
 * basecamp Badge — small status/label pill. `dot` adds a leading status dot.
 * Use tone="module" to inherit the active module accent.
 */
export function Badge({ tone = 'neutral', dot = false, className = '', children, ...rest }) {
  const cls = ['bc-badge', `bc-badge--${tone}`, className].filter(Boolean).join(' ');
  return (
    <span className={cls} {...rest}>
      {dot && <span className="bc-badge__dot" aria-hidden="true" />}
      {children}
    </span>
  );
}
