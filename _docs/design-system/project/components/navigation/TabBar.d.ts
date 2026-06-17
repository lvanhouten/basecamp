import * as React from 'react';

export interface TabBarItem {
  value: string;
  label: string;
  /** A 24px icon node (e.g. Lucide <svg>). */
  icon: React.ReactNode;
}

export interface TabBarCenterAction {
  /** Icon node for the FAB (e.g. a plus). */
  icon: React.ReactNode;
  /** Accessible label, e.g. "Quick add". */
  label: string;
  /** Click handler — typically opens the global Add sheet. */
  onClick?: () => void;
}

/**
 * Bottom navigation bar for the app shell.
 * @startingPoint section="Navigation" subtitle="Launcher nav — Home · ⊕ Add · Activity" viewport="390x96"
 */
export interface TabBarProps extends React.HTMLAttributes<HTMLElement> {
  items: TabBarItem[];
  value: string;
  onChange?: (value: string) => void;
  /** Optional raised brand FAB rendered between the items (the launcher pattern). */
  centerAction?: TabBarCenterAction;
}

/** Bottom navigation bar for the app shell. */
export function TabBar(props: TabBarProps): JSX.Element;
