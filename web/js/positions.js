// Every position on the pitch: how professionals play it, and how a youth
// player tunes it toward the MLS NEXT standard. Skill ids match SKILLS below
// and the `skills` arrays on drills.

export const SKILLS = {
  ballMastery:   { name: 'Ball mastery',            short: 'Mastery' },
  firstTouch:    { name: 'First touch & receiving', short: 'First touch' },
  scanning:      { name: 'Scanning & awareness',    short: 'Scanning' },
  passing:       { name: 'Short passing',           short: 'Passing' },
  rangePass:     { name: 'Long & switch passes',    short: 'Range' },
  turning:       { name: 'Turning',                 short: 'Turning' },
  dribbling:     { name: '1v1 dribbling',           short: '1v1 attack' },
  speedDribble:  { name: 'Running with the ball',   short: 'Carrying' },
  crossing:      { name: 'Crossing',                short: 'Crossing' },
  finishing:     { name: 'Finishing',               short: 'Finishing' },
  heading:       { name: 'Heading & aerial duels',  short: 'Aerial' },
  weakFoot:      { name: 'Weak foot',               short: 'Weak foot' },
  defending1v1:  { name: '1v1 defending',           short: '1v1 defend' },
  positioning:   { name: 'Defensive positioning',   short: 'Positioning' },
  marking:       { name: 'Tight marking',           short: 'Marking' },
  pressing:      { name: 'Pressing',                short: 'Pressing' },
  recovery:      { name: 'Recovery runs',           short: 'Recovery' },
  agility:       { name: 'Speed & agility',         short: 'Agility' },
  holdUp:        { name: 'Hold-up play',            short: 'Hold-up' },
  movement:      { name: 'Off-ball movement',       short: 'Movement' },
  overlap:       { name: 'Overlaps & underlaps',    short: 'Overlaps' },
  gkHandling:    { name: 'GK handling',             short: 'Handling' },
  gkDiving:      { name: 'GK diving',               short: 'Diving' },
  gkCrosses:     { name: 'GK crosses & high balls', short: 'High balls' },
  gkDistribution:{ name: 'GK distribution',         short: 'Distribution' },
  gk1v1:         { name: 'GK 1v1s',                 short: 'GK 1v1' },
  gkFootwork:    { name: 'GK footwork & angles',    short: 'Angles' },
};

export const GROUPS = ['Goalkeeping', 'Defense', 'Midfield', 'Wide', 'Attack'];

export const POSITIONS = {
  gk: {
    name: 'Goalkeeper', short: 'GK', group: 'Goalkeeping',
    pros: ['Alisson', 'Ederson', 'Matt Turner'],
    summary: 'The last defender and the first attacker. Modern keepers stop shots, own the box on crosses, sweep behind a high line and start attacks with both feet.',
    inPossession: [
      'Offer a safe back-pass angle — never stand directly behind the center backs.',
      'Play out with both feet: firm, flat passes into the CB or the dropping 6.',
      'Read the press: go short when it is on, go long to a target when it is not.',
      'Distribute fast after a catch — the quickest counter starts with the keeper.',
    ],
    outPossession: [
      'Set before the shot: weight on the balls of the feet, hands ready, still head.',
      'Position on the line between ball and the center of goal (the angle).',
      'Sweep the space behind your line — start a few yards higher than you think.',
      'Organize: loud, short, specific calls ("Away!", "Keeper!", "Step up!").',
    ],
    traits: ['Handling you can trust', 'Explosive dives', 'Brave in 1v1s', 'Two-footed passing', 'Command of the box'],
    youthTuning: [
      'U13–U14: clean handling every time (W catch, scoop, basket) and collapse dives on both sides before power diving.',
      'U15–U16: footwork and angle play become the difference — be set when the shot is struck, not still moving.',
      'Train weak-foot passing on every session; MLS NEXT teams build from the back and will press you.',
      'Film yourself on crosses — the catch should happen at the highest point with a knee driven up.',
    ],
    scoutsLookFor: ['Set position on every shot', 'Comfort on the ball under a press', 'Takes crosses instead of punching everything', 'Communication you can hear from the stands'],
    coreSkills: ['gkHandling', 'gkFootwork', 'gkDiving', 'gkDistribution', 'gkCrosses', 'gk1v1'],
    spots: ['GK'],
  },
  cb: {
    name: 'Center Back', short: 'CB', group: 'Defense',
    pros: ['Virgil van Dijk', 'William Saliba', 'Rúben Dias'],
    summary: 'Protects the middle of the pitch and starts build-up. Elite center backs win the ball before it is a problem, defend the space behind, and break lines with passes.',
    inPossession: [
      'Split wide when the keeper has it; receive on the back foot, open to the field.',
      'Carry the ball into midfield when no one presses you — step in and commit a player.',
      'Look forward first: a line-breaking pass into the 6, the 10 or the striker’s feet.',
      'Switch play to the far full back when the near side is crowded.',
    ],
    outPossession: [
      'Press, cover, balance: one CB steps, the partner drops and covers at an angle — never flat.',
      'Keep the striker in front of you; know where the space behind is at all times.',
      'Delay 1v1s side-on and show the attacker away from goal.',
      'Attack every aerial ball — get your run up and meet it at the highest point.',
    ],
    traits: ['Reads danger early', 'Dominant in the air', 'Calm passer', 'Recovery pace', 'Leader'],
    youthTuning: [
      'Learn to defend facing the ball and the man at the same time — open body, half-turned.',
      'Master the "step or drop" decision: step when the ball is under pressure, drop when the passer has time.',
      'Passing range is how CBs separate at MLS NEXT tryouts — 40-yard driven switches off both feet.',
      'Heading: practise attacking the ball, not waiting for it. Timing beats height.',
    ],
    scoutsLookFor: ['Composure receiving under pressure', 'Line-breaking passes, not just sideways', 'Body shape in 1v1s', 'Talks and organizes the line'],
    coreSkills: ['positioning', 'defending1v1', 'heading', 'rangePass', 'firstTouch', 'marking', 'scanning'],
    spots: ['LCB', 'RCB'],
  },
  fb: {
    name: 'Full Back', short: 'FB', group: 'Defense', sided: true,
    pros: ['Trent Alexander-Arnold', 'Andrew Robertson', 'Antonee Robinson'],
    summary: 'Defends the flank first, then becomes an extra attacker — overlapping outside the winger, underlapping inside, or tucking into midfield as an inverted full back.',
    inPossession: [
      'Give width when your winger cuts inside; underlap into the half-space when the winger stays wide.',
      'Early crosses from deep into the space between the keeper and the back line.',
      'As an inverted full back, step into midfield only when your team has clear possession.',
      'Scan over the shoulder before every receive — the touchline cuts your options in half.',
    ],
    outPossession: [
      'Defend the back post on crosses from the far side — tuck in, do not ball-watch.',
      'Win the 1v1 against the winger: patient, side-on, show them down the line or inside to help.',
      'Recovery run on the inside line, straight back toward your own goal post.',
      'Stay connected to your center back; the gap between you is where through balls go.',
    ],
    traits: ['Engine to get up and down', 'Defends 1v1', 'Accurate crosser', 'Smart about when to go'],
    youthTuning: [
      'Repeat-sprint fitness is non-negotiable — the role is run, recover, run again.',
      'Learn both overlap and underlap timing: go when the winger’s head goes down to commit the defender.',
      'Crossing variety: driven low, whipped mid-height, and the cutback.',
      'Train defending 1v1 every week — it is the first thing a coach checks for a full back.',
    ],
    scoutsLookFor: ['Wins 1v1s on the flank', 'Recovery speed', 'Final ball quality', 'Knows when to stay home'],
    coreSkills: ['defending1v1', 'recovery', 'crossing', 'overlap', 'speedDribble', 'scanning', 'agility'],
    spots: ['LB', 'RB'],
  },
  wb: {
    name: 'Wing Back', short: 'WB', group: 'Wide', sided: true,
    pros: ['Achraf Hakimi', 'Jeremie Frimpong', 'Ona Batlle'],
    summary: 'In a back three, the wing back owns the whole touchline alone — the team’s width in attack and a fifth defender out of possession.',
    inPossession: [
      'Hold the width high so the winger or 10 can play inside.',
      'Arrive late at the back post for switches — wing backs score from the far side.',
      'Carry the ball forward at speed when there is grass in front of you.',
      'Cross early or drive to the byline; never stall at the halfway line.',
    ],
    outPossession: [
      'Drop to make a back five when the ball is wide on your side.',
      'Press the opposition full back when your team presses high.',
      'Recovery runs on the inside line every time possession is lost.',
    ],
    traits: ['Elite stamina', 'Top-end speed', 'Crossing on the run', '1v1 both ways'],
    youthTuning: [
      'Train repeat sprints: 30–40 yards, short rest, many sets.',
      'Practise receiving switches with your back to the touchline so your first touch goes forward.',
      'Cross on the run off both feet — you rarely get time to set up.',
    ],
    scoutsLookFor: ['Last 10 minutes look like the first 10', 'Arrives in the box', 'Crosses on the move', 'Defends the back post'],
    coreSkills: ['speedDribble', 'crossing', 'recovery', 'defending1v1', 'overlap', 'agility', 'firstTouch'],
    spots: ['LWB', 'RWB'],
  },
  cdm: {
    name: 'Defensive Midfield', short: 'CDM', group: 'Midfield',
    pros: ['Rodri', 'Declan Rice', 'Tyler Adams'],
    summary: 'The 6. Shields the back line, keeps the ball moving and controls the tempo. Few touches, lots of scanning, always in the right place.',
    inPossession: [
      'Show for the ball between the center backs’ passing lanes, on the half-turn.',
      'Play forward when it is on, recycle when it is not — tempo is your job.',
      'Drop between the CBs to make a back three when the team builds.',
      'Switch play quickly to the side with space.',
    ],
    outPossession: [
      'Screen: stand in the passing lane into the opponent’s 10 or striker.',
      'Delay counters — stop the ball carrier, foul smart only when necessary.',
      'Cover for a full back or CB who has stepped out.',
      'Win second balls: arrive at the drop zone before the opponent.',
    ],
    traits: ['Constant scanning', 'Positional discipline', 'Passing range', 'Tackling timing', 'Calm under pressure'],
    youthTuning: [
      'Scanning is the skill: elite central midfielders check their shoulders more than any other position in pro research. Make it a habit before every pass.',
      'Learn to receive on the back foot so you can play forward on the second touch.',
      'Train the switch of play — 30+ yards off the ground and along it.',
      'Positioning drills where you shadow the ball and close passing lanes, not just chase it.',
    ],
    scoutsLookFor: ['Never caught out of position', 'Two- and three-touch rhythm', 'Breaks up counters', 'Plays forward under pressure'],
    coreSkills: ['scanning', 'positioning', 'passing', 'rangePass', 'firstTouch', 'turning', 'defending1v1'],
    spots: ['CDM'],
  },
  cm: {
    name: 'Center Midfield', short: 'CM', group: 'Midfield',
    pros: ['Pedri', 'Federico Valverde', 'Weston McKennie'],
    summary: 'The 8. Box-to-box: connects defense to attack, arrives in the box, and presses. The most complete all-round role on the field.',
    inPossession: [
      'Find the pocket between the opponent’s midfield and defense lines.',
      'Receive half-turned and play forward — every backward pass costs the team time.',
      'Third-man runs: pass, then go beyond for the return.',
      'Arrive late at the edge of the box for cutbacks and second balls.',
    ],
    outPossession: [
      'Lead the midfield press — curve your run to block the pass back inside (cover shadow).',
      'Track runners from midfield into your box.',
      'Stay compact with the 6; the space between you two must stay small.',
    ],
    traits: ['Engine', 'Scanning', 'Turns under pressure', 'Passing both feet', 'Arrives in the box'],
    youthTuning: [
      'Scan before every receive — count how many times you check your shoulder in a 10-second build-up.',
      'Half-turn and back-foot receiving are the two techniques that move a CM up a level.',
      'Weak foot to a usable standard: short and medium passes without thinking about it.',
      'Shoot from the edge of the box — 8s who score get noticed.',
    ],
    scoutsLookFor: ['Plays forward', 'Covers every blade of grass', 'Clean first touch in traffic', 'Goals and assists from midfield'],
    coreSkills: ['scanning', 'firstTouch', 'turning', 'passing', 'weakFoot', 'pressing', 'agility'],
    spots: ['LCM', 'RCM'],
  },
  cam: {
    name: 'Attacking Midfield', short: 'CAM', group: 'Midfield',
    pros: ['Martin Ødegaard', 'Jamal Musiala', 'Bruno Fernandes'],
    summary: 'The 10. Lives between the lines, turns, and creates: the final pass, the shot from the edge, the dribble through a crowded middle.',
    inPossession: [
      'Hide in the pocket behind the opponent’s midfield, then show at the right moment.',
      'Turn on the first touch when the scan says you have space.',
      'Disguise passes — look one way, play the other.',
      'Shoot early from 18–22 yards when the keeper is unset.',
    ],
    outPossession: [
      'Press the 6 or curve onto the CB with a cover shadow on the 6.',
      'Counter-press for five seconds after losing the ball.',
    ],
    traits: ['Vision', 'Tight-space touch', 'Turning', 'Final ball', 'Shooting'],
    youthTuning: [
      'Train turning in tight spaces every single session — half-turn, inside hook, drag-back.',
      'Scan before receiving so the first touch goes forward.',
      'Practise the through ball weighted to the striker’s run, off both feet.',
      'Work your out-of-possession effort — MLS NEXT coaches drop 10s who don’t press.',
    ],
    scoutsLookFor: ['Turns and faces forward', 'Creates chances', 'Unpredictable', 'Works without the ball'],
    coreSkills: ['turning', 'scanning', 'firstTouch', 'passing', 'finishing', 'dribbling', 'ballMastery'],
    spots: ['CAM'],
  },
  wm: {
    name: 'Wide Midfield', short: 'WM', group: 'Wide', sided: true,
    pros: ['Federico Valverde', 'James Milner', 'Ji-sung Park'],
    summary: 'The left or right midfielder in a 4-4-2 or 4-4-1-1. Balances attack and defense on the flank — two-way work rate with quality at the end.',
    inPossession: [
      'Stretch the field with width, then attack the space in behind.',
      'Combine with the full back: give-and-go, overlap, underlap.',
      'Cross from wide or come inside to shoot depending on your stronger foot.',
    ],
    outPossession: [
      'Track the opposing full back all the way back.',
      'Make the block a line of four with your midfield — tuck in when the ball is on the far side.',
      'Double the winger with your full back.',
    ],
    traits: ['Work rate', 'Crossing', 'Defensive discipline', 'Combination play'],
    youthTuning: [
      'Build the engine first: repeat-sprint and recovery runs.',
      'Crossing off both feet, early and from the byline.',
      'Learn defensive shape: when to tuck in, when to press the full back.',
    ],
    scoutsLookFor: ['Two-way effort', 'Quality delivery', 'Positional discipline', 'Combines quickly'],
    coreSkills: ['crossing', 'recovery', 'speedDribble', 'passing', 'defending1v1', 'agility', 'firstTouch'],
    spots: ['LM', 'RM'],
  },
  w: {
    name: 'Winger', short: 'W', group: 'Wide', sided: true,
    pros: ['Bukayo Saka', 'Vinícius Júnior', 'Christian Pulisic'],
    summary: 'The 1v1 specialist. Takes on full backs, cuts inside to shoot (inverted winger) or goes to the byline to cross. Changes games with pace and nerve.',
    inPossession: [
      'Receive side-on so your first touch already threatens the defender.',
      'Isolate the full back, then attack at speed with a change of pace and direction.',
      'Inverted: cut inside onto your strong foot to shoot or slip a pass; traditional: beat them outside and cross.',
      'Attack the far post when the ball is on the other wing.',
    ],
    outPossession: [
      'Press the full back on the trigger (bad touch, back pass).',
      'Cover-shadow the pass inside when pressing from wide.',
      'Track back to help your full back — at MLS NEXT this is expected, not optional.',
    ],
    traits: ['Acceleration', '1v1 confidence', 'End product', 'Both directions'],
    youthTuning: [
      'Work on change of pace more than tricks — slow, slow, explode is what beats defenders.',
      'Get a reliable outside move and inside move so the defender can’t sit on one side.',
      'First touch on the wing: receive across your body, away from pressure, toward goal.',
      'Count your end product: goals + assists + shots per game. Scouts do.',
    ],
    scoutsLookFor: ['Beats the man', 'Goals and assists', 'Brave in possession', 'Tracks back'],
    coreSkills: ['dribbling', 'firstTouch', 'speedDribble', 'finishing', 'crossing', 'agility', 'movement'],
    spots: ['LW', 'RW'],
  },
  ss: {
    name: 'Second Striker / False 9', short: 'SS', group: 'Attack',
    pros: ['Antoine Griezmann', 'Thomas Müller', 'Lionel Messi'],
    summary: 'Plays off the main striker or drops in as a false 9. Finds space between the lines, links play, and arrives in the box at the right moment.',
    inPossession: [
      'Drop off the center backs to receive — drag one with you to open space for runners.',
      'Combine fast: one-twos, lay-offs and flicks around the box.',
      'Arrive, don’t stand: time runs into the box for rebounds and cutbacks.',
    ],
    outPossession: [
      'Screen the 6 so the CBs can’t play through midfield.',
      'Press the CB on the trigger with the other forward.',
    ],
    traits: ['Football IQ', 'Link play', 'Clinical finishing', 'Movement'],
    youthTuning: [
      'Train receiving with back to goal and turning — the false 9 lives there.',
      'Finishing with one and two touches from inside the box.',
      'Watch film of where you got the ball last game — were you in the pocket or flat on the line?',
    ],
    scoutsLookFor: ['Finds space nobody else sees', 'Links play', 'Scores', 'Pressing intelligence'],
    coreSkills: ['movement', 'turning', 'finishing', 'firstTouch', 'passing', 'scanning', 'holdUp'],
    spots: ['SS'],
  },
  st: {
    name: 'Striker', short: 'ST', group: 'Attack',
    pros: ['Erling Haaland', 'Harry Kane', 'Lautaro Martínez'],
    summary: 'The 9. Scores goals. Plays on the shoulder of the last defender, holds the ball up, and leads the press from the front.',
    inPossession: [
      'Run off the shoulder: stay onside, time the run for the passer’s head coming up.',
      'Near post, far post, penalty spot — attack a zone on every cross, don’t wait in one.',
      'Back to goal: use your body, lay it off first time, spin.',
      'Finish across the keeper and low; the far post is your friend.',
    ],
    outPossession: [
      'Lead the press: curve your run to force play one way.',
      'Block the pass into the 6 with your cover shadow.',
    ],
    traits: ['Clinical', 'Movement in the box', 'Strong on the ball', 'Brave', 'Short memory'],
    youthTuning: [
      'First-time finishing is the skill that translates up levels — the time to shoot shrinks every year.',
      'Hold-up play: get your body between the defender and the ball before it arrives.',
      'Head-up movement: check where the CBs are before the cross, then go to space.',
      'Weak-foot finishing every week. Defenders at MLS NEXT will show you onto it.',
    ],
    scoutsLookFor: ['Goals', 'Movement that creates chances', 'Holds the ball up', 'Presses from the front'],
    coreSkills: ['finishing', 'movement', 'holdUp', 'heading', 'firstTouch', 'weakFoot', 'pressing'],
    spots: ['ST'],
  },
};

// Spots on the formation picker → position id, side and pitch coordinates
// (x across the 100-wide pitch from own goal on the left, y down a 64-high pitch).
export const SPOTS = {
  GK:  { pos: 'gk',  x: 6,  y: 32 },
  LCB: { pos: 'cb',  x: 20, y: 24 }, RCB: { pos: 'cb',  x: 20, y: 40 },
  LB:  { pos: 'fb',  x: 25, y: 8,  side: 'L' }, RB:  { pos: 'fb',  x: 25, y: 56, side: 'R' },
  LWB: { pos: 'wb',  x: 38, y: 5,  side: 'L' }, RWB: { pos: 'wb',  x: 38, y: 59, side: 'R' },
  CDM: { pos: 'cdm', x: 36, y: 32 },
  LCM: { pos: 'cm',  x: 48, y: 22 }, RCM: { pos: 'cm',  x: 48, y: 42 },
  CAM: { pos: 'cam', x: 61, y: 32 },
  LM:  { pos: 'wm',  x: 52, y: 7,  side: 'L' }, RM:  { pos: 'wm',  x: 52, y: 57, side: 'R' },
  LW:  { pos: 'w',   x: 72, y: 10, side: 'L' }, RW:  { pos: 'w',   x: 72, y: 54, side: 'R' },
  SS:  { pos: 'ss',  x: 76, y: 32 },
  ST:  { pos: 'st',  x: 88, y: 32 },
};

export const LEVELS = [
  { id: 'rec',     name: 'Recreational' },
  { id: 'travel',  name: 'Town travel' },
  { id: 'hs',      name: 'High school' },
  { id: 'premier', name: 'Club premier / state league' },
  { id: 'npl',     name: 'NPL' },
  { id: 'ecnlrl',  name: 'ECNL Regional League' },
  { id: 'natl',    name: 'National league (USYS, EDP top flight)' },
  { id: 'ecnl',    name: 'ECNL' },
  { id: 'mlsa',    name: 'MLS NEXT Academy Division' },
  { id: 'mlsh',    name: 'MLS NEXT Homegrown Division' },
  { id: 'pro',     name: 'MLS NEXT Pro / college' },
];

export const AGE_GROUPS = ['U12', 'U13', 'U14', 'U15', 'U16', 'U17', 'U19'];

export function levelIndex(id) { return LEVELS.findIndex(l => l.id === id); }
export function levelName(id) { return (LEVELS.find(l => l.id === id) || { name: id || '—' }).name; }
export function spotLabel(code) {
  const s = SPOTS[code];
  if (!s) return '—';
  const p = POSITIONS[s.pos];
  if (p.sided) return `${s.side === 'L' ? 'Left' : 'Right'} ${p.name.toLowerCase()}`.replace(/^./, c => c.toUpperCase());
  return p.name;
}
