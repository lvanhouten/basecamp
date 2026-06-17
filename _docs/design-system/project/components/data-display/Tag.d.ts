import * as React from 'react';

export interface TagProps extends React.HTMLAttributes<HTMLSpanElement> {
  /** When provided, renders a × button that calls this on click. */
  onRemove?: React.MouseEventHandler<HTMLButtonElement>;
  children?: React.ReactNode;
}

/** Removable chip for filters, labels, and multi-select tokens. */
export function Tag(props: TagProps): JSX.Element;
