// Top-down drill animations on a 100 x 64 tactics board.
// A drill's `anim` is { set, steps }. Each step is
//   [seconds to get here, { p, m, d, k, b }, caption?, { cue?, look? }?]
// p = you, m = teammate/feeder, d = defender, k = keeper, b = ball.
// The ball can be a point or the key of the actor it is stuck to ('p', 'd', ...).

const NS = 'http://www.w3.org/2000/svg';
const ACTORS = {
  p: { fill: '#E8582A', ring: '#FFF4EC', label: 'YOU' },
  m: { fill: '#2F7D55', ring: '#E9F5EE', label: 'M' },
  d: { fill: '#1A1F1C', ring: '#D9D3C2', label: 'D' },
  k: { fill: '#E3B23C', ring: '#1A1F1C', label: 'GK' },
};
const CUE_COLORS = { RED: '#D8402B', GREEN: '#2E9E5B', BLUE: '#2D6FD1', YELLOW: '#E3B23C' };

function el(name, attrs = {}, parent) {
  const n = document.createElementNS(NS, name);
  for (const [k, v] of Object.entries(attrs)) n.setAttribute(k, v);
  if (parent) parent.appendChild(n);
  return n;
}
const ease = t => (t < 0.5 ? 2 * t * t : 1 - Math.pow(-2 * t + 2, 2) / 2);
const lerp = (a, b, t) => a + (b - a) * t;

// Turn relative step durations into absolute keyframes with every actor filled in.
function buildTimeline(steps) {
  const frames = [];
  let t = 0;
  let state = {};
  for (const [dur, pos, caption, extra] of steps) {
    t += dur;
    state = { ...state, ...pos };
    frames.push({ t, state: { ...state }, caption: caption || null, extra: extra || {} });
  }
  // carry captions forward so every moment has one
  let last = '';
  for (const f of frames) { if (f.caption) last = f.caption; else f.caption = last; }
  return { frames, total: t };
}

export function mountAnim(host, anim, { youAreKeeper = false, onCaption } = {}) {
  const { frames, total } = buildTimeline(anim.steps);
  const hold = 1.1;
  const loop = total + hold;
  const actorKeys = [...new Set(frames.flatMap(f => Object.keys(f.state)))].filter(k => k !== 'b');
  const hasBall = frames.some(f => f.state.b !== undefined);

  const svg = el('svg', { viewBox: '0 0 100 64', class: 'board', role: 'img', 'aria-label': 'Drill animation' });
  host.innerHTML = '';
  host.appendChild(svg);

  // grass + chalk
  const defs = el('defs', {}, svg);
  const pat = el('pattern', { id: 'stripes' + Math.random().toString(36).slice(2, 7), width: 20, height: 64, patternUnits: 'userSpaceOnUse' }, defs);
  el('rect', { width: 10, height: 64, fill: '#24613F' }, pat);
  el('rect', { x: 10, width: 10, height: 64, fill: '#21593A' }, pat);
  el('rect', { width: 100, height: 64, fill: `url(#${pat.id})` }, svg);
  el('rect', { x: 1.5, y: 1.5, width: 97, height: 61, fill: 'none', stroke: 'rgba(255,255,255,.35)', 'stroke-width': 0.4 }, svg);

  const set = anim.set || {};
  if (set.goal) {
    const { x, y, w } = set.goal;
    const right = x > 50;
    const box = right ? [x - 16, y - 20, 16, 40] : [x, y - 20, 16, 40];
    const six = right ? [x - 6, y - 10, 6, 20] : [x, y - 10, 6, 20];
    el('rect', { x: box[0], y: box[1], width: box[2], height: box[3], fill: 'none', stroke: 'rgba(255,255,255,.45)', 'stroke-width': 0.4 }, svg);
    el('rect', { x: six[0], y: six[1], width: six[2], height: six[3], fill: 'none', stroke: 'rgba(255,255,255,.45)', 'stroke-width': 0.4 }, svg);
    el('rect', { x: right ? x : x - 2.5, y: y - w / 2, width: 2.5, height: w, fill: 'rgba(255,255,255,.18)', stroke: '#fff', 'stroke-width': 0.6 }, svg);
  }
  if (set.wall && set.wall.length === 4) {
    const [x1, y1, x2, y2] = set.wall;
    el('line', { x1, y1, x2, y2, stroke: '#C9C1AE', 'stroke-width': 2.4, 'stroke-linecap': 'square' }, svg);
    el('text', { x: x1 + 3, y: (y1 + y2) / 2, class: 'board-label', transform: `rotate(90 ${x1 + 3} ${(y1 + y2) / 2})` }, svg).textContent = 'WALL';
  }
  for (const [x1, y1, x2, y2] of set.gates || []) {
    el('line', { x1, y1, x2, y2, stroke: 'rgba(255,255,255,.55)', 'stroke-width': 0.35, 'stroke-dasharray': '1 1' }, svg);
    for (const [cx, cy] of [[x1, y1], [x2, y2]]) cone(svg, cx, cy);
  }
  for (const [cx, cy] of set.cones || []) cone(svg, cx, cy);

  // the player's path, faint
  const youKey = youAreKeeper && !actorKeys.includes('p') ? 'k' : 'p';
  const pathPts = frames.filter(f => f.state[youKey]).map(f => f.state[youKey].join(',')).join(' ');
  if (pathPts) el('polyline', { points: pathPts, fill: 'none', stroke: 'rgba(255,244,236,.35)', 'stroke-width': 0.4, 'stroke-dasharray': '1.2 1' }, svg);

  // look wedge
  const wedge = el('path', { fill: 'rgba(255,244,236,.22)', stroke: 'none' }, svg);

  const nodes = {};
  for (const key of actorKeys) {
    const a = ACTORS[key];
    const g = el('g', { class: 'actor' }, svg);
    el('circle', { r: 2.6, fill: a.fill, stroke: a.ring, 'stroke-width': 0.5 }, g);
    const label = key === youKey ? 'YOU' : (key === 'p' ? 'YOU' : a.label);
    el('text', { y: 0.9, 'text-anchor': 'middle', class: 'actor-label', fill: key === 'k' ? '#1A1F1C' : '#fff', 'font-size': label.length > 2 ? 1.7 : 2.1 }, g).textContent = label;
    nodes[key] = g;
  }
  const ball = hasBall ? el('circle', { r: 1.05, fill: '#fff', stroke: '#1A1F1C', 'stroke-width': 0.3 }, svg) : null;

  // cue card
  const cueG = el('g', { opacity: 0 }, svg);
  const cueRect = el('rect', { x: 4, y: 4, width: 14, height: 10, rx: 1.2, fill: '#fff' }, cueG);
  const cueText = el('text', { x: 11, y: 11.2, 'text-anchor': 'middle', class: 'cue-text' }, cueG);

  const posAt = (key, i) => frames[Math.max(0, i)].state[key];
  function actorPos(key, i, e) {
    const a = posAt(key, i - 1) || posAt(key, i);
    const b = posAt(key, i);
    if (!a || !b) return null;
    return [lerp(a[0], b[0], e), lerp(a[1], b[1], e)];
  }
  const lastDir = {};
  function ballAt(i, e) {
    const resolve = (spec, idx, ee) => {
      if (typeof spec !== 'string') return spec;
      const pos = actorPos(spec, idx, ee);
      if (!pos) return [50, 32];
      const prev = posAt(spec, idx - 1) || pos;
      const next = posAt(spec, idx) || pos;
      let dx = next[0] - prev[0], dy = next[1] - prev[1];
      const len = Math.hypot(dx, dy);
      if (len > 0.5) { dx /= len; dy /= len; lastDir[spec] = [dx, dy]; } else { [dx, dy] = lastDir[spec] || [1, 0]; }
      return [pos[0] + dx * 2.4, pos[1] + dy * 2.4];
    };
    const from = frames[Math.max(0, i - 1)].state.b;
    const to = frames[i].state.b;
    if (to === undefined) return null;
    if (typeof to === 'string' && from === to) return resolve(to, i, e);
    const a = resolve(from ?? to, Math.max(0, i - 1), 1);
    const b = resolve(to, i, 1);
    return [lerp(a[0], b[0], e), lerp(a[1], b[1], e)];
  }

  let start = performance.now();
  let pausedAt = null;
  let speed = 1;
  let raf;
  let lastCaption = null;

  function render(now) {
    const elapsed = pausedAt ?? (((now - start) / 1000) * speed);
    const t = elapsed % loop;
    let i = frames.findIndex(f => f.t >= t);
    if (i === -1) i = frames.length - 1;
    const prevT = i > 0 ? frames[i - 1].t : 0;
    const span = frames[i].t - prevT;
    const e = span > 0 ? ease(Math.min(1, (t - prevT) / span)) : 1;

    for (const key of actorKeys) {
      const p = actorPos(key, i, e);
      if (p) { nodes[key].setAttribute('transform', `translate(${p[0]} ${p[1]})`); nodes[key].style.display = ''; }
      else nodes[key].style.display = 'none';
    }
    if (ball) {
      const b = ballAt(i, e);
      // keep the ball visible at a player's feet instead of hidden under the token
      if (b) for (const key of actorKeys) {
        const a = actorPos(key, i, e);
        if (!a) continue;
        const dx = b[0] - a[0], dy = b[1] - a[1], dist = Math.hypot(dx, dy);
        if (dist < 2.6) { const ux = dist > 0.2 ? dx / dist : 0.7, uy = dist > 0.2 ? dy / dist : 0.7; b[0] = a[0] + ux * 2.9; b[1] = a[1] + uy * 2.9; }
      }
      if (b) { ball.setAttribute('cx', b[0]); ball.setAttribute('cy', b[1]); }
    }
    // look wedge follows the frame being approached
    const look = frames[i].extra.look;
    const you = actorPos(youKey, i, e);
    if (look !== undefined && you) {
      const r = 14, half = 22;
      const a1 = (look - half) * Math.PI / 180, a2 = (look + half) * Math.PI / 180;
      wedge.setAttribute('d', `M${you[0]},${you[1]} L${you[0] + r * Math.cos(a1)},${you[1] + r * Math.sin(a1)} A${r},${r} 0 0 1 ${you[0] + r * Math.cos(a2)},${you[1] + r * Math.sin(a2)} Z`);
    } else wedge.setAttribute('d', '');

    const cue = frames[i].extra.cue;
    if (cue) {
      cueG.setAttribute('opacity', 1);
      cueRect.setAttribute('fill', CUE_COLORS[cue] || '#FBFAF5');
      cueText.setAttribute('fill', CUE_COLORS[cue] ? '#fff' : '#15211B');
      cueText.textContent = CUE_COLORS[cue] ? cue : cue;
    } else cueG.setAttribute('opacity', 0);

    const caption = t > total ? frames[frames.length - 1].caption : frames[i].caption;
    if (caption !== lastCaption) { lastCaption = caption; onCaption && onCaption(caption, i); }
    raf = requestAnimationFrame(render);
  }
  raf = requestAnimationFrame(render);

  return {
    toggle() {
      if (pausedAt === null) { pausedAt = ((performance.now() - start) / 1000) * speed; }
      else { start = performance.now() - (pausedAt / speed) * 1000; pausedAt = null; }
      return pausedAt === null;
    },
    restart() { start = performance.now(); if (pausedAt !== null) pausedAt = 0; },
    setSpeed(s) {
      const now = performance.now();
      const elapsed = pausedAt ?? ((now - start) / 1000) * speed;
      speed = s;
      start = now - (elapsed / speed) * 1000;
    },
    destroy() { cancelAnimationFrame(raf); },
    captions: [...new Set(frames.map(f => f.caption).filter(Boolean))],
  };
}

function cone(svg, x, y) {
  el('path', { d: `M${x - 1.3},${y + 1} L${x},${y - 1.4} L${x + 1.3},${y + 1} Z`, fill: '#F07A3A', stroke: '#9B3B12', 'stroke-width': 0.2 }, svg);
}

// Small static pitch used for picking positions.
export function pitchSVG(spots, selected = {}, onPick) {
  const svg = el('svg', { viewBox: '0 0 100 64', class: 'pitch-picker' });
  el('rect', { width: 100, height: 64, rx: 1.5, fill: '#21593A' }, svg);
  for (let i = 0; i < 10; i += 2) el('rect', { x: i * 10, width: 10, height: 64, fill: '#24613F' }, svg);
  const chalk = { fill: 'none', stroke: 'rgba(255,255,255,.5)', 'stroke-width': 0.35 };
  el('rect', { x: 1.5, y: 1.5, width: 97, height: 61, ...chalk }, svg);
  el('line', { x1: 50, y1: 1.5, x2: 50, y2: 62.5, ...chalk }, svg);
  el('circle', { cx: 50, cy: 32, r: 8, ...chalk }, svg);
  el('rect', { x: 1.5, y: 12, width: 15, height: 40, ...chalk }, svg);
  el('rect', { x: 83.5, y: 12, width: 15, height: 40, ...chalk }, svg);
  el('text', { x: 97, y: 5.5, 'text-anchor': 'end', class: 'board-label' }, svg).textContent = 'ATTACK →';
  for (const [code, s] of Object.entries(spots)) {
    const g = el('g', { class: 'spot', tabindex: 0, role: 'button', 'aria-label': code, 'data-code': code, transform: `translate(${s.x} ${s.y})` }, svg);
    const rank = selected[code];
    el('circle', { r: 3.6, class: 'spot-dot' + (rank ? ' is-picked rank-' + rank : '') }, g);
    el('text', { y: 0.95, 'text-anchor': 'middle', class: 'spot-label' }, g).textContent = code;
    if (rank) el('text', { x: 3.4, y: -2.6, class: 'spot-rank' }, g).textContent = rank;
    const pick = () => onPick && onPick(code);
    g.addEventListener('click', pick);
    g.addEventListener('keydown', ev => { if (ev.key === 'Enter' || ev.key === ' ') { ev.preventDefault(); pick(); } });
  }
  return svg;
}
