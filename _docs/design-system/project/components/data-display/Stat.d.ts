import * as React from 'react';

export interface StatProps extends React.HTMLAttributes<HTMLDivElement> {
  /** The number / readout (kept in tabular mono). */
  value: React.ReactNode;
  /** Small superscript unit (e.g. "kg", "min"). */
  unit?: React.ReactNode;
  /** Uppercase caption below. */
  label?: React.ReactNode;
}

/** Big tabular metric with a label. */
export function Stat(props: StatProps): JSX.Element;
