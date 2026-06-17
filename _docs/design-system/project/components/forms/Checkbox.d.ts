import * as React from 'react';

export interface CheckboxProps extends Omit<React.InputHTMLAttributes<HTMLInputElement>, 'type'> {
  /** Text label rendered beside the box. */
  label?: React.ReactNode;
  checked?: boolean;
  defaultChecked?: boolean;
  onChange?: React.ChangeEventHandler<HTMLInputElement>;
  disabled?: boolean;
}

/** Checkbox with an animated checkmark and optional label. */
export function Checkbox(props: CheckboxProps): JSX.Element;
