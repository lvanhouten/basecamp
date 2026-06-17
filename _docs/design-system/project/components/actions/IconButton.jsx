import React from 'react';

/**
 * basecamp IconButton — square, pill-radius control wrapping a single icon.
 * Pass a 24px icon node (e.g. Lucide <svg>) as children. Always give an aria-label.
 */
export function IconButton({
  variant = 'ghost',
  size = 'md',
  disabled = false,
  className = '',
  children,
  ...rest
}) {
  const cls = ['bc-iconbtn', `bc-iconbtn--${variant}`, `bc-iconbtn--${size}`, className]
    .filter(Boolean).join(' ');
  return (
    <button type="button" className={cls} disabled={disabled} {...rest}>
      {children}
    </button>
  );
}
