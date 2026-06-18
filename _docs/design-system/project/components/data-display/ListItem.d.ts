import * as React from 'react';

/**
 * Standard content row (lists, settings, queues).
 * @startingPoint section="Layout" subtitle="Content row — icon, title, subtitle, trailing" viewport="700x150"
 */
export interface ListItemProps extends React.HTMLAttributes<HTMLElement> {
  /** Leading node — an icon (rendered in a tinted tile) or a checkbox. */
  lead?: React.ReactNode;
  /** Primary text. */
  title: React.ReactNode;
  /** Secondary text below the title. */
  subtitle?: React.ReactNode;
  /** Trailing node — chevron, badge, time, switch, etc. */
  trailing?: React.ReactNode;
  /** Strike-through completed style on the title. */
  done?: boolean;
  /** When set, the row becomes a tappable button. */
  onClick?: React.MouseEventHandler;
}

/** Standard content row (lists, settings, queues). */
export function ListItem(props: ListItemProps): JSX.Element;
