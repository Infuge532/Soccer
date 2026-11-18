import { POSITIONS, SKILLS, SPOTS, LEVELS, AGE_GROUPS, GROUPS, levelIndex, levelName, spotLabel } from './positions.js';
import { DRILLS, DRILL_BY_ID, drillsFor } from './drills.js';
import { mountAnim, pitchSVG } from './anim.js';
import { suggest } from './coach.js';
import { runSession } from './session.js';
import { store, todayKey, streak } from './store.js';

const view = document.getElementById('view');
const NEEDS = { ball: 'Ball', cones: 'Cones', wall: 'Wall', partner: 'Partner', goal: 'Goal' };
let cleanup = null;

// ───────── helpers ─────────
const h = (s) => String(s ?? '').replace(/[&<>"']/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
const posOf = (spot) => SPOTS[spot]?.pos;
const ytLink = (q) => `https://www.youtube.com/results?search_query=${encodeURIComponent(q)}`;
function minutes(d) {
  if (d.mode === 'time') return Math.round(d.seconds / 60);
  return Math.max(3, Math.round((d.sets * (d.reps * 5 + d.rest)) / 60));
}
function daySeed() { return Math.floor(Date.now() / 86400000); }

function profileOrRedirect() {
  const p = store.profile;
  if (!p) { location.hash = '#/welcome'; return null; }
  return p;
}

// ───────── today's plan ─────────
export function todaysPlan(p) {
  const main = posOf(p.primary), second = posOf(p.secondary);
  const seed = daySeed();
  const pos = POSITIONS[main];
  const focus = (p.focus && p.focus.length ? p.focus : pos.coreSkills.slice(0, 3));
  const used = new Set();
  const pick = (list) => {
    const free = list.filter(d => !used.has(d.id));
    if (!free.length) return null;
    const d = free[seed % free.length];
    used.add(d.id);
    return d;
  };
  const plan = [];
  const mine = drillsFor(main);
  // 1. warm-up
  const warm = main === 'gk' ? [DRILL_BY_ID['gk-set-handling']] : DRILLS.filter(d => d.skills[0] === 'ballMastery');
  const w = pick(warm); if (w) plan.push({ drill: w, role: 'Warm-up' });
  // 2. two focus blocks
  for (let i = 0; i < 2; i++) {
    const skill = focus[(seed + i) % focus.length];
    const strong = mine.filter(x => x.skills.slice(0, 2).includes(skill) && !used.has(x.id));
    const d = pick(strong.length ? strong : mine.filter(x => x.skills.includes(skill))) || pick(mine);
    if (d) plan.push({ drill: d, role: `Focus · ${SKILLS[skill].short}` });
  }
  // 3. secondary position
  if (second && second !== main) {
    const d = pick(drillsFor(second).filter(x => x.positions.includes(second)));
    if (d) plan.push({ drill: d, role: `Second position · ${POSITIONS[second].short}` });
  }
  // 4. finisher
  const fin = pick(main === 'gk' ? [DRILL_BY_ID['agi-reaction-arrows'], DRILL_BY_ID['gk-reactions']]
    : [DRILL_BY_ID['scan-color-call'], DRILL_BY_ID['agi-reaction-arrows'], DRILL_BY_ID['agi-5-10-5']]);
  if (fin) plan.push({ drill: fin, role: 'Finisher' });
  return plan;
}

// ───────── router ─────────
const routes = {
  welcome: renderWelcome,
  home: renderHome,
  positions: renderPositions,
  pos: renderPosition,
  drill: renderDrill,
  train: renderTrain,
  coach: renderCoach,
  profile: renderProfile,
  pack: renderPack,
};

function route() {
  if (cleanup) { cleanup(); cleanup = null; }
  const [, name = '', ...rest] = (location.hash || '#/').split('/');
  const resolved = routes[name] ? name : (store.profile ? 'home' : 'welcome');
  const fn = routes[resolved];
  document.body.dataset.route = resolved;
  document.querySelectorAll('[data-nav]').forEach(a => a.classList.toggle('is-active', a.dataset.nav === (name || 'home') || (a.dataset.nav === 'positions' && (name === 'pos'))));
  view.scrollTop = 0; window.scrollTo(0, 0);
  fn(...rest.map(decodeURIComponent));
}
window.addEventListener('hashchange', route);

// ───────── onboarding ─────────
function renderWelcome() {
  const existing = store.profile || {};
  const draft = { foot: 'Right', age: 'U15', region: 'East', current: 'npl', goal: 'mlsa', ...existing };
  let step = 0;
  const steps = ['You', 'Positions', 'Level'];

  function draw() {
    view.innerHTML = `
      <section class="onboard">
        <div class="onboard-head">
          <p class="kicker">Player profile · step ${step + 1} of 3</p>
          <h1 class="display">${['Who’s training?', 'Where do you play?', 'Where are you headed?'][step]}</h1>
          <ol class="stepper">${steps.map((s, i) => `<li class="${i === step ? 'on' : i < step ? 'done' : ''}">${s}</li>`).join('')}</ol>
        </div>
        <form class="onboard-form" novalidate>${[stepYou, stepPositions, stepLevel][step]()}</form>
      </section>`;
    const form = view.querySelector('form');
    if (step === 1) mountPicker();
    form.onsubmit = (e) => {
      e.preventDefault();
      const fd = new FormData(form);
      for (const [k, v] of fd.entries()) draft[k] = String(v).trim();
      const err = validate();
      if (err) { form.querySelector('.form-error').textContent = err; return; }
      if (step < 2) { step++; draw(); return; }
      store.saveProfile({ ...draft, createdAt: existing.createdAt || Date.now() });
      location.hash = '#/home';
    };
    const back = form.querySelector('[data-act="back"]');
    if (back) back.onclick = () => {
      const fd = new FormData(form);
      for (const [k, v] of fd.entries()) draft[k] = String(v).trim();
      step--; draw();
    };
  }
  function validate() {
    if (step === 0) {
      if (!draft.name) return 'Add your name.';
      if (draft.email && !/^\S+@\S+\.\S+$/.test(draft.email)) return 'That email doesn’t look right.';
      if (draft.phone && draft.phone.replace(/\D/g, '').length < 10) return 'Phone number needs at least 10 digits.';
    }
    if (step === 1 && !draft.primary) return 'Tap your main position on the pitch.';
    if (step === 2 && levelIndex(draft.goal) <= levelIndex(draft.current)) return 'Pick a goal level above where you play now.';
    return '';
  }
  const field = (name, label, type = 'text', attrs = '') => `
    <label class="field"><span>${label}</span><input name="${name}" type="${type}" value="${h(draft[name] || '')}" ${attrs}></label>`;
  const select = (name, label, options) => `
    <label class="field"><span>${label}</span><select name="${name}">${options.map(([v, t]) => `<option value="${v}" ${draft[name] === v ? 'selected' : ''}>${t}</option>`).join('')}</select></label>`;
  const nav = (last) => `
    <p class="form-error" role="alert"></p>
    <div class="form-nav">
      ${step ? '<button type="button" class="ghost-btn" data-act="back">← Back</button>' : '<span></span>'}
      <button class="cta" type="submit">${last ? 'Build my dashboard' : 'Next'} <span aria-hidden="true">→</span></button>
    </div>`;

  function stepYou() {
    return `
      <div class="grid-2">
        ${field('name', 'Name', 'text', 'autocomplete="name" required')}
        ${select('age', 'Age group', AGE_GROUPS.map(a => [a, a]))}
        ${field('email', 'Email', 'email', 'autocomplete="email"')}
        ${field('phone', 'Phone', 'tel', 'autocomplete="tel"')}
        ${select('foot', 'Strong foot', [['Right', 'Right'], ['Left', 'Left'], ['Both', 'Both']])}
      </div>
      <p class="fine">Saved only in this browser for the prototype — nothing is sent anywhere.</p>
      ${nav(false)}`;
  }
  function stepPositions() {
    return `
      <p class="lede">Tap your <b>main</b> position, then your <b>second</b> and <b>third</b>. Tap again to clear.</p>
      <div class="picker-wrap" data-el="picker"></div>
      <div class="picked" data-el="picked"></div>
      <input type="hidden" name="primary" value="${h(draft.primary || '')}">
      <input type="hidden" name="secondary" value="${h(draft.secondary || '')}">
      <input type="hidden" name="third" value="${h(draft.third || '')}">
      ${nav(false)}`;
  }
  function mountPicker() {
    const order = ['primary', 'secondary', 'third'];
    const wrap = view.querySelector('[data-el="picker"]');
    const paint = () => {
      const sel = {};
      order.forEach((k, i) => { if (draft[k]) sel[draft[k]] = i + 1; });
      wrap.innerHTML = '';
      wrap.appendChild(pitchSVG(SPOTS, sel, onPick));
      order.forEach(k => { view.querySelector(`input[name="${k}"]`).value = draft[k] || ''; });
      view.querySelector('[data-el="picked"]').innerHTML = order.map((k, i) => `
        <div class="picked-row"><span class="rank-badge rank-${i + 1}">${i + 1}</span>
        <span>${['Main', 'Second', 'Third'][i]}</span><strong>${draft[k] ? spotLabel(draft[k]) : '<em>not set</em>'}</strong></div>`).join('');
    };
    const onPick = (code) => {
      const at = order.find(k => draft[k] === code);
      if (at) { draft[at] = ''; const rest = order.map(k => draft[k]).filter(Boolean); order.forEach((k, i) => draft[k] = rest[i] || ''); }
      else { const free = order.find(k => !draft[k]); if (free) draft[free] = code; else draft.third = code; }
      paint();
    };
    paint();
  }
  function stepLevel() {
    const lv = LEVELS.map(l => [l.id, l.name]);
    return `
      <div class="grid-2">
        ${select('current', 'Level you play now', lv)}
        ${field('team', 'Team / division (optional)', 'text', 'placeholder="e.g. N1, U15 Red"')}
        ${select('goal', 'Level you want to reach', lv)}
        ${select('region', 'Region', [['East', 'East'], ['Central', 'Central'], ['West', 'West']])}
      </div>
      ${nav(true)}`;
  }
  draw();
}

// ───────── dashboard ─────────
function renderHome() {
  const p = profileOrRedirect(); if (!p) return;
  const main = posOf(p.primary);
  const pos = POSITIONS[main];
  const plan = todaysPlan(p);
  const history = store.history;
  const doneToday = new Set(history.filter(x => x.date === todayKey() && x.completed).map(x => x.drillId));
  const next = plan.find(x => !doneToday.has(x.drill.id));
  const total = plan.reduce((s, x) => s + minutes(x.drill), 0);
  const focus = p.focus && p.focus.length ? p.focus : pos.coreSkills.slice(0, 3);
  const cur = levelIndex(p.current), goal = levelIndex(p.goal);
  const hour = new Date().getHours();
  const hello = hour < 12 ? 'Morning' : hour < 18 ? 'Afternoon' : 'Evening';
  const group = pos.group;

  view.innerHTML = `
    <section class="dash-hero">
      <div class="dash-id">
        <p class="kicker">${hello}, ${h(p.age)} · ${h(p.region)}</p>
        <h1 class="display">${h(p.name.split(' ')[0])}</h1>
        <div class="id-tags">
          <span class="shirt">${pos.short}</span>
          <span>${h(spotLabel(p.primary))}${p.secondary ? ` / ${h(spotLabel(p.secondary))}` : ''}${p.third ? ` / ${h(spotLabel(p.third))}` : ''}</span>
        </div>
      </div>
      <div class="dash-streak">
        <span class="num">${streak(history)}</span><span class="lbl">day streak</span>
        <span class="num">${history.filter(x => x.completed).length}</span><span class="lbl">sessions</span>
      </div>
    </section>

    <section class="today card-dark">
      <div class="today-head">
        <div>
          <p class="kicker light">Today · ${new Date().toLocaleDateString(undefined, { weekday: 'long', month: 'short', day: 'numeric' })}</p>
          <h2>This is what you’re working on today</h2>
          <p class="today-sub">${focus.map(f => SKILLS[f].name).join(' · ')} — about ${total} minutes.</p>
        </div>
        ${next ? `<a class="cta cta-light" href="#/drill/${next.drill.id}">${doneToday.size ? 'Next drill' : 'Start today'} →</a>` : '<span class="done-tag">Done for today ✓</span>'}
      </div>
      <ol class="plan">
        ${plan.map((x, i) => `
          <li class="${doneToday.has(x.drill.id) ? 'is-done' : ''}">
            <a href="#/drill/${x.drill.id}">
              <span class="plan-n">${String(i + 1).padStart(2, '0')}</span>
              <span class="plan-role">${x.role}</span>
              <span class="plan-name">${x.drill.name}</span>
              <span class="plan-min">${minutes(x.drill)} min</span>
            </a>
          </li>`).join('')}
      </ol>
    </section>

    <section class="quick">
      <p class="kicker">Or pick something else</p>
      <div class="quick-grid">
        <a class="quick-card" href="#/pack/touches"><strong>${group === 'Goalkeeping' ? 'Keeper handling' : `${group === 'Wide' ? 'Wing' : group}`} training & touches</strong><span>First touch and ball mastery for a ${pos.short}</span></a>
        <a class="quick-card" href="#/pos/${main}"><strong>Full ${pos.name.toLowerCase()} library</strong><span>${drillsFor(main).length} drills, how the pros play it</span></a>
        ${p.secondary ? `<a class="quick-card" href="#/pos/${posOf(p.secondary)}"><strong>Second position: ${POSITIONS[posOf(p.secondary)].short}</strong><span>${h(spotLabel(p.secondary))}</span></a>` : ''}
        <a class="quick-card accent" href="#/coach"><strong>Selective training</strong><span>Tell the coach what’s going wrong — pick from options</span></a>
      </div>
    </section>

    <section class="pathway">
      <div class="pathway-copy">
        <p class="kicker">Your pathway</p>
        <h2>${h(levelName(p.current))}${p.team ? ` <small>(${h(p.team)})</small>` : ''} → ${h(levelName(p.goal))}${/mls/.test(p.goal) ? ` <small>${h(p.region)}</small>` : ''}</h2>
        <p>${goal - cur > 0 ? `${goal - cur} step${goal - cur > 1 ? 's' : ''} up the ladder.` : ''} By U16 most MLS NEXT academy rosters are set, and new players mostly come through scouting — so the habits below need to show up in games, not just in drills.</p>
      </div>
      <ol class="ladder">
        ${LEVELS.map((l, i) => `<li class="${i === cur ? 'is-now' : ''} ${i === goal ? 'is-goal' : ''} ${i > cur && i < goal ? 'is-between' : ''}">${l.name}${i === cur ? '<em>you</em>' : i === goal ? '<em>goal</em>' : ''}</li>`).join('')}
      </ol>
      <div class="scouts">
        <h3>What scouts look for in a ${pos.short}</h3>
        <ul>${pos.scoutsLookFor.map(s => `<li>${s}</li>`).join('')}</ul>
      </div>
    </section>

    ${history.length ? `
    <section class="recent">
      <p class="kicker">Recent sessions</p>
      <ul class="recent-list">${history.slice(0, 6).map(x => {
        const d = DRILL_BY_ID[x.drillId];
        return `<li><span>${new Date(x.at).toLocaleDateString(undefined, { month: 'short', day: 'numeric' })}</span><a href="#/drill/${x.drillId}">${d ? d.name : x.drillId}</a><span>${x.reps ? `${x.reps} reps` : `${Math.round(x.seconds / 60)} min`}${x.camera ? ' · 📹' : ''}${x.mistakes ? ` · ${x.mistakes} flags` : ''}</span></li>`;
      }).join('')}</ul>
    </section>` : ''}`;
}

// ───────── packs ─────────
function renderPack(key) {
  const p = profileOrRedirect(); if (!p) return;
  const main = posOf(p.primary);
  const pos = POSITIONS[main];
  let title = '', list = [];
  if (key === 'touches') {
    const skills = main === 'gk' ? ['gkHandling', 'gkDistribution'] : ['firstTouch', 'ballMastery', 'turning', 'weakFoot'];
    const groupPositions = Object.entries(POSITIONS).filter(([, v]) => v.group === pos.group).map(([k]) => k);
    title = main === 'gk' ? 'Keeper handling & feet' : `${pos.group === 'Wide' ? 'Wing' : pos.group} training & touches`;
    list = DRILLS.filter(d => d.skills.some(s => skills.includes(s)) && (d.positions.includes('field') && main !== 'gk' || d.positions.some(x => groupPositions.includes(x))));
  }
  view.innerHTML = `
    <section class="page-head"><a class="back" href="#/home">← Dashboard</a><h1 class="display">${title}</h1><p class="lede">${list.length} drills for a ${pos.name.toLowerCase()}.</p></section>
    <div class="drill-grid">${list.map(drillCard).join('')}</div>`;
}

function drillCard(d) {
  return `
    <a class="drill-card" href="#/drill/${d.id}">
      <span class="dc-level lvl-${d.level.toLowerCase()}">${d.level}</span>
      <strong>${d.name}</strong>
      <span class="dc-blurb">${d.blurb}</span>
      <span class="dc-meta">${minutes(d)} min · ${d.needs.filter(n => n !== 'ball').map(n => NEEDS[n]).join(', ') || 'Just a ball'}${d.cue ? ' · on-screen cues' : ''}</span>
    </a>`;
}

// ───────── positions ─────────
function renderPositions() {
  const p = store.profile;
  const sel = {};
  if (p) ['primary', 'secondary', 'third'].forEach((k, i) => { if (p[k]) sel[p[k]] = i + 1; });
  view.innerHTML = `
    <section class="page-head">
      <p class="kicker">Every position</p>
      <h1 class="display">Pick a position</h1>
      <p class="lede">How professionals play each role, how to tune it as a youth player, and the drills that get you there.</p>
    </section>
    <div class="picker-wrap big" data-el="pitch"></div>
    ${GROUPS.map(g => `
      <section class="pos-group">
        <h2 class="group-title">${g}</h2>
        <div class="pos-list">${Object.entries(POSITIONS).filter(([, v]) => v.group === g).map(([id, v]) => `
          <a class="pos-row" href="#/pos/${id}">
            <span class="shirt">${v.short}</span>
            <span class="pos-row-main"><strong>${v.name}</strong><span>${v.summary}</span></span>
            <span class="pos-row-count">${drillsFor(id).length} drills</span>
          </a>`).join('')}</div>
      </section>`).join('')}`;
  view.querySelector('[data-el="pitch"]').appendChild(pitchSVG(SPOTS, sel, code => { location.hash = `#/pos/${SPOTS[code].pos}`; }));
}

function renderPosition(id) {
  const pos = POSITIONS[id];
  if (!pos) { location.hash = '#/positions'; return; }
  const list = drillsFor(id).sort((a, b) => {
    const r = x => x.positions.includes(id) ? 0 : 1;
    return r(a) - r(b) || pos.coreSkills.indexOf(a.skills[0]) - pos.coreSkills.indexOf(b.skills[0]);
  });
  view.innerHTML = `
    <section class="pos-hero">
      <a class="back" href="#/positions">← All positions</a>
      <div class="pos-hero-row">
        <span class="shirt huge">${pos.short}</span>
        <div>
          <p class="kicker">${pos.group}</p>
          <h1 class="display">${pos.name}</h1>
          <p class="lede">${pos.summary}</p>
          <p class="pros">Study: ${pos.pros.join(' · ')}</p>
        </div>
      </div>
    </section>
    <section class="how">
      <div><h3>With the ball</h3><ul>${pos.inPossession.map(x => `<li>${x}</li>`).join('')}</ul></div>
      <div><h3>Without the ball</h3><ul>${pos.outPossession.map(x => `<li>${x}</li>`).join('')}</ul></div>
    </section>
    <section class="tune">
      <div class="tune-main">
        <p class="kicker">Fine-tuning for MLS NEXT</p>
        <h2>How a youth ${pos.short} gets to the next level</h2>
        <ol>${pos.youthTuning.map(x => `<li>${x}</li>`).join('')}</ol>
      </div>
      <aside class="tune-side">
        <h3>Scouts look for</h3>
        <ul>${pos.scoutsLookFor.map(x => `<li>${x}</li>`).join('')}</ul>
        <h3>Core skills, in order</h3>
        <div class="chips">${pos.coreSkills.map(s => `<span class="chip">${SKILLS[s].name}</span>`).join('')}</div>
      </aside>
    </section>
    <section>
      <h2 class="group-title">Drills for a ${pos.name.toLowerCase()}</h2>
      <div class="drill-grid">${list.map(drillCard).join('')}</div>
    </section>`;
}

// ───────── drill detail ─────────
function renderDrill(id) {
  const d = DRILL_BY_ID[id];
  if (!d) { location.hash = '#/home'; return; }
  const isGK = d.positions.length === 1 && d.positions[0] === 'gk';
  const forPos = d.positions.map(x => x === 'field' ? 'All outfield' : POSITIONS[x].short).join(' · ');
  const s = { format: d.mode, sets: d.sets || 3, reps: d.reps || 10, rest: d.rest || 45, minutes: d.seconds ? d.seconds / 60 : 5 };
  view.innerHTML = `
    <section class="drill-page">
      <a class="back" href="javascript:history.back()">← Back</a>
      <div class="drill-layout">
        <div class="drill-visual">
          <div class="board-wrap" data-el="board"></div>
          <div class="board-bar">
            <button class="ghost-btn" data-act="toggle">❚❚ Pause</button>
            <button class="ghost-btn" data-act="restart">↺ Restart</button>
            <button class="ghost-btn" data-act="speed">0.5×</button>
            <span class="board-caption" data-el="caption"></span>
          </div>
          <div class="legend"><span><i class="dot you"></i>You</span><span><i class="dot mate"></i>Teammate</span><span><i class="dot def"></i>Defender</span><span><i class="dot gk"></i>Keeper</span><span><i class="dot ball"></i>Ball</span><span><i class="cone-i"></i>Cone</span></div>
          <a class="video-link" href="${ytLink(d.video)}" target="_blank" rel="noopener">▶ Watch real footage of this drill <span>YouTube</span></a>
        </div>
        <div class="drill-info">
          <p class="kicker">${d.level} · ${forPos}</p>
          <h1 class="display">${d.name}</h1>
          <p class="lede">${d.blurb}</p>
          <div class="chips">${d.skills.map(x => `<span class="chip">${SKILLS[x].name}</span>`).join('')}${d.needs.map(n => `<span class="chip chip-line">${NEEDS[n]}</span>`).join('')}</div>
          <h3>How to do it</h3>
          <ol class="steps">${d.steps.map(x => `<li>${x}</li>`).join('')}</ol>
          <div class="two">
            <div><h3>Get this right</h3><ul class="ticks">${d.points.map(x => `<li>${x}</li>`).join('')}</ul></div>
            <div><h3>Common mistakes</h3><ul class="crosses">${d.mistakes.map(x => `<li>${x}</li>`).join('')}</ul></div>
          </div>
          ${d.inspired ? `<p class="inspired"><b>Where this comes from:</b> ${d.inspired}</p>` : ''}
        </div>
      </div>

      <form class="start card-dark" data-el="start">
        <div class="start-col">
          <p class="kicker light">Start training</p>
          <div class="seg" role="radiogroup" aria-label="How to train">
            <label><input type="radio" name="how" value="plain" checked><span><b>Just train</b><small>Timer & rep counter</small></span></label>
            <label><input type="radio" name="how" value="camera"><span><b>Camera coach</b><small>Records you, flags mistakes</small></span></label>
          </div>
        </div>
        <div class="start-col">
          <div class="seg small" role="radiogroup" aria-label="Format">
            <label><input type="radio" name="format" value="reps" ${s.format === 'reps' ? 'checked' : ''}><span><b>Reps</b></span></label>
            <label><input type="radio" name="format" value="time" ${s.format === 'time' ? 'checked' : ''}><span><b>Timed</b></span></label>
          </div>
          <div class="nums" data-el="nums"></div>
        </div>
        <div class="start-col end">
          <label class="check"><input type="checkbox" name="voice" checked> Voice callouts</label>
          ${d.tempo ? '<label class="check"><input type="checkbox" name="tempo" checked> Metronome (' + d.tempo + ' bpm)</label>' : ''}
          <button class="cta cta-light big" type="submit">Start training →</button>
        </div>
        <p class="cam-note" data-el="camnote" hidden>Prop your phone or laptop 3–4 yards away so it sees you head to toe. Video and form checks stay on this device. Form checks are estimates from body landmarks — use them as reminders, not a referee.</p>
      </form>
    </section>`;

  const capEl = view.querySelector('[data-el="caption"]');
  const anim = mountAnim(view.querySelector('[data-el="board"]'), d.anim, { youAreKeeper: isGK, onCaption: c => { capEl.textContent = c; } });
  cleanup = () => anim.destroy();
  view.querySelector('[data-act="toggle"]').onclick = e => { const playing = anim.toggle(); e.currentTarget.textContent = playing ? '❚❚ Pause' : '▶ Play'; };
  view.querySelector('[data-act="restart"]').onclick = () => anim.restart();
  let slow = false;
  view.querySelector('[data-act="speed"]').onclick = e => { slow = !slow; anim.setSpeed(slow ? 0.5 : 1); e.currentTarget.textContent = slow ? '1×' : '0.5×'; };

  const form = view.querySelector('[data-el="start"]');
  const nums = form.querySelector('[data-el="nums"]');
  const stepper = (name, label, val, min, max, step = 1) => `
    <label class="num-field"><span>${label}</span><input type="number" name="${name}" value="${val}" min="${min}" max="${max}" step="${step}" inputmode="numeric"></label>`;
  const drawNums = () => {
    const f = form.format.value;
    nums.innerHTML = f === 'reps'
      ? stepper('sets', 'Sets', s.sets, 1, 10) + stepper('reps', 'Reps', s.reps, 1, 50) + stepper('rest', 'Rest (s)', s.rest, 0, 300, 5)
      : stepper('minutes', 'Minutes', s.minutes, 1, 30, 0.5);
  };
  form.querySelectorAll('input[name="format"]').forEach(r => r.onchange = drawNums);
  form.querySelectorAll('input[name="how"]').forEach(r => r.onchange = () => { form.querySelector('[data-el="camnote"]').hidden = form.how.value !== 'camera'; });
  nums.addEventListener('input', e => { s[e.target.name] = +e.target.value; });
  drawNums();
  form.onsubmit = e => {
    e.preventDefault();
    const q = new URLSearchParams({
      format: form.format.value, camera: form.how.value === 'camera' ? 1 : 0,
      voice: form.voice.checked ? 1 : 0, tempo: form.tempo ? (form.tempo.checked ? 1 : 0) : 0,
      sets: s.sets, reps: s.reps, rest: s.rest, seconds: Math.round(s.minutes * 60),
    });
    location.hash = `#/train/${d.id}/${q}`;
  };
}

// ───────── training session ─────────
function renderTrain(id, query = '') {
  const d = DRILL_BY_ID[id];
  if (!d) { location.hash = '#/home'; return; }
  const q = new URLSearchParams(query);
  const opts = {
    format: q.get('format') || d.mode, camera: q.get('camera') === '1', voice: q.get('voice') !== '0', tempo: q.get('tempo') === '1',
    sets: +q.get('sets') || d.sets || 3, reps: +q.get('reps') || d.reps || 10, rest: +(q.get('rest') ?? 45), seconds: +q.get('seconds') || d.seconds || 300,
  };
  document.body.classList.add('in-session');
  const stop = runSession(view, d, opts, async (result) => {
    document.body.classList.remove('in-session');
    let recording = null;
    if (result.camera && result.camera.recording) recording = await result.camera.recording;
    const flags = result.camera ? result.camera.mistakes.reduce((s, m) => s + m.n, 0) : 0;
    if (result.seconds > 15) store.addSession({ drillId: d.id, date: todayKey(), at: Date.now(), seconds: result.seconds, reps: result.reps, completed: result.completed, camera: !!result.camera, mistakes: flags });
    renderReport(d, result, recording);
  });
  cleanup = () => { stop(); document.body.classList.remove('in-session'); };
}

function renderReport(d, r, recording) {
  const c = r.camera;
  const p = store.profile;
  const plan = p ? todaysPlan(p) : [];
  const doneToday = new Set(store.history.filter(x => x.date === todayKey() && x.completed).map(x => x.drillId));
  const next = plan.find(x => !doneToday.has(x.drill.id));
  const mm = `${Math.floor(r.seconds / 60)}:${String(r.seconds % 60).padStart(2, '0')}`;
  view.innerHTML = `
    <section class="report">
      <p class="kicker">${r.completed ? 'Session complete' : 'Session ended early'}</p>
      <h1 class="display">${d.name}</h1>
      <div class="report-stats">
        <div><span class="num">${mm}</span><span class="lbl">time</span></div>
        ${r.format === 'reps' ? `<div><span class="num">${r.reps}</span><span class="lbl">reps</span></div>` : ''}
        ${c && c.lowPct !== null ? `<div><span class="num">${c.lowPct}%</span><span class="lbl">in athletic stance</span></div>` : ''}
        ${c && c.scansPerMin !== null ? `<div><span class="num">${c.scansPerMin}</span><span class="lbl">shoulder checks / min</span></div>` : ''}
      </div>
      ${c ? `
      <div class="report-grid">
        <div>
          <h2>What the camera coach saw</h2>
          ${c.poseError === 'camera' ? '<p>The camera was blocked, so nothing was recorded.</p>'
            : c.poseError === 'pose' ? '<p>Form checks couldn’t load (they need an internet connection the first time). Your recording is still below.</p>'
            : !c.tracked ? '<p>The camera never saw your whole body. Next time, prop it 3–4 yards away at waist height.</p>'
            : c.mistakes.length ? `<ol class="mistakes">${c.mistakes.map(m => `<li><div><strong>${m.msg}</strong><span>${m.n}× · first at ${Math.floor(m.firstAt / 60)}:${String(m.firstAt % 60).padStart(2, '0')}</span></div><p>${m.fix}</p></li>`).join('')}</ol>`
            : '<p class="clean">No form flags — clean session. Make it harder next time: more speed, or the weak foot.</p>'}
          <h3>Also watch for</h3>
          <ul class="crosses">${d.mistakes.map(x => `<li>${x}</li>`).join('')}</ul>
        </div>
        <div>
          ${recording ? `<video class="playback" src="${recording.url}" controls playsinline></video>
            <a class="ghost-btn" href="${recording.url}" download="${d.id}-${todayKey()}.${recording.type.includes('mp4') ? 'mp4' : 'webm'}">⬇ Save the video</a>
            <p class="fine">The video is only in this tab. Save it before you leave if you want to keep it.</p>` : ''}
        </div>
      </div>` : ''}
      <div class="report-actions">
        ${next ? `<a class="cta" href="#/drill/${next.drill.id}">Next in today’s plan: ${next.drill.name} →</a>` : ''}
        <a class="ghost-btn" href="#/drill/${d.id}">Do it again</a>
        <a class="ghost-btn" href="#/home">Dashboard</a>
      </div>
    </section>`;
}

// ───────── selective training ─────────
const chat = { pos: null, log: [] };
function renderCoach() {
  const p = store.profile;
  if (!chat.pos) chat.pos = p ? posOf(p.primary) : 'cm';
  view.innerHTML = `
    <section class="coach">
      <div class="page-head">
        <p class="kicker">Selective training</p>
        <h1 class="display">What needs fixing?</h1>
        <p class="lede">Type what’s going wrong in your own words. The coach answers with drills to pick from — tap one to see how it works.</p>
      </div>
      <div class="pos-chips" role="radiogroup" aria-label="Train as">
        <span class="kicker">Training as</span>
        ${Object.entries(POSITIONS).map(([id, v]) => `<button type="button" class="pchip ${chat.pos === id ? 'on' : ''}" data-pos="${id}" title="${v.name}">${v.short}</button>`).join('')}
      </div>
      <div class="chat" data-el="chat" aria-live="polite"></div>
      <form class="chat-input" data-el="form">
        <input name="msg" autocomplete="off" placeholder="e.g. my touches have been bad on the wing" aria-label="Message the coach">
        <button class="cta" type="submit">Send</button>
      </form>
    </section>`;
  const log = view.querySelector('[data-el="chat"]');
  const paint = () => {
    const starters = ['My first touch has been bad on the wing', 'I keep losing my man on corners', 'I get beat 1v1 too easily', 'I panic under pressure in midfield', 'My weak foot is useless', 'I miss easy chances', 'Goal kicks don’t go far enough'];
    log.innerHTML = (chat.log.length ? '' : `
      <div class="msg coach-msg"><p>Tell me what’s off. Or start with one of these:</p>
      <div class="follow">${starters.map(s => `<button type="button" class="follow-btn" data-say="${h(s)}">${s}</button>`).join('')}</div></div>`)
      + chat.log.map(m => m.from === 'you'
        ? `<div class="msg you-msg"><p>${h(m.text)}</p></div>`
        : `<div class="msg coach-msg"><p>${h(m.line)}</p>
            ${m.options.length ? `<div class="options">${m.options.map((o, i) => `
              <a class="option" href="#/drill/${o.drill.id}"><span class="opt-n">${String.fromCharCode(65 + i)}</span><span class="opt-body"><strong>${o.drill.name}</strong><span>${o.why} · ${minutes(o.drill)} min</span></span><span class="opt-go">→</span></a>`).join('')}</div>` : ''}
            ${m.followUps.length ? `<div class="follow">${m.followUps.map(f => `<button type="button" class="follow-btn" data-say="${h(f)}">${f}</button>`).join('')}</div>` : ''}
          </div>`).join('');
    log.querySelectorAll('[data-say]').forEach(b => b.onclick = () => send(b.dataset.say));
    log.lastElementChild && log.lastElementChild.scrollIntoView({ block: 'nearest', behavior: 'smooth' });
  };
  const send = (text) => {
    if (!text.trim()) return;
    chat.log.push({ from: 'you', text });
    const r = suggest(text, chat.pos);
    if (r.q.typedPos && r.q.typedPos !== chat.pos) {
      chat.pos = r.q.typedPos;
      view.querySelectorAll('.pchip').forEach(b => b.classList.toggle('on', b.dataset.pos === chat.pos));
    }
    chat.log.push({ from: 'coach', ...r });
    paint();
  };
  view.querySelectorAll('.pchip').forEach(b => b.onclick = () => {
    chat.pos = b.dataset.pos;
    view.querySelectorAll('.pchip').forEach(x => x.classList.toggle('on', x === b));
  });
  const form = view.querySelector('[data-el="form"]');
  form.onsubmit = e => { e.preventDefault(); send(form.msg.value); form.msg.value = ''; };
  paint();
}

// ───────── profile ─────────
function renderProfile() {
  const p = profileOrRedirect(); if (!p) return;
  const pos = POSITIONS[posOf(p.primary)];
  const all = [...new Set([...pos.coreSkills, ...Object.keys(SKILLS).filter(k => !k.startsWith('gk') || pos.short === 'GK')])];
  const focus = new Set(p.focus && p.focus.length ? p.focus : pos.coreSkills.slice(0, 3));
  view.innerHTML = `
    <section class="page-head">
      <p class="kicker">Player profile</p>
      <h1 class="display">${h(p.name)}</h1>
    </section>
    <div class="profile-grid">
      <dl class="facts">
        <div><dt>Email</dt><dd>${h(p.email) || '—'}</dd></div>
        <div><dt>Phone</dt><dd>${h(p.phone) || '—'}</dd></div>
        <div><dt>Age group</dt><dd>${h(p.age)}</dd></div>
        <div><dt>Strong foot</dt><dd>${h(p.foot)}</dd></div>
        <div><dt>Main position</dt><dd>${h(spotLabel(p.primary))}</dd></div>
        <div><dt>Second position</dt><dd>${p.secondary ? h(spotLabel(p.secondary)) : '—'}</dd></div>
        <div><dt>Third position</dt><dd>${p.third ? h(spotLabel(p.third)) : '—'}</dd></div>
        <div><dt>Plays now</dt><dd>${h(levelName(p.current))}${p.team ? ` · ${h(p.team)}` : ''}</dd></div>
        <div><dt>Goal</dt><dd>${h(levelName(p.goal))} · ${h(p.region)}</dd></div>
      </dl>
      <div>
        <h2>What you’re working on</h2>
        <p class="lede">Pick up to three. Today’s plan builds around them.</p>
        <div class="focus-pick">${all.map(k => `<label class="fchip"><input type="checkbox" value="${k}" ${focus.has(k) ? 'checked' : ''}><span>${SKILLS[k].name}</span></label>`).join('')}</div>
        <p class="form-error" data-el="ferr"></p>
        <div class="report-actions">
          <a class="cta" href="#/welcome">Edit profile</a>
          <button class="ghost-btn danger" data-act="reset">Delete my data</button>
        </div>
      </div>
    </div>`;
  view.querySelectorAll('.focus-pick input').forEach(cb => cb.onchange = () => {
    const picked = [...view.querySelectorAll('.focus-pick input:checked')].map(x => x.value);
    if (picked.length > 3) { cb.checked = false; view.querySelector('[data-el="ferr"]').textContent = 'Three at most — focus wins.'; return; }
    view.querySelector('[data-el="ferr"]').textContent = '';
    store.saveProfile({ ...store.profile, focus: picked });
  });
  view.querySelector('[data-act="reset"]').onclick = () => {
    if (confirm('Delete your profile and session history from this browser?')) { store.reset(); location.hash = '#/welcome'; }
  };
}

route();
