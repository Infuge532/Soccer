import Foundation

/// Who is training and where they want to get to.
struct PlayerProfile: Codable, Equatable {
    var name = ""
    var email = ""
    var phone = ""
    var age = "U15"
    var foot = "Right"
    /// Spot codes from `Spot.all`, e.g. "RCM".
    var primary = ""
    var secondary = ""
    var third = ""
    var current: Level = .npl
    /// Free text, e.g. "N1" or "U15 Red".
    var team = ""
    var goal: Level = .mlsa
    var region = "East"
    /// Up to three skills the daily plan builds around. Empty = the position's top three.
    var focus: [Skill] = []

    var mainPosition: Position { Spot.find(primary)?.position ?? .cm }
    var secondPosition: Position? { Spot.find(secondary)?.position }
    var firstName: String { name.split(separator: " ").first.map(String.init) ?? name }
    var focusSkills: [Skill] { focus.isEmpty ? Array(mainPosition.info.coreSkills.prefix(3)) : focus }
}

/// One finished Pathway session.
struct PathwaySession: Codable, Identifiable {
    var id = UUID()
    var drillID: String
    var date = Date()
    var seconds: Int
    var reps: Int
    var completed: Bool
    var camera: Bool
    var flags: Int
}

struct PlanItem: Identifiable {
    let drill: PathwayDrill
    let role: String
    var id: String { drill.id }
}

extension Store {
    var profile: PlayerProfile? { data.profile }

    func saveProfile(_ profile: PlayerProfile) { data.profile = profile }

    var pathwaySessions: [PathwaySession] { data.pathwaySessions ?? [] }

    func addPathwaySession(_ session: PathwaySession) {
        var list = data.pathwaySessions ?? []
        list.insert(session, at: 0)
        data.pathwaySessions = Array(list.prefix(300))
    }

    func pathwayDoneToday(_ drillID: String) -> Bool {
        let cal = Calendar.current
        return pathwaySessions.contains { $0.drillID == drillID && $0.completed && cal.isDateInToday($0.date) }
    }

    var pathwayStreak: Int {
        let cal = Calendar.current
        let days = Set(pathwaySessions.filter(\.completed).map { cal.startOfDay(for: $0.date) })
        var day = cal.startOfDay(for: Date())
        if !days.contains(day) { day = cal.date(byAdding: .day, value: -1, to: day) ?? day }
        var count = 0
        while days.contains(day) {
            count += 1
            day = cal.date(byAdding: .day, value: -1, to: day) ?? day
        }
        return count
    }

    /// Today's suggestion: warm-up, two focus blocks, one for the second
    /// position, and a finisher. It rotates daily and is only a suggestion —
    /// the player can always pick something else.
    func todaysPlan(for p: PlayerProfile) -> [PlanItem] {
        let seed = Int(Date().timeIntervalSince1970 / 86_400)
        let main = p.mainPosition
        var used = Set<String>()
        func pick(_ list: [PathwayDrill]) -> PathwayDrill? {
            let free = list.filter { !used.contains($0.id) }
            guard !free.isEmpty else { return nil }
            let d = free[seed % free.count]
            used.insert(d.id)
            return d
        }
        let mine = PathwayLibrary.drills(for: main)
        var plan: [PlanItem] = []

        let warm = main == .gk ? [PathwayLibrary.drill("gk-set-handling")].compactMap { $0 }
            : PathwayLibrary.all.filter { $0.skills.first == .ballMastery }
        if let d = pick(warm) { plan.append(PlanItem(drill: d, role: "Warm-up")) }

        let focus = p.focusSkills
        for i in 0..<2 where !focus.isEmpty {
            let skill = focus[(seed + i) % focus.count]
            let strong = mine.filter { $0.skills.prefix(2).contains(skill) && !used.contains($0.id) }
            if let d = pick(strong.isEmpty ? mine.filter { $0.skills.contains(skill) } : strong) ?? pick(mine) {
                plan.append(PlanItem(drill: d, role: "Focus · \(skill.short)"))
            }
        }

        if let second = p.secondPosition, second != main,
           let d = pick(PathwayLibrary.drills(for: second).filter { $0.positions.contains(second) }) {
            plan.append(PlanItem(drill: d, role: "Second position · \(second.info.short)"))
        }

        let finIDs = main == .gk ? ["agi-reaction-arrows", "gk-reactions"] : ["scan-color-call", "agi-reaction-arrows", "agi-5-10-5"]
        if let d = pick(finIDs.compactMap(PathwayLibrary.drill)) { plan.append(PlanItem(drill: d, role: "Finisher")) }
        return plan
    }
}

// MARK: - Selective training coach

/// Reads what the player types and answers only with drill options to tap.
/// Runs on the phone; no network. Same `suggest` shape a real model could fill later.
enum SelectiveCoach {
    struct Option: Identifiable {
        let drill: PathwayDrill
        let why: String
        var id: String { drill.id }
    }

    struct Reply {
        let line: String
        let options: [Option]
        let followUps: [String]
        let typedPosition: Position?
    }

    private static let skillWords: [(String, [(Skill, Double)])] = [
        ("first touch|touches|touch|receiv|control|trap|settle", [(.firstTouch, 2), (.ballMastery, 0.6)]),
        ("ball mastery|close control|tight space", [(.ballMastery, 2)]),
        ("long ball|long pass|switch|diagonal|range|hit it long", [(.rangePass, 2)]),
        ("pass|passing|playmak|through ball", [(.passing, 1.6)]),
        ("scan|aware|vision|look around|see the field|shoulder|check", [(.scanning, 2)]),
        ("turn|spin|face forward|facing forward", [(.turning, 1.8)]),
        ("dribbl|1v1|one v one|1 v 1|beat (my|the|a|defender|people|players)|take on|skill move|moves|trick", [(.dribbling, 2)]),
        ("run with|carry|\\bcounter\\b|on the break", [(.speedDribble, 2)]),
        ("speed|pace|fast|quick|slow|sprint|explos|agil|reaction|first step", [(.agility, 1.6)]),
        ("cross|delivery|whip|cutback|cut back|byline", [(.crossing, 2)]),
        ("shoot|shot|finish|scor|goals\\b|strik|volley|bend it|curl|chances|in front of goal", [(.finishing, 2)]),
        ("head|header|aerial|in the air|jump", [(.heading, 2), (.gkCrosses, 1)]),
        ("weak foot|left foot|right foot|other foot|both feet|non.?dominant", [(.weakFoot, 2.2)]),
        ("defend|tackl|jockey|get beat|getting beat|beaten|skinned|contain", [(.defending1v1, 2)]),
        ("out of position|positioning|shape|lane|screen|where to stand", [(.positioning, 2)]),
        ("mark|marking|lose my man|losing my man|track my man", [(.marking, 2)]),
        ("\\bpress(ing)?\\b|win it back|win the ball|counter.?press", [(.pressing, 2)]),
        ("recover|track back|tracking back|get back|transition", [(.recovery, 2)]),
        ("hold up|hold the ball|back to goal|bullied|knocked off|strong", [(.holdUp, 2)]),
        ("movement|runs\\b|off the ball|offside|find space|get open|in behind", [(.movement, 2)]),
        ("overlap|underlap", [(.overlap, 2.4)]),
        ("fitness|stamina|tired|engine|gas|conditioning", [(.agility, 1.2), (.recovery, 1.2)]),
        ("catch|handling|drop|fumbl|spill|parry", [(.gkHandling, 2)]),
        ("dive|diving", [(.gkDiving, 2)]),
        ("high ball|punch|corners?|claim", [(.gkCrosses, 2)]),
        ("kick|distribut|goal kick|punt|throw", [(.gkDistribution, 2)]),
        ("breakaway|one on one|1v1", [(.gk1v1, 1.2)]),
        ("angle|set position|footwork|positioning in goal|near post", [(.gkFootwork, 2)]),
    ]

    private static let positionWords: [(String, Position)] = [
        ("wing.?back|wingback", .wb),
        ("full.?back|outside back|right back|left back|\\brb\\b|\\blb\\b", .fb),
        ("center.?back|centre.?back|\\bcb\\b|central defender|defender", .cb),
        ("defensive mid|holding mid|\\bcdm\\b|\\bdm\\b|the 6\\b|number 6|\\bsix\\b", .cdm),
        ("attacking mid|\\bcam\\b|\\bam\\b|the 10\\b|number 10|\\bten\\b|playmaker", .cam),
        ("false 9|second striker|\\bss\\b|withdrawn", .ss),
        ("left mid|right mid|\\blm\\b|\\brm\\b|wide mid", .wm),
        ("\\bwing|winger|\\blw\\b|\\brw\\b|out wide", .w),
        ("center mid|centre mid|central mid|\\bcm\\b|box to box|the 8\\b|number 8|midfield|\\bmid\\b", .cm),
        ("striker|forward|\\bst\\b|\\bcf\\b|number 9|the 9\\b", .st),
        ("keeper|goalie|\\bgk\\b|goalkeeper|in goal|goal kick|punt", .gk),
    ]

    private static let keeperTranslate: [Skill: Skill?] = [
        .firstTouch: .gkHandling, .heading: .gkCrosses, .finishing: nil, .passing: .gkDistribution,
        .rangePass: .gkDistribution, .positioning: .gkFootwork, .agility: .gkFootwork,
        .defending1v1: .gk1v1, .dribbling: .gk1v1,
    ]

    private static func has(_ text: String, _ pattern: String) -> Bool {
        text.range(of: pattern, options: [.regularExpression, .caseInsensitive]) != nil
    }

    static func suggest(_ raw: String, trainingAs fallback: Position) -> Reply {
        let t = " " + raw.lowercased() + " "
        let typed = positionWords.first { has(t, $0.0) }?.1
        let pos = typed ?? fallback

        var skills: [Skill: Double] = [:]
        for (pattern, pairs) in skillWords where has(t, pattern) {
            for (s, w) in pairs { skills[s] = max(skills[s] ?? 0, w) }
        }
        if skills[.defending1v1] != nil && has(t, "get beat|getting beat|beaten|skinned") { skills[.dribbling] = nil }
        if pos == .gk {
            for (k, v) in skills where keeperTranslate.keys.contains(k) {
                skills[k] = nil
                if let g = keeperTranslate[k] ?? nil { skills[g] = max(skills[g] ?? 0, v) }
            }
        } else {
            for k in skills.keys where k.isKeeper { skills[k] = nil }
        }
        if pos != .gk && has(t, "under pressure|pressed|pressure|tight|crowd|traffic|marked") {
            skills[.scanning] = max(skills[.scanning] ?? 0, 1.2)
            skills[.turning] = max(skills[.turning] ?? 0, 0.8)
        }
        let solo = has(t, "alone|solo|by myself|on my own|no partner|nobody|backyard|at home|inside|garage")
        let wall = has(t, "wall|rebounder")

        let scored: [(PathwayDrill, Double, [Skill])] = PathwayLibrary.all.compactMap { d in
            var score = 0.0
            var hits: [Skill] = []
            for (i, sk) in d.skills.enumerated() {
                if let w = skills[sk] { score += w * (i == 0 ? 1.5 : 1); hits.append(sk) }
            }
            guard !hits.isEmpty else { return nil }
            if d.positions.contains(pos) { score += 2 }
            else if pos != .gk && d.outfield { score += 0.6 }
            else { score -= typed != nil ? 4 : 1 }
            if solo && d.needs.contains(.partner) { score -= 3 }
            if wall && d.needs.contains(.wall) { score += 1 }
            return score > 0 ? (d, score, hits) : nil
        }
        let top = scored.sorted { $0.1 > $1.1 }.prefix(5)
        let posName = pos.info.name.lowercased()

        guard !top.isEmpty else {
            return Reply(line: typed != nil ? "Got it — \(posName). Which part of your game?" : "Which part of your game? Tap one, or say it another way.",
                         options: [],
                         followUps: pos.info.coreSkills.prefix(6).map { "My \($0.name.lowercased()) needs work" },
                         typedPosition: typed)
        }
        let skillNames = skills.sorted { $0.value > $1.value }.prefix(2).map { $0.key.name.lowercased() }
        var head = skillNames.joined(separator: " + ") + ", as a \(posName)"
        if solo { head += ", solo" }
        let options = top.map { d, _, hits in
            var why = hits.prefix(2).map(\.short).joined(separator: " · ")
            if d.positions.contains(pos) { why += " — built for \(pos.info.short)" }
            why += d.needs.contains(.partner) ? " — needs a partner" : " — solo"
            return Option(drill: d, why: why)
        }
        return Reply(line: head.prefix(1).uppercased() + head.dropFirst() + ". Pick one:",
                     options: options, followUps: [], typedPosition: typed)
    }
}
