/* basecamp UI kit — icon set (Lucide-style, 24×24, 2px stroke, currentColor).
 * Exposes window.BC.Icons — a map of React components. Pass like icon={<I.home/>}. */
(function () {
  const React = window.React;
  const s = (children, extra) =>
    function Icon(props) {
      return React.createElement(
        'svg',
        Object.assign({ viewBox: '0 0 24 24', fill: 'none', xmlns: 'http://www.w3.org/2000/svg', width: 24, height: 24 }, props),
        children.map((d, i) =>
          React.createElement(d.t || 'path', Object.assign({ key: i, stroke: 'currentColor', strokeWidth: 2, strokeLinecap: 'round', strokeLinejoin: 'round', fill: 'none' }, d))
        )
      );
    };
  const P = (d) => ({ d });
  const C = (cx, cy, r) => ({ t: 'circle', cx, cy, r });

  const Icons = {
    home: s([P('M3 10.5 12 3l9 7.5'), P('M5 9v11h14V9')]),
    list: s([P('M9 6h12M9 12h12M9 18h12'), P('M4 6h.01M4 12h.01M4 18h.01')]),
    dumbbell: s([P('M6.5 6.5l11 11'), P('M3.8 8.6 8.6 3.8M2.4 10l1.4-1.4M14 18.6l1.4 1.4'), P('M15.4 15.4 20.2 20.2M20.2 14l-1.4 1.4M10 3.8 8.6 5.2')]),
    clock: s([C(12, 12, 9), P('M12 7v5l3 2')]),
    plus: s([P('M12 5v14M5 12h14')]),
    check: s([P('M5 12.5 10 17.5 19 7')]),
    chevronRight: s([P('M9 6l6 6-6 6')]),
    chevronLeft: s([P('M15 6l-6 6 6 6')]),
    more: s([C(5, 12, 0.6), C(12, 12, 0.6), C(19, 12, 0.6)]),
    bell: s([P('M6 9a6 6 0 1 1 12 0c0 5 2 6 2 6H4s2-1 2-6'), P('M10.5 20a1.8 1.8 0 0 0 3 0')]),
    play: s([{ t: 'path', d: 'M7 5l12 7-12 7V5z', fill: 'currentColor', stroke: 'none' }]),
    pause: s([P('M8 5v14M16 5v14')]),
    reset: s([P('M3 12a9 9 0 1 0 3-6.7L3 8'), P('M3 4v4h4')]),
    flag: s([P('M5 21V4M5 4h12l-2 4 2 4H5')]),
    settings: s([C(12, 12, 3), P('M19.4 15a1.6 1.6 0 0 0 .3 1.8l.1.1a2 2 0 1 1-2.8 2.8l-.1-.1a1.6 1.6 0 0 0-2.7 1.1V21a2 2 0 1 1-4 0v-.2A1.6 1.6 0 0 0 7 19.3l-.1.1a2 2 0 1 1-2.8-2.8l.1-.1A1.6 1.6 0 0 0 3 13.6H3a2 2 0 1 1 0-4h.2A1.6 1.6 0 0 0 4.7 7l-.1-.1A2 2 0 1 1 7.4 4l.1.1A1.6 1.6 0 0 0 9.3 4.3 1.6 1.6 0 0 0 10.3 3V3a2 2 0 1 1 4 0v.2a1.6 1.6 0 0 0 2.7 1.1l.1-.1a2 2 0 1 1 2.8 2.8l-.1.1a1.6 1.6 0 0 0-.3 1.8z')]),
    search: s([C(11, 11, 7), P('M21 21l-3.6-3.6')]),
    calendar: s([{ t: 'rect', x: 3, y: 5, width: 18, height: 16, rx: 2 }, P('M3 9h18M8 3v4M16 3v4')]),
    flame: s([P('M12 3c1 3-2 4-2 7a2.5 2.5 0 0 0 5 0c0-.7-.2-1.3-.5-1.8C16.5 10 18 12 18 14a6 6 0 1 1-12 0c0-4 4-6 6-11z')]),
    target: s([C(12, 12, 9), C(12, 12, 5), C(12, 12, 1)]),
    trash: s([P('M4 7h16M9 7V5a1 1 0 0 1 1-1h4a1 1 0 0 1 1 1v2M6 7l1 13h10l1-13')]),
    x: s([P('M6 6l12 12M18 6L6 18')]),
    moon: s([P('M20 14.5A8 8 0 0 1 9.5 4 7 7 0 1 0 20 14.5z')]),
    sun: s([C(12, 12, 4), P('M12 2v2M12 20v2M4 12H2M22 12h-2M5 5l1.5 1.5M17.5 17.5 19 19M19 5l-1.5 1.5M6.5 17.5 5 19')]),
    footprints: s([P('M4 16c0-2 .5-3 .5-5S4 7 5.5 7 7 9 7 11s-.5 3-.5 5-2 1.5-2.5 0z'), P('M17 20c0-2 .5-3 .5-5S17 11 18.5 11 20 13 20 15s-.5 3-.5 5-2 1.5-2.5 0z')]),
    droplet: s([P('M12 3s6 6 6 10a6 6 0 1 1-12 0c0-4 6-10 6-10z')]),
    bed: s([P('M3 18V8M3 12h13a4 4 0 0 1 4 4v2M3 18h18'), C(7.5, 10.5, 1.5)]),
    coffee: s([P('M4 8h13v5a4 4 0 0 1-4 4H8a4 4 0 0 1-4-4V8z'), P('M17 9h2a2 2 0 0 1 0 4h-2M7 4v1M11 4v1')]),
    book: s([P('M5 4h12a1 1 0 0 1 1 1v15H6a1 1 0 0 1-1-1V4z'), P('M5 17h13')]),
    sparkle: s([P('M12 3l1.8 5.2L19 10l-5.2 1.8L12 17l-1.8-5.2L5 10l5.2-1.8z')]),
    heart: s([P('M12 20s-7-4.3-9.2-8.5C1.4 8.8 2.7 5.5 6 5.5c2 0 3.2 1.4 4 2.6.8-1.2 2-2.6 4-2.6 3.3 0 4.6 3.3 3.2 6C19 15.7 12 20 12 20z')]),
    trending: s([P('M3 16l5-5 4 4 7-7'), P('M16 8h5v5')]),
    users: s([C(9, 8, 3.2), P('M3 20c0-3.3 2.7-5 6-5s6 1.7 6 5'), P('M16 5.2A3 3 0 0 1 16 11M18 15c2.4.4 4 1.9 4 5')]),
    pulse: s([P('M3 12h3.5l2-7 4 14 2.5-7H21')]),
    grid: s([{ t: 'rect', x: 4, y: 4, width: 7, height: 7, rx: 1.6 }, { t: 'rect', x: 13, y: 4, width: 7, height: 7, rx: 1.6 }, { t: 'rect', x: 4, y: 13, width: 7, height: 7, rx: 1.6 }, { t: 'rect', x: 13, y: 13, width: 7, height: 7, rx: 1.6 }]),
  };
  window.BC = window.BC || {};
  window.BC.Icons = Icons;
})();
