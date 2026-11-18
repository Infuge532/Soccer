import SwiftUI

enum PathRoute: Hashable {
    case drill(String)
    case position(Position)
    case touches
    case card
    case tests
}

extension View {
    func pathwayDestinations() -> some View {
        navigationDestination(for: PathRoute.self) { route in
            switch route {
            case .drill(let id):
                if let d = PathwayLibrary.drill(id) { PathwayDrillView(drill: d) }
            case .position(let p): PositionDetailView(position: p)
            case .touches: TouchesPackView()
            case .card: PlayerCardScreen()
            case .tests: StatTestsView()
            }
        }
    }
}

private let gold = Color(red: 0.89, green: 0.7, blue: 0.24)

struct Kicker: View {
    let text: String
    var color: Color = Theme.accent
    var body: some View {
        Text(text.uppercased()).font(.display(15, .bold)).foregroundStyle(color).tracking(1.2)
    }
}

struct ShirtBadge: View {
    let text: String
    var big = false
    var body: some View {
        Text(text)
            .font(.display(big ? 38 : 17))
            .foregroundStyle(.black)
            .padding(.horizontal, big ? 18 : 9)
            .padding(.vertical, big ? 12 : 5)
            .background(Theme.accent, in: RoundedRectangle(cornerRadius: big ? 14 : 7, style: .continuous))
    }
}

struct Bullets: View {
    let items: [String]
    var mark = "circle.fill"
    var tint: Color = Theme.accent
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(items, id: \.self) { item in
                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    Image(systemName: mark).font(.system(size: mark == "circle.fill" ? 6 : 12, weight: .bold)).foregroundStyle(tint)
                    Text(item).fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}

// MARK: - Home / dashboard

struct PathwayHomeView: View {
    @EnvironmentObject var store: Store
    @State private var showProfile = false
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            Group {
                if let p = store.profile { dashboard(p) } else { ContentUnavailableView("No profile yet", systemImage: "person.crop.circle") }
            }
            .background(Theme.background)
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showProfile) { ProfileView() }
            .sheet(isPresented: $showSettings) { RemindersView() }
            .pathwayDestinations()
        }
    }

    private func dashboard(_ p: PlayerProfile) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                hero(p)
                HStack(alignment: .top, spacing: 12) {
                    NavigationLink(value: PathRoute.card) {
                        PlayerCard(name: p.firstName, ratings: store.cardRatings(for: p), width: 156)
                    }
                    .buttonStyle(.plain)
                    status
                }
                .padding(.horizontal, 20)
                .padding(.top, -96)
                recentDays
                today(p)
                explore(p)
                pathway(p).padding(.horizontal, 20)
                if !store.pathwaySessions.isEmpty { recent.padding(.horizontal, 20) }
            }
            .padding(.bottom, 30)
        }
        .ignoresSafeArea(edges: .top)
    }

    // MARK: Hero

    private func hero(_ p: PlayerProfile) -> some View {
        ZStack(alignment: .top) {
            StadiumBackdrop(fade: 0.48).frame(height: 368)
            HStack(alignment: .center, spacing: 10) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Hi, \(p.firstName)")
                        .font(.system(size: 30, weight: .semibold, design: .rounded))
                        .tracking(-0.7)
                    HStack(spacing: 5) {
                        Image(systemName: "mappin.circle.fill").foregroundStyle(Theme.accent)
                        Text("\(p.age) · \(p.region) region")
                    }
                    .font(.subheadline).foregroundStyle(.white.opacity(0.7))
                }
                Spacer()
                CircleIconButton(symbol: "bell", label: "Reminders and settings") { showSettings = true }
                CircleIconButton(symbol: "person", dot: true, label: "Player profile") { showProfile = true }
            }
            .padding(.horizontal, 20)
            .padding(.top, 64)
        }
    }

    // MARK: Status

    private var status: some View {
        Panel(title: "My status", spacing: 2) {
            StatusRow(label: "Days trained", value: "\(store.allTrainingDays.count)")
            StatusRow(label: "Streak", value: "\(store.overallStreak)")
            StatusRow(label: "Sessions", value: "\(store.pathwaySessions.filter(\.completed).count + store.totalDrills)")
            StatusRow(label: "Minutes", value: "\(store.pathwayMinutes)")
            StatusRow(label: "Best catches", value: "\(store.bestCatchStreak)")
        }
    }

    /// The last five days, looking back only. A lime dot marks a day you trained.
    private var recentDays: some View {
        let cal = Calendar.current
        let days = (0..<5).reversed().compactMap { cal.date(byAdding: .day, value: -$0, to: Date()) }
        return HStack(spacing: 0) {
            ForEach(days, id: \.self) { d in
                let isToday = cal.isDateInToday(d)
                VStack(spacing: 3) {
                    Text(d.formatted(.dateTime.day())).font(.display(30, .bold)).monospacedDigit()
                    Text(d.formatted(.dateTime.weekday(.abbreviated))).font(.footnote).foregroundStyle(isToday ? .white : Theme.muted)
                    Circle().fill(store.trainedAnything(d) ? Theme.accent : Color.white.opacity(0.12)).frame(width: 6, height: 6)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background {
                    if isToday { NotchedPanelShape(radius: 16, tab: 0.5, drop: 6).fill(Theme.card).overlay(NotchedPanelShape(radius: 16, tab: 0.5, drop: 6).stroke(Theme.line)) }
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(d.formatted(.dateTime.weekday(.wide).day()) + (store.trainedAnything(d) ? ", trained" : ""))
            }
        }
        .padding(.horizontal, 14)
    }

    // MARK: Today

    private func today(_ p: PlayerProfile) -> some View {
        let plan = store.todaysPlan(for: p)
        let next = plan.first { !store.pathwayDoneToday($0.drill.id) }
        let total = plan.reduce(0) { $0 + $1.drill.minutes }
        let codes = statCodes(p)
        return Panel(title: "Today's drills") {
            Text("Built around \(p.focusSkills.map(\.short).joined(separator: ", ").lowercased()). About \(total) min, or pick anything else.")
                .font(.subheadline).foregroundStyle(Theme.muted)
            VStack(spacing: 0) {
                ForEach(Array(plan.enumerated()), id: \.element.id) { i, item in
                    let done = store.pathwayDoneToday(item.drill.id)
                    NavigationLink(value: PathRoute.drill(item.drill.id)) {
                        HStack(spacing: 12) {
                            Text(codes(item.drill))
                                .font(.display(15, .bold))
                                .frame(width: 42, height: 42)
                                .background(Circle().fill(i == 0 ? Theme.cardStrong : Theme.accent))
                                .foregroundStyle(i == 0 ? .white : .black)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.drill.name).font(.body.weight(.medium))
                                    .strikethrough(done).opacity(done ? 0.5 : 1)
                                Text("\(item.role) · \(item.drill.minutes) min").font(.caption).foregroundStyle(Theme.muted)
                            }
                            Spacer()
                            Image(systemName: done ? "checkmark.circle.fill" : "arrow.right")
                                .foregroundStyle(done ? Theme.accent : .white)
                        }
                        .padding(.vertical, 12)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    if i < plan.count - 1 { Rectangle().fill(Theme.line).frame(height: 1) }
                }
            }
            if let next {
                NavigationLink(value: PathRoute.drill(next.drill.id)) {
                    Text(plan.first?.id == next.id ? "Start today" : "Next: \(next.drill.name)")
                }
                .buttonStyle(BigButtonStyle())
            } else {
                Label("Done for today", systemImage: "checkmark.seal.fill").font(.headline).foregroundStyle(Theme.accent)
            }
        }
        .padding(.horizontal, 20)
    }

    /// Which card stat a drill builds, for the tag beside it.
    private func statCodes(_ p: PlayerProfile) -> (PathwayDrill) -> String {
        let keeper = p.mainPosition == .gk
        return { d in
            guard let skill = d.skills.first else { return "GO" }
            switch skill {
            case .gkDiving: return "DIV"
            case .gkHandling, .gkCrosses: return "HAN"
            case .gkDistribution: return "DIS"
            case .gk1v1: return "POS"
            case .gkFootwork: return "FTW"
            case .agility: return keeper ? "FTW" : "PAC"
            case .speedDribble, .recovery: return "PAC"
            case .finishing, .weakFoot: return "SHO"
            case .passing, .rangePass, .crossing, .scanning: return keeper ? "REF" : "PAS"
            case .ballMastery, .firstTouch, .turning, .dribbling: return "DRI"
            case .defending1v1, .positioning, .marking, .pressing: return "DEF"
            default: return "PHY"
            }
        }
    }

    // MARK: Explore

    private func explore(_ p: PlayerProfile) -> some View {
        let main = p.mainPosition
        return VStack(alignment: .leading, spacing: 12) {
            SectionHeader(text: "Explore").padding(.horizontal, 20)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    NavigationLink(value: PathRoute.position(main)) {
                        IconPill(symbol: "list.bullet", title: "\(main.info.short) library", count: PathwayLibrary.drills(for: main).count)
                    }
                    NavigationLink(value: PathRoute.touches) {
                        IconPill(symbol: "soccerball", title: main == .gk ? "Handling & feet" : "Touches")
                    }
                    if let second = p.secondPosition, second != main {
                        NavigationLink(value: PathRoute.position(second)) {
                            IconPill(symbol: "arrow.triangle.swap", title: "2nd: \(second.info.short)", count: PathwayLibrary.drills(for: second).count)
                        }
                    }
                    NavigationLink(value: PathRoute.tests) { IconPill(symbol: "stopwatch", title: "Test your stats") }
                    NavigationLink(value: PathRoute.card) { IconPill(symbol: "rectangle.portrait.fill", title: "My card") }
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 20)
            }
        }
    }

    // MARK: Pathway

    private func pathway(_ p: PlayerProfile) -> some View {
        let main = p.mainPosition
        let steps = p.goal.rank - p.current.rank
        return Panel(title: "Your pathway") {
            Text("\(p.current.name)\(p.team.isEmpty ? "" : " (\(p.team))") → \(p.goal.name)")
                .font(.headline)
            if steps > 0 {
                Text("\(steps) step\(steps == 1 ? "" : "s") up the ladder. By U16 most MLS NEXT academy rosters are set and new players mostly come through scouting. The habits below need to show up in games, not just drills.")
                    .font(.footnote).foregroundStyle(Theme.muted)
            }
            VStack(spacing: 3) {
                ForEach(Level.allCases.reversed()) { l in
                    let between = l.rank > p.current.rank && l.rank < p.goal.rank
                    HStack {
                        Text(l.name).font(.caption.weight(.semibold))
                        Spacer()
                        if l == p.current { Text("YOU").font(.display(13, .bold)) }
                        if l == p.goal { Text("GOAL").font(.display(13, .bold)) }
                    }
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .foregroundStyle(l == p.goal || l == p.current ? .black : (between ? .white : Theme.muted))
                    .background(l == p.goal ? Theme.accent : (l == p.current ? .white : (between ? Theme.cardStrong : .clear)),
                                in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
            }
            Text("What scouts look for in a \(main.info.short)").font(.subheadline.weight(.bold)).padding(.top, 4)
            Bullets(items: main.info.scoutsLookFor, mark: "arrowtriangle.up.fill")
        }
    }

    // MARK: Recent

    private var recent: some View {
        Panel(title: "Recent sessions", spacing: 0) {
            ForEach(Array(store.pathwaySessions.prefix(5).enumerated()), id: \.element.id) { i, s in
                HStack(spacing: 12) {
                    Image(systemName: s.camera ? "video.fill" : "figure.run")
                        .foregroundStyle(Theme.accent)
                        .frame(width: 40, height: 40)
                        .background(Circle().fill(Theme.cardStrong))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(PathwayLibrary.drill(s.drillID)?.name ?? s.drillID).font(.subheadline.weight(.medium)).lineLimit(1)
                        Text(s.date.formatted(.dateTime.day().month(.abbreviated).year()) + "  |  " + (s.reps > 0 ? "\(s.reps) reps" : "\(s.seconds / 60) min") + (s.flags > 0 ? " · \(s.flags) flags" : ""))
                            .font(.caption).foregroundStyle(Theme.muted)
                    }
                    Spacer()
                    Image(systemName: "arrow.right").foregroundStyle(.white.opacity(0.7))
                }
                .padding(.vertical, 10)
                if i < min(store.pathwaySessions.count, 5) - 1 { Rectangle().fill(Theme.line).frame(height: 1) }
            }
        }
    }
}

struct TouchesPackView: View {
    @EnvironmentObject var store: Store

    var body: some View {
        let main = store.profile?.mainPosition ?? .cm
        let skills: Set<Skill> = main == .gk ? [.gkHandling, .gkDistribution] : [.firstTouch, .ballMastery, .turning, .weakFoot]
        let group = Position.allCases.filter { $0.info.group == main.info.group }
        let list = PathwayLibrary.all.filter { d in
            d.skills.contains(where: skills.contains) && ((d.outfield && main != .gk) || d.positions.contains(where: group.contains))
        }
        return DrillList(drills: list)
            .navigationTitle(main == .gk ? "Keeper handling" : "Training & touches")
    }
}

struct DrillList: View {
    let drills: [PathwayDrill]
    var body: some View {
        List(drills) { d in
            NavigationLink(value: PathRoute.drill(d.id)) { PathwayDrillRow(drill: d) }
                .listRowBackground(Theme.card)
        }
        .scrollContentBackground(.hidden)
        .background(Theme.background)
    }
}

struct PathwayDrillRow: View {
    let drill: PathwayDrill
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(drill.level.rawValue.uppercased()).font(.caption2.weight(.bold).monospaced())
                    .foregroundStyle(drill.level == .elite ? gold : Theme.accent)
                Spacer()
                Text("\(drill.minutes) min").font(.caption.monospaced()).foregroundStyle(.secondary)
            }
            Text(drill.name).font(.headline)
            Text(drill.blurb).font(.footnote).foregroundStyle(.secondary).lineLimit(2)
            Text(drill.needs.filter { $0 != .ball }.map(\.name).joined(separator: ", ").ifEmpty("Just a ball") + (drill.cue != nil ? " · on-screen cues" : ""))
                .font(.caption2.monospaced()).foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

extension String {
    func ifEmpty(_ other: String) -> String { isEmpty ? other : self }
}

// MARK: - Positions

struct PositionsView: View {
    @EnvironmentObject var store: Store
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("How the pros play every role, how to tune it as a youth player, and the drills that get you there.")
                        .foregroundStyle(.secondary)
                    PitchPicker(picked: pickedRanks) { spot in path.append(PathRoute.position(spot.position)) }
                    ForEach(PositionGroup.allCases, id: \.self) { group in
                        VStack(alignment: .leading, spacing: 8) {
                            Kicker(text: group.rawValue)
                            ForEach(Position.allCases.filter { $0.info.group == group }) { p in
                                NavigationLink(value: PathRoute.position(p)) {
                                    HStack(spacing: 12) {
                                        ShirtBadge(text: p.info.short)
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(p.info.name).font(.headline)
                                            Text(p.info.summary).font(.caption).foregroundStyle(.secondary).lineLimit(2)
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right").foregroundStyle(.tertiary)
                                    }
                                    .padding(14)
                                    .background(Theme.card, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(20)
            }
            .background(Theme.background)
            .navigationTitle("POSITIONS")
            .pathwayDestinations()
        }
    }

    private var pickedRanks: [String: Int] {
        guard let p = store.profile else { return [:] }
        var r: [String: Int] = [:]
        for (i, code) in [p.primary, p.secondary, p.third].enumerated() where !code.isEmpty { r[code] = i + 1 }
        return r
    }
}

struct PositionDetailView: View {
    let position: Position

    var body: some View {
        let info = position.info
        let drills = PathwayLibrary.drills(for: position).sorted { a, b in
            let ra = a.positions.contains(position) ? 0 : 1, rb = b.positions.contains(position) ? 0 : 1
            if ra != rb { return ra < rb }
            return (info.coreSkills.firstIndex(of: a.skills[0]) ?? 99) < (info.coreSkills.firstIndex(of: b.skills[0]) ?? 99)
        }
        return ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .top, spacing: 16) {
                    ShirtBadge(text: info.short, big: true)
                    VStack(alignment: .leading, spacing: 6) {
                        Kicker(text: info.group.rawValue)
                        Text(info.name.uppercased()).font(.display(42))
                    }
                }
                Text(info.summary).font(.body)
                Text("Study: " + info.pros.joined(separator: " · ")).font(.subheadline.weight(.semibold)).foregroundStyle(gold)

                Card { Text("With the ball").font(.headline); Bullets(items: info.inPossession) }
                Card { Text("Without the ball").font(.headline); Bullets(items: info.outPossession) }
                Card {
                    Kicker(text: "Fine-tuning for MLS NEXT")
                    Text("How a youth \(info.short) gets to the next level").font(.headline)
                    ForEach(Array(info.youthTuning.enumerated()), id: \.offset) { i, t in
                        HStack(alignment: .firstTextBaseline, spacing: 12) {
                            Text(String(format: "%02d", i + 1)).font(.title3.weight(.black)).foregroundStyle(Theme.accent)
                            Text(t)
                        }
                    }
                }
                Card {
                    Text("Scouts look for").font(.headline)
                    Bullets(items: info.scoutsLookFor, mark: "arrowtriangle.up.fill")
                    Text("Core skills, in order").font(.headline).padding(.top, 6)
                    FlowChips(items: info.coreSkills.map(\.name))
                }
                if position == .gk {
                    Card {
                        Text("Full keeper library").font(.headline)
                        Text("The Keeper tab has 65+ goalkeeper drills by focus, with 3D demos. The drills below are the keeper work that fits a Pathway plan.")
                            .font(.footnote).foregroundStyle(.secondary)
                    }
                }
                Text("Drills for a \(info.name.lowercased())").font(.title3.weight(.bold))
                ForEach(drills) { d in
                    NavigationLink(value: PathRoute.drill(d.id)) {
                        PathwayDrillRow(drill: d)
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Theme.card, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(20)
        }
        .background(Theme.background)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FlowChips: View {
    let items: [String]
    var body: some View {
        FlowLayout(spacing: 6) {
            ForEach(items, id: \.self) { item in
                Text(item).font(.caption.weight(.semibold))
                    .padding(.horizontal, 10).padding(.vertical, 6)
                    .background(Theme.cardStrong, in: Capsule())
            }
        }
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 320
        var x: CGFloat = 0, y: CGFloat = 0, row: CGFloat = 0
        for s in subviews {
            let size = s.sizeThatFits(.unspecified)
            if x + size.width > width, x > 0 { x = 0; y += row + spacing; row = 0 }
            x += size.width + spacing; row = max(row, size.height)
        }
        return CGSize(width: width, height: y + row)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX, y = bounds.minY, row: CGFloat = 0
        for s in subviews {
            let size = s.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX { x = bounds.minX; y += row + spacing; row = 0 }
            s.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing; row = max(row, size.height)
        }
    }
}

// MARK: - Drill

struct SessionConfig: Identifiable {
    let id = UUID()
    let drill: PathwayDrill
    var format: SessionFormat
    var camera: Bool
    var voice: Bool
    var tempo: Bool
    var sets: Int
    var reps: Int
    var rest: Int
    var seconds: Int
}

struct PathwayDrillView: View {
    let drill: PathwayDrill
    @State private var caption = ""
    @State private var playing = true
    @State private var slow = false
    @State private var restart = 0
    @State private var camera = false
    @State private var format: SessionFormat
    @State private var sets: Int
    @State private var reps: Int
    @State private var rest: Int
    @State private var minutes: Double
    @State private var voice = true
    @State private var tempo = true
    @State private var session: SessionConfig?

    init(drill: PathwayDrill) {
        self.drill = drill
        _format = State(initialValue: drill.format)
        _sets = State(initialValue: drill.sets)
        _reps = State(initialValue: drill.reps)
        _rest = State(initialValue: drill.rest)
        _minutes = State(initialValue: Double(drill.seconds) / 60)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                TacticsBoard(script: drill.board, keeperIsYou: drill.positions == [.gk] && !drill.outfield,
                             caption: $caption, playing: $playing, speed: slow ? 0.5 : 1, restartToken: restart)
                Text(caption.uppercased())
                    .font(.subheadline.weight(.bold))
                    .frame(maxWidth: .infinity, minHeight: 40, alignment: .leading)
                    .padding(.horizontal, 12)
                    .background(Theme.cardStrong, in: RoundedRectangle(cornerRadius: 10))
                    .animation(nil, value: caption)
                HStack(spacing: 10) {
                    Button { playing.toggle() } label: { Label(playing ? "Pause" : "Play", systemImage: playing ? "pause.fill" : "play.fill") }
                    Button { restart += 1 } label: { Label("Restart", systemImage: "arrow.counterclockwise") }
                    Button { slow.toggle() } label: { Text(slow ? "1×" : "0.5×") }
                    Spacer()
                }
                .buttonStyle(.bordered).tint(.white).font(.footnote.weight(.semibold))
                HStack(spacing: 12) {
                    legend(Theme.accent, "You"); legend(Color(red: 0.18, green: 0.49, blue: 0.33), "Mate")
                    legend(Color(white: 0.25), "Defender"); legend(gold, "Keeper")
                }
                .font(.caption2).foregroundStyle(.secondary)
                Link(destination: drill.videoURL) {
                    Label("Watch real footage of this drill", systemImage: "play.rectangle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(BigButtonStyle(filled: false))

                Kicker(text: "\(drill.level.rawValue) · " + (drill.outfield ? "All outfield" : drill.positions.map(\.info.short).joined(separator: " · ")))
                Text(drill.name.uppercased()).font(.display(40))
                Text(drill.blurb)
                FlowChips(items: drill.skills.map(\.name) + drill.needs.map(\.name))

                Card {
                    Text("How to do it").font(.headline)
                    ForEach(Array(drill.steps.enumerated()), id: \.offset) { i, s in
                        HStack(alignment: .firstTextBaseline, spacing: 10) {
                            Text("\(i + 1)").font(.footnote.weight(.bold).monospaced()).foregroundStyle(Theme.accent)
                            Text(s)
                        }
                    }
                }
                Card { Text("Get this right").font(.headline); Bullets(items: drill.points, mark: "checkmark") }
                Card { Text("Common mistakes").font(.headline); Bullets(items: drill.mistakes, mark: "xmark", tint: .red) }
                if let inspired = drill.inspired {
                    Text(inspired).font(.footnote).foregroundStyle(.secondary)
                        .padding(12).background(gold.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
                }

                startPanel
            }
            .padding(20)
        }
        .background(Theme.background)
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(item: $session) { cfg in TrainingSessionView(config: cfg) }
    }

    private func legend(_ c: Color, _ t: String) -> some View {
        HStack(spacing: 4) { Circle().fill(c).frame(width: 9, height: 9); Text(t) }
    }

    private var startPanel: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(text: "Start training").padding(.top, 4)
            Picker("How", selection: $camera) {
                Text("Just train").tag(false)
                Text("Camera coach").tag(true)
            }
            .pickerStyle(.segmented)
            Text(camera ? "Records you and flags mistakes. Prop the phone 3–4 yards away so it sees you head to toe. Video and checks stay on this phone."
                        : "Timer and rep counter.")
                .font(.footnote).foregroundStyle(.secondary)
            Picker("Format", selection: $format) {
                Text("Reps").tag(SessionFormat.reps)
                Text("Timed").tag(SessionFormat.time)
            }
            .pickerStyle(.segmented)
            if format == .reps {
                Stepper("Sets: \(sets)", value: $sets, in: 1...10)
                Stepper("Reps: \(reps)", value: $reps, in: 1...50)
                Stepper("Rest: \(rest) s", value: $rest, in: 0...300, step: 5)
            } else {
                Stepper("Minutes: \(minutes.formatted())", value: $minutes, in: 0.5...30, step: 0.5)
            }
            Toggle("Voice callouts", isOn: $voice)
            if let bpm = drill.tempo { Toggle("Metronome (\(bpm) bpm)", isOn: $tempo) }
            Button {
                session = SessionConfig(drill: drill, format: format, camera: camera, voice: voice, tempo: tempo && drill.tempo != nil,
                                        sets: sets, reps: reps, rest: rest, seconds: Int(minutes * 60))
            } label: { Label("Start training", systemImage: "play.fill") }
            .buttonStyle(BigButtonStyle())
        }
        .padding(18)
        .background(NotchedPanelShape().fill(Theme.card))
        .overlay(NotchedPanelShape().stroke(Theme.line, lineWidth: 1))
    }
}

// MARK: - Selective training

struct SelectiveView: View {
    @EnvironmentObject var store: Store
    @State private var position: Position?
    @State private var text = ""
    @State private var log: [Entry] = []
    @FocusState private var typing: Bool

    struct Entry: Identifiable {
        let id = UUID()
        let you: String?
        let reply: SelectiveCoach.Reply?
    }

    private let starters = ["My first touch has been bad on the wing", "I keep losing my man on corners", "I get beat 1v1 too easily",
                            "I panic under pressure in midfield", "My weak foot is useless", "I miss easy chances", "My goal kicks don't go far enough"]

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Type what's going wrong in your own words. The coach answers with drills to pick from.")
                            .foregroundStyle(.secondary)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 6) {
                                Text("TRAINING AS").font(.caption2.weight(.bold).monospaced()).foregroundStyle(.secondary)
                                ForEach(Position.allCases) { p in
                                    Button(p.info.short) { position = p }
                                        .font(.caption.weight(.bold))
                                        .padding(.horizontal, 10).padding(.vertical, 7)
                                        .foregroundStyle(current == p ? .black : .white)
                                        .background(current == p ? Theme.accent : Theme.card, in: Capsule())
                                }
                            }
                        }
                        if log.isEmpty {
                            coachBubble {
                                Text("Tell me what's off. Or start with one of these:").font(.headline)
                                followUps(starters)
                            }
                        }
                        ForEach(log) { e in
                            if let you = e.you {
                                Text(you)
                                    .padding(12)
                                    .foregroundStyle(.black)
                                    .background(Theme.accent, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                            if let r = e.reply {
                                coachBubble {
                                    Text(r.line).font(.headline)
                                    ForEach(Array(r.options.enumerated()), id: \.element.id) { i, o in
                                        NavigationLink(value: PathRoute.drill(o.drill.id)) {
                                            HStack(spacing: 12) {
                                                Text(String(UnicodeScalar(65 + i)!)).font(.title3.weight(.black)).foregroundStyle(.black)
                                                    .frame(width: 36, height: 36).background(Theme.accent, in: RoundedRectangle(cornerRadius: 8))
                                                VStack(alignment: .leading, spacing: 2) {
                                                    Text(o.drill.name).font(.subheadline.weight(.bold))
                                                    Text("\(o.why) · \(o.drill.minutes) min").font(.caption2.monospaced()).foregroundStyle(.secondary)
                                                }
                                                Spacer()
                                                Image(systemName: "chevron.right").foregroundStyle(Theme.accent)
                                            }
                                            .padding(10)
                                            .background(Theme.cardStrong, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                                        }
                                        .buttonStyle(.plain)
                                    }
                                    if !r.followUps.isEmpty { followUps(r.followUps) }
                                }
                            }
                        }
                        Color.clear.frame(height: 1).id("bottom")
                    }
                    .padding(20)
                }
                .onChange(of: log.count) { _, _ in withAnimation { proxy.scrollTo("bottom") } }
            }
            .safeAreaInset(edge: .bottom) {
                HStack(spacing: 8) {
                    TextField("e.g. my touches have been bad on the wing", text: $text, axis: .vertical)
                        .lineLimit(1...3)
                        .focused($typing)
                        .submitLabel(.send)
                        .onSubmit { send(text) }
                        .padding(12)
                        .background(Theme.cardStrong, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    Button { send(text) } label: { Image(systemName: "arrow.up.circle.fill").font(.system(size: 34)) }
                        .disabled(text.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding(.horizontal, 16).padding(.vertical, 10)
                .background(.ultraThinMaterial)
            }
            .background(Theme.background)
            .navigationTitle("SELECTIVE")
            .pathwayDestinations()
        }
    }

    private var current: Position { position ?? store.profile?.mainPosition ?? .cm }

    private func coachBubble<C: View>(@ViewBuilder _ content: () -> C) -> some View {
        VStack(alignment: .leading, spacing: 10) { content() }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.card, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func followUps(_ items: [String]) -> some View {
        FlowLayout(spacing: 6) {
            ForEach(items, id: \.self) { s in
                Button(s) { send(s) }
                    .font(.footnote)
                    .padding(.horizontal, 10).padding(.vertical, 7)
                    .overlay(Capsule().stroke(Theme.accent.opacity(0.7), style: StrokeStyle(lineWidth: 1, dash: [3, 2])))
                    .foregroundStyle(Theme.accent)
            }
        }
    }

    private func send(_ raw: String) {
        let t = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { return }
        let reply = SelectiveCoach.suggest(t, trainingAs: current)
        if let typed = reply.typedPosition { position = typed }
        log.append(Entry(you: t, reply: reply))
        text = ""
    }
}
