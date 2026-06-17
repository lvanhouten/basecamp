import React from 'react';

/**
 * basecamp Card — rounded surface container. Compose freely.
 * `interactive` adds hover lift; pass `as="button"`/`onClick` for tappable cards.
 */
export function Card({ variant = 'raised', interactive = false, as = 'div', className = '', children, ...rest }) {
  const Tag = as;
  const cls = ['bc-card', `bc-card--${variant}`, interactive ? 'bc-card--interactive' : '', className]
    .filter(Boolean).join(' ');
  return <Tag className={cls} {...rest}>{children}</Tag>;
}
