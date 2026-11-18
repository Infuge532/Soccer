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
- Tabs: **Train**, **Progress**, **Settings** (reminders).
- Dark theme only. The accent is lime green (`Theme` in `KeeperPlanApp.swift`).

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
| `../KeeperWidget/KeeperWidget.swift` | Home-screen widget showing days trained and today's focus |

## Common changes

- **Add a drill:** add a `Drill(...)` to the matching focus array in `Drills.swift`. Give it a unique `id` with the focus prefix (e.g. `dv-` for diving), set `needs`, `amount`, `minutes`, `summary` and `steps`, and optionally `tips`, `timer` (seconds) and `demo`. Nothing else has to be wired up.
- **Change saved data:** `AppData` is decoded from saved JSON. A new field needs a default value, or existing users lose their data on update.
- **Safety matters:** the players are kids. Keep the safety rules in mind (warm up first, no full dives indoors, no max lifts). Don't add drills that break them.

## Testing on a Mac

- Build and run the KeeperPlan scheme on an iPhone simulator in Xcode.
- Debug-only launch arguments (useful for screenshots): `-gallery <page>` shows the 3D demo gallery, `-scrollDrills` scrolls the drill list, and `-showDrill <id>` opens one drill.

## `web/`

A separate static web prototype ("Pathway") for every position on the pitch, not just keepers. It has its own `web/README.md`. Run it with `python3 -m http.server 5179 --directory web`. It is plain JavaScript and runs on Windows too.
