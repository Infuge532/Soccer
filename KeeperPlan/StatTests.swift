import SwiftUI

// Real measurements that set your card stats: sprint times, jumps, lifts,
// juggling records. Each result is scored from 40 (just starting out) to 95
// (top youth level). A stat's starting number is the average of its tests;
// training then adds a little on top.

struct TestEntry: Codable, Identifiable {
    var id = UUID()
    var test: StatTest
    var value: Double
    var date = Date()
}

enum StatTest: String, Codable, CaseIterable, Identifiable {
    case dash40, dash100, proAgility, verticalJump, broadJump, benchPress, pullUps, pushUps
    case juggling, goalKick, throwDistance, rulerDrop
    /// Retired tests. Kept so results saved before they were removed still
    /// load; they aren't shown and don't count.
    case legPress, shotsOnTarget, wallPasses

    var id: String { rawValue }

    /// The tests players can take, in display order.
    static let active: [StatTest] = [.dash40, .dash100, .proAgility, .verticalJump, .broadJump, .benchPress, .pullUps, .pushUps,
                                     .juggling, .goalKick, .throwDistance, .rulerDrop]

    var name: String {
        switch self {
        case .dash40: return "40-yard dash"
        case .dash100: return "100-meter dash"
        case .proAgility: return "5-10-5 shuttle"
        case .verticalJump: return "Vertical jump"
        case .benchPress: return "Bench press, 5 reps"
        case .legPress: return "Leg press, 5 reps"
        case .pullUps: return "Pull-ups"
        case .broadJump: return "Standing broad jump"
        case .pushUps: return "Push-ups in 1 minute"
        case .juggling: return "Juggling record"
        case .shotsOnTarget: return "Shots on target out of 10"
        case .wallPasses: return "Wall passes in 30 seconds"
        case .goalKick: return "Longest goal kick"
        case .throwDistance: return "Longest overarm throw"
        case .rulerDrop: return "Ruler drop catch"
        }
    }

    var unit: String {
        switch self {
        case .dash40, .dash100, .proAgility: return "s"
        case .verticalJump, .broadJump: return "in"
        case .pullUps: return "reps"
        case .benchPress, .legPress: return "lb"
        case .pushUps: return "reps"
        case .juggling: return "touches"
        case .shotsOnTarget: return "/ 10"
        case .wallPasses: return "passes"
        case .goalKick, .throwDistance: return "yd"
        case .rulerDrop: return "cm"
        }
    }

    var howTo: String {
        switch self {
        case .dash40: return "Sprint 40 yards from a standing start. Have someone time you, or use the best of two runs."
        case .dash100: return "Sprint 100 meters on a track or measured field. Fully warm up first."
        case .proAgility: return "Start in the middle, sprint 5 yards right, 10 yards left, 5 yards back to the middle. Touch each line."
        case .verticalJump: return "Stand by a wall and reach up. Then jump and touch as high as you can. Measure the difference in inches."
        case .benchPress: return "The most weight you can lift for 5 clean reps, with an adult spotting you. Don't try a 1-rep max. Skip this if you don't lift yet."
        case .pullUps: return "Full pull-ups in a row: start from a dead hang, chin over the bar, all the way back down. No kipping or swinging."
        case .broadJump: return "Feet together behind a line, swing your arms and jump forward as far as you can. Land on both feet and measure to the back of your heels, in inches. Best of 3."
        case .legPress: return "The most weight you can press for 5 clean reps on a leg-press machine, with an adult nearby. Don't try a 1-rep max."
        case .pushUps: return "Chest to a fist's height off the floor, arms fully straight at the top. Count only good reps."
        case .juggling: return "Your best run of touches without the ball hitting the ground."
        case .shotsOnTarget: return "Ten shots from the edge of the box at a goal. Count how many would have been on target."
        case .wallPasses: return "Stand 5 yards from a wall. Two-touch passes, count how many hit the wall in 30 seconds."
        case .goalKick: return "Your longest goal kick that lands in the air, in yards."
        case .throwDistance: return "Your longest accurate overarm throw, in yards."
        case .rulerDrop: return "A partner holds a 30 cm ruler between your open fingers and drops it without warning. Record where you catch it. Best of 5."
        }
    }

    /// What a U15 player needs for each rating. 50 is an average club
    /// player, 70 a strong club player, 80 an academy player, 90 elite
    /// academy and 99 a top prospect. Between marks the score is a straight
    /// line, so every tenth of a second counts.
    private var marks: [(rating: Double, value: Double)] {
        let ladder: [Double]
        switch self {
        case .dash40: ladder = [6.6, 6.0, 5.6, 5.3, 5.05, 4.8, 4.55]
        case .dash100: ladder = [16.5, 15.0, 14.0, 13.2, 12.5, 11.8, 11.1]
        case .proAgility: ladder = [6.3, 5.8, 5.4, 5.1, 4.85, 4.6, 4.35]
        case .verticalJump: ladder = [8, 12, 15, 18, 21, 25, 29]
        case .benchPress: ladder = [35, 65, 85, 110, 135, 170, 205]
        case .legPress: ladder = [90, 150, 200, 260, 320, 400, 480]
        case .pullUps: ladder = [0, 2, 5, 8, 11, 15, 20]
        case .broadJump: ladder = [55, 66, 74, 80, 86, 93, 100]
        case .pushUps: ladder = [5, 15, 24, 33, 42, 52, 62]
        case .juggling: ladder = [5, 20, 50, 100, 250, 600, 1500]
        case .shotsOnTarget: ladder = [2, 4, 5, 6, 7, 8, 10]
        case .wallPasses: ladder = [8, 14, 18, 22, 26, 30, 35]
        case .goalKick: ladder = [20, 30, 38, 45, 52, 58, 65]
        case .throwDistance: ladder = [10, 18, 24, 30, 35, 40, 46]
        case .rulerDrop: ladder = [28, 22, 18, 15, 12.5, 10, 7.5]
        }
        return zip([40.0, 50, 60, 70, 80, 90, 99], ladder).map { ($0, $1) }
    }

    private enum Kind { case speed, power, strength, skill }

    private var kind: Kind {
        switch self {
        case .dash40, .dash100, .proAgility: return .speed
        case .verticalJump, .goalKick, .throwDistance: return .power
        case .benchPress, .legPress, .pushUps, .pullUps: return .strength
        case .broadJump: return .power
        case .juggling, .shotsOnTarget, .wallPasses, .rulerDrop: return .skill
        }
    }

    /// How a typical player of this age performs next to a U15 player.
    /// Speed changes a little with age, strength a lot.
    private func ageFactor(_ age: String) -> Double {
        let i = ["U12", "U13", "U14", "U15", "U16", "U17", "U19"].firstIndex(of: age) ?? 3
        switch kind {
        case .speed: return [0.92, 0.95, 0.975, 1, 1.02, 1.035, 1.05][i]
        case .power: return [0.8, 0.86, 0.93, 1, 1.06, 1.11, 1.16][i]
        case .strength: return [0.6, 0.7, 0.85, 1, 1.12, 1.22, 1.32][i]
        case .skill: return 1
        }
    }

    var lowerIsBetter: Bool { marks[0].value > marks[1].value }
    private var logScale: Bool { self == .juggling }

    /// The result turned into what it would be for a U15 player.
    private func toU15(_ value: Double, age: String) -> Double {
        lowerIsBetter ? value * ageFactor(age) : value / ageFactor(age)
    }

    /// The card rating for a result, from 25 to 99.
    func rating(_ value: Double, age: String) -> Double {
        let m = marks
        func x(_ v: Double) -> Double { logScale ? log(max(1, v)) : v }
        let v = x(toU15(value, age: age))
        for i in 0..<(m.count - 1) {
            let a = x(m[i].value), b = x(m[i + 1].value)
            let t = (v - a) / (b - a)
            if t <= 1 || i == m.count - 2 {
                let r = m[i].rating + max(i == 0 ? -.infinity : 0, min(1, t)) * (m[i + 1].rating - m[i].rating)
                return min(99, max(25, r))
            }
        }
        return 99
    }

    /// The result a player of this age needs for a rating.
    func target(for rating: Double, age: String) -> Double {
        let m = marks
        guard let j = m.firstIndex(where: { $0.rating >= rating }) else { return m.last!.value }
        var u15 = m[j].value
        if j > 0, m[j].rating != rating {
            let t = (rating - m[j - 1].rating) / (m[j].rating - m[j - 1].rating)
            u15 = m[j - 1].value + t * (m[j].value - m[j - 1].value)
        }
        return lowerIsBetter ? u15 / ageFactor(age) : u15 * ageFactor(age)
    }

    /// The card stats this test sets.
    var statCodes: [String] {
        switch self {
        case .dash40: return ["PAC", "FTW"]
        case .dash100: return ["PAC"]
        case .proAgility: return ["PAC", "FTW"]
        case .verticalJump: return ["PHY", "DIV"]
        case .benchPress, .pullUps, .pushUps, .broadJump: return ["PHY"]
        case .legPress, .shotsOnTarget, .wallPasses: return []
        case .juggling: return ["DRI"]
        case .goalKick, .throwDistance: return ["DIS"]
        case .rulerDrop: return ["REF"]
        }
    }

    var decimals: Bool { [.dash40, .dash100, .proAgility, .verticalJump, .rulerDrop].contains(self) }

    /// Results outside this are almost certainly typos.
    var plausible: ClosedRange<Double> {
        switch self {
        case .dash40: return 3.8...12
        case .dash100: return 9.5...30
        case .proAgility: return 3.8...12
        case .verticalJump: return 1...45
        case .benchPress: return 1...400
        case .legPress: return 1...1200
        case .pullUps: return 0...60
        case .broadJump: return 10...140
        case .pushUps: return 0...150
        case .juggling: return 0...100_000
        case .shotsOnTarget: return 0...10
        case .wallPasses: return 0...80
        case .goalKick: return 1...90
        case .throwDistance: return 1...70
        case .rulerDrop: return 0...30
        }
    }

    func format(_ value: Double) -> String {
        decimals ? value.formatted(.number.precision(.fractionLength(0...2))) : String(Int(value.rounded()))
    }

    /// Wall-catch runs from the catch log count as a handling test for keepers.
    /// Marks: 5 catches is 40, 15 is 50, 30 is 60, 50 is 70, 100 is 80, 200 is 90, 400 is 99.
    static func catchRating(_ best: Int) -> Double {
        let marks: [(Double, Double)] = [(40, 5), (50, 15), (60, 30), (70, 50), (80, 100), (90, 200), (99, 400)]
        let v = log(Double(max(1, best)))
        for i in 0..<(marks.count - 1) {
            let a = log(marks[i].1), b = log(marks[i + 1].1)
            let t = (v - a) / (b - a)
            if t <= 1 || i == marks.count - 2 {
                return min(99, max(25, marks[i].0 + max(i == 0 ? -.infinity : 0, min(1, t)) * (marks[i + 1].0 - marks[i].0)))
            }
        }
        return 99
    }
}

extension Store {
    var testResults: [TestEntry] { data.tests ?? [] }

    func latest(_ test: StatTest) -> TestEntry? {
        testResults.filter { $0.test == test }.max { $0.date < $1.date }
    }

    func addTest(_ test: StatTest, value: Double) {
        var list = data.tests ?? []
        list.append(TestEntry(test: test, value: value))
        data.tests = list
    }

    func deleteTest(_ id: UUID) {
        data.tests?.removeAll { $0.id == id }
    }
}

// MARK: - Screens

struct StatTestsView: View {
    @EnvironmentObject var store: Store
    @State private var entering: StatTest?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Put in real results and your card starts from where you actually are. Your latest result for each test counts. Retest every month or two to move your numbers.")
                    .foregroundStyle(Theme.muted)
                if let p = store.profile {
                    let ratings = store.cardRatings(for: p)
                    ForEach(ratings.stats) { stat in
                        let tests = StatTest.active.filter { $0.statCodes.contains(stat.code) }
                        Panel(title: "\(stat.code) · \(stat.name)", spacing: 0) {
                            HStack {
                                Text("Card number").foregroundStyle(Theme.muted)
                                Spacer()
                                Text("\(stat.value)").font(.display(28)).foregroundStyle(ratings.tier.accent)
                            }
                            .padding(.bottom, 6)
                            if tests.isEmpty && !(stat.code == "HAN") {
                                Text("No test for this one. It only grows with training: \(stat.trainedBy.lowercased()).")
                                    .font(.footnote).foregroundStyle(Theme.muted).padding(.vertical, 8)
                            }
                            ForEach(tests) { t in
                                Button { entering = t } label: { row(t) }.buttonStyle(.plain)
                            }
                            if stat.code == "HAN" {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Wall-catch run").font(.body.weight(.medium))
                                        Text("Log it in the Progress tab").font(.caption).foregroundStyle(Theme.muted)
                                    }
                                    Spacer()
                                    Text(store.bestCatchStreak > 0 ? "\(store.bestCatchStreak) catches" : "Not logged")
                                        .foregroundStyle(store.bestCatchStreak > 0 ? .white : Theme.muted)
                                }
                                .padding(.vertical, 12)
                            }
                        }
                    }
                }
                Text("Scores are set against strong youth players around U15. Safety first: warm up before sprints and jumps, lift only with an adult spotting you, and never test a 1-rep max.")
                    .font(.footnote).foregroundStyle(Theme.muted)
            }
            .padding(20)
        }
        .background(Theme.background)
        .navigationTitle("TEST YOUR STATS")
        .sheet(item: $entering) { TestEntrySheet(test: $0) }
    }

    private var age: String { store.profile?.age ?? "U15" }

    private func row(_ t: StatTest) -> some View {
        let last = store.latest(t)
        return HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(t.name).font(.body.weight(.medium))
                Text(last.map { "Tested " + $0.date.formatted(.dateTime.month(.abbreviated).day()) } ?? "Tap to add a result")
                    .font(.caption).foregroundStyle(Theme.muted)
            }
            Spacer()
            if let last {
                Text("\(t.format(last.value)) \(t.unit)").font(.subheadline)
                Text("\(Int(t.rating(last.value, age: age).rounded()))")
                    .font(.display(18)).foregroundStyle(.black)
                    .frame(width: 38, height: 30)
                    .background(Theme.accent, in: RoundedRectangle(cornerRadius: 8))
            } else {
                Image(systemName: "plus.circle.fill").font(.title3).foregroundStyle(Theme.accent)
            }
        }
        .padding(.vertical, 12)
        .contentShape(Rectangle())
        .overlay(alignment: .top) { Rectangle().fill(Theme.line).frame(height: 1) }
    }
}

struct TestEntrySheet: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss
    let test: StatTest
    @State private var text = ""
    @State private var error = ""
    @FocusState private var focused: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text(test.name.uppercased()).font(.display(40))
                    Text(test.howTo).foregroundStyle(Theme.muted)
                    HStack(alignment: .firstTextBaseline, spacing: 10) {
                        TextField("0", text: $text)
                            .keyboardType(test.decimals ? .decimalPad : .numberPad)
                            .focused($focused)
                            .font(.display(56))
                        Text(test.unit).font(.display(28)).foregroundStyle(Theme.muted)
                    }
                    .padding(.horizontal, 18).padding(.vertical, 10)
                    .background(Theme.card, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Theme.line))
                    if let v = value, test.plausible.contains(v) {
                        Text("Scores \(Int(test.rating(v, age: age).rounded())) for " + test.statCodes.joined(separator: " and "))
                            .font(.subheadline.weight(.semibold)).foregroundStyle(Theme.accent)
                    }
                    targets
                    if !error.isEmpty { Text(error).foregroundStyle(.red).font(.subheadline.weight(.semibold)) }
                    Button("Save result", action: save).buttonStyle(BigButtonStyle())
                    let history = store.testResults.filter { $0.test == test }.sorted { $0.date > $1.date }
                    if !history.isEmpty {
                        Panel(title: "Past results", spacing: 0) {
                            ForEach(history) { e in
                                HStack {
                                    Text(e.date.formatted(.dateTime.month(.abbreviated).day().year())).foregroundStyle(Theme.muted)
                                    Spacer()
                                    Text("\(test.format(e.value)) \(test.unit)")
                                    Button { store.deleteTest(e.id) } label: { Image(systemName: "trash").foregroundStyle(Theme.muted) }
                                        .buttonStyle(.plain)
                                        .accessibilityLabel("Delete this result")
                                        .padding(.leading, 8)
                                }
                                .font(.subheadline)
                                .padding(.vertical, 8)
                            }
                        }
                    }
                }
                .padding(20)
            }
            .background(Theme.background)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } } }
            .onAppear { focused = true }
        }
        .tint(Theme.accent)
        .preferredColorScheme(.dark)
    }

    private var value: Double? { Double(text.replacingOccurrences(of: ",", with: ".")) }

    private var age: String { store.profile?.age ?? "U15" }

    /// What it takes to reach each rating at this player's age.
    private var targets: some View {
        Panel(title: "What it takes at \(age)", spacing: 0) {
            ForEach([50.0, 60, 70, 80, 90, 99], id: \.self) { r in
                HStack {
                    Text("\(Int(r))").font(.display(22)).foregroundStyle(CardTier(overall: Int(r)).accent).frame(width: 40, alignment: .leading)
                    Text(label(r)).foregroundStyle(Theme.muted)
                    Spacer()
                    Text(test.format(roundTarget(test.target(for: r, age: age))) + " \(test.unit)")
                        .font(.subheadline.weight(.semibold)).monospacedDigit()
                }
                .font(.subheadline)
                .padding(.vertical, 6)
            }
            Text(test.lowerIsBetter ? "Faster than the time shown scores higher." : "More than the number shown scores higher.")
                .font(.caption).foregroundStyle(Theme.muted).padding(.top, 6)
        }
    }

    private func label(_ r: Double) -> String {
        switch r {
        case ..<55: return "Average club player"
        case ..<65: return "Good club player"
        case ..<75: return "Strong club player"
        case ..<85: return "Academy level"
        case ..<95: return "Elite academy"
        default: return "Top prospect"
        }
    }

    private func roundTarget(_ v: Double) -> Double {
        test.decimals ? (v * 100).rounded() / 100 : v.rounded()
    }

    private func save() {
        guard let v = value else { error = "Type a number."; return }
        guard test.plausible.contains(v) else {
            error = "\(test.format(v)) \(test.unit) looks off. Check the number and try again."
            return
        }
        store.addTest(test, value: v)
        dismiss()
    }
}
