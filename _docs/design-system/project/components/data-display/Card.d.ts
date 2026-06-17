import * as React from 'react';

/**
 * Rounded surface container.
 * @startingPoint section="Layout" subtitle="Surface card — raised, outlined, flat" viewport="700x200"
 */
export interface CardProps extends React.HTMLAttributes<HTMLElement> {
  /** `raised` (shadow), `outlined` (hairline), `flat` (sunken fill). @default 'raised' */
  variant?: 'raised' | 'outlined' | 'flat';
  /** Adds hover-lift + pointer for tappable cards. */
  interactive?: boolean;
  /** Element/tag to render. @default 'div' */
  as?: any;
  children?: React.ReactNode;
}

/** Rounded surface container. */
export function Card(props: CardProps): JSX.Element;
