# Keeper (KeeperPlan): goalkeeper home-training app

Two people build this app together, each with their own Claude, through this GitHub repo (`Infuge532/Soccer`). Read this file first, and keep it up to date when something important changes.

## Working together

- Run `git pull` before starting. When done: `git add -A && git commit -m "..." && git push`.
- Keep commits small and focused so the other person's pull merges cleanly.
- If a pull conflicts, resolve it by keeping both people's intent. Don't throw away the other person's work.
- One collaborator is on Windows. They can edit the Swift files but can't build or run the iOS app. Only a Mac with Xcode can. Changes made on Windows get checked on the Mac before anyone calls them done.
- `build/` is local Xcode output and is git-ignored. Never commit it.

## What the app is

A SwiftUI iPhone app for a youth goalkeeper training at home. **There is no schedule.** Each day the player picks one or more focuses plus what they have with them, and the app shows every drill that fits. Never bring back weekly plans, set rest days or a 4-week program. The owner removed those on purpose.

- **Focuses** (`Focus` in `Drills.swift`): diving, handling, shot stopping, distribution, footwork, crosses & high balls, 1v1s, reactions, positioning, power.
- **Setup toggles** (`Need` / `Setup`): Outside, Goal, Partner, Wall. A drill is shown only if every one of its `needs` is switched on.
- Tabs: **Home**, **Positions**, **Selective**, **Keeper** (the original Train screen), **Progress**. Reminders and settings, plus the player profile, open from the profile button on Home.
- Dark theme only. The accent is lime green (`Theme` in `KeeperPlanApp.swift`). Headings use the condensed display font (`Font.display`) and sections use `Panel` from `Design.swift`.
- **Player card:** each stat starts from the player's latest test results (or 50 plus a little for their level). Training adds at most a quarter of the gap to 99, slowly, on purpose. Retired tests stay in the `StatTest` enum so old saved results still decode; only `StatTest.active` is shown and scored.

## Pathway (every position)

Pathway is the all-positions part of the app, ported from the `web/` prototype. It is for youth players working toward MLS NEXT. The files are in `KeeperPlan/Pathway/`.

- **Profile onboarding** shows full screen until a profile exists. It collects name, email, phone, age group and strong foot. Main, second and third positions are picked on a pitch. Then the current level (with a team/division text such as "N1"), the goal level and the region. Saved in `AppData.profile`.
- **Home** suggests today's drills: a warm-up, two focus-skill drills, one for the second position, and a finisher. It rotates daily and is only a suggestion. It is not a schedule: there are no weekly plans or rest days, and the Keeper tab keeps its pick-a-focus rule.
- **Positions** covers 11 roles: how pros play each one, how to tune it for MLS NEXT, and its drills.
- **Selective**: the player types a problem and gets tappable drill options back, never advice text. The parser is on-device (`SelectiveCoach` in `PathwayModel.swift`).
- **Sessions** run as reps or timed, with on-screen cues, a metronome and voice. The **camera coach** uses Apple Vision body pose to flag form mistakes and records the drill with AVAssetWriter. All of it stays on the phone. The simulator has no camera, so test the camera coach on a real iPhone.

| File | What it holds |
| --- | --- |
| `PathwayLibrary.swift` | `Skill`, `Position` (with all coaching text), `Spot`, `Level`, `PathwayDrill` and the 43 drills with their board animations. First generated from `web/js/*.js`; edit the Swift now. |
| `PathwayModel.swift` | `PlayerProfile`, `PathwaySession`, today's plan, `SelectiveCoach` |
| `PathwayViews.swift` | Home, positions, drill page, Selective |
| `ProfileViews.swift` | Onboarding and the profile sheet |
| `TacticsBoard.swift` | The animated top-down drill board and the pitch position picker |
| `TrainingSessionView.swift` | The session screen and the report |
| `CameraCoach.swift` | Camera, Vision pose checks, recording |

Debug launch arguments: `-seedProfile` fills in a sample player, and `-tab <n>` opens a tab.

## Project facts

- Xcode project: `KeeperPlan.xcodeproj`. Targets: the **KeeperPlan** app plus the **KeeperWidget** home-screen widget.
- iOS 17.0 minimum, iPhone only, Swift 5.
- Bundle IDs: `app.keeperplan.hometraining` and `app.keeperplan.hometraining.widget`.
- App group: `group.app.keeperplan.hometraining`. The widget reads its data from here.
- The project has a signing team set (`DEVELOPMENT_TEAM`). Someone else building on their own Mac picks their own team under Signing & Capabilities. Don't commit a change to the team ID.

## Files (`KeeperPlan/`)

| File | What it holds |
| --- | --- |
| `KeeperPlanApp.swift` | App entry, the tab bar, `Theme`, and shared `Card` / `BigButtonStyle` UI |
| `Drills.swift` | `Focus`, `Need`, `Setup`, `Drill`, and the whole drill library (`Library`: warm-up, safety rules, ~65 drills grouped by focus) |
| `TrainView.swift` | Main screen: pick the focuses and setup, see the matching drills |
| `DrillDetailView.swift` | One drill: steps, tips, countdown timer, demo |
| `Demos.swift`, `DemoFigure3D.swift` | Animated 3D stick-figure demos (SceneKit). A drill's `demo` field picks one |
| `Tips.swift` | Coaching tips |
| `Store.swift` | All saved data (`AppData`, saved as JSON in UserDefaults under `keeperplan.data.v2`), badges, the catch log, and syncing the widget |
| `ProgressScreen.swift` | Days trained, streaks, badges |
| `Reminders.swift`, `RemindersView.swift` | Training-time notifications and the Settings tab |
| `Alarms.swift` | Real alarms through AlarmKit (iOS 26.1+ only, behind `@available`) |
| `WorkoutSupport.swift` | Voice callouts, video clips, the demo area |
| `Design.swift` | The look: condensed display font, `Panel` (notched section), stadium backdrop (uses an asset named `Stadium` if one exists), buttons and pills |
| `PlayerCard.swift` | The player card: six stats + overall, tiers (bronze/silver/gold/elite), how ratings are worked out, the card screen |
| `StatTests.swift` | Real test results (sprints, jumps, lifts) that set card stats, age-adjusted benchmark ladders, and the test entry screens |
| `../KeeperWidget/KeeperWidget.swift` | Home-screen widget showing days trained and today's focus |

## Common changes

- **Add a drill:** add a `Drill(...)` to the matching focus array in `Drills.swift`. Give it a unique `id` with the focus prefix (e.g. `dv-` for diving), set `needs`, `amount`, `minutes`, `summary` and `steps`, and optionally `tips`, `timer` (seconds) and `demo`. Nothing else has to be wired up.
- **Change saved data:** `AppData` is decoded from saved JSON. A new field needs a default value, or existing users lose their data on update.
- **Safety matters:** the players are kids. Keep the safety rules in mind (warm up first, no full dives indoors, no max lifts). Don't add drills that break them.

## Testing on a Mac

- Build and run the KeeperPlan scheme on an iPhone simulator in Xcode.
- Debug-only launch arguments (useful for screenshots): `-gallery <page>` shows the 3D demo gallery, `-scrollDrills` scrolls the drill list, and `-showDrill <id>` opens one drill.

## `web/`

The original static web prototype of Pathway. It is kept for reference, but the iOS app is now where Pathway work happens. It has its own `web/README.md`.
