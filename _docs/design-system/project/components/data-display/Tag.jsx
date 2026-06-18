import React from 'react';

const X = (
  <svg viewBox="0 0 24 24" fill="none" aria-hidden="true">
    <path d="M6 6l12 12M18 6L6 18" stroke="currentColor" strokeWidth="2" strokeLinecap="round" />
  </svg>
);

/**
 * basecamp Tag — input/filter chip. Pass `onRemove` to render a × button.
 */
export function Tag({ onRemove, className = '', children, ...rest }) {
  const cls = ['bc-tag', onRemove ? '' : 'bc-tag--plain', className].filter(Boolean).join(' ');
  return (
    <span className={cls} {...rest}>
      {children}
      {onRemove && (
        <button type="button" className="bc-tag__x" aria-label="Remove" onClick={onRemove}>{X}</button>
      )}
    </span>
  );
}
