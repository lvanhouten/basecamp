import * as React from 'react';

export interface InputProps extends Omit<React.InputHTMLAttributes<HTMLInputElement>, 'size'> {
  /** Field label rendered above the control. */
  label?: string;
  /** Helper text below the control. */
  hint?: string;
  /** Error message — also flips the control to the invalid state. */
  error?: string;
  /** Render a multi-line <textarea> instead of a single-line input. */
  multiline?: boolean;
  /** Rows for the textarea. @default 3 */
  rows?: number;
}

/** Labeled text field with hint / error states. */
export function Input(props: InputProps): JSX.Element;
