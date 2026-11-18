// Everything is saved in this browser only (localStorage). Nothing is sent anywhere.

const KEY = 'pathway.v1';

function read() {
  try { return JSON.parse(localStorage.getItem(KEY)) || {}; } catch { return {}; }
}
function write(data) {
  try { localStorage.setItem(KEY, JSON.stringify(data)); } catch { /* private mode: keep in memory */ }
  memory = data;
}
let memory = read();

export const store = {
  get profile() { return memory.profile || null; },
  saveProfile(profile) { write({ ...memory, profile }); },
  get history() { return memory.history || []; },
  addSession(entry) { write({ ...memory, history: [entry, ...(memory.history || [])].slice(0, 200) }); },
  reset() { write({}); },
};

export function todayKey(d = new Date()) {
  return d.toISOString().slice(0, 10);
}

export function streak(history) {
  const days = new Set(history.map(h => h.date));
  let n = 0;
  const d = new Date();
  if (!days.has(todayKey(d))) d.setDate(d.getDate() - 1);
  while (days.has(todayKey(d))) { n++; d.setDate(d.getDate() - 1); }
  return n;
}
