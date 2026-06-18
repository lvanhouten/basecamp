import * as React from 'react';

export interface ProgressRingProps extends React.HTMLAttributes<HTMLSpanElement> {
  /** Progress 0–100. */
  value: number;
  /** Diameter in px. @default 64 */
  size?: number;
  /** Stroke width in px. @default 6 */
  thickness?: number;
  /** Center label. Omit for auto "%", pass a node to override, or `null` for none. */
  label?: React.ReactNode;
}

/** Circular progress indicator with a module-aware stroke. */
export function ProgressRing(props: ProgressRingProps): JSX.Element;
