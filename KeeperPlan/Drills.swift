import Foundation

// The drill library. Nothing here is saved: you pick what to work on today and
// what you have with you, and the app shows every drill that fits.

/// Something to work on today. You can pick more than one.
enum Focus: String, CaseIterable, Codable, Identifiable {
    case diving, handling, shotStopping, distribution, footwork
    case crosses, oneVOne, reactions, positioning, power

    var id: String { rawValue }

    var name: String {
        switch self {
        case .diving: return "Diving"
        case .handling: return "Handling"
        case .shotStopping: return "Shot stopping"
        case .distribution: return "Distribution"
        case .footwork: return "Footwork"
        case .crosses: return "Crosses & high balls"
        case .oneVOne: return "1v1s"
        case .reactions: return "Reactions"
        case .positioning: return "Positioning"
        case .power: return "Power & strength"
        }
    }

    var symbol: String {
        switch self {
        case .diving: return "figure.fall"
        case .handling: return "hand.raised.fill"
        case .shotStopping: return "soccerball"
        case .distribution: return "arrow.up.forward"
        case .footwork: return "figure.run"
        case .crosses: return "arrow.up.to.line"
        case .oneVOne: return "person.line.dotted.person.fill"
        case .reactions: return "bolt.fill"
        case .positioning: return "scope"
        case .power: return "dumbbell.fill"
        }
    }
}

/// Things a drill needs. Drills that need something you don't have are hidden.
enum Need: String, CaseIterable, Codable, Identifiable {
    case outside, goal, partner, wall

    var id: String { rawValue }

    var name: String {
        switch self {
        case .outside: return "Outside"
        case .goal: return "Goal"
        case .partner: return "Partner"
        case .wall: return "Wall"
        }
    }

    var symbol: String {
        switch self {
        case .outside: return "sun.max.fill"
        case .goal: return "sportscourt.fill"
        case .partner: return "person.2.fill"
        case .wall: return "square.grid.3x3.fill"
        }
    }
}

/// What you have with you today.
struct Setup: Codable, Equatable {
    var outside = false
    var goal = false
    var partner = false
    var wall = false

    func has(_ need: Need) -> Bool {
        switch need {
        case .outside: return outside
        case .goal: return goal
        case .partner: return partner
        case .wall: return wall
        }
    }

    mutating func toggle(_ need: Need) {
        switch need {
        case .outside: outside.toggle()
        case .goal: goal.toggle()
        case .partner: partner.toggle()
        case .wall: wall.toggle()
        }
    }
}

struct Drill: Identifiable {
    let id: String
    let focus: Focus
    let name: String
    let needs: Set<Need>
    /// How much to do, e.g. "3 × 8 each side".
    let amount: String
    let minutes: Int
    let summary: String
    let steps: [String]
    var tips: [String] = []
    /// Countdown length in seconds, when the drill is timed.
    var timer: Int? = nil
    /// Which 3D demo to show, if one fits.
    var demo: String? = nil

    func fits(_ setup: Setup) -> Bool { needs.allSatisfy(setup.has) }
}

struct WarmupItem: Identifiable {
    let id: String
    let name: String
    let detail: String
}

enum Library {
    static let warmup = [
        WarmupItem(id: "w1", name: "Jog, high knees, butt kicks", detail: "1 min jog in place, then high knees, then butt kicks"),
        WarmupItem(id: "w2", name: "Leg swings", detail: "10 each way (front-back and side-side), each leg"),
        WarmupItem(id: "w3", name: "Squats and twisting lunges", detail: "10 deep squats, then 10 lunges with a twist"),
        WarmupItem(id: "w4", name: "Ready-position bounces", detail: "30 sec of quick bounces on the balls of your feet"),
    ]

    static let safetyRules = [
        "Warm up every time before you dive or jump.",
        "Sharp pain (not normal muscle soreness): stop and rest.",
        "Rest days matter, especially while still growing. Avoid heavy jumping every day.",
        "No full dives indoors. Practise dive shape onto a mattress or pillows only.",
        "Outside, dive on grass, not concrete or hard, dry ground.",
        "Partner shots: start soft and close, and build up. Wear gloves.",
        "No max lifts or powerlifting-style training.",
    ]

    static func drills(for focus: Focus) -> [Drill] { all.filter { $0.focus == focus } }

    static func drill(_ id: String) -> Drill? { byID[id] }

    private static let byID: [String: Drill] = Dictionary(uniqueKeysWithValues: all.map { ($0.id, $0) })

    static let all: [Drill] = diving + handling + shotStopping + distribution + footwork
        + crosses + oneVOne + reactions + positioning + power

    // MARK: Diving

    private static let diving: [Drill] = [
        Drill(id: "dv-kneel", focus: .diving, name: "Kneeling dive shape", needs: [],
              amount: "8 each side", minutes: 6,
              summary: "Learn the landing from your knees, onto a mattress or soft grass.",
              steps: ["Kneel tall with the ball held out in front.",
                      "Fall sideways, top hand behind the ball, bottom hand underneath.",
                      "Land on the side of your thigh, hip and shoulder. Ball touches the ground first.",
                      "Get up, reset, then do the other side."],
              tips: Tips.forDrill("b7"), demo: "b7"),
        Drill(id: "dv-collapse", focus: .diving, name: "Shuffle to collapse", needs: [],
              amount: "5 each side", minutes: 6,
              summary: "Two shuffles, then collapse onto your side for a low ball.",
              steps: ["Start in your set position.",
                      "Take two shuffles to one side.",
                      "Collapse down onto your side on pillows or grass, hands to the ball.",
                      "Get up fast and go the other way."],
              tips: Tips.forDrill("a4"), demo: "a4"),
        Drill(id: "dv-low", focus: .diving, name: "Low dives from standing", needs: [.outside],
              amount: "6 each side", minutes: 8,
              summary: "A full low dive to a ball placed on the grass beside you.",
              steps: ["Put a ball a big step and a half to your side.",
                      "Start in set position. Step towards the ball with the near foot.",
                      "Push off that foot and dive low, hands leading, to pin the ball to the ground.",
                      "Land on your side, not your stomach. Both sides, every rep."],
              tips: ["Step with the near foot, never the far one. Crossing over makes you slow.",
                     "Get your hands to the ball before your body hits the ground.",
                     "Bottom hand behind the ball, top hand on top: it pins the ball down.",
                     "Start the ball closer. Move it out only when the landing is soft."],
              demo: "dive"),
        Drill(id: "dv-recover", focus: .diving, name: "Dive, recover, dive", needs: [.outside],
              amount: "4 rounds", minutes: 8,
              summary: "Two balls, one each side. Dive to one, get up fast, dive to the other.",
              steps: ["Place a ball on the grass to each side, about 2 m away.",
                      "Dive onto the left ball.",
                      "Get up as fast as you can, back into set position.",
                      "Dive onto the right ball. That's one round. Rest 45 sec."],
              tips: ["Getting up fast matters as much as the dive. Push with your top hand.",
                     "Be in a balanced set position before the second dive, even for a split second.",
                     "Stop the round if the dives get sloppy."],
              demo: "dive"),
        Drill(id: "dv-wall", focus: .diving, name: "Wall rebound dives", needs: [.outside, .wall],
              amount: "6 each side", minutes: 8,
              summary: "Throw the ball at the wall at an angle and dive to catch the rebound.",
              steps: ["Stand about 4 m from the wall.",
                      "Throw the ball at the wall so it comes back wide of you.",
                      "Shuffle once, then dive to catch it.",
                      "Make the angle wider as you get better."],
              tips: ["Throw low at first. Low dives are easier to land.",
                     "Watch the ball off the wall, then move. Don't guess.",
                     "Catch it if you can. Parry it away if you can't."],
              demo: "dive"),
        Drill(id: "dv-partner-knee", focus: .diving, name: "Kneeling saves from a partner", needs: [.partner],
              amount: "10 each side", minutes: 8,
              summary: "Your partner throws to either side while you're on your knees.",
              steps: ["Kneel on a mattress or grass. Partner stands 3-4 m away with a ball.",
                      "They throw low to your side.",
                      "Fall into your dive shape and catch it.",
                      "Partner mixes sides once you're comfortable."],
              tips: ["Partner: underarm throws, soft at first.",
                     "Keep your hands in front of you, ready, before every throw.",
                     "Fall slightly forward, towards the ball, not sideways or back."],
              demo: "b7"),
        Drill(id: "dv-corners", focus: .diving, name: "Corner dives in goal", needs: [.outside, .goal, .partner],
              amount: "3 × 6 shots", minutes: 12,
              summary: "Your partner throws or kicks to the corners, you dive to save.",
              steps: ["Stand on your line in the middle of the goal.",
                      "Partner is 10-12 m out with balls.",
                      "They aim for the bottom corners, then the top corners.",
                      "Save, get up, back to the middle before the next ball."],
              tips: ["Step and dive forward at an angle, towards the post, not along the line.",
                     "Top corners: push off hard and reach with your top hand.",
                     "Can't hold it? Push it wide, around the post. Never back into the middle."],
              demo: "dive"),
        Drill(id: "dv-tip", focus: .diving, name: "Tip over the bar", needs: [.outside, .goal, .partner],
              amount: "8 each side", minutes: 8,
              summary: "Partner lobs balls under the bar. Step, jump and tip them over.",
              steps: ["Start a step off your line.",
                      "Partner lobs a ball high to one side.",
                      "Drop step, jump off one leg and tip the ball over the bar with your top hand.",
                      "Land on your feet, back to the start."],
              tips: ["Use the hand furthest from the goal on far-side balls. It reaches higher.",
                     "Open fingers, palm under the ball, push it up and over.",
                     "Turn your body side-on as you go back."],
              demo: "highcatch"),
    ]

    // MARK: Handling

    private static let handling: [Drill] = [
        Drill(id: "hd-wall", focus: .handling, name: "Wall catches", needs: [.wall],
              amount: "50 catches", minutes: 6,
              summary: "Throw at the wall and catch with clean hands. The basic of basics.",
              steps: ["Stand 2-3 m from the wall with a tennis ball or football.",
                      "Throw at chest height.",
                      "Catch in a \"W\" shape, thumbs behind the ball.",
                      "Count your best run without a drop."],
              tips: Tips.forDrill("b1"), demo: "b1"),
        Drill(id: "hd-weak", focus: .handling, name: "Weak-hand wall catches", needs: [.wall],
              amount: "50 catches", minutes: 6,
              summary: "Same as wall catches, using only your weaker hand.",
              steps: ["Stand a little closer than usual.",
                      "Throw and catch with your weak hand only.",
                      "Soft fingers. Give with the ball."],
              tips: Tips.forDrill("b1w"), demo: "b1w"),
        Drill(id: "hd-juggle", focus: .handling, name: "Two-ball wall juggle", needs: [.wall],
              amount: "Practise until it clicks", minutes: 5,
              summary: "Two tennis balls against the wall, one in each hand.",
              steps: ["Start with one ball until the rhythm is steady.",
                      "Add the second ball.",
                      "Throw one as the other reaches the wall."],
              tips: Tips.forDrill("b5"), timer: 180, demo: "b5"),
        Drill(id: "hd-scoop", focus: .handling, name: "Low-ball pickups", needs: [.wall],
              amount: "15 each side", minutes: 6,
              summary: "Roll the ball hard at the wall and scoop it up behind a long barrier.",
              steps: ["Roll the ball hard at the wall.",
                      "As it comes back, kneel on one leg with your body behind the ball.",
                      "Scoop it up with palms open and hug it to your chest.",
                      "Switch which knee goes down."],
              tips: Tips.forDrill("b6"), demo: "b6"),
        Drill(id: "hd-taps", focus: .handling, name: "Ball taps", needs: [],
              amount: "3 × 30 sec", minutes: 4,
              summary: "Tap the ball quickly between your fingertips to build soft, strong hands.",
              steps: ["Hold a football above your head, arms almost straight.",
                      "Tap it fast between your two hands with fingertips only.",
                      "Move it down to chest height, then to your waist, without stopping."],
              tips: ["Fingertips, not palms. Your palms should never touch the ball.",
                     "Fast and small. The ball should barely move between your hands.",
                     "Watch the ball the whole time."],
              timer: 30),
        Drill(id: "hd-selffeed", focus: .handling, name: "Self-feed catches", needs: [],
              amount: "30 catches", minutes: 5,
              summary: "Throw the ball up and catch it at different heights. Works anywhere.",
              steps: ["Throw the ball up in front of you.",
                      "Catch it at the highest point with your hands in a \"W\".",
                      "Mix it up: catch at chest height, then let it drop and scoop it from your knees."],
              tips: ["Arms out in front. Catch where you can see the ball and your hands.",
                     "Bring every catch into your chest so it's safe.",
                     "Inside? Keep it low so you don't hit the ceiling."]),
        Drill(id: "hd-partner", focus: .handling, name: "Partner throws: head, chest, feet", needs: [.partner],
              amount: "3 × 10", minutes: 8,
              summary: "Your partner throws at different heights. Pick the right catch for each.",
              steps: ["Partner stands 5 m away.",
                      "They throw at your head, then chest, then feet, in any order.",
                      "Head: \"W\" catch. Chest: hug it in. Feet: scoop it up.",
                      "Switch roles if they want a turn."],
              tips: ["Get your body behind the ball every time. Hands are the first barrier, body is the second.",
                     "Move your feet to get in line, don't just reach.",
                     "Partner: throw harder only once every catch is clean."]),
        Drill(id: "hd-volleys", focus: .handling, name: "Volleys from close range", needs: [.outside, .partner],
              amount: "20 catches", minutes: 8,
              summary: "Your partner volleys the ball at you from their hands.",
              steps: ["Partner stands 8-10 m away with balls.",
                      "They drop the ball and volley it at you.",
                      "Catch it and throw it back."],
              tips: ["Set your feet just before they strike the ball.",
                     "Hard shot at your chest? Let your body give a little to soak it up.",
                     "Partner: aim at the keeper first, then just to the side."]),
    ]

    // MARK: Shot stopping

    private static let shotStopping: [Drill] = [
        Drill(id: "ss-set", focus: .shotStopping, name: "Set position on the clap", needs: [],
              amount: "3 × 30 sec", minutes: 4,
              summary: "Move, then snap into a balanced set position, as a striker would shoot.",
              steps: ["Shuffle side to side, or jog on the spot.",
                      "Every few seconds, clap (or have the timer beep) and freeze in set position.",
                      "Feet shoulder-width apart, weight forward, hands out ready."],
              tips: Tips.forDrill("a3"), timer: 30, demo: "a3"),
        Drill(id: "ss-wallset", focus: .shotStopping, name: "Set and catch at the wall", needs: [.wall],
              amount: "30 catches", minutes: 6,
              summary: "Throw, hop into set position, catch the rebound.",
              steps: ["Throw hard at the wall.",
                      "Small hop so you land in set just before the ball arrives.",
                      "Catch it."],
              tips: Tips.forDrill("b2"), demo: "b2"),
        Drill(id: "ss-turn", focus: .shotStopping, name: "Turn and save", needs: [.wall],
              amount: "20 catches", minutes: 6,
              summary: "Face away from the wall, throw over your shoulder, turn and catch.",
              steps: ["Stand facing away from the wall.",
                      "Throw the ball over your shoulder at the wall.",
                      "Turn on the bounce and catch it."],
              tips: Tips.forDrill("b3"), demo: "b3"),
        Drill(id: "ss-kickwall", focus: .shotStopping, name: "Kick it, save it", needs: [.outside, .wall],
              amount: "20 shots", minutes: 8,
              summary: "Kick the ball at the wall yourself and save what comes back.",
              steps: ["Stand 6-8 m from the wall.",
                      "Kick the ball firmly at the wall.",
                      "Get set quickly and save the rebound.",
                      "Kick at different heights so you get different saves."],
              tips: ["Don't watch your kick. Get set right away.",
                     "Low rebounds: get your body behind the ball.",
                     "Move closer to make it faster."],
              demo: "kick"),
        Drill(id: "ss-angles", focus: .shotStopping, name: "Partner shots without a goal", needs: [.outside, .partner],
              amount: "3 × 8 shots", minutes: 10,
              summary: "Make a goal with two bags or cones. Your partner shoots from different spots.",
              steps: ["Put two bags about 5 big steps apart as posts.",
                      "Partner shoots from 10-12 m, moving to a new spot each time.",
                      "Get set before every shot and save."],
              tips: ["Reset your position for every new spot. Stand on the line between the ball and the middle of the goal.",
                     "Stay big and still as they strike the ball.",
                     "Partner: placement over power at first."]),
        Drill(id: "ss-box", focus: .shotStopping, name: "Shots from the edge of the box", needs: [.outside, .goal, .partner],
              amount: "3 × 8 shots", minutes: 12,
              summary: "Real shots on a real goal from 16-18 m.",
              steps: ["Partner lines up balls on the edge of the box.",
                      "They shoot one at a time. You save and get back up.",
                      "Short rest between sets."],
              tips: ["Small step forward as they shoot, then set. Never moving as the ball is struck.",
                     "Hold what you can. Push hard shots wide, out of danger.",
                     "Talk to yourself: set, watch, save."]),
        Drill(id: "ss-rapid", focus: .shotStopping, name: "Rapid fire", needs: [.outside, .goal, .partner],
              amount: "4 rounds of 5", minutes: 10,
              summary: "Five shots in a row, one after the other. Get up and get set fast.",
              steps: ["Partner has 5 balls in a line about 10 m out.",
                      "They shoot as soon as you're back up and set.",
                      "Five shots, then rest 60 sec."],
              tips: ["Getting back to your feet quickly is the whole drill.",
                     "Be set for every shot, even if it's only for a split second.",
                     "Partner: wait until the keeper is up. Don't shoot at someone on the floor."]),
        Drill(id: "ss-rebound", focus: .shotStopping, name: "Save and second save", needs: [.outside, .goal, .partner],
              amount: "10 rounds", minutes: 10,
              summary: "Partner shoots, then follows in for the rebound.",
              steps: ["Partner shoots from 12 m.",
                      "If you can't hold it, push it wide.",
                      "They chase the rebound and shoot again. Get up and save it."],
              tips: ["Parry to the side, away from the middle of the goal.",
                     "Watch where the ball goes as you get up.",
                     "Get up towards the ball, not away from it."]),
    ]

    // MARK: Distribution

    private static let distribution: [Drill] = [
        Drill(id: "ds-roll", focus: .distribution, name: "Roll to a target", needs: [],
              amount: "20 rolls", minutes: 5,
              summary: "Bowl the ball underarm along the ground to hit a target.",
              steps: ["Put a shoe or bottle 5-8 m away.",
                      "Step forward and get low, like bowling.",
                      "Roll the ball along the ground and hit the target.",
                      "Move it further away after 5 hits."],
              tips: ["Release the ball on the ground, not dropped from your waist. No bounce.",
                     "Follow through with your hand pointing at the target.",
                     "A firm, flat roll is easy for a teammate to control."],
              demo: "roll"),
        Drill(id: "ds-throw-wall", focus: .distribution, name: "Overarm throws at a wall target", needs: [.outside, .wall],
              amount: "20 throws", minutes: 6,
              summary: "Pick a spot on the wall and hit it with an overarm throw.",
              steps: ["Pick a spot on the wall, about head height.",
                      "Start 10 m away.",
                      "Throw overarm, like a bowler in cricket, straight arm over the top.",
                      "Step back after every 5 good hits."],
              tips: ["Point your other arm at the target, then pull it down as you throw.",
                     "Step forward with the foot opposite your throwing arm.",
                     "Let the ball roll off your fingers so it doesn't spin sideways."],
              demo: "throw"),
        Drill(id: "ds-throw-partner", focus: .distribution, name: "Throws to a partner", needs: [.outside, .partner],
              amount: "20 throws", minutes: 8,
              summary: "Roll, side-arm and overarm throws to a moving partner.",
              steps: ["Partner jogs to different spots 10-25 m away.",
                      "Short: roll it. Medium: side-arm throw. Long: overarm.",
                      "Aim for their feet, or just in front of them if they're running."],
              tips: ["Throw it fast. A quick throw starts an attack before the other team is ready.",
                     "Low and flat is easier to control than high and loopy.",
                     "Lead a moving player: aim where they're going, not where they are."],
              demo: "throw"),
        Drill(id: "ds-volley-wall", focus: .distribution, name: "Half-volleys at the wall", needs: [.outside, .wall],
              amount: "20 kicks", minutes: 8,
              summary: "Drop the ball from your hands and strike it into the wall.",
              steps: ["Stand 10-15 m from the wall.",
                      "Hold the ball out in front and drop it.",
                      "Kick it just as it hits the ground (half-volley), or before (volley).",
                      "Aim for the same spot every time."],
              tips: ["Drop the ball, don't throw it up. A steady drop makes a steady kick.",
                     "Strike with your laces, toe pointed down.",
                     "Keep your head down and over the ball as you kick."],
              demo: "kick"),
        Drill(id: "ds-passwall", focus: .distribution, name: "Two-touch passing off the wall", needs: [.wall],
              amount: "3 × 1 min", minutes: 5,
              summary: "Pass, control, pass. Both feet. Like playing out from the back.",
              steps: ["Stand 3-5 m from the wall.",
                      "Pass with your right foot, control the rebound, pass with your left.",
                      "Keep going for a minute without a mistake."],
              tips: ["Inside of the foot, ankle locked.",
                     "First touch goes slightly to the side, out of your feet, ready to pass.",
                     "Your weaker foot needs this more. Use it every other pass."],
              timer: 60, demo: "kick"),
        Drill(id: "ds-punt", focus: .distribution, name: "Kicks for distance", needs: [.outside],
              amount: "15 kicks", minutes: 10,
              summary: "Volleys and goal kicks on your own. Kick, chase, kick back.",
              steps: ["Kick the ball out of your hands as far as you can.",
                      "Jog to it, place it and take a goal kick back.",
                      "Mark your best distance with a shoe and try to beat it."],
              tips: ["Distance comes from a clean strike, not swinging harder.",
                     "Goal kicks: plant your standing foot beside the ball and lean back a little to lift it.",
                     "A flatter, lower kick reaches a teammate faster."],
              demo: "kick"),
        Drill(id: "ds-longpartner", focus: .distribution, name: "Long kicks to a partner", needs: [.outside, .partner],
              amount: "20 kicks", minutes: 10,
              summary: "Goal kicks and volleys to a partner 25-40 m away.",
              steps: ["Partner stands 25 m away.",
                      "Alternate goal kicks and kicks from your hands.",
                      "They move further back after 3 good kicks in a row."],
              tips: ["Pick a target: their chest. Close is good; on target is better.",
                     "Kick through the middle of the ball for a straight flight.",
                     "Partner: give a thumbs up for each one you could control."],
              demo: "kick"),
        Drill(id: "ds-backpass", focus: .distribution, name: "Back-pass under pressure", needs: [.outside, .partner],
              amount: "15 passes", minutes: 8,
              summary: "Partner passes back to you and chases. Clear it or pass it before they get there.",
              steps: ["Make a small gate with two bags 20 m away.",
                      "Partner passes to you, then runs at you.",
                      "Take one touch and pass through the gate, or kick it long if they're close."],
              tips: ["Check over your shoulder before the ball arrives.",
                     "First touch away from the runner.",
                     "When in doubt, kick it out. Safe beats fancy."]),
        Drill(id: "ds-zone", focus: .distribution, name: "Hit the zone", needs: [.outside, .goal],
              amount: "15 goal kicks", minutes: 10,
              summary: "Goal kicks from the 6-yard box into a target area.",
              steps: ["Place two bags 30-40 m out, about 10 m apart.",
                      "Take goal kicks from the 6-yard line.",
                      "Count how many land between the bags."],
              tips: ["Same run-up every time: two or three steps from an angle.",
                     "Arms out for balance as you strike.",
                     "Keep score and try to beat it next time."],
              demo: "kick"),
    ]

    // MARK: Footwork

    private static let footwork: [Drill] = [
        Drill(id: "fw-ladder", focus: .footwork, name: "Tape ladder quick feet", needs: [],
              amount: "3 × 3 passes", minutes: 5,
              summary: "Two feet in each box, forward then back. Tape on the floor works.",
              steps: ["Lay out a ladder with tape, chalk or sticks.",
                      "Two feet in each box, as fast as you can while staying clean.",
                      "Forward, then back. Rest 30 sec between sets."],
              tips: Tips.forDrill("a1"), demo: "a1"),
        Drill(id: "fw-inout", focus: .footwork, name: "Ladder in-in-out-out", needs: [],
              amount: "3 passes each way", minutes: 5,
              summary: "Sideways along the ladder, feet in and out of each box.",
              steps: ["Face the side of the ladder.",
                      "In, in, out, out, moving one box each time.",
                      "Both directions."],
              tips: Tips.forDrill("a2"), demo: "a2"),
        Drill(id: "fw-shuffle", focus: .footwork, name: "Set-position shuffles", needs: [],
              amount: "3 × 30 sec", minutes: 4,
              summary: "Three steps left, set. Three steps right, set. Never cross your feet.",
              steps: ["Start in your set position.",
                      "Shuffle three steps to one side and stop in set.",
                      "Shuffle back. Keep going until the timer ends."],
              tips: Tips.forDrill("a3"), timer: 30, demo: "a3"),
        Drill(id: "fw-dropstep", focus: .footwork, name: "Drop step and recover", needs: [],
              amount: "6 each side", minutes: 4,
              summary: "The first step back for a ball going over your head.",
              steps: ["Start in your set position.",
                      "Drop step back at 45 degrees.",
                      "Push back to your start spot and set."],
              tips: Tips.forDrill("a5"), demo: "a5"),
        Drill(id: "fw-hops", focus: .footwork, name: "Line hops", needs: [],
              amount: "3 × 20 sec", minutes: 3,
              summary: "Two-foot hops side to side over a line.",
              steps: ["Stand beside a line.",
                      "Hop over it and back with both feet together.",
                      "Quick and quiet until the timer ends."],
              tips: Tips.forDrill("a6"), timer: 20, demo: "a6"),
        Drill(id: "fw-posts", focus: .footwork, name: "Post to post", needs: [.goal],
              amount: "5 lengths", minutes: 5,
              summary: "Shuffle across the goal, touch the post, set, shuffle back.",
              steps: ["Start at one post, facing out.",
                      "Shuffle across your line to the other post.",
                      "Touch it, set, and shuffle back. That's one length."],
              tips: ["Stay a step off the line, not on it.",
                     "Look out at the pitch, not at your feet.",
                     "Near the post, take one small step and set, as if a shot is coming."],
              demo: "a3"),
        Drill(id: "fw-mirror", focus: .footwork, name: "Mirror your partner", needs: [.partner],
              amount: "4 × 20 sec", minutes: 4,
              summary: "Your partner moves side to side, you copy them in your set position.",
              steps: ["Stand facing your partner, 3 m apart.",
                      "They shuffle, stop and change direction.",
                      "Stay opposite them the whole time. Swap after each set."],
              tips: ["React, don't guess.",
                     "Keep your feet apart. Shuffle, never cross.",
                     "Partner: fake a move now and then."],
              timer: 20, demo: "a3"),
        Drill(id: "fw-sprint", focus: .footwork, name: "Sprint out and set", needs: [.outside],
              amount: "8 sprints", minutes: 6,
              summary: "Sprint out 5 m, then slow down fast into a set position.",
              steps: ["Start on a line.",
                      "Sprint 5 m forward.",
                      "Take short, quick steps to slow down and land in set.",
                      "Walk back. Go again."],
              tips: ["The stop is the drill. Short steps, sink your hips.",
                     "Arms up and ready as you set.",
                     "This is how you close down a striker."]),
    ]

    // MARK: Crosses and high balls

    private static let crosses: [Drill] = [
        Drill(id: "cr-footwork", focus: .crosses, name: "High-ball footwork", needs: [],
              amount: "8 each side", minutes: 5,
              summary: "Shadow the movement: drop step, cross-over, jump with your knee up.",
              steps: ["Start in set position.",
                      "Drop step back, one cross-over step.",
                      "Jump off one leg, drive the other knee up, reach both hands high.",
                      "Land and reset."],
              tips: ["Drive the knee on the side the ball is coming from. It protects you.",
                     "Arms reach up early, not at the last second.",
                     "Inside? Do the steps and a small jump. Save the full jumps for outside."],
              demo: "a5"),
        Drill(id: "cr-selffeed", focus: .crosses, name: "Throw high and catch", needs: [.outside],
              amount: "20 catches", minutes: 6,
              summary: "Throw the ball high in front of you and catch it at the top of your jump.",
              steps: ["Throw the ball high and slightly in front of you.",
                      "Take two steps, jump off one leg with the other knee up.",
                      "Catch it at the highest point, in front of your head.",
                      "Bring it straight down to your chest as you land."],
              tips: ["Catch it in front of your head, where you can see it.",
                     "Hands in the \"W\" shape, thumbs nearly touching.",
                     "Shout \"Keeper!\" every time. Make it a habit."],
              demo: "highcatch"),
        Drill(id: "cr-wall", focus: .crosses, name: "High catches off a wall", needs: [.outside, .wall],
              amount: "20 catches", minutes: 6,
              summary: "Throw high onto the wall and catch the ball at the top of your jump.",
              steps: ["Stand 4-5 m from the wall.",
                      "Throw up high so the ball loops back over you.",
                      "Step, jump and catch at your highest point."],
              tips: ["Time it. Leave late and jump up, don't jump early and wait.",
                     "Knee up, hands up, eyes on the ball."],
              demo: "highcatch"),
        Drill(id: "cr-lobs", focus: .crosses, name: "Partner lobs", needs: [.outside, .partner],
              amount: "20 catches", minutes: 8,
              summary: "Your partner lobs the ball over and around you. Go and claim it.",
              steps: ["Partner stands 10 m away and lobs the ball high.",
                      "Move your feet to get under it.",
                      "Jump and catch at the top. Shout \"Keeper!\""],
              tips: ["Move first, jump last.",
                     "Behind you? Drop step, don't backpedal.",
                     "Partner: lob to different spots."],
              demo: "highcatch"),
        Drill(id: "cr-punch", focus: .crosses, name: "Punching clear", needs: [.outside, .partner],
              amount: "10 one-fist, 10 two-fist", minutes: 8,
              summary: "Partner lobs. You punch it high, far and wide.",
              steps: ["Partner lobs the ball to you from 8 m.",
                      "Two fists together, flat, for balls coming straight at you.",
                      "One fist for balls that go across you: punch it on in the same direction."],
              tips: ["Punch through the bottom half of the ball to send it up and away.",
                     "Short, powerful punch. Not a big swing.",
                     "Height, distance, width. In that order."]),
        Drill(id: "cr-crosses", focus: .crosses, name: "Crosses into the box", needs: [.outside, .goal, .partner],
              amount: "15 crosses", minutes: 12,
              summary: "Partner crosses from the wing. Come off your line and claim it.",
              steps: ["Start near the near post.",
                      "Partner crosses from wide, 25-30 m out.",
                      "Decide early: come and catch, or stay. Shout your call.",
                      "Switch the wing after 5."],
              tips: ["Stand a bit open so you can see the crosser and the box.",
                     "Once you go, go all the way.",
                     "Catch it at the highest point. Punch it if you can't hold it."]),
    ]

    // MARK: 1v1s

    private static let oneVOne: [Drill] = [
        Drill(id: "ov-shape", focus: .oneVOne, name: "Block shape", needs: [],
              amount: "10 reps", minutes: 4,
              summary: "Practise the spread and K-block shapes for close-range shots.",
              steps: ["Start in set position.",
                      "Spread: drop low, legs wide, arms wide and low, hands open.",
                      "K-block: one knee down, other leg out to the side, arms out.",
                      "Alternate between them."],
              tips: ["Make yourself as wide as possible, close to the ground.",
                     "Hands low and wide. Most 1v1 shots go low.",
                     "Eyes on the ball, not the striker's face."],
              demo: "block"),
        Drill(id: "ov-smother", focus: .oneVOne, name: "Smother at the feet", needs: [.partner],
              amount: "8 each side", minutes: 6,
              summary: "Partner dribbles slowly at you. Get down side-on and smother the ball.",
              steps: ["Partner dribbles at walking speed.",
                      "When the ball is away from their foot, go down side-on.",
                      "Hands to the ball, body behind it. Hold it tight."],
              tips: ["Go when the ball leaves their foot, not when it's on it.",
                     "Hands first, head protected behind your arms.",
                     "On a mattress or grass only. Partner: stop when the keeper goes down."],
              demo: "a4"),
        Drill(id: "ov-close", focus: .oneVOne, name: "Close down and set", needs: [.outside],
              amount: "10 reps", minutes: 6,
              summary: "Sprint at an imaginary striker, slow down and set at the right moment.",
              steps: ["Place a ball 12 m away as the striker.",
                      "Sprint towards it.",
                      "About 3 m away, slow down with short steps and set low and wide.",
                      "Walk back. Go again."],
              tips: ["Fast at the start, slow and set at the end.",
                     "Never run at full speed into a striker. They'll go round you.",
                     "Set before they can shoot."]),
        Drill(id: "ov-partner", focus: .oneVOne, name: "1v1 against a partner", needs: [.outside, .partner],
              amount: "10 attempts", minutes: 10,
              summary: "Partner dribbles at a small goal of bags. Stop them scoring.",
              steps: ["Make a goal with two bags 4 m apart.",
                      "Partner starts 20 m out and dribbles in to score.",
                      "Come out, close the angle, stay big and make the save or block."],
              tips: ["Close the gap when the ball is away from their foot.",
                     "Stay on your feet as long as you can. Make them decide.",
                     "Partner: no shots from distance. Get close and try to beat the keeper."]),
        Drill(id: "ov-goal", focus: .oneVOne, name: "Breakaways on goal", needs: [.outside, .goal, .partner],
              amount: "10 attempts", minutes: 12,
              summary: "Partner runs through from halfway. Come and meet them.",
              steps: ["Partner starts 30 m out with the ball.",
                      "They dribble in and try to score.",
                      "Come off your line, close the angle and set before they shoot."],
              tips: ["Keep in line with the ball and the middle of the goal as you come out.",
                     "Big touch from them? Go and win the ball.",
                     "Low shots: spread or K-block. Chip: drop step and get back."]),
    ]

    // MARK: Reactions

    private static let reactions: [Drill] = [
        Drill(id: "rx-ball", focus: .reactions, name: "Reaction ball", needs: [.wall],
              amount: "3 × 1 min", minutes: 5,
              summary: "A reaction ball, or a tennis ball into the wall-floor corner. Catch the odd bounce.",
              steps: ["Throw the ball into the corner where the floor meets the wall.",
                      "React to the bounce and catch it.",
                      "Keep going for the full minute."],
              tips: Tips.forDrill("b4"), timer: 60, demo: "b4"),
        Drill(id: "rx-close", focus: .reactions, name: "Close-range wall catches", needs: [.wall],
              amount: "3 × 30 sec", minutes: 4,
              summary: "Tennis ball, 1.5 m from the wall. As fast as you can.",
              steps: ["Stand very close to the wall.",
                      "Throw and catch as fast as you can, one hand then the other.",
                      "Count your catches in 30 sec and try to beat it."],
              tips: ["Soft hands are faster than stiff hands.",
                     "Keep your elbows bent and hands up.",
                     "Drop it? Pick up and keep counting."],
              timer: 30, demo: "b1"),
        Drill(id: "rx-palm", focus: .reactions, name: "Palm drop catch", needs: [],
              amount: "20 each hand", minutes: 4,
              summary: "Drop a ball from one hand and snatch it with the other before it hits the floor.",
              steps: ["Hold a tennis ball at shoulder height, palm down.",
                      "Drop it and catch it with the same hand before it falls past your waist.",
                      "Then try: drop it with one hand, catch with the other."],
              tips: ["Relaxed hand, ready to snap shut.",
                     "Watch the ball, not your hand.",
                     "Getting easy? Hold it lower so you have less time."]),
        Drill(id: "rx-drop", focus: .reactions, name: "Ball drop", needs: [.partner],
              amount: "15 drops", minutes: 5,
              summary: "Partner holds two balls out wide and drops one. Catch it before the second bounce.",
              steps: ["Partner stands 2-3 m away, a tennis ball in each outstretched hand.",
                      "You stand in set position.",
                      "They drop one. Explode to it and catch it."],
              tips: ["Push off the foot on the far side.",
                     "First step quick and low.",
                     "Partner: move further back as they get quicker."]),
        Drill(id: "rx-turn", focus: .reactions, name: "Turn on the call", needs: [.partner],
              amount: "15 catches", minutes: 6,
              summary: "Face away from your partner. Turn when they shout and catch the throw.",
              steps: ["Stand with your back to your partner, 5 m away.",
                      "They shout \"Turn!\" and throw.",
                      "Turn, find the ball and catch it."],
              tips: ["Turn your head first, then your body.",
                     "Hands up as you turn.",
                     "Partner: throw just as they turn, not before."]),
        Drill(id: "rx-deflect", focus: .reactions, name: "Deflected shots", needs: [.outside, .goal, .partner],
              amount: "15 shots", minutes: 10,
              summary: "Put a bag or bench in front of the goal. Partner shoots through it for deflections.",
              steps: ["Place a bag or cones 3-4 m in front of goal.",
                      "Partner shoots low through them.",
                      "React to the deflection and save."],
              tips: ["Stay set and stay on your feet as long as you can.",
                     "Watch the ball all the way, not the striker.",
                     "Hands low. Deflections often skid."]),
    ]

    // MARK: Positioning

    private static let positioning: [Drill] = [
        Drill(id: "ps-tape", focus: .positioning, name: "Angle lines on the floor", needs: [],
              amount: "10 positions", minutes: 6,
              summary: "Mark two posts on the floor and practise finding the right spot for every angle.",
              steps: ["Put two shoes 2-3 m apart as posts.",
                      "Put a ball in front at different angles.",
                      "Stand on the line between the ball and the middle of your goal.",
                      "Check: you should cut off the same gap on each side."],
              tips: ["Imagine a line from the ball to the middle of the goal. Stand on it.",
                     "Closer to the ball means less goal to cover, but chips get easier.",
                     "Look back at your posts to check, then look at the ball."]),
        Drill(id: "ps-arc", focus: .positioning, name: "Walk the arc", needs: [.goal],
              amount: "3 laps", minutes: 6,
              summary: "Shuffle in an arc in front of goal, setting at each spot.",
              steps: ["Imagine an arc from post to post, about 2 m out.",
                      "Shuffle along it.",
                      "Stop and set at 5 spots, then come back."],
              tips: ["Near post: stay close to it. Far post: step back a little.",
                     "Touch a post now and then to know where you are without looking."]),
        Drill(id: "ps-angles", focus: .positioning, name: "Ball around the box", needs: [.outside, .goal],
              amount: "8 positions", minutes: 8,
              summary: "Place balls around the box. Go to the right spot for each one.",
              steps: ["Place 8 balls in an arc 12-18 m out.",
                      "For each one, move to your spot and set.",
                      "Look back at the posts to check you're in the middle of the angle."],
              tips: ["Line from the ball to the centre of the goal. Get on it.",
                     "Wider balls: closer to the near post.",
                     "Do it fast. In a game you only get a second."]),
        Drill(id: "ps-partner", focus: .positioning, name: "Move with the ball, then save", needs: [.outside, .goal, .partner],
              amount: "12 shots", minutes: 10,
              summary: "Partner dribbles around the box. You keep adjusting, then they shoot.",
              steps: ["Partner dribbles across the edge of the box.",
                      "You shuffle to stay on the right angle.",
                      "They shoot at any moment. Be set and save."],
              tips: ["Small adjusting steps. Big steps leave you off balance.",
                     "Set as their foot goes back to shoot.",
                     "Partner: shoot early sometimes to catch them moving."]),
        Drill(id: "ps-bags", focus: .positioning, name: "Angles with bag posts", needs: [.outside, .partner],
              amount: "12 shots", minutes: 8,
              summary: "No goal needed. Two bags as posts, partner shoots from different angles.",
              steps: ["Put two bags 5 big steps apart.",
                      "Partner moves to a new spot for each shot.",
                      "Get on the right angle, set, save."],
              tips: ["Check your spot before every shot.",
                     "Partner: shoot from tight angles too."]),
    ]

    // MARK: Power and strength

    private static let power: [Drill] = [
        Drill(id: "pw-squatjump", focus: .power, name: "Squat jumps", needs: [],
              amount: "3 × 6", minutes: 5,
              summary: "Explosive jumps for a stronger push-off when you dive.",
              steps: ["Sit back into a squat.", "Swing your arms and jump straight up.",
                      "Land softly. Rest 60-90 sec between sets."],
              tips: Tips.forDrill("c1"), demo: "c1"),
        Drill(id: "pw-skater", focus: .power, name: "Skater bounds", needs: [],
              amount: "3 × 6 each side", minutes: 6,
              summary: "Leap sideways onto one leg and hold. Same push as a dive.",
              steps: ["Stand on one leg.", "Leap sideways onto the other leg.", "Hold the landing for 1 sec, then go back."],
              tips: Tips.forDrill("c2"), demo: "c2"),
        Drill(id: "pw-split", focus: .power, name: "Split-squat jumps", needs: [],
              amount: "3 × 5 each leg", minutes: 5,
              summary: "Jump and switch legs in the air.",
              steps: ["Start in a lunge.", "Jump and switch legs in the air.", "Land softly in a lunge on the other side."],
              tips: Tips.forDrill("c3"), demo: "c3"),
        Drill(id: "pw-tuck", focus: .power, name: "Tuck jumps", needs: [],
              amount: "2 × 5", minutes: 4,
              summary: "Jump high and pull your knees to your chest. Hard, so do them last.",
              steps: ["Jump straight up.", "Pull your knees up to your chest.", "Land softly and reset each time."],
              tips: Tips.forDrill("c4"), demo: "c4"),
        Drill(id: "pw-goblet", focus: .power, name: "Goblet squat", needs: [],
              amount: "3 × 10", minutes: 6,
              summary: "Leg strength. A dumbbell, a full backpack or no weight at all.",
              steps: ["Hold the weight at your chest.", "Sit down between your heels.", "Stand up, pushing the floor away."],
              tips: Tips.forDrill("s1"), demo: "s1"),
        Drill(id: "pw-bulgarian", focus: .power, name: "Bulgarian split squat", needs: [],
              amount: "3 × 8 each leg", minutes: 8,
              summary: "One-leg strength with your back foot on a bed or bench.",
              steps: ["Back foot on the bed or bench.", "Lower straight down on the front leg.", "Push back up."],
              tips: Tips.forDrill("s2"), demo: "s2"),
        Drill(id: "pw-pushup", focus: .power, name: "Push-ups", needs: [],
              amount: "3 × max good reps", minutes: 5,
              summary: "Upper-body strength for getting up fast and pushing shots away.",
              steps: ["Hands just wider than your shoulders.", "Lower your chest to just above the floor.", "Push back up. Stop when the form breaks."],
              tips: Tips.forDrill("s4"), demo: "s4"),
        Drill(id: "pw-sideplank", focus: .power, name: "Side plank", needs: [],
              amount: "3 × 30 sec each side", minutes: 5,
              summary: "Core strength for strong, stable dives.",
              steps: ["Elbow under your shoulder.", "Lift your hips into a straight line.", "Hold, then switch sides."],
              tips: Tips.forDrill("s6"), timer: 30, demo: "s6"),
        Drill(id: "pw-deadbug", focus: .power, name: "Dead bugs", needs: [],
              amount: "3 × 10", minutes: 4,
              summary: "Core control, lying on your back.",
              steps: ["Lie on your back, arms up, knees over hips.", "Lower the opposite arm and leg slowly.", "Bring them back and switch."],
              tips: Tips.forDrill("s7"), demo: "s7"),
    ]
}
