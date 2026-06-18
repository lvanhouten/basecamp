import React from 'react';

/**
 * basecamp ProgressRing — circular progress, module-aware stroke.
 * `value` is 0–100. Renders its own % label unless `label` is supplied
 * (pass `label={null}` for no label, or a node like a duration).
 */
export function ProgressRing({ value = 0, size = 64, thickness = 6, label, className = '', ...rest }) {
  const v = Math.max(0, Math.min(100, value));
  const r = (size - thickness) / 2;
  const c = 2 * Math.PI * r;
  const offset = c * (1 - v / 100);
  const content = label === undefined ? `${Math.round(v)}%` : label;
  return (
    <span className={['bc-ring', className].filter(Boolean).join(' ')} style={{ width: size, height: size }} role="img" aria-label={`${Math.round(v)} percent`} {...rest}>
      <svg width={size} height={size} viewBox={`0 0 ${size} ${size}`}>
        <circle className="bc-ring__track" cx={size / 2} cy={size / 2} r={r} strokeWidth={thickness} />
        <circle className="bc-ring__fill" cx={size / 2} cy={size / 2} r={r} strokeWidth={thickness}
          strokeDasharray={c} strokeDashoffset={offset} />
      </svg>
      {content !== null && (
        <span className="bc-ring__label" style={{ fontSize: Math.max(11, size * 0.24) }}>{content}</span>
      )}
    </span>
  );
}
