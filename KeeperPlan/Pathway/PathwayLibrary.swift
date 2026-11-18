// Generated from web/js/positions.js and web/js/drills.js, then owned by the app.
// Pathway: every position on the pitch, for players working toward MLS NEXT.

import Foundation

enum Skill: String, CaseIterable, Codable, Identifiable {
    case ballMastery
    case firstTouch
    case scanning
    case passing
    case rangePass
    case turning
    case dribbling
    case speedDribble
    case crossing
    case finishing
    case heading
    case weakFoot
    case defending1v1
    case positioning
    case marking
    case pressing
    case recovery
    case agility
    case holdUp
    case movement
    case overlap
    case gkHandling
    case gkDiving
    case gkCrosses
    case gkDistribution
    case gk1v1
    case gkFootwork

    var id: String { rawValue }

    var name: String {
        switch self {
        case .ballMastery: return "Ball mastery"
        case .firstTouch: return "First touch & receiving"
        case .scanning: return "Scanning & awareness"
        case .passing: return "Short passing"
        case .rangePass: return "Long & switch passes"
        case .turning: return "Turning"
        case .dribbling: return "1v1 dribbling"
        case .speedDribble: return "Running with the ball"
        case .crossing: return "Crossing"
        case .finishing: return "Finishing"
        case .heading: return "Heading & aerial duels"
        case .weakFoot: return "Weak foot"
        case .defending1v1: return "1v1 defending"
        case .positioning: return "Defensive positioning"
        case .marking: return "Tight marking"
        case .pressing: return "Pressing"
        case .recovery: return "Recovery runs"
        case .agility: return "Speed & agility"
        case .holdUp: return "Hold-up play"
        case .movement: return "Off-ball movement"
        case .overlap: return "Overlaps & underlaps"
        case .gkHandling: return "GK handling"
        case .gkDiving: return "GK diving"
        case .gkCrosses: return "GK crosses & high balls"
        case .gkDistribution: return "GK distribution"
        case .gk1v1: return "GK 1v1s"
        case .gkFootwork: return "GK footwork & angles"
        }
    }

    var short: String {
        switch self {
        case .ballMastery: return "Mastery"
        case .firstTouch: return "First touch"
        case .scanning: return "Scanning"
        case .passing: return "Passing"
        case .rangePass: return "Range"
        case .turning: return "Turning"
        case .dribbling: return "1v1 attack"
        case .speedDribble: return "Carrying"
        case .crossing: return "Crossing"
        case .finishing: return "Finishing"
        case .heading: return "Aerial"
        case .weakFoot: return "Weak foot"
        case .defending1v1: return "1v1 defend"
        case .positioning: return "Positioning"
        case .marking: return "Marking"
        case .pressing: return "Pressing"
        case .recovery: return "Recovery"
        case .agility: return "Agility"
        case .holdUp: return "Hold-up"
        case .movement: return "Movement"
        case .overlap: return "Overlaps"
        case .gkHandling: return "Handling"
        case .gkDiving: return "Diving"
        case .gkCrosses: return "High balls"
        case .gkDistribution: return "Distribution"
        case .gk1v1: return "GK 1v1"
        case .gkFootwork: return "Angles"
        }
    }

    var isKeeper: Bool { rawValue.hasPrefix("gk") }
}

enum PositionGroup: String, CaseIterable {
    case goalkeeping = "Goalkeeping", defense = "Defense", midfield = "Midfield", wide = "Wide", attack = "Attack"
}

struct PositionInfo {
    let name: String
    let short: String
    let group: PositionGroup
    let sided: Bool
    let pros: [String]
    let summary: String
    let inPossession: [String]
    let outPossession: [String]
    let traits: [String]
    let youthTuning: [String]
    let scoutsLookFor: [String]
    let coreSkills: [Skill]
}

enum Position: String, CaseIterable, Codable, Identifiable {
    case gk
    case cb
    case fb
    case wb
    case cdm
    case cm
    case cam
    case wm
    case w
    case ss
    case st

    var id: String { rawValue }

    var info: PositionInfo {
        switch self {
        case .gk: return PositionInfo(
            name: "Goalkeeper", short: "GK", group: .goalkeeping, sided: false,
            pros: ["Alisson", "Ederson", "Matt Turner"],
            summary: "The last defender and the first attacker. Modern keepers stop shots, own the box on crosses, sweep behind a high line and start attacks with both feet.",
            inPossession: ["Offer a safe back-pass angle — never stand directly behind the center backs.", "Play out with both feet: firm, flat passes into the CB or the dropping 6.", "Read the press: go short when it is on, go long to a target when it is not.", "Distribute fast after a catch — the quickest counter starts with the keeper."],
            outPossession: ["Set before the shot: weight on the balls of the feet, hands ready, still head.", "Position on the line between ball and the center of goal (the angle).", "Sweep the space behind your line — start a few yards higher than you think.", "Organize: loud, short, specific calls (\"Away!\", \"Keeper!\", \"Step up!\")."],
            traits: ["Handling you can trust", "Explosive dives", "Brave in 1v1s", "Two-footed passing", "Command of the box"],
            youthTuning: ["U13–U14: clean handling every time (W catch, scoop, basket) and collapse dives on both sides before power diving.", "U15–U16: footwork and angle play become the difference — be set when the shot is struck, not still moving.", "Train weak-foot passing on every session; MLS NEXT teams build from the back and will press you.", "Film yourself on crosses — the catch should happen at the highest point with a knee driven up."],
            scoutsLookFor: ["Set position on every shot", "Comfort on the ball under a press", "Takes crosses instead of punching everything", "Communication you can hear from the stands"],
            coreSkills: [.gkHandling, .gkFootwork, .gkDiving, .gkDistribution, .gkCrosses, .gk1v1])
        case .cb: return PositionInfo(
            name: "Center Back", short: "CB", group: .defense, sided: false,
            pros: ["Virgil van Dijk", "William Saliba", "Rúben Dias"],
            summary: "Protects the middle of the pitch and starts build-up. Elite center backs win the ball before it is a problem, defend the space behind, and break lines with passes.",
            inPossession: ["Split wide when the keeper has it; receive on the back foot, open to the field.", "Carry the ball into midfield when no one presses you — step in and commit a player.", "Look forward first: a line-breaking pass into the 6, the 10 or the striker’s feet.", "Switch play to the far full back when the near side is crowded."],
            outPossession: ["Press, cover, balance: one CB steps, the partner drops and covers at an angle — never flat.", "Keep the striker in front of you; know where the space behind is at all times.", "Delay 1v1s side-on and show the attacker away from goal.", "Attack every aerial ball — get your run up and meet it at the highest point."],
            traits: ["Reads danger early", "Dominant in the air", "Calm passer", "Recovery pace", "Leader"],
            youthTuning: ["Learn to defend facing the ball and the man at the same time — open body, half-turned.", "Master the \"step or drop\" decision: step when the ball is under pressure, drop when the passer has time.", "Passing range is how CBs separate at MLS NEXT tryouts — 40-yard driven switches off both feet.", "Heading: practise attacking the ball, not waiting for it. Timing beats height."],
            scoutsLookFor: ["Composure receiving under pressure", "Line-breaking passes, not just sideways", "Body shape in 1v1s", "Talks and organizes the line"],
            coreSkills: [.positioning, .defending1v1, .heading, .rangePass, .firstTouch, .marking, .scanning])
        case .fb: return PositionInfo(
            name: "Full Back", short: "FB", group: .defense, sided: true,
            pros: ["Trent Alexander-Arnold", "Andrew Robertson", "Antonee Robinson"],
            summary: "Defends the flank first, then becomes an extra attacker — overlapping outside the winger, underlapping inside, or tucking into midfield as an inverted full back.",
            inPossession: ["Give width when your winger cuts inside; underlap into the half-space when the winger stays wide.", "Early crosses from deep into the space between the keeper and the back line.", "As an inverted full back, step into midfield only when your team has clear possession.", "Scan over the shoulder before every receive — the touchline cuts your options in half."],
            outPossession: ["Defend the back post on crosses from the far side — tuck in, do not ball-watch.", "Win the 1v1 against the winger: patient, side-on, show them down the line or inside to help.", "Recovery run on the inside line, straight back toward your own goal post.", "Stay connected to your center back; the gap between you is where through balls go."],
            traits: ["Engine to get up and down", "Defends 1v1", "Accurate crosser", "Smart about when to go"],
            youthTuning: ["Repeat-sprint fitness is non-negotiable — the role is run, recover, run again.", "Learn both overlap and underlap timing: go when the winger’s head goes down to commit the defender.", "Crossing variety: driven low, whipped mid-height, and the cutback.", "Train defending 1v1 every week — it is the first thing a coach checks for a full back."],
            scoutsLookFor: ["Wins 1v1s on the flank", "Recovery speed", "Final ball quality", "Knows when to stay home"],
            coreSkills: [.defending1v1, .recovery, .crossing, .overlap, .speedDribble, .scanning, .agility])
        case .wb: return PositionInfo(
            name: "Wing Back", short: "WB", group: .wide, sided: true,
            pros: ["Achraf Hakimi", "Jeremie Frimpong", "Ona Batlle"],
            summary: "In a back three, the wing back owns the whole touchline alone — the team’s width in attack and a fifth defender out of possession.",
            inPossession: ["Hold the width high so the winger or 10 can play inside.", "Arrive late at the back post for switches — wing backs score from the far side.", "Carry the ball forward at speed when there is grass in front of you.", "Cross early or drive to the byline; never stall at the halfway line."],
            outPossession: ["Drop to make a back five when the ball is wide on your side.", "Press the opposition full back when your team presses high.", "Recovery runs on the inside line every time possession is lost."],
            traits: ["Elite stamina", "Top-end speed", "Crossing on the run", "1v1 both ways"],
            youthTuning: ["Train repeat sprints: 30–40 yards, short rest, many sets.", "Practise receiving switches with your back to the touchline so your first touch goes forward.", "Cross on the run off both feet — you rarely get time to set up."],
            scoutsLookFor: ["Last 10 minutes look like the first 10", "Arrives in the box", "Crosses on the move", "Defends the back post"],
            coreSkills: [.speedDribble, .crossing, .recovery, .defending1v1, .overlap, .agility, .firstTouch])
        case .cdm: return PositionInfo(
            name: "Defensive Midfield", short: "CDM", group: .midfield, sided: false,
            pros: ["Rodri", "Declan Rice", "Tyler Adams"],
            summary: "The 6. Shields the back line, keeps the ball moving and controls the tempo. Few touches, lots of scanning, always in the right place.",
            inPossession: ["Show for the ball between the center backs’ passing lanes, on the half-turn.", "Play forward when it is on, recycle when it is not — tempo is your job.", "Drop between the CBs to make a back three when the team builds.", "Switch play quickly to the side with space."],
            outPossession: ["Screen: stand in the passing lane into the opponent’s 10 or striker.", "Delay counters — stop the ball carrier, foul smart only when necessary.", "Cover for a full back or CB who has stepped out.", "Win second balls: arrive at the drop zone before the opponent."],
            traits: ["Constant scanning", "Positional discipline", "Passing range", "Tackling timing", "Calm under pressure"],
            youthTuning: ["Scanning is the skill: elite central midfielders check their shoulders more than any other position in pro research. Make it a habit before every pass.", "Learn to receive on the back foot so you can play forward on the second touch.", "Train the switch of play — 30+ yards off the ground and along it.", "Positioning drills where you shadow the ball and close passing lanes, not just chase it."],
            scoutsLookFor: ["Never caught out of position", "Two- and three-touch rhythm", "Breaks up counters", "Plays forward under pressure"],
            coreSkills: [.scanning, .positioning, .passing, .rangePass, .firstTouch, .turning, .defending1v1])
        case .cm: return PositionInfo(
            name: "Center Midfield", short: "CM", group: .midfield, sided: false,
            pros: ["Pedri", "Federico Valverde", "Weston McKennie"],
            summary: "The 8. Box-to-box: connects defense to attack, arrives in the box, and presses. The most complete all-round role on the field.",
            inPossession: ["Find the pocket between the opponent’s midfield and defense lines.", "Receive half-turned and play forward — every backward pass costs the team time.", "Third-man runs: pass, then go beyond for the return.", "Arrive late at the edge of the box for cutbacks and second balls."],
            outPossession: ["Lead the midfield press — curve your run to block the pass back inside (cover shadow).", "Track runners from midfield into your box.", "Stay compact with the 6; the space between you two must stay small."],
            traits: ["Engine", "Scanning", "Turns under pressure", "Passing both feet", "Arrives in the box"],
            youthTuning: ["Scan before every receive — count how many times you check your shoulder in a 10-second build-up.", "Half-turn and back-foot receiving are the two techniques that move a CM up a level.", "Weak foot to a usable standard: short and medium passes without thinking about it.", "Shoot from the edge of the box — 8s who score get noticed."],
            scoutsLookFor: ["Plays forward", "Covers every blade of grass", "Clean first touch in traffic", "Goals and assists from midfield"],
            coreSkills: [.scanning, .firstTouch, .turning, .passing, .weakFoot, .pressing, .agility])
        case .cam: return PositionInfo(
            name: "Attacking Midfield", short: "CAM", group: .midfield, sided: false,
            pros: ["Martin Ødegaard", "Jamal Musiala", "Bruno Fernandes"],
            summary: "The 10. Lives between the lines, turns, and creates: the final pass, the shot from the edge, the dribble through a crowded middle.",
            inPossession: ["Hide in the pocket behind the opponent’s midfield, then show at the right moment.", "Turn on the first touch when the scan says you have space.", "Disguise passes — look one way, play the other.", "Shoot early from 18–22 yards when the keeper is unset."],
            outPossession: ["Press the 6 or curve onto the CB with a cover shadow on the 6.", "Counter-press for five seconds after losing the ball."],
            traits: ["Vision", "Tight-space touch", "Turning", "Final ball", "Shooting"],
            youthTuning: ["Train turning in tight spaces every single session — half-turn, inside hook, drag-back.", "Scan before receiving so the first touch goes forward.", "Practise the through ball weighted to the striker’s run, off both feet.", "Work your out-of-possession effort — MLS NEXT coaches drop 10s who don’t press."],
            scoutsLookFor: ["Turns and faces forward", "Creates chances", "Unpredictable", "Works without the ball"],
            coreSkills: [.turning, .scanning, .firstTouch, .passing, .finishing, .dribbling, .ballMastery])
        case .wm: return PositionInfo(
            name: "Wide Midfield", short: "WM", group: .wide, sided: true,
            pros: ["Federico Valverde", "James Milner", "Ji-sung Park"],
            summary: "The left or right midfielder in a 4-4-2 or 4-4-1-1. Balances attack and defense on the flank — two-way work rate with quality at the end.",
            inPossession: ["Stretch the field with width, then attack the space in behind.", "Combine with the full back: give-and-go, overlap, underlap.", "Cross from wide or come inside to shoot depending on your stronger foot."],
            outPossession: ["Track the opposing full back all the way back.", "Make the block a line of four with your midfield — tuck in when the ball is on the far side.", "Double the winger with your full back."],
            traits: ["Work rate", "Crossing", "Defensive discipline", "Combination play"],
            youthTuning: ["Build the engine first: repeat-sprint and recovery runs.", "Crossing off both feet, early and from the byline.", "Learn defensive shape: when to tuck in, when to press the full back."],
            scoutsLookFor: ["Two-way effort", "Quality delivery", "Positional discipline", "Combines quickly"],
            coreSkills: [.crossing, .recovery, .speedDribble, .passing, .defending1v1, .agility, .firstTouch])
        case .w: return PositionInfo(
            name: "Winger", short: "W", group: .wide, sided: true,
            pros: ["Bukayo Saka", "Vinícius Júnior", "Christian Pulisic"],
            summary: "The 1v1 specialist. Takes on full backs, cuts inside to shoot (inverted winger) or goes to the byline to cross. Changes games with pace and nerve.",
            inPossession: ["Receive side-on so your first touch already threatens the defender.", "Isolate the full back, then attack at speed with a change of pace and direction.", "Inverted: cut inside onto your strong foot to shoot or slip a pass; traditional: beat them outside and cross.", "Attack the far post when the ball is on the other wing."],
            outPossession: ["Press the full back on the trigger (bad touch, back pass).", "Cover-shadow the pass inside when pressing from wide.", "Track back to help your full back — at MLS NEXT this is expected, not optional."],
            traits: ["Acceleration", "1v1 confidence", "End product", "Both directions"],
            youthTuning: ["Work on change of pace more than tricks — slow, slow, explode is what beats defenders.", "Get a reliable outside move and inside move so the defender can’t sit on one side.", "First touch on the wing: receive across your body, away from pressure, toward goal.", "Count your end product: goals + assists + shots per game. Scouts do."],
            scoutsLookFor: ["Beats the man", "Goals and assists", "Brave in possession", "Tracks back"],
            coreSkills: [.dribbling, .firstTouch, .speedDribble, .finishing, .crossing, .agility, .movement])
        case .ss: return PositionInfo(
            name: "Second Striker / False 9", short: "SS", group: .attack, sided: false,
            pros: ["Antoine Griezmann", "Thomas Müller", "Lionel Messi"],
            summary: "Plays off the main striker or drops in as a false 9. Finds space between the lines, links play, and arrives in the box at the right moment.",
            inPossession: ["Drop off the center backs to receive — drag one with you to open space for runners.", "Combine fast: one-twos, lay-offs and flicks around the box.", "Arrive, don’t stand: time runs into the box for rebounds and cutbacks."],
            outPossession: ["Screen the 6 so the CBs can’t play through midfield.", "Press the CB on the trigger with the other forward."],
            traits: ["Football IQ", "Link play", "Clinical finishing", "Movement"],
            youthTuning: ["Train receiving with back to goal and turning — the false 9 lives there.", "Finishing with one and two touches from inside the box.", "Watch film of where you got the ball last game — were you in the pocket or flat on the line?"],
            scoutsLookFor: ["Finds space nobody else sees", "Links play", "Scores", "Pressing intelligence"],
            coreSkills: [.movement, .turning, .finishing, .firstTouch, .passing, .scanning, .holdUp])
        case .st: return PositionInfo(
            name: "Striker", short: "ST", group: .attack, sided: false,
            pros: ["Erling Haaland", "Harry Kane", "Lautaro Martínez"],
            summary: "The 9. Scores goals. Plays on the shoulder of the last defender, holds the ball up, and leads the press from the front.",
            inPossession: ["Run off the shoulder: stay onside, time the run for the passer’s head coming up.", "Near post, far post, penalty spot — attack a zone on every cross, don’t wait in one.", "Back to goal: use your body, lay it off first time, spin.", "Finish across the keeper and low; the far post is your friend."],
            outPossession: ["Lead the press: curve your run to force play one way.", "Block the pass into the 6 with your cover shadow."],
            traits: ["Clinical", "Movement in the box", "Strong on the ball", "Brave", "Short memory"],
            youthTuning: ["First-time finishing is the skill that translates up levels — the time to shoot shrinks every year.", "Hold-up play: get your body between the defender and the ball before it arrives.", "Head-up movement: check where the CBs are before the cross, then go to space.", "Weak-foot finishing every week. Defenders at MLS NEXT will show you onto it."],
            scoutsLookFor: ["Goals", "Movement that creates chances", "Holds the ball up", "Presses from the front"],
            coreSkills: [.finishing, .movement, .holdUp, .heading, .firstTouch, .weakFoot, .pressing])
        }
    }
}

/// A spot on the formation picker. x runs 0-100 from your own goal, y 0-64 across.
struct Spot: Identifiable {
    let code: String
    let position: Position
    let x: Double
    let y: Double
    let side: String?
    var id: String { code }

    var label: String {
        let info = position.info
        guard info.sided, let side else { return info.name }
        return (side == "L" ? "Left " : "Right ") + info.name.lowercased()
    }

    static let all: [Spot] = [
        Spot(code: "GK", position: .gk, x: 6.0, y: 32.0, side: nil),
        Spot(code: "LCB", position: .cb, x: 20.0, y: 24.0, side: nil),
        Spot(code: "RCB", position: .cb, x: 20.0, y: 40.0, side: nil),
        Spot(code: "LB", position: .fb, x: 25.0, y: 8.0, side: "L"),
        Spot(code: "RB", position: .fb, x: 25.0, y: 56.0, side: "R"),
        Spot(code: "LWB", position: .wb, x: 38.0, y: 5.0, side: "L"),
        Spot(code: "RWB", position: .wb, x: 38.0, y: 59.0, side: "R"),
        Spot(code: "CDM", position: .cdm, x: 36.0, y: 32.0, side: nil),
        Spot(code: "LCM", position: .cm, x: 48.0, y: 22.0, side: nil),
        Spot(code: "RCM", position: .cm, x: 48.0, y: 42.0, side: nil),
        Spot(code: "CAM", position: .cam, x: 61.0, y: 32.0, side: nil),
        Spot(code: "LM", position: .wm, x: 52.0, y: 7.0, side: "L"),
        Spot(code: "RM", position: .wm, x: 52.0, y: 57.0, side: "R"),
        Spot(code: "LW", position: .w, x: 72.0, y: 10.0, side: "L"),
        Spot(code: "RW", position: .w, x: 72.0, y: 54.0, side: "R"),
        Spot(code: "SS", position: .ss, x: 76.0, y: 32.0, side: nil),
        Spot(code: "ST", position: .st, x: 88.0, y: 32.0, side: nil),
    ]

    static func find(_ code: String?) -> Spot? { all.first { $0.code == code } }
}

enum Level: String, CaseIterable, Codable, Identifiable {
    case rec
    case travel
    case hs
    case premier
    case npl
    case ecnlrl
    case natl
    case ecnl
    case mlsa
    case mlsh
    case pro

    var id: String { rawValue }

    var name: String {
        switch self {
        case .rec: return "Recreational"
        case .travel: return "Town travel"
        case .hs: return "High school"
        case .premier: return "Club premier / state league"
        case .npl: return "NPL"
        case .ecnlrl: return "ECNL Regional League"
        case .natl: return "National league (USYS, EDP top flight)"
        case .ecnl: return "ECNL"
        case .mlsa: return "MLS NEXT Academy Division"
        case .mlsh: return "MLS NEXT Homegrown Division"
        case .pro: return "MLS NEXT Pro / college"
        }
    }

    var rank: Int { Level.allCases.firstIndex(of: self) ?? 0 }
}

enum Equipment: String, Codable {
    case ball, cones, wall, partner, goal
    var name: String { rawValue.capitalized }
}

enum CueKind: String { case colors, arrows, numbers }

enum FormCheck: String, CaseIterable {
    case low, headUp, base, hands, balance, scan
}

/// One actor or the ball at a keyframe. Grid is 100 x 64.
struct BoardMark {
    let key: String
    let x: Double
    let y: Double
    /// For the ball only: stuck to this actor ("p", "m", "d", "k").
    let attach: String?

    init(_ key: String, _ x: Double, _ y: Double) { self.key = key; self.x = x; self.y = y; attach = nil }
    init(ballOn actor: String) { key = "b"; x = 0; y = 0; attach = actor }
}

struct BoardStep {
    let dur: Double
    let marks: [BoardMark]
    var caption: String? = nil
    var cue: String? = nil
    var look: Double? = nil
}

struct BoardSetup {
    var cones: [(Double, Double)] = []
    var gates: [(Double, Double, Double, Double)] = []
    var wall: (Double, Double, Double, Double)? = nil
    var goal: (x: Double, y: Double, w: Double)? = nil
}

struct BoardScript {
    let setup: BoardSetup
    let steps: [BoardStep]
}

enum SessionFormat: String, Codable { case reps, time }

enum DrillLevel: String { case foundation = "Foundation", build = "Build", elite = "Elite" }

struct PathwayDrill: Identifiable {
    let id: String
    let name: String
    let level: DrillLevel
    /// Empty means every outfield position.
    let positions: [Position]
    let outfield: Bool
    let skills: [Skill]
    let needs: [Equipment]
    let format: SessionFormat
    var sets = 3
    var reps = 10
    var rest = 45
    var seconds = 300
    var cue: CueKind? = nil
    var tempo: Int? = nil
    var interval: (work: Int, rest: Int)? = nil
    let blurb: String
    let steps: [String]
    let points: [String]
    let mistakes: [String]
    let checks: [FormCheck]
    let video: String
    var inspired: String? = nil
    let board: BoardScript

    func fits(_ position: Position) -> Bool {
        positions.contains(position) || (outfield && position != .gk)
    }

    var minutes: Int {
        format == .time ? max(1, seconds / 60) : max(3, (sets * (reps * 5 + rest)) / 60)
    }

    var videoURL: URL {
        var c = URLComponents(string: "https://www.youtube.com/results")!
        c.queryItems = [URLQueryItem(name: "search_query", value: video)]
        return c.url!
    }
}

enum PathwayLibrary {
    static func drill(_ id: String) -> PathwayDrill? { byID[id] }
    private static let byID: [String: PathwayDrill] = Dictionary(uniqueKeysWithValues: all.map { ($0.id, $0) })
    static func drills(for position: Position) -> [PathwayDrill] { all.filter { $0.fits(position) } }

    static let all: [PathwayDrill] = [
        bmSoleLadder,
        bmCroquetaBox,
        bmConeWeave,
        scanColorCall,
        scanArrowTurn,
        ftWallOpen,
        ftAerial,
        ftWingReceive,
        passWeakWall,
        passSwitch,
        passDisguiseGates,
        turnPocket,
        turnMenu,
        dribPickSide,
        dribChangePace,
        dribCutInside,
        dribCarry,
        crossEarly,
        crossCutback,
        finFirstTime,
        finNearPost,
        fin1v1Keeper,
        finVolley,
        holdUp,
        moveShoulder,
        headClear,
        defJockey,
        defApproach,
        defRecovery,
        defCoverShadow,
        defTightMark,
        midScreen,
        midBoxToBox,
        agi5105,
        agiReactionArrows,
        fbOverlap,
        gkSetHandling,
        gkCollapse,
        gkHighBall,
        gkDistribution,
        gk1v1Block,
        gkAngles,
        gkReactions,
    ]

    private static let bmSoleLadder = PathwayDrill(
        id: "bm-sole-ladder", name: "Sole-roll ladder", level: .foundation,
        positions: [], outfield: true,
        skills: [.ballMastery, .weakFoot], needs: [.ball],
        format: .time,
        seconds: 300, tempo: 110,
        blurb: "Five-minute follow-along: toe taps, sole rolls, pull-push and L-turns on a metronome beat. Thousands of touches, both feet.",
        steps: ["Toe taps on the top of the ball, one touch per beat, for 45 seconds.", "Sole roll across the body right-to-left, then left-to-right, keep the ball under you.", "Pull-push: pull back with the sole, push forward with the laces of the same foot. Switch feet every 8.", "L-turn: pull back, then push it behind your standing leg with the inside of the same foot.", "Finish with 45 seconds of \"fast feet\" — as many alternating touches as you can."],
        points: ["Stay on the balls of your feet", "Knees bent, chest over the ball", "Light touches — the ball should barely move", "Lift your eyes between touches"],
        mistakes: ["Standing flat-footed and upright", "Only using the strong foot", "Touches so hard the ball runs away"],
        checks: [.low, .balance],
        video: "soccer ball mastery sole rolls toe taps follow along",
        inspired: "Techne / Project Pro style follow-along ball mastery with a beat to keep tempo",
        board: BoardScript(setup: BoardSetup(cones: [(40.0, 22.0), (60.0, 22.0), (40.0, 42.0), (60.0, 42.0)]), steps: [
            BoardStep(dur: 0.0, marks: [BoardMark("p", 50.0, 34.0), BoardMark("b", 50.0, 31.0)], caption: "Toe taps — touch the top of the ball on every beat"),
            BoardStep(dur: 0.4, marks: [BoardMark("p", 50.0, 34.0), BoardMark("b", 50.0, 31.5)]),
            BoardStep(dur: 0.4, marks: [BoardMark("p", 50.0, 34.0), BoardMark("b", 50.0, 31.0)]),
            BoardStep(dur: 0.6, marks: [BoardMark("p", 50.0, 34.0), BoardMark("b", 46.0, 31.0)], caption: "Sole roll across your body"),
            BoardStep(dur: 0.6, marks: [BoardMark("p", 50.0, 34.0), BoardMark("b", 54.0, 31.0)]),
            BoardStep(dur: 0.6, marks: [BoardMark("p", 50.0, 34.0), BoardMark("b", 50.0, 31.0)]),
            BoardStep(dur: 0.5, marks: [BoardMark("p", 50.0, 34.0), BoardMark("b", 50.0, 34.0)], caption: "Pull back with the sole…"),
            BoardStep(dur: 0.5, marks: [BoardMark("p", 50.0, 34.0), BoardMark("b", 50.0, 29.0)], caption: "…push forward with the laces"),
            BoardStep(dur: 0.5, marks: [BoardMark("p", 50.0, 34.0), BoardMark("b", 50.0, 33.0)], caption: "L-turn: pull…"),
            BoardStep(dur: 0.6, marks: [BoardMark("p", 50.0, 34.0), BoardMark("b", 55.0, 36.0)], caption: "…and push it behind your standing leg"),
            BoardStep(dur: 0.8, marks: [BoardMark("p", 52.0, 34.0), BoardMark("b", 55.0, 33.0)], caption: "Reset and repeat on the other foot"),
            BoardStep(dur: 0.6, marks: [BoardMark("p", 50.0, 34.0), BoardMark("b", 50.0, 31.0)]),
        ]))

    private static let bmCroquetaBox = PathwayDrill(
        id: "bm-croqueta-box", name: "La Croqueta box", level: .build,
        positions: [.cam, .cm, .w, .ss, .wm], outfield: false,
        skills: [.ballMastery, .dribbling], needs: [.ball, .cones],
        format: .reps,
        sets: 3, reps: 10, rest: 45,
        blurb: "Quick inside-to-inside shift (Iniesta’s croqueta) to slip between two cones, then explode out. The move for escaping pressure in a crowded midfield.",
        steps: ["Set two cones a yard apart — that is your \"defender gap\".", "Dribble at the gap at half speed.", "Just before the cones, shift the ball from the inside of one foot to the inside of the other.", "Explode through the gap with your next touch.", "Turn at the end cone and come back the other way."],
        points: ["Small, fast shift — the ball travels less than a foot", "Stay low through the move", "Accelerate out of it — the move is useless without the burst"],
        mistakes: ["Doing the move too far from the cones", "Big shift that a defender can poke away", "No change of pace afterwards"],
        checks: [.low, .headUp],
        video: "la croqueta tutorial soccer iniesta move drill",
        board: BoardScript(setup: BoardSetup(cones: [(50.0, 29.0), (50.0, 35.0), (85.0, 32.0), (15.0, 32.0)]), steps: [
            BoardStep(dur: 0.0, marks: [BoardMark("p", 18.0, 32.0), BoardMark(ballOn: "p")], caption: "Dribble at the gap"),
            BoardStep(dur: 1.4, marks: [BoardMark("p", 44.0, 32.0), BoardMark(ballOn: "p")]),
            BoardStep(dur: 0.35, marks: [BoardMark("p", 46.0, 31.0), BoardMark("b", 47.0, 30.5)], caption: "Inside of right → inside of left"),
            BoardStep(dur: 0.35, marks: [BoardMark("p", 47.0, 32.0), BoardMark("b", 48.5, 33.0)]),
            BoardStep(dur: 0.6, marks: [BoardMark("p", 56.0, 32.0), BoardMark(ballOn: "p")], caption: "Explode through the gap"),
            BoardStep(dur: 1.2, marks: [BoardMark("p", 82.0, 32.0), BoardMark(ballOn: "p")], caption: "Turn at the end cone"),
            BoardStep(dur: 0.5, marks: [BoardMark("p", 80.0, 33.0), BoardMark(ballOn: "p")]),
            BoardStep(dur: 1.6, marks: [BoardMark("p", 55.0, 32.0), BoardMark(ballOn: "p")], caption: "Same move on the way back"),
            BoardStep(dur: 0.4, marks: [BoardMark("p", 52.0, 33.0), BoardMark("b", 51.0, 34.0)]),
            BoardStep(dur: 1.2, marks: [BoardMark("p", 18.0, 32.0), BoardMark(ballOn: "p")]),
        ]))

    private static let bmConeWeave = PathwayDrill(
        id: "bm-cone-weave", name: "Two-foot cone weave", level: .foundation,
        positions: [], outfield: true,
        skills: [.ballMastery, .speedDribble, .weakFoot], needs: [.ball, .cones],
        format: .reps,
        sets: 4, reps: 4, rest: 40,
        blurb: "Six cones, two yards apart. Weave with outside and inside of each foot, then sprint the last ten yards.",
        steps: ["Lay six cones in a line two yards apart.", "Rep 1: right foot only — outside out, inside back.", "Rep 2: left foot only.", "Rep 3: alternate feet.", "After the last cone, push the ball ahead and sprint 10 yards."],
        points: ["A touch every step", "Eyes up after each touch", "Arms out for balance"],
        mistakes: ["Ball too far from the feet", "Watching the ball the entire time", "Slowing down on the weak foot"],
        checks: [.low, .headUp],
        video: "soccer cone weave dribbling drill inside outside",
        board: BoardScript(setup: BoardSetup(cones: [(25.0, 32.0), (35.0, 32.0), (45.0, 32.0), (55.0, 32.0), (65.0, 32.0), (75.0, 32.0)]), steps: [
            BoardStep(dur: 0.0, marks: [BoardMark("p", 14.0, 32.0), BoardMark(ballOn: "p")], caption: "Outside of the foot to go around"),
            BoardStep(dur: 0.6, marks: [BoardMark("p", 25.0, 27.0), BoardMark(ballOn: "p")]),
            BoardStep(dur: 0.6, marks: [BoardMark("p", 35.0, 37.0), BoardMark(ballOn: "p")], caption: "Inside to bring it back"),
            BoardStep(dur: 0.6, marks: [BoardMark("p", 45.0, 27.0), BoardMark(ballOn: "p")]),
            BoardStep(dur: 0.6, marks: [BoardMark("p", 55.0, 37.0), BoardMark(ballOn: "p")]),
            BoardStep(dur: 0.6, marks: [BoardMark("p", 65.0, 27.0), BoardMark(ballOn: "p")]),
            BoardStep(dur: 0.6, marks: [BoardMark("p", 75.0, 37.0), BoardMark(ballOn: "p")]),
            BoardStep(dur: 0.5, marks: [BoardMark("p", 80.0, 32.0), BoardMark("b", 86.0, 32.0)], caption: "Push it out and sprint"),
            BoardStep(dur: 0.7, marks: [BoardMark("p", 92.0, 32.0), BoardMark("b", 94.0, 32.0)]),
        ]))

    private static let scanColorCall = PathwayDrill(
        id: "scan-color-call", name: "Shoulder-check color call", level: .foundation,
        positions: [.cdm, .cm, .cam, .cb, .fb, .ss], outfield: false,
        skills: [.scanning, .firstTouch], needs: [.ball, .wall],
        format: .time,
        seconds: 240, cue: .colors,
        blurb: "Pass off a wall with your phone behind you. Colors flash on screen — check your shoulder, shout the color before the ball comes back, then play away from it.",
        steps: ["Stand 5 yards from a wall. Put your phone on the ground 3 yards behind you, screen up.", "Pass into the wall. While the ball travels, check over a shoulder at the screen.", "Call the color out loud before you receive.", "RED = pressure: receive and turn away to the other side. GREEN = time: open up and play forward. BLUE = play one-touch.", "Alternate which shoulder you check."],
        points: ["Scan while the ball is traveling, not when it arrives", "Quick head turn — eyes, not the whole body", "Check again right before the touch"],
        mistakes: ["Only scanning when you have the ball", "Always checking the same shoulder", "Turning the whole body so you face backward"],
        checks: [.scan, .low],
        video: "soccer scanning drill shoulder check before receiving",
        inspired: "Trainerso-style color cues (the app flashes colors so players learn to check their shoulder). Pro research on scanning (Jordet) found central midfielders scan the most — Xavi averaged 0.83 scans per second before receiving.",
        board: BoardScript(setup: BoardSetup(wall: (80.0, 14.0, 80.0, 50.0)), steps: [
            BoardStep(dur: 0.0, marks: [BoardMark("p", 60.0, 32.0), BoardMark(ballOn: "p")], caption: "Pass into the wall"),
            BoardStep(dur: 0.7, marks: [BoardMark("p", 60.0, 32.0), BoardMark("b", 79.0, 32.0)], caption: "Scan while it travels", look: 180.0),
            BoardStep(dur: 0.7, marks: [BoardMark("p", 60.0, 32.0), BoardMark("b", 62.0, 32.0)], caption: "Call the color: GREEN", cue: "GREEN", look: 0.0),
            BoardStep(dur: 0.5, marks: [BoardMark("p", 61.0, 34.0), BoardMark("b", 63.0, 36.0)], caption: "Open up, play forward"),
            BoardStep(dur: 0.7, marks: [BoardMark("p", 62.0, 36.0), BoardMark("b", 79.0, 34.0)]),
            BoardStep(dur: 0.7, marks: [BoardMark("p", 62.0, 36.0), BoardMark("b", 64.0, 36.0)], caption: "RED — pressure!", cue: "RED", look: 180.0),
            BoardStep(dur: 0.5, marks: [BoardMark("p", 61.0, 31.0), BoardMark("b", 61.0, 28.0)], caption: "Turn away from it"),
            BoardStep(dur: 0.7, marks: [BoardMark("p", 60.0, 32.0), BoardMark(ballOn: "p")]),
        ]))

    private static let scanArrowTurn = PathwayDrill(
        id: "scan-arrow-turn", name: "Scan & turn on the arrow", level: .build,
        positions: [.cdm, .cm, .cam, .ss], outfield: false,
        skills: [.scanning, .turning, .firstTouch], needs: [.ball, .wall, .cones],
        format: .time,
        seconds: 300, cue: .arrows,
        blurb: "Your phone calls the turn: ← → or ↑. Check it over your shoulder while the ball comes back off the wall, then turn into that gate in one touch.",
        steps: ["Two cone gates 5 yards to your left and right, phone behind you.", "Pass into the wall; scan the screen while the ball travels.", "← or → : receive on the back foot and turn through that gate.", "↑ : set it back one touch to the wall (no space to turn)."],
        points: ["Open your hips to the side you are turning", "Receive on the back foot", "First touch goes through the gate, not to your feet"],
        mistakes: ["Receiving square, then needing two touches to turn", "Looking after the ball arrives"],
        checks: [.scan, .low],
        video: "half turn receive back foot midfielder drill",
        inspired: "Reaction-light boards (A-Champs ROX style) reduced to a phone screen",
        board: BoardScript(setup: BoardSetup(gates: [(56.0, 12.0, 64.0, 12.0), (56.0, 52.0, 64.0, 52.0)], wall: (82.0, 14.0, 82.0, 50.0)), steps: [
            BoardStep(dur: 0.0, marks: [BoardMark("p", 60.0, 32.0), BoardMark(ballOn: "p")], caption: "Pass in"),
            BoardStep(dur: 0.7, marks: [BoardMark("p", 60.0, 32.0), BoardMark("b", 81.0, 32.0)], caption: "Scan behind", look: 180.0),
            BoardStep(dur: 0.6, marks: [BoardMark("p", 60.0, 32.0), BoardMark("b", 63.0, 32.0)], caption: "Arrow says LEFT", cue: "←", look: 0.0),
            BoardStep(dur: 0.6, marks: [BoardMark("p", 60.0, 24.0), BoardMark("b", 60.0, 20.0)], caption: "Back-foot touch through the gate"),
            BoardStep(dur: 0.7, marks: [BoardMark("p", 60.0, 13.0), BoardMark("b", 60.0, 10.0)]),
            BoardStep(dur: 1.0, marks: [BoardMark("p", 60.0, 32.0), BoardMark(ballOn: "p")], caption: "Reset"),
            BoardStep(dur: 0.7, marks: [BoardMark("p", 60.0, 32.0), BoardMark("b", 81.0, 32.0)], caption: "Scan again", look: 180.0),
            BoardStep(dur: 0.6, marks: [BoardMark("p", 60.0, 32.0), BoardMark("b", 63.0, 32.0)], caption: "RIGHT", cue: "→", look: 0.0),
            BoardStep(dur: 0.6, marks: [BoardMark("p", 60.0, 40.0), BoardMark("b", 60.0, 44.0)]),
            BoardStep(dur: 0.7, marks: [BoardMark("p", 60.0, 51.0), BoardMark("b", 60.0, 54.0)]),
        ]))

    private static let ftWallOpen = PathwayDrill(
        id: "ft-wall-open", name: "Wall two-touch: open body", level: .foundation,
        positions: [], outfield: true,
        skills: [.firstTouch, .passing, .weakFoot], needs: [.ball, .wall],
        format: .reps,
        sets: 4, reps: 20, rest: 30,
        blurb: "Receive across your body with the far foot, take it out of your feet, pass back with the other foot. The single most transferable touch drill there is.",
        steps: ["Stand 6–8 yards from the wall.", "Pass in with your right; receive with the LEFT across your body so the ball rolls past your standing leg.", "Pass back with the left. Then mirror it.", "Progress: one-touch every third pass."],
        points: ["Open your hips before the ball arrives", "First touch moves the ball a yard into space", "Pass with the inside of the foot, ankle locked"],
        mistakes: ["Stopping the ball dead under your feet", "Receiving with the near foot so you face the wall", "Weak foot only \"helping\""],
        checks: [.low, .balance],
        video: "wall passing drill receive across body back foot soccer",
        board: BoardScript(setup: BoardSetup(wall: (80.0, 14.0, 80.0, 50.0)), steps: [
            BoardStep(dur: 0.0, marks: [BoardMark("p", 60.0, 28.0), BoardMark(ballOn: "p")], caption: "Right foot into the wall"),
            BoardStep(dur: 0.7, marks: [BoardMark("p", 60.0, 28.0), BoardMark("b", 79.0, 30.0)]),
            BoardStep(dur: 0.7, marks: [BoardMark("p", 60.0, 30.0), BoardMark("b", 61.0, 31.0)], caption: "Open up — receive with the far foot"),
            BoardStep(dur: 0.4, marks: [BoardMark("p", 60.0, 34.0), BoardMark("b", 61.0, 36.0)], caption: "Touch it out of your feet"),
            BoardStep(dur: 0.7, marks: [BoardMark("p", 60.0, 36.0), BoardMark("b", 79.0, 34.0)], caption: "Pass back with the other foot"),
            BoardStep(dur: 0.7, marks: [BoardMark("p", 60.0, 34.0), BoardMark("b", 61.0, 33.0)]),
            BoardStep(dur: 0.4, marks: [BoardMark("p", 60.0, 29.0), BoardMark("b", 61.0, 28.0)], caption: "Mirror it"),
            BoardStep(dur: 0.7, marks: [BoardMark("p", 60.0, 28.0), BoardMark("b", 79.0, 30.0)]),
        ]))

    private static let ftAerial = PathwayDrill(
        id: "ft-aerial", name: "Aerial control ladder", level: .build,
        positions: [], outfield: true,
        skills: [.firstTouch], needs: [.ball],
        format: .reps,
        sets: 3, reps: 12, rest: 40,
        blurb: "Throw the ball up and kill it with the foot, thigh, then chest. Each surface \"gives\" like a cushion so the ball drops dead in front of you.",
        steps: ["Toss the ball 10–15 feet up.", "Foot: lift your foot to meet it and withdraw as it lands — like catching an egg.", "Thigh: raise the thigh flat, drop it on contact.", "Chest: lean back slightly, arms out, let it roll off.", "Every control finishes with a touch into space."],
        points: ["Move under the ball early", "Relax the surface at contact", "Finish with a touch away, not on the spot"],
        mistakes: ["Stabbing at the ball so it bounces away", "Waiting flat-footed", "Arms flapping on chest control"],
        checks: [.balance, .low],
        video: "soccer aerial ball control drill cushion foot thigh chest",
        board: BoardScript(setup: BoardSetup(), steps: [
            BoardStep(dur: 0.0, marks: [BoardMark("p", 50.0, 34.0), BoardMark("b", 50.0, 33.0)], caption: "Toss it up"),
            BoardStep(dur: 0.7, marks: [BoardMark("p", 50.0, 34.0), BoardMark("b", 50.0, 14.0)]),
            BoardStep(dur: 0.7, marks: [BoardMark("p", 50.0, 33.0), BoardMark("b", 50.0, 31.0)], caption: "Cushion with the foot"),
            BoardStep(dur: 0.6, marks: [BoardMark("p", 52.0, 34.0), BoardMark("b", 56.0, 34.0)], caption: "Touch into space"),
            BoardStep(dur: 0.6, marks: [BoardMark("p", 55.0, 34.0), BoardMark("b", 55.0, 33.0)]),
            BoardStep(dur: 0.7, marks: [BoardMark("p", 55.0, 34.0), BoardMark("b", 55.0, 14.0)], caption: "Up again — thigh this time"),
            BoardStep(dur: 0.7, marks: [BoardMark("p", 55.0, 33.0), BoardMark("b", 55.0, 31.5)], caption: "Thigh flat, give on contact"),
            BoardStep(dur: 0.6, marks: [BoardMark("p", 52.0, 34.0), BoardMark("b", 48.0, 34.0)]),
            BoardStep(dur: 0.6, marks: [BoardMark("p", 50.0, 34.0), BoardMark("b", 50.0, 33.0)]),
        ]))

    private static let ftWingReceive = PathwayDrill(
        id: "ft-wing-receive", name: "Wing receive: touch inside or down the line", level: .build,
        positions: [.w, .wm, .wb, .fb], outfield: false,
        skills: [.firstTouch, .dribbling, .scanning], needs: [.ball, .cones, .partner],
        format: .reps,
        sets: 4, reps: 8, rest: 40,
        blurb: "Receive a pass on the touchline with a passive defender behind you. Check your shoulder, then take your first touch away from pressure — inside or down the line.",
        steps: ["You stand on the touchline, a partner (or cone \"defender\") 3 yards behind you.", "A pass comes in from the inside (or off a wall).", "Before it arrives, check where the defender is.", "Defender tight on the inside → first touch down the line. Defender outside/far → first touch inside toward goal.", "Attack the cone gate in front of you with your second touch."],
        points: ["Side-on body — see the passer and the field", "First touch forward, never backward", "Use the outside of the foot to go down the line"],
        mistakes: ["Receiving with your back to goal", "Touching it into the defender", "Touch too heavy so it runs out of play"],
        checks: [.scan, .low],
        video: "winger first touch receiving drill side on body shape",
        board: BoardScript(setup: BoardSetup(cones: [(92.0, 4.0)], gates: [(70.0, 10.0, 70.0, 22.0), (84.0, 4.0, 84.0, 12.0)]), steps: [
            BoardStep(dur: 0.0, marks: [BoardMark("p", 60.0, 6.0), BoardMark("d", 56.0, 8.0), BoardMark("m", 44.0, 30.0), BoardMark("b", 44.0, 30.0)], caption: "Mate plays it into your feet"),
            BoardStep(dur: 0.2, marks: [BoardMark("p", 60.0, 6.0), BoardMark("b", 46.0, 27.0), BoardMark("d", 56.0, 8.0)], caption: "Check your shoulder", look: 200.0),
            BoardStep(dur: 0.7, marks: [BoardMark("p", 60.0, 6.0), BoardMark("b", 58.0, 8.0), BoardMark("d", 57.0, 9.0)], caption: "Defender is inside…", look: 0.0),
            BoardStep(dur: 0.5, marks: [BoardMark("p", 66.0, 5.0), BoardMark("b", 70.0, 5.0), BoardMark("d", 59.0, 8.0)], caption: "…so touch it down the line"),
            BoardStep(dur: 0.8, marks: [BoardMark("p", 80.0, 6.0), BoardMark(ballOn: "p"), BoardMark("d", 65.0, 8.0)], caption: "Attack the gate"),
            BoardStep(dur: 0.6, marks: [BoardMark("p", 86.0, 7.0), BoardMark(ballOn: "p"), BoardMark("d", 70.0, 8.0)]),
        ]))

    private static let passWeakWall = PathwayDrill(
        id: "pass-weak-wall", name: "Weak-foot wall ladder", level: .foundation,
        positions: [], outfield: true,
        skills: [.weakFoot, .passing], needs: [.ball, .wall],
        format: .time,
        seconds: 300,
        blurb: "Five minutes on the weak foot only: two-touch, then one-touch, then from further away. Make your weak foot boring.",
        steps: ["Minute 1–2: weak foot only, two touches, 5 yards.", "Minute 3: one-touch, 5 yards.", "Minute 4: step back to 10 yards, two touches.", "Minute 5: driven passes from 15 yards."],
        points: ["Plant foot next to the ball, pointing at the target", "Ankle locked, toe up", "Strike the middle of the ball"],
        mistakes: ["Sneaking in strong-foot touches", "Toe poking", "Leaning back so the ball pops up"],
        checks: [.balance],
        video: "weak foot passing drill against wall soccer",
        board: BoardScript(setup: BoardSetup(wall: (80.0, 14.0, 80.0, 50.0)), steps: [
            BoardStep(dur: 0.0, marks: [BoardMark("p", 64.0, 32.0), BoardMark(ballOn: "p")], caption: "Weak foot only"),
            BoardStep(dur: 0.6, marks: [BoardMark("p", 64.0, 32.0), BoardMark("b", 79.0, 32.0)]),
            BoardStep(dur: 0.6, marks: [BoardMark("p", 64.0, 32.0), BoardMark("b", 65.0, 32.0)], caption: "Control"),
            BoardStep(dur: 0.4, marks: [BoardMark("p", 64.0, 32.0), BoardMark("b", 65.5, 32.5)]),
            BoardStep(dur: 0.6, marks: [BoardMark("p", 64.0, 32.0), BoardMark("b", 79.0, 31.0)], caption: "Pass"),
            BoardStep(dur: 0.6, marks: [BoardMark("p", 64.0, 32.0), BoardMark("b", 65.0, 32.0)]),
            BoardStep(dur: 1.0, marks: [BoardMark("p", 52.0, 32.0), BoardMark(ballOn: "p")], caption: "Step back — longer and driven"),
            BoardStep(dur: 0.6, marks: [BoardMark("p", 52.0, 32.0), BoardMark("b", 79.0, 33.0)]),
            BoardStep(dur: 0.7, marks: [BoardMark("p", 52.0, 32.0), BoardMark("b", 53.0, 32.0)]),
        ]))

    private static let passSwitch = PathwayDrill(
        id: "pass-switch", name: "Driven switch of play", level: .build,
        positions: [.cb, .cdm, .cm, .fb, .gk], outfield: false,
        skills: [.rangePass, .firstTouch, .scanning], needs: [.ball, .partner, .cones],
        format: .reps,
        sets: 4, reps: 10, rest: 45,
        blurb: "35–45 yard driven passes to a partner’s chest or feet, then a two-touch return. How center backs and 6s break a press by switching the side.",
        steps: ["Partner 35–45 yards away, in a 5-yard target box.", "Take a touch out of your feet at an angle to the target.", "Approach at 45°, plant foot beside the ball, strike through the middle with the laces.", "Partner controls and drives it back.", "Score a point every time it lands in the box without bouncing twice."],
        points: ["Angled approach", "Strike through the center, follow through low", "Lock the ankle, toe down"],
        mistakes: ["Chipping it high and slow", "Leaning back", "No touch to set it — striking a ball that’s under your feet"],
        checks: [.balance],
        video: "how to hit a driven long pass soccer switch of play technique",
        board: BoardScript(setup: BoardSetup(gates: [(84.0, 26.0, 92.0, 26.0), (84.0, 38.0, 92.0, 38.0), (84.0, 26.0, 84.0, 38.0), (92.0, 26.0, 92.0, 38.0)]), steps: [
            BoardStep(dur: 0.0, marks: [BoardMark("p", 14.0, 32.0), BoardMark("m", 88.0, 32.0), BoardMark(ballOn: "p")], caption: "Touch at an angle"),
            BoardStep(dur: 0.6, marks: [BoardMark("p", 20.0, 30.0), BoardMark("b", 23.0, 30.0)]),
            BoardStep(dur: 0.4, marks: [BoardMark("p", 22.0, 30.0), BoardMark("b", 24.0, 30.0)], caption: "Drive it — laces through the middle"),
            BoardStep(dur: 1.3, marks: [BoardMark("p", 24.0, 31.0), BoardMark("b", 88.0, 32.0)], caption: "Lands in the box"),
            BoardStep(dur: 0.5, marks: [BoardMark("m", 88.0, 32.0), BoardMark("b", 86.0, 32.0)], caption: "Partner controls…"),
            BoardStep(dur: 1.3, marks: [BoardMark("p", 22.0, 30.0), BoardMark("b", 24.0, 30.0)], caption: "…and drives it back"),
        ]))

    private static let passDisguiseGates = PathwayDrill(
        id: "pass-disguise-gates", name: "Disguised pass through gates", level: .elite,
        positions: [.cam, .cm, .ss, .cdm], outfield: false,
        skills: [.passing, .scanning, .weakFoot], needs: [.ball, .cones, .partner],
        format: .reps,
        sets: 3, reps: 12, rest: 40,
        blurb: "Three small gates in front of you. Your partner shouts a gate as you receive — look at another gate, then pass through the called one.",
        steps: ["Three 1-yard gates, 10 yards away: left, center, right.", "Partner feeds you and calls a gate as the ball travels.", "Shape your body to the wrong gate.", "Play through the called gate with the outside or inside of the foot."],
        points: ["Eyes and hips sell the lie", "Late decision, quick ankle", "Outside-of-foot passes need the toe pointed down and in"],
        mistakes: ["Telegraphing with your eyes", "Slowing down to disguise"],
        checks: [.balance, .scan],
        video: "no look pass disguise passing drill soccer",
        board: BoardScript(setup: BoardSetup(gates: [(78.0, 14.0, 78.0, 20.0), (80.0, 29.0, 80.0, 35.0), (78.0, 44.0, 78.0, 50.0)]), steps: [
            BoardStep(dur: 0.0, marks: [BoardMark("p", 50.0, 32.0), BoardMark("m", 30.0, 32.0), BoardMark("b", 30.0, 32.0)], caption: "Feed comes in"),
            BoardStep(dur: 0.8, marks: [BoardMark("p", 50.0, 32.0), BoardMark("b", 49.0, 32.0)], caption: "Body faces the top gate…", look: -35.0),
            BoardStep(dur: 0.3, marks: [BoardMark("p", 50.0, 32.0), BoardMark("b", 51.0, 33.0)], caption: "…partner called RIGHT"),
            BoardStep(dur: 0.9, marks: [BoardMark("p", 50.0, 32.0), BoardMark("b", 78.0, 47.0)], caption: "Outside of the foot through the right gate"),
            BoardStep(dur: 0.5, marks: [BoardMark("p", 50.0, 32.0), BoardMark("b", 84.0, 49.0)]),
        ]))

    private static let turnPocket = PathwayDrill(
        id: "turn-pocket", name: "Half-turn in the pocket", level: .build,
        positions: [.cam, .cm, .cdm, .ss], outfield: false,
        skills: [.turning, .scanning, .firstTouch], needs: [.ball, .partner, .cones],
        format: .reps,
        sets: 4, reps: 8, rest: 40,
        blurb: "Drift into a small box between two cone \"lines\", check your shoulder, receive half-turned and play forward in two touches.",
        steps: ["Mark a 5×5 yard pocket. A cone defender sits behind it.", "Start outside the pocket, check your shoulder, then step in to show.", "Receive on the back foot with your hips open to the field.", "Turn and dribble or pass through the end gate."],
        points: ["Arrive in the pocket as the pass is played", "Back-foot receive = already facing forward", "Scan twice: before showing and right before the touch"],
        mistakes: ["Standing in the pocket waiting", "Receiving square to the passer", "Turning into the defender"],
        checks: [.scan, .low],
        video: "half turn receiving between the lines drill attacking midfielder",
        board: BoardScript(setup: BoardSetup(cones: [(62.0, 32.0)], gates: [(44.0, 24.0, 56.0, 24.0), (44.0, 40.0, 56.0, 40.0)]), steps: [
            BoardStep(dur: 0.0, marks: [BoardMark("p", 50.0, 16.0), BoardMark("m", 20.0, 32.0), BoardMark("b", 20.0, 32.0)], caption: "Scan before you show", look: 0.0),
            BoardStep(dur: 0.8, marks: [BoardMark("p", 49.0, 30.0), BoardMark("b", 24.0, 32.0)], caption: "Step into the pocket"),
            BoardStep(dur: 0.8, marks: [BoardMark("p", 50.0, 32.0), BoardMark("b", 48.0, 32.0)], caption: "Receive on the back foot, hips open", look: 0.0),
            BoardStep(dur: 0.5, marks: [BoardMark("p", 54.0, 33.0), BoardMark("b", 57.0, 34.0)], caption: "Turn away from the defender"),
            BoardStep(dur: 0.8, marks: [BoardMark("p", 70.0, 35.0), BoardMark(ballOn: "p")], caption: "Play forward"),
            BoardStep(dur: 0.6, marks: [BoardMark("p", 72.0, 35.0), BoardMark("b", 92.0, 32.0)]),
        ]))

    private static let turnMenu = PathwayDrill(
        id: "turn-menu", name: "Turn menu: Cruyff, drag-back, hook", level: .foundation,
        positions: [], outfield: true,
        skills: [.turning, .ballMastery], needs: [.ball, .cones],
        format: .reps,
        sets: 3, reps: 12, rest: 40,
        blurb: "Dribble at a cone, turn with a different move each rep, and accelerate away. Builds the turns you need when a defender closes you down.",
        steps: ["Two cones 15 yards apart.", "Dribble at a cone. Two yards before it: Cruyff (fake a pass, drag behind the standing leg).", "Next rep: drag-back with the sole and spin.", "Next rep: inside hook — cut it back with the inside of the foot.", "Accelerate three touches out of every turn."],
        points: ["Sell the fake", "Lower your center of gravity as you turn", "Accelerate out of the turn"],
        mistakes: ["Turning on the cone instead of before it", "Jogging out of the turn"],
        checks: [.low, .headUp],
        video: "cruyff turn drag back inside hook tutorial drill",
        board: BoardScript(setup: BoardSetup(cones: [(30.0, 32.0), (72.0, 32.0)]), steps: [
            BoardStep(dur: 0.0, marks: [BoardMark("p", 32.0, 32.0), BoardMark(ballOn: "p")], caption: "Dribble at the cone"),
            BoardStep(dur: 1.3, marks: [BoardMark("p", 64.0, 32.0), BoardMark(ballOn: "p")]),
            BoardStep(dur: 0.4, marks: [BoardMark("p", 66.0, 32.0), BoardMark("b", 67.0, 31.0)], caption: "Cruyff: fake the pass…"),
            BoardStep(dur: 0.4, marks: [BoardMark("p", 66.0, 32.0), BoardMark("b", 64.0, 33.5)], caption: "…drag behind the standing leg"),
            BoardStep(dur: 1.2, marks: [BoardMark("p", 40.0, 33.0), BoardMark(ballOn: "p")], caption: "Accelerate away"),
            BoardStep(dur: 0.5, marks: [BoardMark("p", 36.0, 32.0), BoardMark("b", 37.0, 32.0)], caption: "Drag-back with the sole"),
            BoardStep(dur: 0.4, marks: [BoardMark("p", 37.0, 32.0), BoardMark("b", 40.0, 32.0)]),
            BoardStep(dur: 1.2, marks: [BoardMark("p", 64.0, 32.0), BoardMark(ballOn: "p")]),
        ]))

    private static let dribPickSide = PathwayDrill(
        id: "drib-pick-side", name: "Pick-a-side 1v1", level: .build,
        positions: [.w, .wm, .ss, .cam, .wb, .st], outfield: false,
        skills: [.dribbling, .agility], needs: [.ball, .cones, .partner],
        format: .reps,
        sets: 4, reps: 6, rest: 60,
        blurb: "Dribble at a defender who guards two gates. Read their weight, commit hard to one side and explode through the gate.",
        steps: ["Two gates 10 yards apart behind your partner.", "Dribble at the defender at speed.", "Two yards out: a feint (step-over, body swerve) to shift the defender’s weight.", "Go the other way through a gate.", "Defender starts at 50–75% and goes full once you are winning."],
        points: ["Attack at speed — defenders hate pace", "Get close before the move", "Explode out of the feint"],
        mistakes: ["Doing the move from 5 yards away", "Slowing down before you beat them", "Big touch past them into their path"],
        checks: [.low, .headUp],
        video: "1v1 dribbling drill two gates beat defender",
        board: BoardScript(setup: BoardSetup(gates: [(78.0, 16.0, 78.0, 24.0), (78.0, 40.0, 78.0, 48.0)]), steps: [
            BoardStep(dur: 0.0, marks: [BoardMark("p", 22.0, 32.0), BoardMark("d", 66.0, 32.0), BoardMark(ballOn: "p")], caption: "Attack the defender at speed"),
            BoardStep(dur: 1.4, marks: [BoardMark("p", 56.0, 32.0), BoardMark(ballOn: "p"), BoardMark("d", 64.0, 32.0)]),
            BoardStep(dur: 0.4, marks: [BoardMark("p", 58.0, 34.0), BoardMark("b", 60.0, 33.0), BoardMark("d", 63.0, 35.0)], caption: "Feint right — defender shifts"),
            BoardStep(dur: 0.4, marks: [BoardMark("p", 61.0, 30.0), BoardMark("b", 64.0, 27.0), BoardMark("d", 63.0, 36.0)], caption: "Explode left"),
            BoardStep(dur: 0.8, marks: [BoardMark("p", 76.0, 22.0), BoardMark(ballOn: "p"), BoardMark("d", 66.0, 30.0)], caption: "Through the gate"),
            BoardStep(dur: 0.5, marks: [BoardMark("p", 82.0, 20.0), BoardMark(ballOn: "p"), BoardMark("d", 70.0, 26.0)]),
        ]))

    private static let dribChangePace = PathwayDrill(
        id: "drib-change-pace", name: "Slow, slow, explode", level: .foundation,
        positions: [.w, .wm, .wb, .fb, .ss], outfield: false,
        skills: [.dribbling, .speedDribble, .agility], needs: [.ball, .cones],
        format: .reps,
        sets: 4, reps: 6, rest: 45,
        blurb: "Pros beat full backs with pace changes, not tricks. Walk the ball into a \"defender\" cone, then burst past with one big touch and sprint.",
        steps: ["Cone \"defender\" 15 yards ahead, finish cone 15 yards behind it.", "Dribble slowly with small touches — invite the defender.", "At 2 yards: one sharp touch past the cone with the outside of the foot.", "Sprint onto it with two big touches to the finish."],
        points: ["Slow touches close to the body", "Drop your hips just before the burst", "First three steps short and fast"],
        mistakes: ["Same speed the whole way", "Burst too early", "Upright body at the change"],
        checks: [.low],
        video: "change of pace dribbling winger drill explode past defender",
        board: BoardScript(setup: BoardSetup(cones: [(56.0, 32.0), (90.0, 32.0)]), steps: [
            BoardStep(dur: 0.0, marks: [BoardMark("p", 20.0, 32.0), BoardMark(ballOn: "p")], caption: "Slow… small touches"),
            BoardStep(dur: 2.2, marks: [BoardMark("p", 50.0, 32.0), BoardMark(ballOn: "p")], caption: "Invite the defender"),
            BoardStep(dur: 0.3, marks: [BoardMark("p", 52.0, 33.0), BoardMark("b", 60.0, 35.0)], caption: "Explode — one sharp touch past"),
            BoardStep(dur: 0.7, marks: [BoardMark("p", 70.0, 34.0), BoardMark("b", 76.0, 33.0)], caption: "Sprint onto it"),
            BoardStep(dur: 0.6, marks: [BoardMark("p", 88.0, 32.0), BoardMark(ballOn: "p")]),
        ]))

    private static let dribCutInside = PathwayDrill(
        id: "drib-cut-inside", name: "Cut inside & bend it", level: .build,
        positions: [.w, .wm, .ss, .cam], outfield: false,
        skills: [.dribbling, .finishing], needs: [.ball, .cones, .goal],
        format: .reps,
        sets: 3, reps: 8, rest: 60,
        blurb: "The inverted winger’s signature: drive at the full back down the wing, cut inside onto your strong foot and curl it to the far post.",
        steps: ["Start wide, 30 yards from goal. Cone \"full back\" at the corner of the box.", "Drive at it down the line.", "Hard inside cut with the inside of the outside foot.", "One touch to set, then curl toward the far post with the inside of your foot."],
        points: ["Sell the outside run first", "Cut sharply — 90 degrees", "Wrap your foot around the ball, follow through across your body"],
        mistakes: ["Drifting inside slowly so the defender reads it", "Shooting with the laces when the angle needs curl"],
        checks: [.low, .balance],
        video: "inverted winger cut inside and curl finishing drill",
        board: BoardScript(setup: BoardSetup(cones: [(78.0, 16.0)], goal: (x: 98.0, y: 32.0, w: 14.0)), steps: [
            BoardStep(dur: 0.0, marks: [BoardMark("p", 44.0, 8.0), BoardMark(ballOn: "p"), BoardMark("k", 96.0, 32.0)], caption: "Drive down the line"),
            BoardStep(dur: 1.4, marks: [BoardMark("p", 72.0, 10.0), BoardMark(ballOn: "p")], caption: "Sell the outside run"),
            BoardStep(dur: 0.4, marks: [BoardMark("p", 74.0, 13.0), BoardMark("b", 74.0, 17.0)], caption: "Cut inside — hard"),
            BoardStep(dur: 0.6, marks: [BoardMark("p", 78.0, 22.0), BoardMark(ballOn: "p"), BoardMark("k", 95.0, 30.0)], caption: "Set it on your strong foot"),
            BoardStep(dur: 0.9, marks: [BoardMark("p", 79.0, 23.0), BoardMark("b", 98.0, 39.0), BoardMark("k", 95.0, 31.0)], caption: "Curl it to the far post"),
        ]))

    private static let dribCarry = PathwayDrill(
        id: "drib-carry", name: "Running with the ball: 3 touches, 30 yards", level: .foundation,
        positions: [.w, .wb, .fb, .st, .cm, .wm], outfield: false,
        skills: [.speedDribble, .agility], needs: [.ball, .cones],
        format: .reps,
        sets: 4, reps: 5, rest: 60,
        blurb: "Cover 30 yards with as few touches as possible at top speed — the counter-attack carry. Push the ball out of your feet into space.",
        steps: ["Two cones 30 yards apart.", "Push the ball 5–8 yards ahead with the laces or outside of the foot.", "Sprint onto it; touch again on your stride.", "Goal: 30 yards in 3–4 touches without slowing down."],
        points: ["Touch on your running stride", "Laces or outside of the foot, not the inside", "Look up between touches"],
        mistakes: ["Tiny touches that slow you down", "Overrunning the ball", "Head down for 30 yards"],
        checks: [.headUp],
        video: "running with the ball at speed drill soccer",
        board: BoardScript(setup: BoardSetup(cones: [(16.0, 32.0), (88.0, 32.0)]), steps: [
            BoardStep(dur: 0.0, marks: [BoardMark("p", 16.0, 32.0), BoardMark(ballOn: "p")], caption: "Push it out of your feet"),
            BoardStep(dur: 0.3, marks: [BoardMark("p", 18.0, 32.0), BoardMark("b", 34.0, 32.0)]),
            BoardStep(dur: 0.8, marks: [BoardMark("p", 34.0, 32.0), BoardMark("b", 36.0, 32.0)], caption: "Touch on your stride"),
            BoardStep(dur: 0.3, marks: [BoardMark("p", 36.0, 32.0), BoardMark("b", 56.0, 32.0)]),
            BoardStep(dur: 0.8, marks: [BoardMark("p", 56.0, 32.0), BoardMark("b", 58.0, 32.0)], caption: "Look up between touches"),
            BoardStep(dur: 0.3, marks: [BoardMark("p", 58.0, 32.0), BoardMark("b", 80.0, 32.0)]),
            BoardStep(dur: 0.8, marks: [BoardMark("p", 86.0, 32.0), BoardMark(ballOn: "p")], caption: "30 yards, 3 touches"),
        ]))

    private static let crossEarly = PathwayDrill(
        id: "cross-early", name: "Early cross from deep", level: .build,
        positions: [.fb, .wb, .wm], outfield: false,
        skills: [.crossing, .speedDribble], needs: [.ball, .cones, .goal],
        format: .reps,
        sets: 3, reps: 8, rest: 45,
        blurb: "Cross from 30–35 yards out into the \"corridor\" between keeper and back line — the delivery Trent Alexander-Arnold made famous.",
        steps: ["Dribble down the wing from the halfway line.", "At the cone (level with the top of the penalty area or deeper), look up.", "Whip it into the space between the 6-yard box and the penalty spot.", "Alternate: driven at waist height, and whipped with curl away from the keeper."],
        points: ["Look up before you cross — pick a zone", "Strike the side of the ball for curl", "Body leans slightly over the ball to keep it from floating"],
        mistakes: ["Crossing at the keeper", "Lofted, slow crosses defenders can head", "Not looking up first"],
        checks: [.balance, .headUp],
        video: "early cross technique full back whipped cross drill",
        board: BoardScript(setup: BoardSetup(gates: [(86.0, 26.0, 92.0, 26.0), (86.0, 38.0, 92.0, 38.0)], goal: (x: 98.0, y: 32.0, w: 14.0)), steps: [
            BoardStep(dur: 0.0, marks: [BoardMark("p", 46.0, 8.0), BoardMark(ballOn: "p"), BoardMark("k", 96.0, 32.0), BoardMark("m", 72.0, 34.0)], caption: "Carry down the wing"),
            BoardStep(dur: 1.2, marks: [BoardMark("p", 64.0, 9.0), BoardMark(ballOn: "p"), BoardMark("m", 78.0, 33.0)], caption: "Look up — pick the corridor", look: 30.0),
            BoardStep(dur: 0.4, marks: [BoardMark("p", 66.0, 10.0), BoardMark("b", 67.0, 11.0)], caption: "Whip it in"),
            BoardStep(dur: 1.0, marks: [BoardMark("p", 68.0, 11.0), BoardMark("b", 88.0, 31.0), BoardMark("m", 87.0, 31.0), BoardMark("k", 95.0, 31.0)], caption: "Runner attacks the space"),
            BoardStep(dur: 0.4, marks: [BoardMark("b", 98.0, 30.0)]),
        ]))

    private static let crossCutback = PathwayDrill(
        id: "cross-cutback", name: "Byline cutback", level: .build,
        positions: [.w, .wb, .wm, .fb], outfield: false,
        skills: [.crossing, .dribbling], needs: [.ball, .cones, .goal],
        format: .reps,
        sets: 3, reps: 8, rest: 45,
        blurb: "Drive to the byline, then pull it back to the penalty spot. Many goals come from cutbacks — the arriving player faces the goal while defenders run toward their own.",
        steps: ["Dribble to the byline inside the box.", "Look up and pick the spot — usually the penalty spot or the edge of the 6.", "Pass it back firmly with the inside of the foot along the ground.", "Alternate with a partner arriving to finish first time."],
        points: ["Get to the byline — the closer, the better the angle", "Pass, don’t blast", "Along the ground"],
        mistakes: ["Cutting back to where defenders are standing", "Ball too soft, too close to the keeper"],
        checks: [.headUp],
        video: "cutback cross drill byline soccer",
        board: BoardScript(setup: BoardSetup(goal: (x: 98.0, y: 32.0, w: 14.0)), steps: [
            BoardStep(dur: 0.0, marks: [BoardMark("p", 70.0, 10.0), BoardMark(ballOn: "p"), BoardMark("k", 96.0, 32.0), BoardMark("m", 70.0, 30.0)], caption: "Drive to the byline"),
            BoardStep(dur: 1.0, marks: [BoardMark("p", 93.0, 16.0), BoardMark(ballOn: "p"), BoardMark("m", 76.0, 31.0)]),
            BoardStep(dur: 0.3, marks: [BoardMark("p", 94.0, 17.0), BoardMark("b", 94.0, 18.0)], caption: "Look up — pick the spot", look: 160.0),
            BoardStep(dur: 0.8, marks: [BoardMark("p", 94.0, 17.0), BoardMark("b", 82.0, 32.0), BoardMark("m", 82.0, 32.0)], caption: "Pull it back to the arriving player"),
            BoardStep(dur: 0.5, marks: [BoardMark("b", 98.0, 36.0), BoardMark("m", 83.0, 32.0)], caption: "First-time finish"),
        ]))

    private static let finFirstTime = PathwayDrill(
        id: "fin-first-time", name: "First-time finish across goal", level: .build,
        positions: [.st, .ss, .w, .cam], outfield: false,
        skills: [.finishing, .weakFoot], needs: [.ball, .goal, .partner],
        format: .reps,
        sets: 4, reps: 8, rest: 45,
        blurb: "Partner rolls balls across the top of the six-yard box; you meet each one first time and finish low across the keeper.",
        steps: ["Partner on the corner of the box, you at the penalty spot.", "They pass across the 6-yard line.", "Time your run, meet it first time with the inside of the foot.", "Aim low, far post. Switch sides so you use both feet."],
        points: ["Open your body to the far post", "Side-foot for accuracy, laces for power only when needed", "Head over the ball"],
        mistakes: ["Taking a touch you don’t have time for", "Leaning back — ball over the bar", "Shooting at the keeper’s body"],
        checks: [.balance],
        video: "first time finishing drill striker across goal",
        board: BoardScript(setup: BoardSetup(goal: (x: 98.0, y: 32.0, w: 14.0)), steps: [
            BoardStep(dur: 0.0, marks: [BoardMark("p", 78.0, 32.0), BoardMark("m", 86.0, 14.0), BoardMark("b", 86.0, 14.0), BoardMark("k", 96.0, 32.0)], caption: "Ball comes across"),
            BoardStep(dur: 0.4, marks: [BoardMark("p", 80.0, 30.0)], caption: "Time your run"),
            BoardStep(dur: 0.7, marks: [BoardMark("p", 87.0, 25.0), BoardMark("b", 87.0, 25.0)], caption: "Meet it first time"),
            BoardStep(dur: 0.5, marks: [BoardMark("p", 88.0, 26.0), BoardMark("b", 98.0, 37.0), BoardMark("k", 96.0, 30.0)], caption: "Low, far post"),
        ]))

    private static let finNearPost = PathwayDrill(
        id: "fin-near-post", name: "Near-post run and finish", level: .elite,
        positions: [.st, .ss], outfield: false,
        skills: [.finishing, .movement], needs: [.ball, .goal, .partner, .cones],
        format: .reps,
        sets: 3, reps: 8, rest: 50,
        blurb: "Fake toward the far post, then sprint across the front of a cone \"defender\" to the near post and flick or poke it in.",
        steps: ["Cone defender at the penalty spot.", "Start wide of it. As the crosser’s head goes down, take a step toward the far post.", "Explode across the front of the cone to the near post.", "Finish first time — redirect, don’t blast."],
        points: ["Get across the first defender", "Read the crosser: head down, leg back = go", "Redirect the ball’s pace"],
        mistakes: ["Running too early and arriving before the ball", "Running behind the defender instead of across"],
        checks: [.balance],
        video: "near post run striker movement finishing crosses",
        board: BoardScript(setup: BoardSetup(cones: [(86.0, 32.0)], goal: (x: 98.0, y: 32.0, w: 14.0)), steps: [
            BoardStep(dur: 0.0, marks: [BoardMark("p", 80.0, 38.0), BoardMark("m", 80.0, 6.0), BoardMark("b", 80.0, 6.0), BoardMark("k", 96.0, 32.0)], caption: "Fake toward the far post"),
            BoardStep(dur: 0.6, marks: [BoardMark("p", 82.0, 42.0)]),
            BoardStep(dur: 0.5, marks: [BoardMark("b", 81.0, 7.0)], caption: "Crosser’s head goes down — GO"),
            BoardStep(dur: 0.8, marks: [BoardMark("p", 92.0, 27.0), BoardMark("b", 92.0, 26.0)], caption: "Across the front to the near post"),
            BoardStep(dur: 0.3, marks: [BoardMark("b", 98.0, 28.0), BoardMark("k", 96.0, 33.0)], caption: "Redirect it in"),
        ]))

    private static let fin1v1Keeper = PathwayDrill(
        id: "fin-1v1-keeper", name: "1v1 vs the keeper: shift & slot", level: .build,
        positions: [.st, .ss, .w, .cam], outfield: false,
        skills: [.finishing, .dribbling], needs: [.ball, .goal],
        format: .reps,
        sets: 3, reps: 8, rest: 45,
        blurb: "Through on goal. Take a shifting touch to move the keeper, then slot it past them low into the corner — the keeper has committed.",
        steps: ["Start 30 yards out, dribble at goal.", "Watch the keeper set.", "At 10–12 yards, one touch sideways to shift the keeper.", "Slot low into the corner the keeper has left."],
        points: ["Look at the keeper, not the ball", "Shift touch across the keeper", "Pass it into the net — accuracy beats power"],
        mistakes: ["Blasting at the keeper", "Going too close so the keeper smothers", "Deciding before you read the keeper"],
        checks: [.headUp, .balance],
        video: "1v1 with goalkeeper finishing drill striker",
        board: BoardScript(setup: BoardSetup(goal: (x: 98.0, y: 32.0, w: 14.0)), steps: [
            BoardStep(dur: 0.0, marks: [BoardMark("p", 56.0, 32.0), BoardMark(ballOn: "p"), BoardMark("k", 95.0, 32.0)], caption: "Through on goal"),
            BoardStep(dur: 1.3, marks: [BoardMark("p", 82.0, 32.0), BoardMark(ballOn: "p"), BoardMark("k", 92.0, 32.0)], caption: "Keeper comes out and sets"),
            BoardStep(dur: 0.4, marks: [BoardMark("p", 84.0, 35.0), BoardMark("b", 85.0, 37.0), BoardMark("k", 91.0, 34.0)], caption: "Shift touch"),
            BoardStep(dur: 0.6, marks: [BoardMark("p", 85.0, 36.0), BoardMark("b", 98.0, 27.0), BoardMark("k", 91.0, 36.0)], caption: "Slot it into the space"),
        ]))

    private static let finVolley = PathwayDrill(
        id: "fin-volley", name: "Volley & half-volley", level: .elite,
        positions: [.st, .cam, .ss, .cm], outfield: false,
        skills: [.finishing], needs: [.ball, .goal],
        format: .reps,
        sets: 3, reps: 10, rest: 45,
        blurb: "Drop the ball from your hands, strike it as it comes off the ground (half-volley) or before (volley). Keep it down.",
        steps: ["Stand at the edge of the box with the ball in your hands.", "Drop it, let it bounce once, strike it just as it rises.", "Knee over the ball, toe pointed, laces through the center.", "Progress: toss it to the side and volley across your body."],
        points: ["Knee over the ball", "Short backswing", "Land on your shooting foot"],
        mistakes: ["Leaning back", "Huge swing", "Striking under the ball"],
        checks: [.balance],
        video: "half volley technique drill shooting",
        board: BoardScript(setup: BoardSetup(goal: (x: 98.0, y: 32.0, w: 14.0)), steps: [
            BoardStep(dur: 0.0, marks: [BoardMark("p", 74.0, 32.0), BoardMark("b", 74.5, 31.0), BoardMark("k", 96.0, 32.0)], caption: "Drop the ball"),
            BoardStep(dur: 0.5, marks: [BoardMark("b", 76.0, 32.0)], caption: "It bounces…"),
            BoardStep(dur: 0.3, marks: [BoardMark("p", 75.0, 32.0), BoardMark("b", 76.5, 32.0)], caption: "…strike as it rises, knee over it"),
            BoardStep(dur: 0.5, marks: [BoardMark("b", 98.0, 36.0), BoardMark("k", 96.0, 33.0)]),
        ]))

    private static let holdUp = PathwayDrill(
        id: "hold-up", name: "Back-to-goal hold-up & lay-off", level: .build,
        positions: [.st, .ss], outfield: false,
        skills: [.holdUp, .firstTouch, .passing], needs: [.ball, .partner],
        format: .reps,
        sets: 4, reps: 8, rest: 45,
        blurb: "Partner leans on you from behind. Receive a pass with your back to goal, pin them, and lay it off first time or spin.",
        steps: ["Partner/feeder 15 yards away; a second partner (or bag) behind you.", "Before the pass, back into the defender — feel where they are.", "Show with your arm, receive on your back foot away from them.", "Lay off first time to the feeder’s side, or spin if the defender is too tight on one shoulder."],
        points: ["Wide base, low center of gravity", "Body between the defender and the ball", "Lay-off is firm and to the runner’s front foot"],
        mistakes: ["Standing upright so you get knocked off", "Letting the defender nick in front", "Lay-off too soft"],
        checks: [.base, .low],
        video: "striker hold up play drill back to goal",
        board: BoardScript(setup: BoardSetup(goal: (x: 98.0, y: 32.0, w: 14.0)), steps: [
            BoardStep(dur: 0.0, marks: [BoardMark("p", 74.0, 32.0), BoardMark("d", 77.0, 32.0), BoardMark("m", 50.0, 32.0), BoardMark("b", 50.0, 32.0)], caption: "Back into the defender"),
            BoardStep(dur: 0.8, marks: [BoardMark("p", 74.0, 32.0), BoardMark("d", 76.0, 32.0), BoardMark("b", 72.0, 32.0)], caption: "Receive — body in between"),
            BoardStep(dur: 0.4, marks: [BoardMark("p", 74.0, 32.0), BoardMark("b", 72.0, 32.0)]),
            BoardStep(dur: 0.7, marks: [BoardMark("b", 60.0, 36.0), BoardMark("m", 60.0, 36.0)], caption: "Lay it off"),
            BoardStep(dur: 0.6, marks: [BoardMark("p", 80.0, 30.0), BoardMark("d", 79.0, 33.0), BoardMark("m", 62.0, 36.0)], caption: "Spin and run"),
            BoardStep(dur: 0.6, marks: [BoardMark("b", 86.0, 30.0), BoardMark("p", 85.0, 30.0)]),
        ]))

    private static let moveShoulder = PathwayDrill(
        id: "move-shoulder", name: "Run off the shoulder", level: .build,
        positions: [.st, .w, .ss, .wb], outfield: false,
        skills: [.movement, .finishing], needs: [.ball, .partner, .cones, .goal],
        format: .reps,
        sets: 4, reps: 6, rest: 60,
        blurb: "Stay on the shoulder of a cone \"last defender\", curve your run to stay onside, and go when the passer’s head comes up.",
        steps: ["Line of cones = the defensive line.", "Walk along the line, checking the passer and the line.", "As the passer takes their touch and lifts their head: curve the run.", "Receive in stride and finish."],
        points: ["Curve the run — never straight at the passer", "Go on the passer’s cue, not your own", "First touch forward into the space"],
        mistakes: ["Running too early (offside)", "Straight runs the defender can read", "Stopping when the pass is late"],
        checks: [.scan],
        video: "striker run in behind off the shoulder timing drill",
        board: BoardScript(setup: BoardSetup(cones: [(66.0, 14.0), (66.0, 26.0), (66.0, 38.0), (66.0, 50.0)], goal: (x: 98.0, y: 32.0, w: 14.0)), steps: [
            BoardStep(dur: 0.0, marks: [BoardMark("p", 63.0, 40.0), BoardMark("m", 36.0, 30.0), BoardMark("b", 36.0, 30.0), BoardMark("k", 95.0, 32.0)], caption: "Stay level with the line", look: 180.0),
            BoardStep(dur: 1.0, marks: [BoardMark("p", 64.0, 34.0)], caption: "Passer looks up…"),
            BoardStep(dur: 0.4, marks: [BoardMark("p", 64.0, 33.0)], caption: "Curve the run — GO"),
            BoardStep(dur: 0.4, marks: [BoardMark("b", 40.0, 30.0)]),
            BoardStep(dur: 0.9, marks: [BoardMark("p", 76.0, 28.0), BoardMark("b", 77.0, 28.0)], caption: "Receive in stride"),
            BoardStep(dur: 0.6, marks: [BoardMark("p", 86.0, 30.0), BoardMark(ballOn: "p")]),
            BoardStep(dur: 0.4, marks: [BoardMark("b", 98.0, 36.0), BoardMark("k", 95.0, 30.0)], caption: "Finish"),
        ]))

    private static let headClear = PathwayDrill(
        id: "head-clear", name: "Attack-the-ball clearances", level: .build,
        positions: [.cb, .cdm, .st, .fb], outfield: false,
        skills: [.heading], needs: [.ball, .partner],
        format: .reps,
        sets: 3, reps: 8, rest: 60,
        blurb: "Partner serves high balls; take a run-up, jump off one foot and head it high and far with your forehead. Low volume, high quality.",
        steps: ["Partner throws or kicks a high ball from 15 yards.", "Take two or three steps to attack it — never wait for it to drop on you.", "Jump off one foot, use your arms for leverage (not elbows).", "Contact with the forehead, eyes open, neck strong — direct it up and away."],
        points: ["Attack the ball", "Eyes open, mouth closed", "Forehead, not the top of the head"],
        mistakes: ["Waiting under the ball", "Closing eyes", "Leading with the elbow (foul)"],
        checks: [.balance],
        video: "defensive heading technique drill clearance",
        inspired: "US Soccer heading guidance limits heading for young players — follow your club’s rules on age and volume.",
        board: BoardScript(setup: BoardSetup(), steps: [
            BoardStep(dur: 0.0, marks: [BoardMark("p", 40.0, 36.0), BoardMark("m", 70.0, 32.0), BoardMark("b", 70.0, 32.0)], caption: "Serve comes in high"),
            BoardStep(dur: 0.5, marks: [BoardMark("p", 42.0, 35.0), BoardMark("b", 56.0, 24.0)], caption: "Attack it — two steps"),
            BoardStep(dur: 0.5, marks: [BoardMark("p", 47.0, 33.0), BoardMark("b", 48.0, 32.0)], caption: "Jump off one foot, forehead"),
            BoardStep(dur: 0.9, marks: [BoardMark("b", 74.0, 10.0)], caption: "High and away"),
        ]))

    private static let defJockey = PathwayDrill(
        id: "def-jockey", name: "Jockey & show outside", level: .foundation,
        positions: [.cb, .fb, .wb, .cdm, .wm], outfield: false,
        skills: [.defending1v1, .agility], needs: [.cones],
        format: .time,
        seconds: 180,
        blurb: "Side-on, low, on the balls of your feet. Mirror an attacker (or a zig-zag of cones) backwards for 20 seconds at a time, always showing them toward the line.",
        steps: ["Zig-zag of cones going backwards, or a partner dribbling at you.", "Get side-on: one foot forward, knees bent, weight on the balls of the feet.", "Shuffle — never cross your feet.", "Keep an arm’s length plus a bit; show them outside, away from goal.", "Tackle only when the touch is heavy or they turn their back."],
        points: ["Side-on, never square", "Low and patient", "Eyes on the ball, not the hips or the feet tricks"],
        mistakes: ["Square stance so the attacker goes either way", "Diving in", "Crossing your feet"],
        checks: [.low, .base],
        video: "jockeying defending 1v1 body shape drill",
        board: BoardScript(setup: BoardSetup(cones: [(30.0, 20.0), (44.0, 44.0), (58.0, 20.0), (72.0, 44.0)]), steps: [
            BoardStep(dur: 0.0, marks: [BoardMark("p", 78.0, 40.0), BoardMark("d", 70.0, 40.0), BoardMark("b", 69.0, 40.0)], caption: "Side-on, low — attacker comes at you"),
            BoardStep(dur: 1.2, marks: [BoardMark("p", 64.0, 24.0), BoardMark("d", 58.0, 24.0), BoardMark("b", 57.0, 24.0)], caption: "Shuffle, don’t cross your feet"),
            BoardStep(dur: 1.2, marks: [BoardMark("p", 50.0, 42.0), BoardMark("d", 44.0, 42.0), BoardMark("b", 43.0, 42.0)], caption: "Show them outside"),
            BoardStep(dur: 1.2, marks: [BoardMark("p", 36.0, 22.0), BoardMark("d", 30.0, 22.0), BoardMark("b", 29.0, 22.0)]),
            BoardStep(dur: 0.5, marks: [BoardMark("p", 32.0, 20.0), BoardMark("b", 32.0, 18.0), BoardMark("d", 30.0, 18.0)], caption: "Heavy touch — now tackle"),
        ]))

    private static let defApproach = PathwayDrill(
        id: "def-approach", name: "Close down: sprint, brake, side-on", level: .foundation,
        positions: [.cb, .fb, .wb, .cdm, .cm], outfield: false,
        skills: [.defending1v1, .pressing, .agility], needs: [.cones],
        format: .reps,
        sets: 4, reps: 6, rest: 40,
        blurb: "Sprint at the attacker while the ball travels, brake with short choppy steps, and arrive side-on and balanced — the approach decides the 1v1.",
        steps: ["Cone 15 yards away = the attacker receiving.", "Sprint while the pass is traveling.", "Last 3 yards: short, choppy steps to brake.", "Arrive side-on, low, an arm’s length away. Hold for 2 seconds."],
        points: ["Sprint while the ball travels", "Brake with small steps", "Arrive balanced — not flying in"],
        mistakes: ["Arriving at full speed", "Arriving square", "Stopping too far away"],
        checks: [.low, .base],
        video: "defending approach close down attacker technique drill",
        board: BoardScript(setup: BoardSetup(cones: [(70.0, 32.0)]), steps: [
            BoardStep(dur: 0.0, marks: [BoardMark("p", 30.0, 32.0), BoardMark("d", 72.0, 32.0), BoardMark("b", 90.0, 32.0)], caption: "Ball travels to the attacker"),
            BoardStep(dur: 0.9, marks: [BoardMark("p", 56.0, 32.0), BoardMark("b", 72.0, 32.0)], caption: "Sprint while it travels"),
            BoardStep(dur: 0.7, marks: [BoardMark("p", 65.0, 33.0)], caption: "Choppy steps — brake"),
            BoardStep(dur: 0.5, marks: [BoardMark("p", 66.5, 33.5)], caption: "Side-on, low, arm’s length"),
            BoardStep(dur: 0.8, marks: [BoardMark("p", 66.5, 33.5)]),
        ]))

    private static let defRecovery = PathwayDrill(
        id: "def-recovery", name: "Recovery run: inside line", level: .build,
        positions: [.fb, .wb, .wm, .w, .cdm, .cb], outfield: false,
        skills: [.recovery, .agility, .positioning], needs: [.cones],
        format: .reps,
        sets: 4, reps: 5, rest: 60,
        blurb: "When the ball is lost, sprint back on the line between the ball and your own near post — not toward the ball. Repeat-sprint fitness meets positioning.",
        steps: ["Start 40 yards from goal at a \"lost the ball\" cone.", "Turn and sprint toward a cone at your own near post — the goal-side line.", "At the edge of the box, look over your shoulder, slow down and get side-on.", "Jog back, repeat."],
        points: ["Inside line first, ball second", "Look over your shoulder while running", "Finish goal-side and set"],
        mistakes: ["Chasing the ball carrier from behind", "Stopping at halfway", "Arriving flat-footed"],
        checks: [.scan, .low],
        video: "recovery run defending full back drill soccer",
        board: BoardScript(setup: BoardSetup(cones: [(56.0, 12.0), (14.0, 26.0)], goal: (x: 2.0, y: 32.0, w: 14.0)), steps: [
            BoardStep(dur: 0.0, marks: [BoardMark("p", 56.0, 12.0), BoardMark("d", 52.0, 20.0), BoardMark("b", 51.0, 21.0)], caption: "Ball lost — turn"),
            BoardStep(dur: 0.4, marks: [BoardMark("p", 54.0, 13.0), BoardMark("d", 48.0, 22.0), BoardMark(ballOn: "d")]),
            BoardStep(dur: 1.3, marks: [BoardMark("p", 30.0, 20.0), BoardMark("d", 36.0, 26.0), BoardMark(ballOn: "d")], caption: "Sprint the inside line to your near post", look: 60.0),
            BoardStep(dur: 0.8, marks: [BoardMark("p", 18.0, 25.0), BoardMark("d", 26.0, 28.0), BoardMark(ballOn: "d")], caption: "Goal-side — get set"),
            BoardStep(dur: 0.5, marks: [BoardMark("p", 19.0, 26.0)]),
        ]))

    private static let defCoverShadow = PathwayDrill(
        id: "def-cover-shadow", name: "Cover-shadow press", level: .elite,
        positions: [.st, .cam, .cm, .w, .ss], outfield: false,
        skills: [.pressing, .positioning], needs: [.cones, .partner],
        format: .reps,
        sets: 4, reps: 6, rest: 45,
        blurb: "Press the ball carrier on a curved run so your body blocks the pass behind you. Forces play one way — how pro forwards press center backs.",
        steps: ["Partner with the ball at one cone; a second cone (the \"6\") sits behind you.", "On the trigger (bad touch, back pass), sprint to press.", "Curve your run so the \"6\" stays directly behind you — in your shadow.", "Force the passer to go wide or long."],
        points: ["Curve, don’t sprint straight", "Scan to know where the 6 is", "Press on the trigger, not all the time"],
        mistakes: ["Straight run that leaves the pass inside open", "Pressing without a trigger", "Overrunning the ball"],
        checks: [.scan, .low],
        video: "cover shadow pressing technique forward",
        board: BoardScript(setup: BoardSetup(cones: [(50.0, 34.0)]), steps: [
            BoardStep(dur: 0.0, marks: [BoardMark("p", 56.0, 18.0), BoardMark("m", 30.0, 40.0), BoardMark("b", 30.0, 40.0), BoardMark("d", 48.0, 34.0)], caption: "Trigger: back pass to the CB"),
            BoardStep(dur: 0.5, marks: [BoardMark("p", 52.0, 22.0)], caption: "Curve your run…", look: 180.0),
            BoardStep(dur: 0.9, marks: [BoardMark("p", 38.0, 36.0), BoardMark("b", 30.0, 40.0)], caption: "…the 6 stays in your shadow"),
            BoardStep(dur: 0.7, marks: [BoardMark("b", 30.0, 10.0), BoardMark("p", 34.0, 38.0)], caption: "Forced wide"),
        ]))

    private static let defTightMark = PathwayDrill(
        id: "def-tight-mark", name: "Tight marking: see ball and man", level: .build,
        positions: [.cb, .cdm, .fb], outfield: false,
        skills: [.marking, .positioning, .scanning], needs: [.partner],
        format: .time,
        seconds: 180,
        blurb: "Stay goal-side of a moving partner at arm’s length while keeping the ball (a second partner or a cone) in view. Open body, half-turned.",
        steps: ["Partner A moves around a 10×10 box. Partner B or a cone is \"the ball\".", "Stay goal-side, a touch-tight arm’s length away.", "Body half-turned so you see the ball and the runner.", "When the \"ball\" calls, step in front to intercept."],
        points: ["Goal-side always", "See both — never turn your back on the ball", "A light hand on the attacker to feel them"],
        mistakes: ["Ball-watching and losing the runner", "Getting too tight so they spin you", "Square body"],
        checks: [.scan, .low],
        video: "man marking defending technique goal side drill",
        board: BoardScript(setup: BoardSetup(goal: (x: 2.0, y: 32.0, w: 14.0)), steps: [
            BoardStep(dur: 0.0, marks: [BoardMark("d", 40.0, 26.0), BoardMark("p", 35.0, 28.0), BoardMark("m", 70.0, 32.0), BoardMark("b", 70.0, 32.0)], caption: "Goal-side, arm’s length", look: 0.0),
            BoardStep(dur: 1.0, marks: [BoardMark("d", 36.0, 40.0), BoardMark("p", 31.0, 38.0)], caption: "Move with them"),
            BoardStep(dur: 1.0, marks: [BoardMark("d", 44.0, 34.0), BoardMark("p", 38.0, 34.0)], caption: "Half-turned — see ball and man", look: 20.0),
            BoardStep(dur: 0.5, marks: [BoardMark("b", 50.0, 33.0)], caption: "Pass is coming"),
            BoardStep(dur: 0.5, marks: [BoardMark("p", 47.0, 33.0), BoardMark("b", 48.0, 33.0)], caption: "Step in front — intercept"),
        ]))

    private static let midScreen = PathwayDrill(
        id: "mid-screen", name: "Screen the passing lane", level: .build,
        positions: [.cdm, .cm], outfield: false,
        skills: [.positioning, .scanning], needs: [.cones],
        format: .time,
        seconds: 240, cue: .numbers,
        blurb: "Four numbered cones around you are passers; a center cone is the 10 you protect. The screen calls a number — shuffle into the lane between that passer and the 10.",
        steps: ["Four cones (1–4) in a square 15 yards apart, one cone in the middle (the 10).", "Phone in front of you calls a number.", "Shuffle into the line between that number and the middle cone.", "Hold, scan, react to the next call."],
        points: ["Move as the call happens", "Scan to know where the 10 is", "Side-on, ready to intercept"],
        mistakes: ["Running to the ball instead of the lane", "Ending square to the passer"],
        checks: [.scan, .low, .base],
        video: "defensive midfielder screening positioning drill",
        board: BoardScript(setup: BoardSetup(cones: [(30.0, 12.0), (70.0, 12.0), (70.0, 52.0), (30.0, 52.0), (50.0, 32.0)]), steps: [
            BoardStep(dur: 0.0, marks: [BoardMark("p", 50.0, 38.0)], caption: "Screen calls 1", cue: "1"),
            BoardStep(dur: 0.7, marks: [BoardMark("p", 42.0, 24.0)], caption: "Get in the lane 1 → 10"),
            BoardStep(dur: 0.8, marks: [BoardMark("p", 42.0, 24.0)], caption: "Screen calls 3", cue: "3"),
            BoardStep(dur: 0.9, marks: [BoardMark("p", 58.0, 40.0)]),
            BoardStep(dur: 0.8, marks: [BoardMark("p", 58.0, 40.0)], caption: "2", cue: "2"),
            BoardStep(dur: 0.9, marks: [BoardMark("p", 58.0, 24.0)]),
        ]))

    private static let midBoxToBox = PathwayDrill(
        id: "mid-box-to-box", name: "Box-to-box repeat runs", level: .build,
        positions: [.cm, .cdm, .wm, .wb, .fb], outfield: false,
        skills: [.agility, .recovery], needs: [.cones],
        format: .time,
        seconds: 480, interval: (work: 15, rest: 15),
        blurb: "15 seconds hard, 15 seconds jog. Eight minutes of the stop-start running a center mid does all game.",
        steps: ["Two cones 50–60 yards apart.", "Sprint at 85–90% for 15 seconds.", "Jog for 15 seconds.", "Repeat for 8 minutes. The timer beeps the switches."],
        points: ["Same speed in rep 16 as rep 1", "Run tall, relaxed shoulders", "Breathe out hard on the jog"],
        mistakes: ["Going 100% early and dying", "Walking the recovery"],
        checks: [],
        video: "15 15 interval running soccer fitness",
        board: BoardScript(setup: BoardSetup(cones: [(14.0, 32.0), (86.0, 32.0)]), steps: [
            BoardStep(dur: 0.0, marks: [BoardMark("p", 14.0, 32.0)], caption: "Sprint 15 seconds"),
            BoardStep(dur: 1.6, marks: [BoardMark("p", 86.0, 32.0)]),
            BoardStep(dur: 2.4, marks: [BoardMark("p", 54.0, 32.0)], caption: "Jog 15 seconds"),
            BoardStep(dur: 1.2, marks: [BoardMark("p", 14.0, 32.0)], caption: "Sprint again"),
        ]))

    private static let agi5105 = PathwayDrill(
        id: "agi-5-10-5", name: "5-10-5 pro agility", level: .foundation,
        positions: [.gk], outfield: true,
        skills: [.agility], needs: [.cones],
        format: .reps,
        sets: 3, reps: 4, rest: 60,
        blurb: "The combine shuttle: 5 yards one way, 10 back, 5 to the middle. Low, sharp cuts.",
        steps: ["Three cones in a line, 5 yards apart.", "Start at the middle, sprint 5 yards right, touch the line.", "Sprint 10 yards left, touch.", "Sprint 5 back through the middle."],
        points: ["Drop your hips into each cut", "Plant on the outside foot", "Touch the line with your hand"],
        mistakes: ["Rounding the turns", "Standing up at the cuts"],
        checks: [.low],
        video: "5-10-5 pro agility shuttle technique",
        board: BoardScript(setup: BoardSetup(cones: [(30.0, 32.0), (50.0, 32.0), (70.0, 32.0)]), steps: [
            BoardStep(dur: 0.0, marks: [BoardMark("p", 50.0, 34.0)], caption: "Start in the middle"),
            BoardStep(dur: 0.6, marks: [BoardMark("p", 70.0, 34.0)], caption: "5 yards — touch"),
            BoardStep(dur: 1.0, marks: [BoardMark("p", 30.0, 34.0)], caption: "10 yards back — touch"),
            BoardStep(dur: 0.6, marks: [BoardMark("p", 52.0, 34.0)], caption: "Through the middle"),
        ]))

    private static let agiReactionArrows = PathwayDrill(
        id: "agi-reaction-arrows", name: "Reaction arrows", level: .foundation,
        positions: [.gk], outfield: true,
        skills: [.agility, .scanning], needs: [],
        format: .time,
        seconds: 120, cue: .arrows,
        blurb: "Phone 5 yards in front. Arrows flash at random — explode two steps in that direction and back. Trains first-step speed and reading cues.",
        steps: ["Phone on a bag or bench, 5 yards away.", "Athletic stance, quick feet.", "Arrow flashes: two explosive steps that way, then back to center.", "Go for 20 seconds, rest 10."],
        points: ["Stay on your toes between cues", "First step is the push, not a reach", "Low hips"],
        mistakes: ["Standing tall between cues", "Guessing before the arrow"],
        checks: [.low, .base],
        video: "reaction agility drill lights soccer",
        inspired: "A-Champs ROX / reaction-light training reduced to a phone screen",
        board: BoardScript(setup: BoardSetup(), steps: [
            BoardStep(dur: 0.0, marks: [BoardMark("p", 50.0, 34.0)], caption: "Quick feet, wait"),
            BoardStep(dur: 0.6, marks: [BoardMark("p", 50.0, 34.0)], caption: "←", cue: "←"),
            BoardStep(dur: 0.4, marks: [BoardMark("p", 40.0, 34.0)]),
            BoardStep(dur: 0.5, marks: [BoardMark("p", 50.0, 34.0)]),
            BoardStep(dur: 0.4, marks: [BoardMark("p", 50.0, 34.0)], caption: "↑", cue: "↑"),
            BoardStep(dur: 0.4, marks: [BoardMark("p", 50.0, 24.0)]),
            BoardStep(dur: 0.5, marks: [BoardMark("p", 50.0, 34.0)]),
            BoardStep(dur: 0.4, marks: [BoardMark("p", 50.0, 34.0)], caption: "→", cue: "→"),
            BoardStep(dur: 0.4, marks: [BoardMark("p", 60.0, 34.0)]),
            BoardStep(dur: 0.5, marks: [BoardMark("p", 50.0, 34.0)]),
        ]))

    private static let fbOverlap = PathwayDrill(
        id: "fb-overlap", name: "Overlap or underlap?", level: .elite,
        positions: [.fb, .wb, .wm, .w, .cm], outfield: false,
        skills: [.overlap, .crossing, .movement], needs: [.ball, .partner, .cones],
        format: .reps,
        sets: 3, reps: 8, rest: 60,
        blurb: "Your winger drives at a cone defender. Winger goes inside → you overlap outside. Winger stays wide → you underlap into the half-space. Receive and cross.",
        steps: ["You are the full back, partner is the winger with the ball.", "Winger dribbles at a cone defender.", "Watch their first move: inside = you go outside (overlap); wide = you go inside (underlap).", "Time it for when their head goes down — they release you.", "Cross or cut back first time."],
        points: ["Run when the defender is committed", "Call it: \"Hold!\" / \"Inside!\"", "Arrive at speed, cross early"],
        mistakes: ["Running into the same space as the winger", "Arriving too early and standing"],
        checks: [.scan],
        video: "overlap underlap full back winger drill",
        board: BoardScript(setup: BoardSetup(cones: [(72.0, 10.0)], goal: (x: 98.0, y: 32.0, w: 14.0)), steps: [
            BoardStep(dur: 0.0, marks: [BoardMark("p", 44.0, 6.0), BoardMark("m", 56.0, 12.0), BoardMark("b", 57.0, 12.0)], caption: "Winger drives at the defender"),
            BoardStep(dur: 0.9, marks: [BoardMark("m", 64.0, 16.0), BoardMark("b", 65.0, 16.0), BoardMark("p", 56.0, 4.0)], caption: "Winger cuts inside — go OUTSIDE"),
            BoardStep(dur: 0.7, marks: [BoardMark("m", 66.0, 20.0), BoardMark("b", 66.0, 21.0), BoardMark("p", 70.0, 4.0)]),
            BoardStep(dur: 0.6, marks: [BoardMark("b", 80.0, 5.0), BoardMark("p", 76.0, 4.0)], caption: "Released"),
            BoardStep(dur: 0.6, marks: [BoardMark("p", 84.0, 6.0), BoardMark(ballOn: "p")]),
            BoardStep(dur: 0.7, marks: [BoardMark("b", 88.0, 30.0)], caption: "Cross first time"),
        ]))

    private static let gkSetHandling = PathwayDrill(
        id: "gk-set-handling", name: "Set position & handling ladder", level: .foundation,
        positions: [.gk], outfield: false,
        skills: [.gkHandling, .gkFootwork], needs: [.ball, .wall],
        format: .reps,
        sets: 4, reps: 15, rest: 30,
        blurb: "Throw against a wall, get set before it comes back, and catch it cleanly: W at the head, basket at the chest, scoop on the ground.",
        steps: ["4–6 yards from a wall.", "Throw the ball at the wall, small hop into the set position as it hits.", "High: W catch, thumbs almost touching behind the ball.", "Chest: basket — elbows in, ball into the body.", "Ground: scoop — little fingers together, body behind the ball."],
        points: ["Set as the ball is struck", "Hands lead, eyes on the ball into the hands", "Body behind the ball every time"],
        mistakes: ["Moving at the moment of contact", "Catching with stiff hands", "Ball bouncing off the chest"],
        checks: [.low, .hands, .base],
        video: "goalkeeper handling drill wall w catch basket scoop",
        inspired: "Same handling work as the Keeper iOS app drill library",
        board: BoardScript(setup: BoardSetup(wall: (80.0, 14.0, 80.0, 50.0)), steps: [
            BoardStep(dur: 0.0, marks: [BoardMark("k", 60.0, 32.0), BoardMark("b", 61.0, 32.0)], caption: "Throw at the wall"),
            BoardStep(dur: 0.6, marks: [BoardMark("b", 79.0, 30.0)], caption: "Get set as it hits"),
            BoardStep(dur: 0.6, marks: [BoardMark("b", 61.0, 31.0)], caption: "W catch at head height"),
            BoardStep(dur: 0.6, marks: [BoardMark("b", 79.0, 34.0)]),
            BoardStep(dur: 0.6, marks: [BoardMark("b", 61.0, 33.0)], caption: "Basket into the chest"),
        ]))

    private static let gkCollapse = PathwayDrill(
        id: "gk-collapse", name: "Collapse dives", level: .foundation,
        positions: [.gk], outfield: false,
        skills: [.gkDiving, .gkHandling], needs: [.ball, .partner],
        format: .reps,
        sets: 3, reps: 10, rest: 40,
        blurb: "Kneel or stand, collapse sideways onto the ball: bottom hand behind, top hand on top, land on your side — not your stomach.",
        steps: ["Partner rolls or throws balls a yard to each side.", "Step toward the ball with the near foot, collapse the near leg.", "Bottom hand behind, top hand on top, ball pinned to the ground.", "Land on the side of your hip and shoulder."],
        points: ["Hands get there first", "Land on your side", "Eyes on the ball until it is in"],
        mistakes: ["Landing on your stomach or elbows", "Diving backwards", "Diving before you step"],
        checks: [.hands, .low],
        video: "goalkeeper collapse dive technique drill",
        board: BoardScript(setup: BoardSetup(goal: (x: 4.0, y: 32.0, w: 14.0)), steps: [
            BoardStep(dur: 0.0, marks: [BoardMark("k", 8.0, 32.0), BoardMark("m", 26.0, 32.0), BoardMark("b", 26.0, 32.0)], caption: "Set"),
            BoardStep(dur: 0.6, marks: [BoardMark("b", 8.0, 27.0)], caption: "Ball to your left"),
            BoardStep(dur: 0.4, marks: [BoardMark("k", 8.0, 28.0)], caption: "Collapse — hands first"),
            BoardStep(dur: 0.8, marks: [BoardMark("k", 8.0, 32.0), BoardMark("b", 26.0, 32.0)]),
            BoardStep(dur: 0.6, marks: [BoardMark("b", 8.0, 37.0)], caption: "Other side"),
            BoardStep(dur: 0.4, marks: [BoardMark("k", 8.0, 36.0)]),
        ]))

    private static let gkHighBall = PathwayDrill(
        id: "gk-high-ball", name: "High ball: catch at the highest point", level: .build,
        positions: [.gk], outfield: false,
        skills: [.gkCrosses, .gkHandling], needs: [.ball, .partner, .goal],
        format: .reps,
        sets: 3, reps: 10, rest: 45,
        blurb: "Partner crosses or throws from wide. Call \"Keeper!\", attack the ball with a step and a knee drive, and catch it above your head.",
        steps: ["Start in the middle of the goal, slightly forward.", "Watch the crosser; adjust your position as the ball leaves.", "Call \"Keeper!\" early and loud.", "Take off from one foot, drive the other knee up for protection.", "W catch at the highest point; bring it down to the chest."],
        points: ["Call early", "Take off one foot, knee up", "Catch in front of your head"],
        mistakes: ["Staying on the line", "Two-footed jump", "Catching behind the head"],
        checks: [.hands],
        video: "goalkeeper catching crosses technique high ball drill",
        board: BoardScript(setup: BoardSetup(goal: (x: 4.0, y: 32.0, w: 14.0)), steps: [
            BoardStep(dur: 0.0, marks: [BoardMark("k", 7.0, 32.0), BoardMark("m", 24.0, 8.0), BoardMark("b", 24.0, 8.0)], caption: "Watch the crosser"),
            BoardStep(dur: 0.5, marks: [BoardMark("k", 9.0, 31.0), BoardMark("b", 20.0, 14.0)], caption: "Call \"KEEPER!\""),
            BoardStep(dur: 0.7, marks: [BoardMark("k", 13.0, 30.0), BoardMark("b", 14.0, 29.0)], caption: "Attack it — knee up"),
            BoardStep(dur: 0.3, marks: [BoardMark("b", 13.5, 30.0)], caption: "Catch at the highest point"),
        ]))

    private static let gkDistribution = PathwayDrill(
        id: "gk-distribution", name: "Distribution: pass, side-volley, throw", level: .build,
        positions: [.gk], outfield: false,
        skills: [.gkDistribution, .rangePass], needs: [.ball, .cones, .partner],
        format: .reps,
        sets: 3, reps: 10, rest: 40,
        blurb: "Hit three targets: firm pass into a CB cone, overarm throw to a full back, side-volley to a winger 40+ yards out.",
        steps: ["CB target 15 yards away, full-back target 25 yards wide, winger target 40+ yards.", "Pass: two-touch, both feet, firm and flat.", "Throw: overarm, follow through, land it at the full back’s feet.", "Side-volley: drop the ball, lean away, swing through flat so it travels low and fast."],
        points: ["Pick the target before the catch", "Both feet on passes", "Side-volley stays low — drive, don’t loft"],
        mistakes: ["Only kicking long", "Weak-foot avoidance", "Side-volley ballooning"],
        checks: [.balance],
        video: "goalkeeper distribution side volley technique drill",
        board: BoardScript(setup: BoardSetup(cones: [(22.0, 22.0), (30.0, 56.0), (62.0, 8.0)], goal: (x: 4.0, y: 32.0, w: 14.0)), steps: [
            BoardStep(dur: 0.0, marks: [BoardMark("k", 9.0, 32.0), BoardMark("b", 10.0, 32.0)], caption: "Pass to the CB"),
            BoardStep(dur: 0.7, marks: [BoardMark("b", 22.0, 23.0)]),
            BoardStep(dur: 0.8, marks: [BoardMark("b", 10.0, 32.0)], caption: "Throw to the full back"),
            BoardStep(dur: 0.9, marks: [BoardMark("b", 30.0, 55.0)]),
            BoardStep(dur: 0.8, marks: [BoardMark("b", 10.0, 32.0)], caption: "Side-volley to the winger"),
            BoardStep(dur: 1.0, marks: [BoardMark("b", 62.0, 9.0)]),
        ]))

    private static let gk1v1Block = PathwayDrill(
        id: "gk-1v1-block", name: "1v1 block: spread & K-barrier", level: .elite,
        positions: [.gk], outfield: false,
        skills: [.gk1v1, .gkFootwork], needs: [.ball, .partner, .goal],
        format: .reps,
        sets: 3, reps: 8, rest: 60,
        blurb: "Partner dribbles in. Close the distance while the ball is away from their feet, set when they touch, then spread wide or drop into a K-barrier for close shots.",
        steps: ["Partner starts 25 yards out and dribbles at goal.", "Advance on the heavy touches; set every time they touch the ball.", "Far (6–10 yards): stay big and set.", "Close (2–4 yards): spread — make an X shape — or K-barrier (one knee down, other leg out)."],
        points: ["Move when the ball is away from their foot", "Set when they touch", "Stay big, hands out to the side, not up"],
        mistakes: ["Rushing and getting chipped", "Going down early", "Turning your face away"],
        checks: [.low, .hands, .base],
        video: "goalkeeper 1v1 spread k barrier technique",
        board: BoardScript(setup: BoardSetup(goal: (x: 4.0, y: 32.0, w: 14.0)), steps: [
            BoardStep(dur: 0.0, marks: [BoardMark("k", 7.0, 32.0), BoardMark("m", 52.0, 32.0), BoardMark(ballOn: "m")], caption: "Attacker comes in"),
            BoardStep(dur: 1.0, marks: [BoardMark("m", 36.0, 32.0), BoardMark("b", 33.0, 32.0), BoardMark("k", 12.0, 32.0)], caption: "Heavy touch — close down"),
            BoardStep(dur: 0.4, marks: [BoardMark(ballOn: "m"), BoardMark("m", 32.0, 32.0)], caption: "They touch — SET"),
            BoardStep(dur: 0.7, marks: [BoardMark("m", 22.0, 31.0), BoardMark(ballOn: "m"), BoardMark("k", 15.0, 32.0)], caption: "Close the angle"),
            BoardStep(dur: 0.4, marks: [BoardMark("b", 17.0, 32.0), BoardMark("k", 16.0, 32.0)], caption: "Spread — big X"),
        ]))

    private static let gkAngles = PathwayDrill(
        id: "gk-angles", name: "Angle play: arc steps", level: .foundation,
        positions: [.gk], outfield: false,
        skills: [.gkFootwork], needs: [.cones, .goal],
        format: .reps,
        sets: 3, reps: 10, rest: 30, cue: .numbers,
        blurb: "Five cones in an arc outside the six-yard box are \"shooters\". Shuffle to the line between each cone and the center of goal, then set.",
        steps: ["Lay 5 cones in an arc 16–18 yards out.", "Partner (or the screen) calls a cone.", "Shuffle — feet don’t cross — onto the line between that cone and the middle of the goal.", "Set: feet shoulder-width, weight forward, hands ready."],
        points: ["Shuffle, never cross feet", "Set before the call’s shot", "A step off your line toward the ball cuts the angle"],
        mistakes: ["Standing in the middle of goal regardless of the ball", "Still moving when set should happen"],
        checks: [.low, .base, .hands],
        video: "goalkeeper angle play positioning arc drill",
        board: BoardScript(setup: BoardSetup(cones: [(22.0, 12.0), (26.0, 22.0), (28.0, 32.0), (26.0, 42.0), (22.0, 52.0)], goal: (x: 4.0, y: 32.0, w: 14.0)), steps: [
            BoardStep(dur: 0.0, marks: [BoardMark("k", 8.0, 32.0)], caption: "Cone 1", cue: "1"),
            BoardStep(dur: 0.6, marks: [BoardMark("k", 9.0, 27.0)], caption: "Shuffle onto the line"),
            BoardStep(dur: 0.8, marks: [BoardMark("k", 9.0, 27.0)], caption: "Cone 5", cue: "5"),
            BoardStep(dur: 0.8, marks: [BoardMark("k", 9.0, 37.0)]),
            BoardStep(dur: 0.8, marks: [BoardMark("k", 9.0, 37.0)], caption: "Cone 3", cue: "3"),
            BoardStep(dur: 0.6, marks: [BoardMark("k", 10.0, 32.0)]),
        ]))

    private static let gkReactions = PathwayDrill(
        id: "gk-reactions", name: "Reaction saves off the wall", level: .build,
        positions: [.gk], outfield: false,
        skills: [.gkHandling, .gkDiving], needs: [.ball, .wall],
        format: .time,
        seconds: 180, interval: (work: 30, rest: 15),
        blurb: "Face a wall from 3–4 yards. Throw a tennis ball or size-3 ball against it at angles and react to the rebound — quick hands, small saves.",
        steps: ["Kneel or stand 3–4 yards from a wall.", "Throw at different heights and angles.", "React — hands only first, then add small steps and short dives.", "30 seconds on, 15 off."],
        points: ["Soft hands", "Stay set between throws", "Eyes follow the ball all the way"],
        mistakes: ["Throwing easy balls", "Standing upright between reps"],
        checks: [.hands, .low],
        video: "goalkeeper reaction drill wall tennis ball",
        board: BoardScript(setup: BoardSetup(wall: (80.0, 14.0, 80.0, 50.0)), steps: [
            BoardStep(dur: 0.0, marks: [BoardMark("k", 66.0, 32.0), BoardMark("b", 67.0, 32.0)], caption: "Throw at an angle"),
            BoardStep(dur: 0.4, marks: [BoardMark("b", 79.0, 26.0)]),
            BoardStep(dur: 0.4, marks: [BoardMark("b", 67.0, 37.0), BoardMark("k", 66.0, 36.0)], caption: "React"),
            BoardStep(dur: 0.4, marks: [BoardMark("b", 79.0, 38.0)]),
            BoardStep(dur: 0.4, marks: [BoardMark("b", 67.0, 27.0), BoardMark("k", 66.0, 28.0)]),
        ]))
}
