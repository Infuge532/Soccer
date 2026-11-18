import WidgetKit
import SwiftUI

// The home-screen widget. It cannot see the app's own storage, so the app
// writes the days you trained and today's picks into a shared app group, and
// the widget works out the streak and this week's days from that.

private let group = "group.app.keeperplan.hometraining"
private let accent = Color(red: 0.74, green: 0.93, blue: 0.22)

struct KeeperEntry: TimelineEntry {
    let date: Date
    /// What you picked to work on today, if anything.
    let focus: String?
    let drillsToday: Int
    let weekDone: Int
    let streak: Int
}

private enum Shared {
    static let formatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    static func entry(for date: Date) -> KeeperEntry {
        let defaults = UserDefaults(suiteName: group)
        let done = Set(defaults?.stringArray(forKey: "doneDays") ?? [])
        let cal = Calendar.current
        let today = cal.startOfDay(for: date)
        let todayKey = formatter.string(from: today)

        // Today's picks only count if they were written today.
        let picksAreToday = defaults?.string(forKey: "todayKey") == todayKey
        let focus = picksAreToday ? defaults?.string(forKey: "todayFocus") : nil
        let drills = picksAreToday ? defaults?.integer(forKey: "todayDone") ?? 0 : 0

        let offset = (cal.component(.weekday, from: today) + 5) % 7
        let monday = cal.date(byAdding: .day, value: -offset, to: today) ?? today
        let weekDone = (0..<7).filter { i in
            guard let day = cal.date(byAdding: .day, value: i, to: monday) else { return false }
            return done.contains(formatter.string(from: day))
        }.count

        // Days in a row. Today only counts once a drill is done.
        var day = today
        if !done.contains(todayKey) { day = cal.date(byAdding: .day, value: -1, to: day) ?? day }
        var streak = 0
        while done.contains(formatter.string(from: day)) {
            streak += 1
            guard let previous = cal.date(byAdding: .day, value: -1, to: day) else { break }
            day = previous
        }

        return KeeperEntry(date: date, focus: (focus?.isEmpty ?? true) ? nil : focus,
                           drillsToday: drills, weekDone: weekDone, streak: streak)
    }
}

struct KeeperProvider: TimelineProvider {
    func placeholder(in context: Context) -> KeeperEntry {
        KeeperEntry(date: Date(), focus: "Diving + Distribution", drillsToday: 2, weekDone: 3, streak: 3)
    }

    func getSnapshot(in context: Context, completion: @escaping (KeeperEntry) -> Void) {
        completion(Shared.entry(for: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<KeeperEntry>) -> Void) {
        // One entry now and one just after midnight, when "today" changes.
        let now = Date()
        let cal = Calendar.current
        let midnight = cal.date(byAdding: .day, value: 1, to: cal.startOfDay(for: now)) ?? now.addingTimeInterval(86400)
        let entries = [Shared.entry(for: now), Shared.entry(for: midnight.addingTimeInterval(60))]
        completion(Timeline(entries: entries, policy: .after(midnight.addingTimeInterval(120))))
    }
}

struct KeeperWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: KeeperEntry

    var body: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.drillsToday > 0 ? "\(entry.drillsToday) DRILL\(entry.drillsToday == 1 ? "" : "S") TODAY" : "TODAY")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(accent)
                Text(entry.focus ?? "What are you working on?")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .lineLimit(3)
                    .minimumScaleFactor(0.8)
                Spacer(minLength: 0)
                Label("\(entry.streak)", systemImage: "flame.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(entry.streak > 0 ? accent : .gray)
                if family == .systemSmall {
                    Text("\(entry.weekDone) day\(entry.weekDone == 1 ? "" : "s") this week")
                        .font(.caption2)
                        .foregroundStyle(.gray)
                }
            }
            if family != .systemSmall {
                Spacer(minLength: 0)
                ZStack {
                    Circle().stroke(Color.white.opacity(0.15), lineWidth: 9)
                    Circle()
                        .trim(from: 0, to: min(1, Double(entry.weekDone) / 7))
                        .stroke(accent, style: StrokeStyle(lineWidth: 9, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    VStack(spacing: 0) {
                        Text("\(entry.weekDone)/7")
                            .font(.headline.bold())
                            .foregroundStyle(.white)
                        Text("week")
                            .font(.caption2)
                            .foregroundStyle(.gray)
                    }
                }
                .frame(width: 84, height: 84)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .containerBackground(Color(red: 0.04, green: 0.06, blue: 0.05), for: .widget)
    }
}

@main
struct KeeperWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "KeeperWidget", provider: KeeperProvider()) { entry in
            KeeperWidgetView(entry: entry)
        }
        .configurationDisplayName("Keeper")
        .description("What you're working on today, your days this week and your streak.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
