# Pathway — position training prototype

A static web prototype for youth players working toward MLS NEXT. No build step.

```bash
python3 -m http.server 5179 --directory web
```

Then open http://localhost:5179. The site uses ES modules, so it has to be served over http (opening the HTML file directly from disk won't work). The camera needs `localhost` or https.

## What's in it

| Page | What it does |
| --- | --- |
| Player profile (`#/welcome`) | Name, email, phone, age group, strong foot. Then main, second and third position picked on a pitch, then current level (with optional team or division, such as "N1"), goal level and region. Saved to localStorage only. |
| Dashboard (`#/home`) | Today's plan: a warm-up, two blocks on the player's focus skills, one block for their second position, and a finisher. It rotates daily. Also shows quick packs, the pathway ladder with what scouts look for, and recent sessions. |
| Positions (`#/positions`, `#/pos/:id`) | 11 roles: GK, CB, FB, WB, CDM, CM, CAM, WM, W, SS/false 9 and ST. Each covers how the pros play it with and without the ball, how to tune it for MLS NEXT, what scouts look for, and the role's drills. |
| Drill (`#/drill/:id`) | 43 drills. Each has an animated top-down demo, a YouTube footage search link, steps, coaching points, common mistakes and a start panel (Just train or Camera coach; reps or timed). |
| Session (`#/train/...`) | Rep counter with rest timer, or a countdown with work/rest intervals. Some drills add on-screen cues (colors, arrows or numbers, Trainerso / reaction-light style) or a metronome. Voice callouts are optional. |
| Camera coach | Records with MediaRecorder and runs MediaPipe Pose (`@mediapipe/tasks-vision@0.10.14`) on the device. It flags standing tall, head down, a narrow base, low hands and leaning back, and counts shoulder checks per minute. The report lists the flags with fixes and timestamps, plus the recording to watch or save. |
| Selective training (`#/coach`) | Type what's wrong in plain words. The coach answers only with tappable drill options, ranked by the skill, the position (typed or chosen) and the situation (solo, wall, under pressure). |

## Files

- `js/positions.js`: positions, skills, the formation spots and levels
- `js/drills.js`: the drill library and the animation scripts
- `js/anim.js`: the SVG tactics-board animator and the position picker
- `js/coach.js`: the Selective-training intent parser and ranker. It is keyword based and runs on the device. To put a real LLM behind it, keep `suggest(text, pos)` returning `{ line, options, followUps }` and limit the model to choosing drill ids from `DRILLS`.
- `js/session.js`: timers, cues, the metronome and the camera coach
- `js/store.js`: localStorage

## Known limits

- The camera checks are 2D-landmark heuristics. Treat them as reminders, not grading.
- The pose model downloads from jsDelivr and Google storage the first time, so it needs internet once.
- The profile isn't sent to a server yet. Email and phone are stored only in the browser.
