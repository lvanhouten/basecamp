import * as React from 'react';

export interface IconButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  /** `ghost` (transparent), `soft` (tinted), `solid` (filled, module-aware). @default 'ghost' */
  variant?: 'ghost' | 'soft' | 'solid';
  /** @default 'md' */
  size?: 'sm' | 'md' | 'lg';
  /** A single 24px icon node. */
  children?: React.ReactNode;
  /** Required for accessibility — describes the action. */
  'aria-label': string;
}

/** Square icon-only control with a pill radius. */
export function IconButton(props: IconButtonProps): JSX.Element;
