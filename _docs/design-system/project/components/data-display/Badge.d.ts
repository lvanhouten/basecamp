import * as React from 'react';

export interface BadgeProps extends React.HTMLAttributes<HTMLSpanElement> {
  /** Color tone. `module` follows the active module accent. @default 'neutral' */
  tone?: 'neutral' | 'brand' | 'module' | 'success' | 'warning' | 'danger' | 'solid';
  /** Show a leading status dot. */
  dot?: boolean;
  children?: React.ReactNode;
}

/** Small status / count / label pill. */
export function Badge(props: BadgeProps): JSX.Element;
