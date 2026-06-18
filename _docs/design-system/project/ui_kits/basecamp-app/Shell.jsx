/* basecamp UI kit — app shell chrome: PhoneFrame, StatusBar, ScreenHeader.
 * Exposes window.BC.Shell. Platform-agnostic mobile frame. */
(function () {
  const React = window.React;
  const h = React.createElement;
  const { IconButton } = window.BasecampDesignSystem_e1341e;
  const I = window.BC.Icons;

  function StatusBar() {
    return h('div', { className: 'bc-statusbar' },
      h('span', { className: 'bc-statusbar__time' }, '9:41'),
      h('div', { className: 'bc-statusbar__icons' },
        h('svg', { width: 18, height: 12, viewBox: '0 0 18 12', fill: 'currentColor' },
          h('rect', { x: 0, y: 8, width: 3, height: 4, rx: 1 }),
          h('rect', { x: 5, y: 5, width: 3, height: 7, rx: 1 }),
          h('rect', { x: 10, y: 2, width: 3, height: 10, rx: 1 }),
          h('rect', { x: 15, y: 0, width: 3, height: 12, rx: 1 })),
        h('svg', { width: 17, height: 12, viewBox: '0 0 17 12', fill: 'none' },
          h('path', { d: 'M8.5 3.5c2 0 3.8.8 5 2M3.5 1.5C5 .5 6.7 0 8.5 0s3.5.5 5 1.5M8.5 6.5c.8 0 1.6.3 2.2.9', stroke: 'currentColor', strokeWidth: 1.6, strokeLinecap: 'round' }),
          h('circle', { cx: 8.5, cy: 10.5, r: 1.2, fill: 'currentColor' })),
        h('svg', { width: 26, height: 13, viewBox: '0 0 26 13', fill: 'none' },
          h('rect', { x: 0.5, y: 0.5, width: 21, height: 12, rx: 3, stroke: 'currentColor', strokeOpacity: 0.4 }),
          h('rect', { x: 2, y: 2, width: 16, height: 9, rx: 1.5, fill: 'currentColor' }),
          h('rect', { x: 23, y: 4, width: 2, height: 5, rx: 1, fill: 'currentColor', fillOpacity: 0.4 })))
    );
  }

  function ScreenHeader({ title, eyebrow, action, onAction, actionLabel, large }) {
    return h('header', { className: 'bc-screenhead' + (large ? ' bc-screenhead--lg' : '') },
      h('div', null,
        eyebrow && h('div', { className: 'bc-screenhead__eyebrow' }, eyebrow),
        h('h1', { className: 'bc-screenhead__title' }, title)),
      action && h(IconButton, { 'aria-label': actionLabel || 'Action', variant: 'soft', onClick: onAction }, action)
    );
  }

  function PhoneFrame({ children, theme }) {
    return h('div', { className: 'bc-phone', 'data-theme': theme === 'dark' ? 'dark' : undefined },
      h('div', { className: 'bc-phone__notch' }),
      h(StatusBar),
      children
    );
  }

  window.BC.Shell = { PhoneFrame, StatusBar, ScreenHeader };
})();
