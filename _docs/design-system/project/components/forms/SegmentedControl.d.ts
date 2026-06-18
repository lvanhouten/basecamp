import * as React from 'react';

export interface SegmentOption {
  value: string;
  label: React.ReactNode;
}

export interface SegmentedControlProps {
  /** Options as strings or {value,label} objects. */
  options: (string | SegmentOption)[];
  /** Currently selected value. */
  value: string;
  /** Called with the newly selected value. */
  onChange?: (value: string) => void;
  className?: string;
}

/** Pill-track segmented single-select (tabs/filters/modes). */
export function SegmentedControl(props: SegmentedControlProps): JSX.Element;
