import React from 'react';

/**
 * basecamp ListItem — a row with optional leading icon, title, subtitle, and
 * trailing content. Pass `onClick` to make it a tappable button row; pass
 * `done` to render the title with a completed (struck-through) style.
 */
export function ListItem({ lead, title, subtitle, trailing, done = false, onClick, className = '', ...rest }) {
  const interactive = !!onClick;
  const Tag = interactive ? 'button' : 'div';
  const cls = ['bc-listitem', interactive ? 'bc-listitem--button' : '', className].filter(Boolean).join(' ');
  return (
    <Tag className={cls} onClick={onClick} type={interactive ? 'button' : undefined} {...rest}>
      {lead && <span className="bc-listitem__lead">{lead}</span>}
      <span className="bc-listitem__body">
        <span className={`bc-listitem__title${done ? ' bc-listitem__title--done' : ''}`}>{title}</span>
        {subtitle && <span className="bc-listitem__sub">{subtitle}</span>}
      </span>
      {trailing != null && <span className="bc-listitem__trail">{trailing}</span>}
    </Tag>
  );
}
