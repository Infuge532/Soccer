import SwiftUI
import Charts

struct ProgressScreen: View {
    @EnvironmentObject private var store: Store
    @State private var newCatchStreak = 0

    private let letters = ["M", "T", "W", "T", "F", "S", "S"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if let p = store.profile {
                        let r = store.cardRatings(for: p)
                        PlayerCard(name: p.firstName, ratings: r, width: 210)
                            .shadow(color: r.tier.accent.opacity(0.2), radius: 30)
                            .padding(.vertical, 8)
                        CardBreakdown(ratings: r)
                    }
                    stats
                    calendar
                    focusChart
                    badgesCard
                    catchCard
                    history
                }
                .padding(16)
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("PROGRESS")
        }
    }

    private var stats: some View {
        HStack(spacing: 12) {
            StatTile(value: "\(store.history.count)", label: "days trained")
            StatTile(value: "\(store.streak)", label: "day streak")
            StatTile(value: "\(store.totalDrills)", label: "drills done")
        }
    }

    /// The last four weeks, Monday to Sunday.
    private var calendar: some View {
        let start = Calendar.current.date(byAdding: .day, value: -21, to: Store.monday(of: Date())) ?? Date()
        return Card {
            HStack {
                Text("Last 4 weeks")
                    .font(.headline)
                Spacer()
                Text("\(store.daysTrained(inWeekOf: Date())) this week")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            HStack(spacing: 0) {
                ForEach(0..<7, id: \.self) { column in
                    Text(letters[column])
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            ForEach(0..<4, id: \.self) { week in
                HStack(spacing: 0) {
                    ForEach(0..<7, id: \.self) { column in
                        let day = Calendar.current.date(byAdding: .day, value: week * 7 + column, to: start) ?? start
                        DayDot(state: state(day))
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
    }

    private func state(_ day: Date) -> DayDot.State {
        let cal = Calendar.current
        if store.trained(day) { return .done }
        if cal.isDateInToday(day) { return .today }
        return cal.startOfDay(for: day) > cal.startOfDay(for: Date()) ? .future : .empty
    }

    @ViewBuilder
    private var focusChart: some View {
        let counts = store.drillsByFocus
        Card {
            Text("Drills by focus")
                .font(.headline)
            if store.totalDrills == 0 {
                Text("Tick off drills and you'll see here what you've been working on most.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                Chart(counts, id: \.focus) { item in
                    BarMark(x: .value("Drills", item.count), y: .value("Focus", item.focus.name))
                        .foregroundStyle(item.count > 0 ? Theme.accent : Color.white.opacity(0.15))
                        .annotation(position: .trailing) {
                            Text("\(item.count)")
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(.secondary)
                        }
                }
                .chartXAxis(.hidden)
                .frame(height: CGFloat(counts.count) * 28)
            }
        }
    }

    private var badgesCard: some View {
        Card {
            Text("Badges")
                .font(.headline)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 14) {
                ForEach(store.badges) { badge in
                    VStack(spacing: 6) {
                        Image(systemName: badge.symbol)
                            .font(.title2)
                            .frame(width: 52, height: 52)
                            .foregroundStyle(badge.earned ? Color.black : Color.white.opacity(0.3))
                            .background(badge.earned ? Theme.accent : Color.white.opacity(0.08), in: Circle())
                        Text(badge.title)
                            .font(.caption2)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(badge.earned ? .white : .secondary)
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("\(badge.title), \(badge.earned ? "earned" : "not earned yet")")
                }
            }
        }
    }

    private var catchCard: some View {
        Card {
            Text("Wall-catch streak")
                .font(.headline)
            Text("Log your longest run of catches without a drop, and try to beat it. Best so far: \(store.bestCatchStreak).")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            if store.data.catches.count >= 2 {
                Chart(store.data.catches) { entry in
                    LineMark(x: .value("Date", entry.date), y: .value("Catches", entry.count))
                        .foregroundStyle(Theme.accent)
                    PointMark(x: .value("Date", entry.date), y: .value("Catches", entry.count))
                        .foregroundStyle(Theme.accent)
                }
                .frame(height: 140)
            }
            HStack {
                StepButton(symbol: "minus") { newCatchStreak = max(0, newCatchStreak - 5) }
                Spacer()
                Text("\(newCatchStreak)")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .monospacedDigit()
                Spacer()
                StepButton(symbol: "plus") { newCatchStreak += 5 }
            }
            Stepper("Fine adjust by 1", value: $newCatchStreak, in: 0...2000)
                .font(.subheadline)
            Button("Log streak") {
                store.addCatchStreak(newCatchStreak)
                newCatchStreak = 0
            }
            .buttonStyle(BigButtonStyle())
            .disabled(newCatchStreak == 0)
            .opacity(newCatchStreak == 0 ? 0.4 : 1)
        }
    }

    private var history: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Training days")
                .font(.headline)
            if store.history.isEmpty {
                Text("Nothing yet. Tick off your first drill and the day shows up here.")
                    .foregroundStyle(.secondary)
            }
            ForEach(store.history) { log in
                let worked = focuses(of: log)
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(Store.date(fromKey: log.dayKey)?.formatted(.dateTime.weekday(.wide).month().day()) ?? log.dayKey)
                            .font(.body.weight(.semibold))
                        Text(worked.map(\.name).joined(separator: " · "))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text("\(log.done.count) drill\(log.done.count == 1 ? "" : "s")")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.accent)
                }
                .padding(16)
                .background(Theme.card, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// The focuses you actually did drills for that day, in the order you did them.
    private func focuses(of log: DayLog) -> [Focus] {
        var seen: [Focus] = []
        for id in log.done {
            if let focus = Library.drill(id)?.focus, !seen.contains(focus) { seen.append(focus) }
        }
        return seen
    }
}

private struct StatTile: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.display(38))
                .monospacedDigit()
                .foregroundStyle(Theme.accent)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 84)
        .padding(.vertical, 10)
        .background(Theme.card, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Theme.line))
    }
}

struct DayDot: View {
    enum State { case done, today, empty, future }

    let state: State
    var size: CGFloat = 30

    var body: some View {
        ZStack {
            switch state {
            case .done:
                Circle().fill(Theme.accent)
                Image(systemName: "checkmark")
                    .font(.system(size: size * 0.42, weight: .bold))
                    .foregroundStyle(.black)
            case .today:
                Circle().strokeBorder(Theme.accent, lineWidth: 2.5)
            case .empty:
                Circle().strokeBorder(Color.white.opacity(0.2), lineWidth: 2)
            case .future:
                Circle().fill(Color.white.opacity(0.12))
                    .frame(width: size * 0.25, height: size * 0.25)
            }
        }
        .frame(width: size, height: size)
        .accessibilityLabel(state == .done ? "Trained" : state == .today ? "Today" : "Not trained")
    }
}
