import * as React from 'react';

/**
 * Primary pill action button. Module-aware fill.
 * @startingPoint section="Actions" subtitle="Pill button — primary, secondary, ghost, danger" viewport="700x150"
 */
export interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  /** Visual style. `primary` fills with the active module accent (or brand). */
  variant?: 'primary' | 'secondary' | 'ghost' | 'danger';
  /** Control height. @default 'md' */
  size?: 'sm' | 'md' | 'lg';
  /** Stretch to fill the container width. */
  block?: boolean;
  /** Show a spinner and disable interaction. */
  loading?: boolean;
  /** Icon node rendered before the label (e.g. a Lucide <svg>). */
  iconLeft?: React.ReactNode;
  /** Icon node rendered after the label. */
  iconRight?: React.ReactNode;
  children?: React.ReactNode;
}

/** Primary pill action button. */
export function Button(props: ButtonProps): JSX.Element;
