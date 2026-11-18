// Selective training "AI". It reads what the player types, works out the
// position, the skill and the situation, and answers only with drill options
// to tap — never a lecture. Runs fully on-device; see README for wiring a
// real language model behind the same interface.

import { DRILLS } from './drills.js';
import { POSITIONS, SKILLS } from './positions.js';

const SKILL_WORDS = [
  [/first touch|touches|touch|receiv|control|trap|settle/, ['firstTouch', 2], ['ballMastery', 0.6]],
  [/ball mastery|footwork with the ball|close control|tight space/, ['ballMastery', 2]],
  [/long ball|long pass|switch|diagonal|range|hit it long/, ['rangePass', 2]],
  [/pass|passing|playmak|through ball/, ['passing', 1.6]],
  [/scan|aware|vision|look around|see the field|shoulder|check/, ['scanning', 2]],
  [/turn|spin|facing forward|face forward|back to (the )?play/, ['turning', 1.8]],
  [/dribbl|1v1|one v one|1 v 1|beat (my|the|a|defender|people|players)|take on|skill move|moves|trick/, ['dribbling', 2]],
  [/run with|carry|\bcounter\b|on the break/, ['speedDribble', 2]],
  [/speed|pace|fast|quick|slow|sprint|explos|agil|reaction|first step/, ['agility', 1.6]],
  [/cross|delivery|whip|cutback|cut back|byline/, ['crossing', 2]],
  [/shoot|shot|finish|scor|goals\b|strik|volley|bend it|curl|chances|in front of goal/, ['finishing', 2]],
  [/head|header|aerial|in the air|jump/, ['heading', 2], ['gkCrosses', 1]],
  [/weak foot|left foot|right foot|other foot|both feet|non.?dominant/, ['weakFoot', 2.2]],
  [/defend|tackl|jockey|get beat|getting beat|beaten|skinned|1v1 defend|contain/, ['defending1v1', 2]],
  [/out of position|positioning|shape|lane|screen|where to stand/, ['positioning', 2]],
  [/mark|marking|lose my man|losing my man|track my man/, ['marking', 2]],
  [/\bpress(ing)?\b|win it back|win the ball|counter.?press/, ['pressing', 2]],
  [/recover|track back|tracking back|get back|transition/, ['recovery', 2]],
  [/hold up|hold the ball|back to goal|bullied|knocked off|strong/, ['holdUp', 2]],
  [/movement|runs\b|off the ball|offside|find space|get open|in behind/, ['movement', 2]],
  [/overlap|underlap/, ['overlap', 2.4]],
  [/fitness|stamina|tired|engine|gas|conditioning/, ['agility', 1.2], ['recovery', 1.2]],
  // goalkeeping
  [/catch|handling|drop|fumbl|spill|parry/, ['gkHandling', 2]],
  [/dive|diving/, ['gkDiving', 2]],
  [/high ball|punch|corners?|claim/, ['gkCrosses', 2]],
  [/kick|distribut|goal kick|punt|throw/, ['gkDistribution', 2]],
  [/breakaway|one on one|1v1/, ['gk1v1', 1.2]],
  [/angle|set position|footwork|positioning in goal|near post/, ['gkFootwork', 2]],
];

const POSITION_WORDS = [
  [/wing.?back|wingback/, 'wb'],
  [/full.?back|outside back|right back|left back|\brb\b|\blb\b/, 'fb'],
  [/center.?back|centre.?back|\bcb\b|central defender|defender/, 'cb'],
  [/defensive mid|holding mid|\bcdm\b|\bdm\b|the 6\b|number 6|\bsix\b/, 'cdm'],
  [/attacking mid|\bcam\b|\bam\b|the 10\b|number 10|\bten\b|playmaker/, 'cam'],
  [/false 9|second striker|\bss\b|withdrawn/, 'ss'],
  [/left mid|right mid|\blm\b|\brm\b|wide mid/, 'wm'],
  [/\bwing|winger|\blw\b|\brw\b|on the wide|out wide/, 'w'],
  [/center mid|centre mid|central mid|\bcm\b|box to box|the 8\b|number 8|midfield|\bmid\b/, 'cm'],
  [/striker|forward|\bst\b|\bcf\b|number 9|the 9\b/, 'st'],
  [/keeper|goalie|\bgk\b|goalkeeper|in goal|goal kick|punt/, 'gk'],
];

const GK_TRANSLATE = { firstTouch: 'gkHandling', heading: 'gkCrosses', finishing: null, passing: 'gkDistribution', rangePass: 'gkDistribution', positioning: 'gkFootwork', agility: 'gkFootwork', defending1v1: 'gk1v1', dribbling: 'gk1v1' };

export function parse(text, fallbackPos) {
  const t = ' ' + text.toLowerCase() + ' ';
  let pos = null;
  for (const [re, id] of POSITION_WORDS) if (re.test(t)) { pos = id; break; }
  const skills = {};
  for (const [re, ...pairs] of SKILL_WORDS) {
    if (!re.test(t)) continue;
    for (const [s, w] of pairs) skills[s] = Math.max(skills[s] || 0, w);
  }
  if (skills.defending1v1 && /get beat|getting beat|beaten|skinned/.test(t)) delete skills.dribbling;
  const finalPos = pos || fallbackPos;
  if (finalPos === 'gk') {
    for (const [k, v] of Object.entries({ ...skills })) {
      if (k in GK_TRANSLATE) { delete skills[k]; const g = GK_TRANSLATE[k]; if (g) skills[g] = Math.max(skills[g] || 0, v); }
    }
  } else {
    for (const k of Object.keys(skills)) if (k.startsWith('gk')) delete skills[k];
  }
  const pressure = /under pressure|pressed|pressure|tight|crowd|traffic|marked/.test(t);
  if (pressure && finalPos !== 'gk') { skills.scanning = Math.max(skills.scanning || 0, 1.2); skills.turning = Math.max(skills.turning || 0, 0.8); }
  const solo = /alone|solo|by myself|on my own|no partner|no one|nobody|backyard|at home|inside|garage/.test(t);
  const wall = /wall|rebounder/.test(t);
  const noCones = /no cones/.test(t);
  return { pos: finalPos, typedPos: pos, skills, solo, wall, noCones, pressure };
}

function score(drill, q) {
  let s = 0;
  const hits = [];
  drill.skills.forEach((sk, i) => {
    if (q.skills[sk]) { s += q.skills[sk] * (i === 0 ? 1.5 : 1); hits.push(sk); }
  });
  if (!hits.length) return null;
  if (q.pos) {
    if (drill.positions.includes(q.pos)) s += 2;
    else if (q.pos !== 'gk' && drill.positions.includes('field')) s += 0.6;
    else s -= q.typedPos ? 4 : 1;
  }
  if (q.solo && drill.needs.includes('partner')) s -= 3;
  if (q.wall && drill.needs.includes('wall')) s += 1;
  if (q.noCones && drill.needs.includes('cones')) s -= 1.5;
  return { drill, s, hits };
}

export function suggest(text, fallbackPos) {
  const q = parse(text, fallbackPos);
  const results = DRILLS.map(d => score(d, q)).filter(Boolean).filter(r => r.s > 0)
    .sort((a, b) => b.s - a.s).slice(0, 5);
  const posName = q.pos ? POSITIONS[q.pos].name.toLowerCase() : null;
  const skillNames = Object.entries(q.skills).sort((a, b) => b[1] - a[1]).slice(0, 2).map(([k]) => SKILLS[k].name.toLowerCase());

  if (!results.length) {
    return {
      q, options: [],
      line: q.typedPos ? `Got it — ${posName}. Which part of your game?` : 'Which part of your game? Tap one, or say it another way.',
      followUps: followUpsFor(q.pos),
    };
  }
  const headline = [skillNames.join(' + '), posName && `as a ${posName}`, q.solo && 'solo'].filter(Boolean).join(', ');
  return {
    q,
    line: `${cap(headline)}. Pick one to see how it works:`,
    options: results.map(r => ({
      drill: r.drill,
      why: [
        r.hits.slice(0, 2).map(h => SKILLS[h].short).join(' · '),
        q.pos && r.drill.positions.includes(q.pos) ? `built for ${POSITIONS[q.pos].short}` : null,
        r.drill.needs.includes('partner') ? 'needs a partner' : 'solo',
      ].filter(Boolean).join(' — '),
    })),
    followUps: [],
  };
}

function followUpsFor(pos) {
  const p = POSITIONS[pos] || POSITIONS.cm;
  return p.coreSkills.slice(0, 6).map(k => `My ${SKILLS[k].name.toLowerCase()} needs work`);
}
const cap = s => s ? s[0].toUpperCase() + s.slice(1) : s;
