// A training session: reps or timed, optional on-screen cues and metronome,
// optional camera coach that records you and flags form mistakes using
// on-device pose detection (MediaPipe). Video never leaves the browser.

const POSE_VERSION = '0.10.14';
const POSE_BUNDLE = `https://cdn.jsdelivr.net/npm/@mediapipe/tasks-vision@${POSE_VERSION}/vision_bundle.mjs`;
const POSE_WASM = `https://cdn.jsdelivr.net/npm/@mediapipe/tasks-vision@${POSE_VERSION}/wasm`;
const POSE_MODEL = 'https://storage.googleapis.com/mediapipe-models/pose_landmarker/pose_landmarker_lite/float16/1/pose_landmarker_lite.task';

const CHECKS = {
  low:     { msg: 'Bend your knees — get low',          fix: 'Athletic stance: knees bent, weight on the balls of your feet.' },
  headUp:  { msg: 'Lift your eyes off the ball',         fix: 'Glance down to touch, then eyes up. Use your peripheral vision for the ball.' },
  base:    { msg: 'Widen your base',                     fix: 'Feet a little wider than your shoulders so you can move either way.' },
  hands:   { msg: 'Hands up and ready',                  fix: 'Hands out in front at waist height or above — ready before the ball comes.' },
  balance: { msg: 'Stay balanced — chest over the ball', fix: 'Leaning back sends the ball high and kills your balance. Stay stacked over the ball.' },
  scan:    { msg: 'Check your shoulder',                 fix: 'Scan while the ball is traveling — a quick head turn, at least once per pass.' },
  frame:   { msg: 'Step back — whole body in frame',     fix: 'Prop the camera 3–4 yards away at waist height so it sees head to feet.' },
};

const CUE_SETS = {
  colors: [['RED', '#D8402B'], ['GREEN', '#2E9E5B'], ['BLUE', '#2D6FD1'], ['YELLOW', '#E3B23C']],
  arrows: [['←', '#15211B'], ['→', '#15211B'], ['↑', '#15211B']],
  numbers: [['1', '#15211B'], ['2', '#15211B'], ['3', '#15211B'], ['4', '#15211B'], ['5', '#15211B']],
};

let audioCtx;
function beep(freq = 880, dur = 0.09, vol = 0.18) {
  try {
    audioCtx = audioCtx || new (window.AudioContext || window.webkitAudioContext)();
    const o = audioCtx.createOscillator(), g = audioCtx.createGain();
    o.frequency.value = freq; g.gain.value = vol;
    o.connect(g); g.connect(audioCtx.destination);
    o.start(); g.gain.exponentialRampToValueAtTime(0.0001, audioCtx.currentTime + dur);
    o.stop(audioCtx.currentTime + dur + 0.02);
  } catch { /* no audio */ }
}
function say(text) {
  try { const u = new SpeechSynthesisUtterance(text); u.rate = 1.05; speechSynthesis.cancel(); speechSynthesis.speak(u); } catch { /* no speech */ }
}
const fmt = s => `${Math.floor(s / 60)}:${String(Math.max(0, Math.floor(s % 60))).padStart(2, '0')}`;

export function runSession(root, drill, opts, onDone) {
  const o = { ...opts };
  const startedAt = Date.now();
  let stopped = false;
  const timers = [];
  const every = (fn, ms) => { const id = setInterval(fn, ms); timers.push(() => clearInterval(id)); };

  root.innerHTML = `
    <div class="sess ${o.camera ? 'with-cam' : ''}">
      <header class="sess-top">
        <button class="ghost-btn" data-act="quit">✕ End</button>
        <div class="sess-title"><span class="kicker">${o.camera ? 'Camera coach' : 'Training'}</span><strong>${drill.name}</strong></div>
        <button class="ghost-btn" data-act="voice" aria-pressed="${o.voice}">${o.voice ? '🔊 Voice on' : '🔈 Voice off'}</button>
      </header>
      <div class="sess-body">
        ${o.camera ? `
        <div class="cam-wrap">
          <video class="cam" playsinline muted autoplay></video>
          <canvas class="cam-overlay"></canvas>
          <div class="cam-status"><span class="rec-dot"></span><span data-el="camstatus">Starting camera…</span></div>
          <div class="cam-callout" data-el="callout"></div>
        </div>` : ''}
        <div class="sess-main">
          <div class="cue" data-el="cue" hidden></div>
          <div class="big-num" data-el="big">0</div>
          <div class="big-sub" data-el="sub"></div>
          <div class="progress"><div class="progress-bar" data-el="bar"></div></div>
          <div class="sess-controls" data-el="controls"></div>
          <ol class="sess-steps">${drill.steps.map(s => `<li>${s}</li>`).join('')}</ol>
        </div>
      </div>
    </div>`;
  const $ = sel => root.querySelector(`[data-el="${sel}"]`);
  const big = $('big'), sub = $('sub'), bar = $('bar'), controls = $('controls'), cueEl = $('cue');

  root.querySelector('[data-act="voice"]').onclick = e => {
    o.voice = !o.voice;
    e.currentTarget.textContent = o.voice ? '🔊 Voice on' : '🔈 Voice off';
    e.currentTarget.setAttribute('aria-pressed', o.voice);
  };

  // ── metronome ──
  if (drill.tempo && o.tempo !== false) {
    let n = 0;
    every(() => { if (!paused) beep(n++ % 4 === 0 ? 1100 : 760, 0.04, 0.12); }, 60000 / drill.tempo);
  }

  // ── cues ──
  let paused = false;
  let cueTimeout;
  function scheduleCue() {
    if (!drill.cue || stopped) return;
    cueTimeout = setTimeout(() => {
      if (!paused && !resting) {
        const set = CUE_SETS[drill.cue];
        const [label, color] = set[Math.floor(Math.random() * set.length)];
        cueEl.hidden = false;
        cueEl.textContent = label;
        cueEl.style.background = color;
        cueEl.style.color = '#fff';
        beep(1320, 0.12, 0.22);
        if (o.voice) say(label === '←' ? 'left' : label === '→' ? 'right' : label === '↑' ? 'back' : label.toLowerCase());
        setTimeout(() => { cueEl.hidden = true; }, 1300);
      }
      scheduleCue();
    }, 2600 + Math.random() * 2600);
  }
  scheduleCue();
  timers.push(() => clearTimeout(cueTimeout));

  // ── reps or time ──
  let resting = false;
  let repsDone = 0;
  let setIdx = 0;
  let elapsed = 0;

  function finish(completed = true) {
    if (stopped) return;
    stopped = true;
    timers.forEach(f => f());
    const cam = camera ? camera.stop() : null;
    onDone({
      drillId: drill.id,
      completed,
      format: o.format,
      seconds: Math.round((Date.now() - startedAt) / 1000),
      reps: repsDone,
      sets: o.format === 'reps' ? setIdx + (completed ? 0 : 0) : null,
      camera: cam,
    });
  }
  root.querySelector('[data-act="quit"]').onclick = () => finish(false);

  if (o.format === 'reps') {
    const total = o.sets * o.reps;
    controls.innerHTML = `
      <button class="rep-btn" data-act="rep">+1 rep</button>
      <button class="ghost-btn" data-act="skip">Skip rest</button>
      <p class="hint">Tap the button (or press space) after every rep.</p>`;
    const repBtn = controls.querySelector('[data-act="rep"]');
    const skipBtn = controls.querySelector('[data-act="skip"]');
    skipBtn.hidden = true;
    let restLeft = 0;
    const draw = () => {
      if (resting) { big.textContent = fmt(restLeft); sub.textContent = `Rest — set ${setIdx + 1} of ${o.sets} next`; }
      else { big.textContent = repsDone - setIdx * o.reps; sub.textContent = `of ${o.reps} reps · set ${setIdx + 1} of ${o.sets}`; }
      bar.style.width = `${(repsDone / total) * 100}%`;
    };
    const endRest = () => { resting = false; skipBtn.hidden = true; repBtn.disabled = false; beep(990, 0.25); if (o.voice) say(`Set ${setIdx + 1}. Go.`); draw(); };
    const addRep = () => {
      if (resting || stopped) return;
      repsDone++;
      beep(660, 0.05);
      if (repsDone % o.reps === 0) {
        if (repsDone >= total) { draw(); setIdx = o.sets; finish(true); return; }
        setIdx++;
        resting = true; restLeft = o.rest; skipBtn.hidden = false; repBtn.disabled = true;
        if (o.voice) say(`Set done. Rest ${o.rest} seconds.`);
      }
      draw();
    };
    repBtn.onclick = addRep;
    skipBtn.onclick = endRest;
    const key = e => { if (e.code === 'Space' && !e.target.closest('input,textarea')) { e.preventDefault(); addRep(); } };
    window.addEventListener('keydown', key);
    timers.push(() => window.removeEventListener('keydown', key));
    every(() => {
      if (!resting) return;
      restLeft--;
      if (restLeft <= 3 && restLeft > 0) beep(520, 0.08);
      if (restLeft <= 0) endRest(); else draw();
    }, 1000);
    draw();
  } else {
    const total = o.seconds;
    const [work, rest] = drill.interval || [0, 0];
    controls.innerHTML = `
      <button class="rep-btn" data-act="pause">Pause</button>
      <button class="ghost-btn" data-act="done">Finish now</button>`;
    controls.querySelector('[data-act="pause"]').onclick = e => {
      paused = !paused; e.currentTarget.textContent = paused ? 'Resume' : 'Pause';
    };
    controls.querySelector('[data-act="done"]').onclick = () => finish(true);
    let lastPhase = null;
    const draw = () => {
      const left = total - elapsed;
      big.textContent = fmt(left);
      if (work) {
        const inCycle = elapsed % (work + rest);
        const phase = inCycle < work ? 'WORK' : 'EASY';
        const phaseLeft = phase === 'WORK' ? work - inCycle : work + rest - inCycle;
        sub.textContent = `${phase} · ${phaseLeft}s`;
        root.querySelector('.sess').dataset.phase = phase;
        if (phase !== lastPhase) { if (lastPhase) { beep(phase === 'WORK' ? 1100 : 600, 0.3); if (o.voice) say(phase === 'WORK' ? 'Go' : 'Easy'); } lastPhase = phase; }
      } else sub.textContent = paused ? 'Paused' : 'Keep going';
      bar.style.width = `${(elapsed / total) * 100}%`;
    };
    every(() => {
      if (paused) return;
      elapsed++;
      if (total - elapsed === 60 && total > 120) { beep(880, 0.15); if (o.voice) say('One minute left'); }
      if (total - elapsed <= 3 && total - elapsed > 0) beep(520, 0.08);
      if (elapsed >= total) { draw(); beep(990, 0.4); finish(true); return; }
      draw();
    }, 1000);
    draw();
    if (o.voice) say('Go');
  }

  // ── camera coach ──
  let camera = null;
  if (o.camera) camera = startCamera(root, drill, o, () => paused || resting);

  return () => { if (!stopped) { stopped = true; timers.forEach(f => f()); camera && camera.stop(); } };
}

function startCamera(root, drill, o, isIdle) {
  const video = root.querySelector('video.cam');
  const canvas = root.querySelector('canvas.cam-overlay');
  const ctx = canvas.getContext('2d');
  const status = root.querySelector('[data-el="camstatus"]');
  const callout = root.querySelector('[data-el="callout"]');
  const checks = [...new Set([...(drill.checks || []), 'frame'])];
  const t0 = performance.now();

  const state = {
    stream: null, recorder: null, chunks: [], landmarker: null, raf: 0, stopped: false,
    since: {}, counts: {}, firstAt: {}, lastCall: 0, lowFrames: 0, poseFrames: 0,
    scans: 0, turned: false, lastScan: performance.now(), poseError: null, recordingUrl: null,
  };

  (async () => {
    try {
      state.stream = await navigator.mediaDevices.getUserMedia({ video: { facingMode: 'user', width: { ideal: 1280 }, height: { ideal: 720 } }, audio: false });
    } catch (err) {
      status.textContent = 'Camera blocked — allow camera access in your browser, or train without it.';
      state.poseError = 'camera';
      return;
    }
    if (state.stopped) { state.stream.getTracks().forEach(t => t.stop()); return; }
    video.srcObject = state.stream;
    await video.play().catch(() => {});
    try {
      const type = ['video/webm;codecs=vp9', 'video/webm', 'video/mp4'].find(t => window.MediaRecorder && MediaRecorder.isTypeSupported(t));
      state.recorder = new MediaRecorder(state.stream, type ? { mimeType: type } : undefined);
      state.recorder.ondataavailable = e => e.data.size && state.chunks.push(e.data);
      state.recorder.start(1000);
      status.textContent = 'Recording · loading form checks…';
    } catch { status.textContent = 'Live view (this browser cannot record)'; }

    try {
      const vision = await import(/* @vite-ignore */ POSE_BUNDLE);
      const files = await vision.FilesetResolver.forVisionTasks(POSE_WASM);
      state.landmarker = await vision.PoseLandmarker.createFromOptions(files, {
        baseOptions: { modelAssetPath: POSE_MODEL, delegate: 'GPU' },
        runningMode: 'VIDEO', numPoses: 1,
      });
      status.textContent = state.recorder ? 'Recording · AI form checks on' : 'AI form checks on';
    } catch (err) {
      state.poseError = 'pose';
      status.textContent = (state.recorder ? 'Recording' : 'Live view') + ' · form checks unavailable offline';
    }
    loop();
  })();

  function flag(key, now) {
    state.counts[key] = (state.counts[key] || 0) + 1;
    if (state.firstAt[key] === undefined) state.firstAt[key] = Math.round((now - t0) / 1000);
    if (now - state.lastCall > 3500) {
      state.lastCall = now;
      callout.textContent = CHECKS[key].msg;
      callout.classList.add('show');
      setTimeout(() => callout.classList.remove('show'), 2200);
      if (o.voice) say(CHECKS[key].msg);
    }
  }
  // sustained condition → one flag per stretch
  function sustain(key, bad, ms, now) {
    if (bad) {
      if (!state.since[key]) state.since[key] = now;
      else if (now - state.since[key] > ms && state.since[key] !== -1) { flag(key, now); state.since[key] = -1; }
    } else state.since[key] = 0;
  }

  let lastVideoTime = -1;
  function loop() {
    if (state.stopped) return;
    state.raf = requestAnimationFrame(loop);
    if (!state.landmarker || video.readyState < 2 || video.currentTime === lastVideoTime) return;
    lastVideoTime = video.currentTime;
    const now = performance.now();
    canvas.width = video.videoWidth; canvas.height = video.videoHeight;
    let res;
    try { res = state.landmarker.detectForVideo(video, now); } catch { return; }
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    const lm = res.landmarks && res.landmarks[0];
    if (!lm) { sustain('frame', !isIdle(), 2500, now); return; }
    draw(lm);
    if (isIdle()) return;
    evaluate(lm, now);
  }

  const BONES = [[11, 12], [11, 13], [13, 15], [12, 14], [14, 16], [11, 23], [12, 24], [23, 24], [23, 25], [25, 27], [24, 26], [26, 28], [27, 31], [28, 32]];
  function draw(lm) {
    const W = canvas.width, H = canvas.height;
    ctx.lineWidth = Math.max(3, W / 240);
    ctx.strokeStyle = 'rgba(232,88,42,.9)';
    for (const [a, b] of BONES) {
      if (lm[a].visibility < 0.4 || lm[b].visibility < 0.4) continue;
      ctx.beginPath(); ctx.moveTo(lm[a].x * W, lm[a].y * H); ctx.lineTo(lm[b].x * W, lm[b].y * H); ctx.stroke();
    }
    ctx.fillStyle = '#FFF4EC';
    for (const i of [0, 11, 12, 13, 14, 15, 16, 23, 24, 25, 26, 27, 28]) {
      if (lm[i].visibility < 0.4) continue;
      ctx.beginPath(); ctx.arc(lm[i].x * W, lm[i].y * H, ctx.lineWidth * 1.2, 0, Math.PI * 2); ctx.fill();
    }
  }

  const angle = (a, b, c) => {
    const v1 = [a.x - b.x, a.y - b.y], v2 = [c.x - b.x, c.y - b.y];
    const cos = (v1[0] * v2[0] + v1[1] * v2[1]) / (Math.hypot(...v1) * Math.hypot(...v2));
    return Math.acos(Math.max(-1, Math.min(1, cos))) * 180 / Math.PI;
  };
  const vis = (lm, ...ids) => ids.every(i => lm[i].visibility > 0.5);

  function evaluate(lm, now) {
    const legs = vis(lm, 23, 24, 25, 26, 27, 28);
    sustain('frame', !legs, 2500, now);
    const shW = Math.hypot(lm[11].x - lm[12].x, lm[11].y - lm[12].y) || 0.0001;
    if (legs) {
      state.poseFrames++;
      const knee = (angle(lm[23], lm[25], lm[27]) + angle(lm[24], lm[26], lm[28])) / 2;
      if (knee < 158) state.lowFrames++;
      if (checks.includes('low')) sustain('low', knee > 166, 1400, now);
      if (checks.includes('base')) {
        const ankles = Math.hypot(lm[27].x - lm[28].x, lm[27].y - lm[28].y);
        sustain('base', ankles / shW < 0.85, 1600, now);
      }
      if (checks.includes('balance')) {
        const sh = { x: (lm[11].x + lm[12].x) / 2, y: (lm[11].y + lm[12].y) / 2 };
        const hip = { x: (lm[23].x + lm[24].x) / 2, y: (lm[23].y + lm[24].y) / 2 };
        const lean = Math.abs(Math.atan2(sh.x - hip.x, hip.y - sh.y) * 180 / Math.PI);
        sustain('balance', lean > 28, 1000, now);
      }
      if (checks.includes('hands') && vis(lm, 15, 16)) {
        const hipY = (lm[23].y + lm[24].y) / 2;
        sustain('hands', lm[15].y > hipY && lm[16].y > hipY, 1500, now);
      }
    }
    if (vis(lm, 0, 11, 12)) {
      if (checks.includes('headUp')) {
        const shY = (lm[11].y + lm[12].y) / 2;
        sustain('headUp', (shY - lm[0].y) / shW < 0.28, 2200, now);
      }
      if (checks.includes('scan')) {
        const shX = (lm[11].x + lm[12].x) / 2;
        const yaw = (lm[0].x - shX) / shW;
        const turned = Math.abs(yaw) > 0.32 || lm[7].visibility < 0.3 || lm[8].visibility < 0.3;
        if (turned && !state.turned) { state.scans++; state.lastScan = now; }
        state.turned = turned;
        if (now - state.lastScan > 7000) { flag('scan', now); state.lastScan = now; }
      }
    }
  }

  return {
    stop() {
      if (state.stopped) return null;
      state.stopped = true;
      cancelAnimationFrame(state.raf);
      const minutes = (performance.now() - t0) / 60000;
      const result = {
        poseError: state.poseError,
        mistakes: Object.entries(state.counts).map(([key, n]) => ({ key, n, msg: CHECKS[key].msg, fix: CHECKS[key].fix, firstAt: state.firstAt[key] })).sort((a, b) => b.n - a.n),
        lowPct: state.poseFrames ? Math.round((state.lowFrames / state.poseFrames) * 100) : null,
        scansPerMin: checks.includes('scan') && minutes > 0.1 && !state.poseError ? +(state.scans / minutes).toFixed(1) : null,
        tracked: state.poseFrames > 0,
        recording: null,
      };
      const done = () => { state.stream && state.stream.getTracks().forEach(t => t.stop()); try { state.landmarker && state.landmarker.close(); } catch {} };
      if (state.recorder && state.recorder.state !== 'inactive') {
        result.recording = new Promise(resolve => {
          state.recorder.onstop = () => {
            const blob = new Blob(state.chunks, { type: state.recorder.mimeType || 'video/webm' });
            resolve(blob.size ? { url: URL.createObjectURL(blob), type: blob.type } : null);
            done();
          };
          state.recorder.stop();
        });
      } else done();
      return result;
    },
  };
}

export { CHECKS };
