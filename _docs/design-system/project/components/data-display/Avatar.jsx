import React from 'react';

/**
 * basecamp Avatar — circular user/entity image or initials fallback.
 */
export function Avatar({ src, name = '', size = 'md', className = '', ...rest }) {
  const initials = name
    .split(' ')
    .map((p) => p[0])
    .filter(Boolean)
    .slice(0, 2)
    .join('')
    .toUpperCase();
  const cls = ['bc-avatar', `bc-avatar--${size}`, className].filter(Boolean).join(' ');
  return (
    <span className={cls} role="img" aria-label={name || undefined} {...rest}>
      {src ? <img src={src} alt={name} /> : initials}
    </span>
  );
}
