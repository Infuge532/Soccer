import SwiftUI

// The player card: an overall rating, your position and six stats.
// Each stat starts from your real test results (sprint times, jumps, lifts,
// see StatTests.swift), or from 50 plus a little for your level if you
// haven't tested. Training adds on top, slowly: at most a quarter of the
// way to 99, and it takes hundreds of drills to get most of that.

struct CardStat: Identifiable, Equatable {
    let code: String
    let name: String
    let value: Int
    /// Completed drills that fed this stat.
    let drills: Int
    /// What to train to raise it.
    let trainedBy: String
    /// Test results behind the starting number, e.g. "40-yard dash 5.1 s".
    var tested: [String] = []
    /// The number before training is added.
    var base: Int = 50
    var id: String { code }
}

enum CardTier: String {
    case bronze, silver, gold, elite

    init(overall: Int) {
        self = overall >= 80 ? .elite : overall >= 70 ? .gold : overall >= 60 ? .silver : .bronze
    }

    var name: String { rawValue.capitalized }
    var floor: Int { [CardTier.bronze: 50, .silver: 60, .gold: 70, .elite: 80][self]! }
    var next: CardTier? { [CardTier.bronze: .silver, .silver: .gold, .gold: .elite][self] }

    /// The tier's colour: badge, numbers and edge highlight.
    var accent: Color {
        switch self {
        case .bronze: return Color(red: 0.91, green: 0.64, blue: 0.43)
        case .silver: return Color(red: 0.85, green: 0.88, blue: 0.91)
        case .gold: return Color(red: 1, green: 0.83, blue: 0.42)
        case .elite: return Theme.accent
        }
    }
}

struct CardRatings: Equatable {
    let position: String
    let stats: [CardStat]
    var overall: Int { stats.isEmpty ? 50 : Int((Double(stats.map(\.value).reduce(0, +)) / Double(stats.count)).rounded()) }
    var tier: CardTier { CardTier(overall: overall) }
}

private struct StatRecipe {
    let code: String
    let name: String
    let focuses: [Focus]
    let skills: [Skill]
    let trainedBy: String
}

private let keeperRecipes = [
    StatRecipe(code: "DIV", name: "Diving", focuses: [.diving, .power], skills: [.gkDiving], trainedBy: "Diving and power drills"),
    StatRecipe(code: "HAN", name: "Handling", focuses: [.handling, .crosses], skills: [.gkHandling, .gkCrosses], trainedBy: "Handling, crosses and high balls"),
    StatRecipe(code: "DIS", name: "Distribution", focuses: [.distribution], skills: [.gkDistribution], trainedBy: "Throws, rolls and kicks"),
    StatRecipe(code: "REF", name: "Reflexes", focuses: [.reactions, .shotStopping], skills: [], trainedBy: "Reactions and shot stopping"),
    StatRecipe(code: "FTW", name: "Footwork", focuses: [.footwork], skills: [.gkFootwork, .agility], trainedBy: "Footwork and agility"),
    StatRecipe(code: "POS", name: "Positioning", focuses: [.positioning, .oneVOne], skills: [.gk1v1], trainedBy: "Positioning and 1v1s"),
]

private let outfieldRecipes = [
    StatRecipe(code: "PAC", name: "Pace", focuses: [], skills: [.agility, .speedDribble, .recovery], trainedBy: "Speed, agility and running with the ball"),
    StatRecipe(code: "SHO", name: "Shooting", focuses: [], skills: [.finishing, .weakFoot], trainedBy: "Finishing and weak-foot work"),
    StatRecipe(code: "PAS", name: "Passing", focuses: [], skills: [.passing, .rangePass, .crossing, .scanning], trainedBy: "Passing, switches, crossing and scanning"),
    StatRecipe(code: "DRI", name: "Dribbling", focuses: [], skills: [.ballMastery, .firstTouch, .turning, .dribbling], trainedBy: "Ball mastery, first touch, turning and 1v1s"),
    StatRecipe(code: "DEF", name: "Defending", focuses: [], skills: [.defending1v1, .positioning, .marking, .pressing], trainedBy: "1v1 defending, marking and pressing"),
    StatRecipe(code: "PHY", name: "Physical", focuses: [], skills: [.heading, .holdUp, .movement, .overlap], trainedBy: "Heading, hold-up play and off-ball runs"),
]

extension Store {
    /// The card for this player. `leavingOutLatest` gives the card as it was
    /// before the most recent Pathway session, for the level-up moment.
    func cardRatings(for p: PlayerProfile, leavingOutLatest: Bool = false) -> CardRatings {
        let keeper = p.mainPosition == .gk
        var focusCounts: [Focus: Int] = [:]
        if keeper { for item in drillsByFocus { focusCounts[item.focus] = item.count } }
        var skillCounts: [Skill: Int] = [:]
        for s in pathwaySessions.dropFirst(leavingOutLatest ? 1 : 0) where s.completed {
            for skill in Set(PathwayLibrary.drill(s.drillID)?.skills ?? []) { skillCounts[skill, default: 0] += 1 }
        }
        let untested = 50 + p.current.rank / 2
        let stats = (keeper ? keeperRecipes : outfieldRecipes).map { r in
            let n = r.focuses.reduce(0) { $0 + (focusCounts[$1] ?? 0) } + r.skills.reduce(0) { $0 + (skillCounts[$1] ?? 0) }
            var scores: [Double] = []
            var notes: [String] = []
            for test in StatTest.active where test.statCodes.contains(r.code) {
                if let e = latest(test) {
                    scores.append(test.rating(e.value, age: p.age))
                    notes.append("\(test.name) \(test.format(e.value)) \(test.unit)")
                }
            }
            if keeper && r.code == "HAN" && bestCatchStreak > 0 {
                scores.append(StatTest.catchRating(bestCatchStreak))
                notes.append("Wall-catch run \(bestCatchStreak)")
            }
            let base = scores.isEmpty ? untested : Int((scores.reduce(0, +) / Double(scores.count)).rounded())
            // Hard to climb: a quarter of the gap to 99 at most, ~40% of that after 50 drills.
            let gain = Int(Double(max(0, 99 - base)) * 0.25 * (1 - exp(-Double(n) / 100)))
            return CardStat(code: r.code, name: r.name, value: min(99, base + gain), drills: n, trainedBy: r.trainedBy,
                            tested: notes, base: base)
        }
        return CardRatings(position: p.mainPosition.info.short, stats: stats)
    }

    /// Every day with a Keeper drill ticked or a Pathway session finished.
    var allTrainingDays: Set<String> {
        var days = Set(history.map(\.dayKey))
        for s in pathwaySessions where s.completed { days.insert(Self.dayKey(s.date)) }
        return days
    }

    func trainedAnything(_ date: Date) -> Bool { allTrainingDays.contains(Self.dayKey(date)) }

    /// Days in a row across both kinds of training.
    var overallStreak: Int {
        let days = allTrainingDays
        let cal = Calendar.current
        var day = cal.startOfDay(for: Date())
        if !days.contains(Self.dayKey(day)) { day = cal.date(byAdding: .day, value: -1, to: day) ?? day }
        var count = 0
        while days.contains(Self.dayKey(day)) {
            count += 1
            guard let previous = cal.date(byAdding: .day, value: -1, to: day) else { break }
            day = previous
        }
        return count
    }

    var pathwayMinutes: Int { pathwaySessions.reduce(0) { $0 + $1.seconds } / 60 }
}

// MARK: - Card view

/// Shield outline with a raised tab across the top, like a trading card.
struct PlayerCardShape: Shape {
    func path(in r: CGRect) -> Path {
        let w = r.width, h = r.height
        func pt(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: r.minX + x * w, y: r.minY + y * h) }
        var p = Path()
        let corners = [pt(0, 0.06), pt(0.3, 0.06), pt(0.37, 0), pt(0.63, 0), pt(0.7, 0.06), pt(1, 0.06), pt(1, 0.86), pt(0.5, 1), pt(0, 0.86)]
        p.move(to: CGPoint(x: (corners[8].x + corners[0].x) / 2, y: (corners[8].y + corners[0].y) / 2))
        for i in 0..<corners.count {
            p.addArc(tangent1End: corners[i], tangent2End: corners[(i + 1) % corners.count], radius: w * 0.04)
        }
        p.closeSubpath()
        return p
    }
}

/// The small lime tag with the overall and position.
private struct RatingTag: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: r.minX, y: r.minY))
        p.addLine(to: CGPoint(x: r.maxX, y: r.minY))
        p.addLine(to: CGPoint(x: r.maxX, y: r.maxY - r.height * 0.16))
        p.addLine(to: CGPoint(x: r.midX, y: r.maxY))
        p.addLine(to: CGPoint(x: r.minX, y: r.maxY - r.height * 0.16))
        p.closeSubpath()
        return p
    }
}

struct PlayerCard: View {
    let name: String
    let ratings: CardRatings
    var width: CGFloat = 170
    /// Stat codes to light up, e.g. after a session.
    var highlight: Set<String> = []

    var body: some View {
        let u = width / 14
        let tier = ratings.tier
        let height = width / 0.72
        ZStack(alignment: .topLeading) {
            VStack(spacing: u * 0.35) {
                ZStack {
                    Circle().fill(LinearGradient(colors: [tier.accent.opacity(0.9), tier.accent.opacity(0.45)], startPoint: .top, endPoint: .bottom))
                    Image(systemName: "person.fill")
                        .font(.system(size: u * 2.6))
                        .foregroundStyle(Color.black.opacity(0.75))
                        .offset(y: u * 0.25)
                        .clipShape(Circle())
                }
                .frame(width: u * 4.8, height: u * 4.8)
                .clipShape(Circle())
                Text(name.uppercased())
                    .font(.display(u * 1.75))
                    .foregroundStyle(.white)
                    .lineLimit(1).minimumScaleFactor(0.5)
                    .padding(.top, u * 0.2)
                HStack(alignment: .top, spacing: u * 0.8) {
                    column(Array(ratings.stats.prefix(3)), u)
                    Rectangle().fill(Color.white.opacity(0.18)).frame(width: 1, height: u * 4.6)
                    column(Array(ratings.stats.dropFirst(3)), u)
                }
                .padding(.top, u * 0.5)
                Spacer(minLength: 0)
            }
            .padding(.top, u * 2.5)
            .padding(.horizontal, u * 0.9)
            .frame(width: width, height: height)
            .background {
                ZStack {
                    PlayerCardShape().fill(LinearGradient(colors: [Color(red: 0.14, green: 0.15, blue: 0.15), Color(red: 0.07, green: 0.075, blue: 0.075)],
                                                          startPoint: .top, endPoint: .bottom))
                    PlayerCardShape().fill(RadialGradient(colors: [tier.accent.opacity(0.18), .clear], center: .top, startRadius: 0, endRadius: height * 0.6))
                }
            }
            .overlay {
                PlayerCardShape().stroke(LinearGradient(colors: [tier.accent.opacity(0.7), Color.white.opacity(0.08), tier.accent.opacity(0.35)],
                                                        startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: max(1, u * 0.12))
            }
            // Side accents, like the edges of a real card
            .overlay(alignment: .leading) { Capsule().fill(tier.accent).frame(width: max(2, u * 0.22), height: u * 3).offset(y: u * 1.5) }
            .overlay(alignment: .trailing) { Capsule().fill(tier.accent).frame(width: max(2, u * 0.22), height: u * 3).offset(y: u * 1.5) }

            VStack(spacing: -u * 0.25) {
                Text("\(ratings.overall)").font(.display(u * 2.1)).monospacedDigit()
                Text(ratings.position).font(.display(u * 1, .bold))
            }
            .foregroundStyle(.black)
            .padding(.horizontal, u * 0.5).padding(.top, u * 0.25).padding(.bottom, u * 0.6)
            .background(RatingTag().fill(tier.accent))
            .rotationEffect(.degrees(-4))
            .offset(x: -u * 0.55, y: u * 1.4)
            .contentTransition(.numericText())
        }
        .frame(width: width, height: height)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(name) player card, \(tier.name), overall \(ratings.overall), " + ratings.stats.map { "\($0.name) \($0.value)" }.joined(separator: ", "))
    }

    private func column(_ stats: [CardStat], _ u: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: u * 0.25) {
            ForEach(stats) { s in
                let lit = highlight.contains(s.code)
                HStack(spacing: u * 0.55) {
                    Text(s.code).font(.display(u * 1.05, .bold)).foregroundStyle(Color.white.opacity(0.7))
                        .frame(width: u * 2.3, alignment: .leading)
                    Text("\(s.value)").font(.display(u * 1.15, .bold)).monospacedDigit()
                        .foregroundStyle(lit ? .white : ratings.tier.accent)
                        .shadow(color: lit ? ratings.tier.accent : .clear, radius: 6)
                        .contentTransition(.numericText(value: Double(s.value)))
                }
            }
        }
    }
}

// MARK: - Full card screen

struct PlayerCardScreen: View {
    @EnvironmentObject var store: Store

    var body: some View {
        ScrollView {
            if let p = store.profile {
                let r = store.cardRatings(for: p)
                VStack(spacing: 24) {
                    ZStack(alignment: .bottom) {
                        StadiumBackdrop(fade: 0.5).frame(height: 420)
                        PlayerCard(name: p.firstName, ratings: r, width: 230)
                            .shadow(color: r.tier.accent.opacity(0.25), radius: 40)
                            .padding(.bottom, 4)
                    }
                    CardBreakdown(ratings: r)
                        .padding(.horizontal, 20)
                }
                .padding(.bottom, 30)
            }
        }
        .ignoresSafeArea(edges: .top)
        .background(Theme.background)
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// Tier progress and every stat with what feeds it.
struct CardBreakdown: View {
    let ratings: CardRatings
    @State private var showTests = false

    var body: some View {
        let tier = ratings.tier
        VStack(spacing: 16) {
            Panel(title: "\(tier.name) card") {
                if let next = tier.next {
                    Text("Overall \(ratings.overall). Reach \(next.floor) for a \(next.name.lowercased()) card.")
                        .foregroundStyle(Theme.muted)
                    ProgressView(value: Double(ratings.overall - tier.floor), total: Double(next.floor - tier.floor))
                        .tint(tier.accent)
                } else {
                    Text("Overall \(ratings.overall). The top tier. Keep stacking reps toward 99.")
                        .foregroundStyle(Theme.muted)
                }
            }
            Panel(title: "Your stats") {
                ForEach(ratings.stats) { s in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(alignment: .firstTextBaseline) {
                            Text(s.code).font(.display(22)).foregroundStyle(tier.accent).frame(width: 46, alignment: .leading)
                            Text(s.name).font(.subheadline.weight(.semibold))
                            Spacer()
                            Text("\(s.value)").font(.display(26)).monospacedDigit()
                        }
                        GeometryReader { g in
                            ZStack(alignment: .leading) {
                                Capsule().fill(Theme.cardStrong)
                                Capsule().fill(tier.accent).frame(width: g.size.width * CGFloat(s.value) / 99)
                            }
                        }
                        .frame(height: 5)
                        Text(s.tested.isEmpty ? "Not tested yet · starts at \(s.base)" : "From " + s.tested.joined(separator: ", ") + " · \(s.base)")
                            .font(.caption).foregroundStyle(s.tested.isEmpty ? Theme.muted : .white.opacity(0.85))
                        Text("+\(s.value - s.base) from \(s.drills) drill\(s.drills == 1 ? "" : "s") · \(s.trainedBy.lowercased())")
                            .font(.caption).foregroundStyle(Theme.muted)
                    }
                    .padding(.vertical, 4)
                }
            }
            Button { showTests = true } label: { Label("Enter test results", systemImage: "stopwatch") }
                .buttonStyle(BigButtonStyle())
            Text("Each stat starts from your test results, like a 40-yard dash time or a jump. Training adds to it slowly: each drill adds less than the one before, and training alone can only close a quarter of the gap to 99. To make a big jump, get faster or stronger and retest.")
                .font(.footnote).foregroundStyle(Theme.muted)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .sheet(isPresented: $showTests) {
            NavigationStack {
                StatTestsView()
                    .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { showTests = false } } }
            }
            .tint(Theme.accent)
            .preferredColorScheme(.dark)
        }
    }
}
